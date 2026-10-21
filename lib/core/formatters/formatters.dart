import 'package:intl/intl.dart';

import '../date/local_date.dart';

const appLocale = 'id_ID';

/// "Rabu, 21 Oktober 2026"
String formatLongDate(LocalDate d) =>
    DateFormat('EEEE, d MMMM y', appLocale).format(d.toLocalDateTime());

/// "21 Oktober 2026"
String formatDate(LocalDate d) => DateFormat('d MMMM y', appLocale).format(d.toLocalDateTime());

/// "21 Okt"
String formatShortDate(LocalDate d) => DateFormat('d MMM', appLocale).format(d.toLocalDateTime());

/// "Rabu"
String formatWeekday(LocalDate d) => DateFormat('EEEE', appLocale).format(d.toLocalDateTime());

/// "Oktober 2026"
String formatMonthYear(LocalDate d) => DateFormat('MMMM y', appLocale).format(d.toLocalDateTime());

/// "21 Okt – 27 Okt 2026"
String formatRange(DateRange r) {
  if (r.start == r.end) return formatDate(r.start);
  final sameYear = r.start.year == r.end.year;
  final start = DateFormat(sameYear ? 'd MMM' : 'd MMM y', appLocale).format(r.start.toLocalDateTime());
  final end = DateFormat('d MMM y', appLocale).format(r.end.toLocalDateTime());
  return '$start – $end';
}

/// "Hari ini", "Kemarin", "Besok", or null.
String? relativeDayLabel(LocalDate d, LocalDate today) => switch (today.daysUntil(d)) {
  0 => 'Hari ini',
  -1 => 'Kemarin',
  1 => 'Besok',
  _ => null,
};

/// "45 menit", "1 jam", "2 jam 15 menit".
String formatDuration(int minutes) {
  if (minutes < 60) return '$minutes menit';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h jam' : '$h jam $m menit';
}

/// "12", "2,5"
String formatNumber(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return NumberFormat('#,##0.##', appLocale).format(value);
}

/// "14.30" style local time of a [DateTime].
String formatClock(DateTime t) => DateFormat('HH.mm', appLocale).format(t);

String formatDateTime(DateTime t) => DateFormat('d MMM y, HH.mm', appLocale).format(t);

/// Change between two counts in neutral words.
String describeChange(int current, int previous) {
  if (current == previous) return 'sama dengan periode sebelumnya';
  final diff = (current - previous).abs();
  return current > previous
      ? '$diff lebih banyak dari periode sebelumnya ($previous)'
      : '$diff lebih sedikit dari periode sebelumnya ($previous)';
}
