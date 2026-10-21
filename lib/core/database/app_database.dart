import 'package:drift/drift.dart';

import '../../features/activities/domain/activity_status.dart';
import '../../features/habits/domain/habit_enums.dart';
import '../../features/prayers/domain/prayer.dart';
import '../../features/worship/domain/worship_enums.dart';
import '../util/ids.dart';
import 'app_database.steps.dart';
import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AppSettings,
    Categories,
    Activities,
    Habits,
    HabitSchedules,
    HabitRecords,
    PrayerRecords,
    WorshipItems,
    WorshipRecords,
    Reflections,
    ReflectionAnswers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Bump together with a new migration step in [migration] and a schema
  /// snapshot in `drift_schemas/` (see docs/DATA_MODEL.md).
  static const currentSchemaVersion = 2;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await SeedData.insertDefaults(this, nowUtcMillis());
    },
    // Each step runs inside the migration transaction managed by drift: if a
    // step throws, the upgrade is rolled back and the database keeps its
    // previous version. The original file is additionally copied before
    // opening (see database_opener.dart). Data is never dropped to "fix" a
    // failed migration.
    onUpgrade: (m, from, to) async {
      await customStatement('PRAGMA foreign_keys = OFF');
      await transaction(() async {
        await stepByStep(
          from1To2: (m, schema) async {
            await m.addColumn(schema.activities, schema.activities.tags);
          },
        )(m, from, to);
      });
      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.hadUpgrade) {
        final problems = await customSelect(
          'PRAGMA foreign_key_check',
        ).get();
        if (problems.isNotEmpty) {
          throw StateError('Pemeriksaan relasi data gagal setelah migrasi.');
        }
      }
    },
  );
}
