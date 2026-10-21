// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:jujur/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v2 preserves existing data', () async {
    const category = v1.CategoriesData(
      id: 'cat-belajar',
      name: 'Belajar',
      sortOrder: 0,
      archived: 0,
      createdAt: 1,
      updatedAt: 1,
    );
    const activity = v1.ActivitiesData(
      id: 'a1',
      title: 'Belajar "Drift", bab 2',
      categoryId: 'cat-belajar',
      dateKey: '2026-10-01',
      startMinute: 1380,
      endMinute: 30,
      endsNextDay: 1,
      durationMinutes: 90,
      status: 'done',
      notes: 'Catatan\nbaris dua',
      createdAt: 2,
      updatedAt: 3,
    );
    const prayer = v1.PrayerRecordsData(
      id: 'p1',
      prayer: 'subuh',
      dateKey: '2026-10-01',
      status: 'done',
      jamaah: 1,
      createdAt: 4,
      updatedAt: 4,
    );
    const reflection = v1.ReflectionsData(
      id: 'r1',
      dateKey: '2026-10-01',
      body: 'Alhamdulillah.',
      createdAt: 5,
      updatedAt: 5,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.categories, category);
        batch.insert(oldDb.activities, activity);
        batch.insert(oldDb.prayerRecords, prayer);
        batch.insert(oldDb.reflections, reflection);
      },
      validateItems: (newDb) async {
        final activities = await newDb.select(newDb.activities).get();
        expect(activities, [
          v2.ActivitiesData(
            id: activity.id,
            title: activity.title,
            categoryId: activity.categoryId,
            dateKey: activity.dateKey,
            startMinute: activity.startMinute,
            endMinute: activity.endMinute,
            endsNextDay: activity.endsNextDay,
            durationMinutes: activity.durationMinutes,
            status: activity.status,
            notes: activity.notes,
            tags: null,
            createdAt: activity.createdAt,
            updatedAt: activity.updatedAt,
          ),
        ]);
        expect((await newDb.select(newDb.prayerRecords).getSingle()).toJson(), prayer.toJson());
        expect((await newDb.select(newDb.reflections).getSingle()).toJson(), reflection.toJson());
        expect((await newDb.select(newDb.categories).getSingle()).toJson(), category.toJson());
      },
    );
  });
}
