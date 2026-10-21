import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/errors/app_failure.dart';
import 'habit_enums.dart';
import 'recurrence.dart';

/// User input for creating or editing a habit definition.
class HabitDraft {
  const HabitDraft({
    required this.name,
    required this.trackingType,
    required this.startDate,
    required this.recurrence,
    this.description,
    this.categoryId,
    this.icon,
    this.color,
    this.targetUnit,
    this.endDate,
    this.weekdaysMask = WeekdayMask.all,
    this.intervalDays,
    this.targetValue,
    this.reminderMinute,
  });

  final String name;
  final String? description;
  final String? categoryId;
  final String? icon;
  final String? color;
  final HabitTrackingType trackingType;
  final String? targetUnit;
  final LocalDate startDate;
  final LocalDate? endDate;
  final RecurrenceType recurrence;
  final int weekdaysMask;
  final int? intervalDays;
  final double? targetValue;
  final int? reminderMinute;

  void validate() {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Nama kebiasaan wajib diisi.', field: 'name');
    }
    if (trimmed.length > 80) {
      throw const ValidationFailure('Nama maksimal 80 karakter.', field: 'name');
    }
    if (recurrence == RecurrenceType.weekdays &&
        (weekdaysMask & WeekdayMask.all) == 0) {
      throw const ValidationFailure('Pilih minimal satu hari.', field: 'recurrence');
    }
    if (recurrence == RecurrenceType.interval) {
      final n = intervalDays;
      if (n == null || n < 2 || n > 365) {
        throw const ValidationFailure(
          'Jarak hari harus antara 2 dan 365.',
          field: 'recurrence',
        );
      }
    }
    final end = endDate;
    if (end != null && end.isBefore(startDate)) {
      throw const ValidationFailure(
        'Tanggal berakhir tidak boleh sebelum tanggal mulai.',
        field: 'endDate',
      );
    }
    final target = targetValue;
    if (target != null) {
      if (trackingType == HabitTrackingType.check) {
        throw const ValidationFailure('Kebiasaan centang tidak memakai target.');
      }
      if (target <= 0 || target > 100000) {
        throw const ValidationFailure(
          'Target harus lebih dari 0.',
          field: 'target',
        );
      }
    }
    if (!MinuteOfDay.isValid(reminderMinute)) {
      throw const ValidationFailure('Waktu pengingat tidak valid.');
    }
  }

  /// Normalized schedule fields as stored.
  ScheduleRule toRule(LocalDate effectiveFrom) => ScheduleRule(
    effectiveFrom: effectiveFrom,
    recurrence: recurrence,
    weekdaysMask: recurrence == RecurrenceType.weekdays ? weekdaysMask : 0,
    intervalDays: recurrence == RecurrenceType.interval ? intervalDays : null,
    targetValue: trackingType == HabitTrackingType.check ? null : targetValue,
  );

  LocalDate? get normalizedEndDate =>
      recurrence == RecurrenceType.once ? startDate : endDate;
}

/// Suggests a status from a measured value and target.
HabitStatus statusForValue(double value, double? target) {
  if (value <= 0) return HabitStatus.notDone;
  if (target == null || value >= target) return HabitStatus.done;
  return HabitStatus.partial;
}
