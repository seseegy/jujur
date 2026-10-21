/// Helpers for wall-clock times stored as minutes since local midnight.
///
/// Activity start/end times and prayer completion times are stored as a local
/// minute-of-day next to the record's date key. This keeps the time exactly as
/// the user entered it, independent of later timezone changes.
abstract final class MinuteOfDay {
  static const int max = 24 * 60 - 1;

  static bool isValid(int? minute) =>
      minute == null || (minute >= 0 && minute <= max);

  static String format(int minute) {
    final h = (minute ~/ 60).toString().padLeft(2, '0');
    final m = (minute % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Parses `HH:mm`. Returns null for invalid input.
  static int? parse(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    if (h > 23 || m > 59) return null;
    return h * 60 + m;
  }

  static int fromDateTime(DateTime dateTime) =>
      dateTime.hour * 60 + dateTime.minute;
}
