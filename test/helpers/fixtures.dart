import 'package:drift/drift.dart' show Value;
import 'package:jujur/core/database/app_database.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/features/activities/data/activity_repository.dart';
import 'package:jujur/features/activities/domain/activity_draft.dart';
import 'package:jujur/features/activities/domain/activity_status.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/habits/domain/habit_draft.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/habits/domain/recurrence.dart';
import 'package:jujur/features/prayers/data/prayer_repository.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';
import 'package:jujur/features/reflections/data/reflection_repository.dart';
import 'package:jujur/features/settings/data/settings_repository.dart';
import 'package:jujur/features/worship/data/worship_repository.dart';
import 'package:jujur/features/worship/domain/worship_enums.dart';

const indonesianText =
    'Alhamdulillah, hari ini "cukup" baik.\nBesok coba lebih awal — insyaAllah; 100% semangat. Ümlaut ✓';

/// Ids created by [populate], for assertions.
class Populated {
  late String activityId;
  late String formulaActivityId;
  late String readingHabitId;
  late String exerciseHabitId;
}

/// Fills [db] with every supported record type.
Future<Populated> populate(AppDatabase db, {LocalDate? day}) async {
  final d = day ?? LocalDate(2026, 10, 19);
  final ids = Populated();
  final activities = ActivityRepository(db);
  ids.activityId = await activities.create(
    ActivityDraft(
      title: 'Belajar Flutter, bab "state"',
      date: d,
      categoryId: 'cat-belajar',
      startMinute: 22 * 60,
      endMinute: 30,
      endsNextDay: true,
      notes: indonesianText,
      tags: const ['kerja', 'fokus'],
    ),
  );
  ids.formulaActivityId = await activities.create(
    ActivityDraft(title: '=SUM(A1:A9)', date: d, status: ActivityStatus.planned, notes: '+62 812'),
  );

  final habits = HabitRepository(db);
  ids.readingHabitId = await habits.create(
    HabitDraft(
      name: 'Membaca buku',
      trackingType: HabitTrackingType.quantity,
      targetUnit: 'halaman',
      targetValue: 20,
      startDate: d.addDays(-7),
      recurrence: RecurrenceType.daily,
    ),
  );
  ids.exerciseHabitId = await habits.create(
    HabitDraft(
      name: 'Olahraga',
      trackingType: HabitTrackingType.check,
      startDate: d.addDays(-7),
      recurrence: RecurrenceType.weekdays,
      weekdaysMask: WeekdayMask.of([1, 3, 5]),
    ),
  );
  await habits.setRecord(
    habitId: ids.readingHabitId,
    date: d,
    status: HabitStatus.partial,
    value: 12,
    note: 'Bab 3 selesai sebagian',
  );
  await habits.setRecord(habitId: ids.exerciseHabitId, date: d, status: HabitStatus.done);

  final prayers = PrayerRepository(db);
  await prayers.setStatus(
    prayer: Prayer.subuh,
    date: d,
    status: PrayerStatus.done,
    performedMinute: const Value(4 * 60 + 45),
    jamaah: const Value(true),
  );
  await prayers.setStatus(prayer: Prayer.magrib, date: d, status: PrayerStatus.missed, note: const Value('Di jalan'));

  final worship = WorshipRepository(db);
  final tilawah = await (db.select(db.worshipItems)..where((t) => t.id.equals('wsp-tilawah'))).getSingle();
  await worship.setRecord(item: tilawah, date: d, status: WorshipStatus.done, value: 4);

  await ReflectionRepository(db).save(
    d,
    body: indonesianText,
    answers: {'Hal apa yang saya syukuri hari ini?': 'Keluarga sehat, "alhamdulillah".'},
  );
  await SettingsRepository(db).set('week_start', '7');
  await SettingsRepository(db).set('local.today.collapsed.habits', 'true');
  return ids;
}

/// A comparable dump of all tables (rows sorted by id).
Future<Map<String, List<Map<String, Object?>>>> dumpTables(AppDatabase db) async {
  const tables = [
    'categories', 'activities', 'habits', 'habit_schedules', 'habit_records', 'prayer_records',
    'worship_items', 'worship_records', 'reflections', 'reflection_answers',
  ];
  return {
    for (final t in tables)
      t: [for (final r in await db.customSelect('SELECT * FROM $t ORDER BY id').get()) r.data],
  };
}
