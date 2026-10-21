import '../../../core/date/local_date.dart';
import 'habit_enums.dart';

/// Weekday bit mask helpers. Bit 0 = Monday ... bit 6 = Sunday (ISO order).
abstract final class WeekdayMask {
  static const all = 0x7F;
  static const workdays = 0x1F;

  static int of(Iterable<int> isoWeekdays) =>
      isoWeekdays.fold(0, (mask, d) => mask | (1 << (d - 1)));

  static bool contains(int mask, int isoWeekday) =>
      mask & (1 << (isoWeekday - 1)) != 0;

  static List<int> days(int mask) => [
    for (var d = 1; d <= 7; d++)
      if (contains(mask, d)) d,
  ];
}

/// One version of a habit's recurrence rule.
class ScheduleRule {
  const ScheduleRule({
    required this.effectiveFrom,
    required this.recurrence,
    this.weekdaysMask = 0,
    this.intervalDays,
    this.targetValue,
  });

  final LocalDate effectiveFrom;
  final RecurrenceType recurrence;
  final int weekdaysMask;
  final int? intervalDays;
  final double? targetValue;
}

/// Pure calendar-based recurrence evaluation for habits.
///
/// Uses calendar dates only (never durations in seconds), so daylight-saving
/// and timezone changes cannot shift which days are scheduled.
class HabitSchedulePlan {
  HabitSchedulePlan({
    required this.startDate,
    required this.endDate,
    required List<ScheduleRule> rules,
  }) : rules = [...rules]
         ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom)) {
    if (this.rules.isEmpty) {
      throw ArgumentError('Kebiasaan membutuhkan setidaknya satu jadwal');
    }
  }

  final LocalDate startDate;
  final LocalDate? endDate;

  /// Sorted by [ScheduleRule.effectiveFrom] ascending.
  final List<ScheduleRule> rules;

  /// The rule that applies on [date]: the latest version effective on or
  /// before it, or the earliest version for dates before every version.
  ScheduleRule ruleFor(LocalDate date) {
    var result = rules.first;
    for (final rule in rules) {
      if (rule.effectiveFrom.isAfter(date)) break;
      result = rule;
    }
    return result;
  }

  bool isScheduledOn(LocalDate date) {
    if (date.isBefore(startDate)) return false;
    final end = endDate;
    if (end != null && date.isAfter(end)) return false;

    final rule = ruleFor(date);
    switch (rule.recurrence) {
      case RecurrenceType.daily:
        return true;
      case RecurrenceType.weekdays:
        return WeekdayMask.contains(rule.weekdaysMask, date.weekday);
      case RecurrenceType.interval:
        final n = rule.intervalDays ?? 1;
        if (n <= 1) return true;
        // Counted from the later of the habit start and the version start,
        // so a schedule change restarts the cycle on its effective date.
        final anchor = rule.effectiveFrom.isAfter(startDate)
            ? rule.effectiveFrom
            : startDate;
        return anchor.daysUntil(date) % n == 0;
      case RecurrenceType.once:
        return date == startDate;
    }
  }

  double? targetOn(LocalDate date) => ruleFor(date).targetValue;

  /// Scheduled dates within [range].
  Iterable<LocalDate> scheduledDays(DateRange range) =>
      range.days.where(isScheduledOn);
}

/// Human readable description of a rule, e.g. "Sen, Rab, Jum".
String describeRule(ScheduleRule rule) {
  switch (rule.recurrence) {
    case RecurrenceType.daily:
      return 'Setiap hari';
    case RecurrenceType.weekdays:
      if (rule.weekdaysMask == WeekdayMask.all) return 'Setiap hari';
      if (rule.weekdaysMask == WeekdayMask.workdays) return 'Hari kerja';
      final days = WeekdayMask.days(rule.weekdaysMask);
      if (days.isEmpty) return 'Belum ada hari dipilih';
      return days.map((d) => shortWeekdayNames[d - 1]).join(', ');
    case RecurrenceType.interval:
      final n = rule.intervalDays ?? 1;
      return n <= 1 ? 'Setiap hari' : 'Setiap $n hari';
    case RecurrenceType.once:
      return 'Sekali';
  }
}

const shortWeekdayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const weekdayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
