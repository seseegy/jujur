import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/features/habits/domain/habit_draft.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/habits/domain/recurrence.dart';
import 'package:jujur/features/habits/domain/streak.dart';

HabitSchedulePlan plan(List<ScheduleRule> rules, {LocalDate? start, LocalDate? end}) =>
    HabitSchedulePlan(startDate: start ?? rules.first.effectiveFrom, endDate: end, rules: rules);

void main() {
  final mon = LocalDate(2026, 10, 19);

  group('recurrence', () {
    test('daily within start and end dates', () {
      final p = plan([ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.daily)], end: mon.addDays(2));
      expect(p.isScheduledOn(mon.addDays(-1)), isFalse);
      expect(p.isScheduledOn(mon), isTrue);
      expect(p.isScheduledOn(mon.addDays(2)), isTrue);
      expect(p.isScheduledOn(mon.addDays(3)), isFalse);
    });

    test('selected weekdays', () {
      final p = plan([
        ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.weekdays, weekdaysMask: WeekdayMask.of([1, 3, 5])),
      ]);
      final scheduled = p.scheduledDays(DateRange(mon, mon.addDays(6))).toList();
      expect(scheduled, [mon, mon.addDays(2), mon.addDays(4)]);
    });

    test('every N days counted from the start date, across month ends', () {
      final start = LocalDate(2026, 1, 30);
      final p = plan([ScheduleRule(effectiveFrom: start, recurrence: RecurrenceType.interval, intervalDays: 3)]);
      expect(p.isScheduledOn(LocalDate(2026, 2, 2)), isTrue);
      expect(p.isScheduledOn(LocalDate(2026, 2, 3)), isFalse);
      expect(p.isScheduledOn(LocalDate(2026, 3, 1)), isTrue); // 30 days later
      expect(p.isScheduledOn(LocalDate(2026, 3, 3)), isFalse); // 32 days later
    });

    test('once only on its start date', () {
      final p = plan([ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.once)]);
      expect(p.isScheduledOn(mon), isTrue);
      expect(p.isScheduledOn(mon.addDays(1)), isFalse);
    });

    test('schedule versions apply from their effective date only', () {
      final p = plan([
        ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.daily, targetValue: 10),
        ScheduleRule(
          effectiveFrom: mon.addDays(7),
          recurrence: RecurrenceType.weekdays,
          weekdaysMask: WeekdayMask.of([1]),
          targetValue: 20,
        ),
      ]);
      expect(p.isScheduledOn(mon.addDays(3)), isTrue);
      expect(p.targetOn(mon.addDays(3)), 10);
      expect(p.isScheduledOn(mon.addDays(8)), isFalse);
      expect(p.isScheduledOn(mon.addDays(14)), isTrue);
      expect(p.targetOn(mon.addDays(14)), 20);
    });

    test('describes rules in Indonesian', () {
      expect(describeRule(ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.weekdays, weekdaysMask: WeekdayMask.workdays)), 'Hari kerja');
      expect(describeRule(ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.weekdays, weekdaysMask: WeekdayMask.of([1, 3]))), 'Sen, Rab');
      expect(describeRule(ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.interval, intervalDays: 2)), 'Setiap 2 hari');
    });
  });

  group('streak', () {
    final p = plan([
      ScheduleRule(effectiveFrom: mon, recurrence: RecurrenceType.weekdays, weekdaysMask: WeekdayMask.of([1, 3, 5])),
    ]);

    test('ignores unscheduled days and an unrecorded today', () {
      final records = {mon: HabitStatus.done, mon.addDays(2): HabitStatus.done};
      // Friday (today) not recorded yet: streak is still 2.
      expect(currentStreak(plan: p, records: records, today: mon.addDays(4)), 2);
    });

    test('a missing record on a past scheduled day ends the streak', () {
      final records = {mon: HabitStatus.done, mon.addDays(4): HabitStatus.done};
      expect(currentStreak(plan: p, records: records, today: mon.addDays(4)), 1);
    });

    test('skipped days neither break nor extend the streak', () {
      final records = {mon: HabitStatus.done, mon.addDays(2): HabitStatus.skipped, mon.addDays(4): HabitStatus.done};
      expect(currentStreak(plan: p, records: records, today: mon.addDays(4)), 2);
    });

    test('partial or not done ends the streak', () {
      final records = {mon: HabitStatus.done, mon.addDays(2): HabitStatus.partial, mon.addDays(4): HabitStatus.done};
      expect(currentStreak(plan: p, records: records, today: mon.addDays(4)), 1);
    });
  });

  group('habit draft validation', () {
    HabitDraft draft({
      String name = 'Membaca',
      RecurrenceType recurrence = RecurrenceType.daily,
      int mask = WeekdayMask.all,
      int? interval,
      double? target,
      HabitTrackingType type = HabitTrackingType.quantity,
      LocalDate? end,
    }) => HabitDraft(
      name: name,
      trackingType: type,
      startDate: mon,
      endDate: end,
      recurrence: recurrence,
      weekdaysMask: mask,
      intervalDays: interval,
      targetValue: target,
    );

    test('accepts a valid draft', () => expect(() => draft(target: 20).validate(), returnsNormally));
    test('requires a name', () => expect(() => draft(name: '  ').validate(), throwsA(anything)));
    test('requires a weekday', () {
      expect(() => draft(recurrence: RecurrenceType.weekdays, mask: 0).validate(), throwsA(anything));
    });
    test('validates interval range', () {
      expect(() => draft(recurrence: RecurrenceType.interval, interval: 1).validate(), throwsA(anything));
      expect(() => draft(recurrence: RecurrenceType.interval, interval: 3).validate(), returnsNormally);
    });
    test('end date not before start', () {
      expect(() => draft(end: mon.addDays(-1)).validate(), throwsA(anything));
    });
    test('positive target', () => expect(() => draft(target: 0).validate(), throwsA(anything)));
    test('check habits take no target', () {
      expect(() => draft(type: HabitTrackingType.check, target: 2).validate(), throwsA(anything));
    });

    test('status from value and target', () {
      expect(statusForValue(20, 20), HabitStatus.done);
      expect(statusForValue(12, 20), HabitStatus.partial);
      expect(statusForValue(0, 20), HabitStatus.notDone);
      expect(statusForValue(3, null), HabitStatus.done);
    });
  });
}
