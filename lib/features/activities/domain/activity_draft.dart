import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/errors/app_failure.dart';
import 'activity_status.dart';

/// User input for creating or editing an activity, with validation rules.
class ActivityDraft {
  const ActivityDraft({
    required this.title,
    required this.date,
    this.description,
    this.categoryId,
    this.startMinute,
    this.endMinute,
    this.endsNextDay = false,
    this.durationMinutes,
    this.status = ActivityStatus.done,
    this.notes,
    this.tags = const [],
  });

  final String title;
  final String? description;
  final String? categoryId;
  final LocalDate date;
  final int? startMinute;
  final int? endMinute;
  final bool endsNextDay;
  final int? durationMinutes;
  final ActivityStatus status;
  final String? notes;
  final List<String> tags;

  static const maxTitleLength = 120;

  /// Validates the draft and returns the duration to store, if any.
  ///
  /// Rules:
  /// - A title is required.
  /// - An end time requires a start time.
  /// - An end time earlier than the start time is only valid when the user
  ///   explicitly marks the activity as ending on the next day; durations are
  ///   never silently wrapped around midnight.
  /// - When both times are present the duration is derived from them as
  ///   wall-clock minutes; otherwise an explicit duration may be given.
  int? validate() {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Judul aktivitas wajib diisi.', field: 'title');
    }
    if (trimmed.length > maxTitleLength) {
      throw const ValidationFailure(
        'Judul terlalu panjang (maksimal $maxTitleLength karakter).',
        field: 'title',
      );
    }
    if (!MinuteOfDay.isValid(startMinute) || !MinuteOfDay.isValid(endMinute)) {
      throw const ValidationFailure('Waktu tidak valid.', field: 'time');
    }
    final start = startMinute;
    final end = endMinute;
    if (end != null && start == null) {
      throw const ValidationFailure(
        'Isi waktu mulai jika mengisi waktu selesai.',
        field: 'time',
      );
    }
    if (start != null && end != null) {
      final minutes = computeDuration(start, end, endsNextDay: endsNextDay);
      if (minutes == null) {
        throw const ValidationFailure(
          'Waktu selesai lebih awal dari waktu mulai. Aktifkan "Berakhir '
          'keesokan hari" jika aktivitas melewati tengah malam.',
          field: 'time',
        );
      }
      if (minutes == 0) {
        throw const ValidationFailure(
          'Waktu selesai sama dengan waktu mulai.',
          field: 'time',
        );
      }
      return minutes;
    }
    if (endsNextDay) {
      throw const ValidationFailure(
        'Isi waktu mulai dan selesai untuk aktivitas yang melewati tengah malam.',
        field: 'time',
      );
    }
    final duration = durationMinutes;
    if (duration != null && (duration <= 0 || duration > 24 * 60)) {
      throw const ValidationFailure(
        'Durasi harus antara 1 menit dan 24 jam.',
        field: 'duration',
      );
    }
    return duration;
  }

  /// Wall-clock minutes between [start] and [end], or null when the range is
  /// invalid (end before start without [endsNextDay], or longer than a day).
  static int? computeDuration(int start, int end, {required bool endsNextDay}) {
    if (endsNextDay) {
      if (end >= start) return null;
      return 24 * 60 - start + end;
    }
    if (end < start) return null;
    return end - start;
  }

  static List<String> normalizeTags(Iterable<String> raw) {
    final seen = <String>{};
    final result = <String>[];
    for (final tag in raw) {
      final t = tag.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (t.isEmpty || t.length > 30) continue;
      if (seen.add(t.toLowerCase())) result.add(t);
      if (result.length == 10) break;
    }
    return result;
  }

  static List<String> parseTags(String? stored) =>
      stored == null || stored.isEmpty ? const [] : normalizeTags(stored.split(','));
}
