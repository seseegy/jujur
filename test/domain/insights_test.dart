import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/features/activities/data/activity_repository.dart';
import 'package:jujur/features/activities/domain/activity_draft.dart';
import 'package:jujur/features/activities/domain/activity_status.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/habits/domain/habit_draft.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/habits/domain/recurrence.dart';
import 'package:jujur/features/insights/data/insights_repository.dart';
import 'package:jujur/features/prayers/data/prayer_repository.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';
import 'package:jujur/features/reflections/data/reflection_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // A known dataset: week of Mon 2026-10-12 .. Sun 2026-10-18, "today" is
  // Wed 2026-10-14 (so 3 elapsed days).
  final mon = LocalDate(2026, 10, 12);
  final today = mon.addDays(2);
  final week = DateRange(mon, mon.addDays(6));

  test('empty database produces an honest empty report', () async {
    final db = openInMemoryDatabase();
    final report = await InsightsRepository(db, HabitRepository(db)).report(week, today);
    expect(report.isEmpty, isTrue);
    expect(report.prayers.recorded, 0);
    // Unrecorded prayers are reported as unrecorded, never as missed.
    expect(report.prayers.unrecorded, 15);
    expect(report.prayers.count(PrayerStatus.missed), 0);
    expect(report.habits, isEmpty);
    await db.close();
  });

  test('statistics match a known dataset', () async {
    final db = openInMemoryDatabase();
    final activities = ActivityRepository(db);
    await activities.create(ActivityDraft(title: 'Baca', date: mon, categoryId: 'cat-membaca', durationMinutes: 30));
    await activities.create(ActivityDraft(title: 'Baca', date: mon.addDays(1), categoryId: 'cat-membaca', durationMinutes: 45));
    await activities.create(ActivityDraft(title: 'Kerja', date: mon.addDays(1), categoryId: 'cat-bekerja', startMinute: 9 * 60, endMinute: 12 * 60));
    await activities.create(ActivityDraft(title: 'Rencana', date: mon.addDays(2), status: ActivityStatus.planned, durationMinutes: 60));
    // Previous week: one done activity.
    await activities.create(ActivityDraft(title: 'Lama', date: mon.addDays(-3)));

    final habits = HabitRepository(db);
    final habitId = await habits.create(
      HabitDraft(
        name: 'Olahraga',
        trackingType: HabitTrackingType.check,
        startDate: mon.addDays(-30),
        recurrence: RecurrenceType.weekdays,
        weekdaysMask: WeekdayMask.of([1, 3, 5]),
      ),
    );
    await habits.setRecord(habitId: habitId, date: mon, status: HabitStatus.done);
    // Wednesday (today) is scheduled but unrecorded.

    final prayers = PrayerRepository(db);
    await prayers.setStatus(prayer: Prayer.subuh, date: mon, status: PrayerStatus.done, jamaah: const Value(true));
    await prayers.setStatus(prayer: Prayer.zuhur, date: mon, status: PrayerStatus.qadha);
    await prayers.setStatus(prayer: Prayer.asar, date: mon, status: PrayerStatus.missed);
    await prayers.setStatus(prayer: Prayer.subuh, date: mon.addDays(1), status: PrayerStatus.excused);

    await ReflectionRepository(db).save(mon.addDays(1), body: 'Hari yang tenang.', answers: const {});

    final report = await InsightsRepository(db, HabitRepository(db)).report(week, today);
    expect(report.effectiveDays, 3);
    expect(report.activities.total, 4);
    expect(report.activities.done, 3);
    expect(report.activities.totalMinutes, 30 + 45 + 180);
    expect(report.activities.averageMinutes, 85);
    expect(report.activities.categories.first.name, 'Membaca');
    expect(report.activities.categories.first.minutes, 75);

    final habit = report.habits.single;
    expect(habit.scheduledDays, 2); // Mon and Wed (Fri is in the future)
    expect(habit.done, 1);
    expect(habit.unrecordedScheduled, 1);

    expect(report.prayers.days, 3);
    expect(report.prayers.count(PrayerStatus.done), 1);
    expect(report.prayers.count(PrayerStatus.qadha), 1);
    expect(report.prayers.count(PrayerStatus.missed), 1);
    expect(report.prayers.count(PrayerStatus.excused), 1);
    expect(report.prayers.unrecorded, 15 - 4);
    expect(report.prayers.unrecordedByPrayer[Prayer.subuh], 1);
    expect(report.prayers.jamaah, 1);

    expect(report.reflectionDates, [mon.addDays(1)]);
    expect(report.current.activitiesDone, 3);
    expect(report.previous.activitiesDone, 1);
    expect(report.current.prayersPerformed, 2);
    expect(report.daysWithRecords, 3);
    await db.close();
  });
}
