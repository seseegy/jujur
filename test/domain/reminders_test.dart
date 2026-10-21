import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/core/notifications/reminder_planner.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/habits/domain/habit_draft.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/habits/domain/recurrence.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';
import 'package:jujur/features/prayers/domain/prayer_times.dart';
import 'package:jujur/features/settings/domain/preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();

  tz.Location jakarta() => tz.getLocation('Asia/Jakarta');

  Preferences prefs(Map<String, String> raw) => Preferences(raw);

  group('prayer times', () {
    test('calculates plausible Kemenag times for Jakarta locally', () {
      final t = PrayerTimesCalculator.calculate(
        date: LocalDate(2026, 10, 21),
        location: jakarta(),
        methodId: 'kemenag',
        latitude: -6.2,
        longitude: 106.8,
      );
      // Published schedules for Jakarta on this date are around
      // Subuh 04:1x, Zuhur 11:3x, Asar 14:4x, Magrib 17:4x, Isya 18:5x.
      expect(t.minutes[Prayer.subuh]! ~/ 60, 4);
      expect(t.minutes[Prayer.zuhur]! ~/ 60, 11);
      expect(t.minutes[Prayer.asar]! ~/ 60, 14);
      expect(t.minutes[Prayer.magrib]! ~/ 60, 17);
      expect(t.minutes[Prayer.isya]! ~/ 60, 18);
      expect(t.source, PrayerTimeSource.calculated);
    });

    test('requires an explicit method and coordinates', () {
      final noMethod = PrayerTimesCalculator.compute(
        prefs({SettingKeys.prayerTimesMode: 'calculated', SettingKeys.prayerLatitude: '-6.2', SettingKeys.prayerLongitude: '106.8'}),
        LocalDate(2026, 10, 21),
        jakarta(),
      );
      expect(noMethod, isA<PrayerTimesUnavailable>());
      final noCoords = PrayerTimesCalculator.compute(
        prefs({SettingKeys.prayerTimesMode: 'calculated', SettingKeys.prayerCalcMethod: 'kemenag'}),
        LocalDate(2026, 10, 21),
        jakarta(),
      );
      expect(noCoords, isA<PrayerTimesUnavailable>());
    });

    test('manual times are used as entered', () {
      final t = PrayerTimesCalculator.compute(
        prefs({
          SettingKeys.prayerTimesMode: 'manual',
          SettingKeys.prayerManualTimes: jsonEncode({'subuh': 4 * 60 + 30, 'isya': 19 * 60}),
        }),
        LocalDate(2026, 10, 21),
        jakarta(),
      ) as DayPrayerTimes;
      expect(t.minutes, {Prayer.subuh: 270, Prayer.isya: 1140});
      expect(t.source, PrayerTimeSource.manual);
    });
  });

  group('reminder planner', () {
    final now = tz.TZDateTime(jakarta(), 2026, 10, 21, 12, 0);
    final manual = {
      SettingKeys.prayerTimesMode: 'manual',
      SettingKeys.prayerManualTimes: jsonEncode({for (final p in Prayer.values) p.name: 5 * 60 + p.index * 180}),
    };

    test('no reminders when disabled', () {
      final plan = ReminderPlanner.plan(prefs: prefs(manual), habits: const [], now: now, prayerLocation: jakarta());
      expect(plan, isEmpty);
    });

    test('plans selected prayers for 7 days, future only, unique ids, no private text', () {
      final plan = ReminderPlanner.plan(
        prefs: prefs({
          ...manual,
          SettingKeys.prayerRemindersEnabled: 'true',
          SettingKeys.prayerReminderPrayers: 'subuh,isya',
          SettingKeys.prayerReminderOffset: '10',
        }),
        habits: const [],
        now: now,
        prayerLocation: jakarta(),
      );
      // Today: Subuh 05:00 has passed, Isya 17:00 (+10) remains; 6 more days x 2.
      expect(plan, hasLength(1 + 6 * 2));
      expect(plan.every((r) => r.at.isAfter(now)), isTrue);
      expect(plan.map((r) => r.id).toSet(), hasLength(plan.length));
      expect(plan.first.at.hour, 17);
      expect(plan.first.at.minute, 10);
      expect(plan.every((r) => !r.body.contains('refleksi')), isTrue);
    });

    test('habit reminders follow the schedule and skip archived habits', () async {
      final db = openInMemoryDatabase();
      final repo = HabitRepository(db);
      await repo.create(
        HabitDraft(
          name: 'Olahraga',
          trackingType: HabitTrackingType.check,
          startDate: LocalDate(2026, 10, 1),
          recurrence: RecurrenceType.weekdays,
          weekdaysMask: WeekdayMask.of([1, 3, 5]),
          reminderMinute: 18 * 60,
        ),
      );
      final archived = await repo.create(
        HabitDraft(
          name: 'Lama',
          trackingType: HabitTrackingType.check,
          startDate: LocalDate(2026, 10, 1),
          recurrence: RecurrenceType.daily,
          reminderMinute: 18 * 60,
        ),
      );
      await repo.setArchived(archived, true);
      final plan = ReminderPlanner.plan(
        prefs: Preferences.empty,
        habits: await repo.loadDefinitions(),
        now: now,
        prayerLocation: jakarta(),
      );
      // Wed 21 (18:00 still ahead), Fri 23, Mon 26.
      expect(plan.map((r) => r.at.day), [21, 23, 26]);
      expect(plan.every((r) => r.title == 'Olahraga'), isTrue);
      await db.close();
    });
  });
}
