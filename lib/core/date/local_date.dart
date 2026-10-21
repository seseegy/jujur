/// A calendar date without time or timezone.
///
/// Date-based records (activities, habit records, prayer records, worship
/// records, reflections) are keyed by a [LocalDate] serialized as
/// `YYYY-MM-DD`. The key is derived from the device's local wall clock at the
/// moment of recording and is never converted through UTC, so a record never
/// moves to another day because of a timezone change.
///
/// Arithmetic is performed on UTC [DateTime] values internally so that
/// daylight-saving transitions cannot produce 23- or 25-hour "days".
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Today's date according to the device's local clock.
  factory LocalDate.today([DateTime Function()? clock]) =>
      LocalDate.fromDateTime((clock ?? DateTime.now)());

  /// Parses a `YYYY-MM-DD` key. Throws [FormatException] for invalid input,
  /// including impossible dates such as `2025-02-30`.
  factory LocalDate.parse(String key) {
    final match = _keyPattern.firstMatch(key);
    if (match == null) {
      throw FormatException('Tanggal tidak valid', key);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) {
      throw FormatException('Tanggal tidak valid', key);
    }
    return LocalDate(year, month, day);
  }

  static LocalDate? tryParse(String? key) {
    if (key == null) return null;
    try {
      return LocalDate.parse(key);
    } on FormatException {
      return null;
    }
  }

  static final _keyPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  DateTime get _utc => DateTime.utc(year, month, day);

  /// ISO weekday: Monday = 1 ... Sunday = 7.
  int get weekday => _utc.weekday;

  String get key =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(_utc.add(Duration(days: days)));

  /// Adds calendar months, clamping the day to the target month's length.
  LocalDate addMonths(int months) {
    final total = year * 12 + (month - 1) + months;
    final y = total ~/ 12;
    final m = total % 12 + 1;
    final d = day.clamp(1, daysInMonth(y, m));
    return LocalDate(y, m, d);
  }

  /// Number of calendar days from this date to [other] (negative if earlier).
  int daysUntil(LocalDate other) => other._utc.difference(_utc).inDays;

  LocalDate get firstOfMonth => LocalDate(year, month, 1);
  LocalDate get lastOfMonth => LocalDate(year, month, daysInMonth(year, month));

  /// The first day of the week containing this date.
  /// [weekStart] is an ISO weekday (1 = Monday, 6 = Saturday, 7 = Sunday).
  LocalDate startOfWeek(int weekStart) {
    final offset = (weekday - weekStart + 7) % 7;
    return addDays(-offset);
  }

  /// Local midnight of this date as a [DateTime] in the device timezone.
  DateTime toLocalDateTime([int minuteOfDay = 0]) =>
      DateTime(year, month, day, minuteOfDay ~/ 60, minuteOfDay % 60);

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) {
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) return 29;
    return days[month - 1];
  }

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}

/// An inclusive range of calendar dates.
class DateRange {
  DateRange(this.start, this.end) {
    if (end.isBefore(start)) {
      throw ArgumentError('Tanggal akhir tidak boleh sebelum tanggal awal');
    }
  }

  final LocalDate start;
  final LocalDate end;

  int get lengthInDays => start.daysUntil(end) + 1;

  bool contains(LocalDate date) => !date.isBefore(start) && !date.isAfter(end);

  Iterable<LocalDate> get days sync* {
    for (var d = start; !d.isAfter(end); d = d.addDays(1)) {
      yield d;
    }
  }

  /// The range of equal length immediately before this one.
  DateRange get previous =>
      DateRange(start.addDays(-lengthInDays), start.addDays(-1));

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start..$end';
}
