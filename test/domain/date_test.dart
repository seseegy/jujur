import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/core/date/time_of_day_minutes.dart';

void main() {
  group('LocalDate', () {
    test('parses and formats keys', () {
      final d = LocalDate.parse('2026-03-09');
      expect(d.key, '2026-03-09');
      expect(d, LocalDate(2026, 3, 9));
    });

    test('rejects impossible dates', () {
      expect(() => LocalDate.parse('2025-02-29'), throwsFormatException);
      expect(() => LocalDate.parse('2026-13-01'), throwsFormatException);
      expect(() => LocalDate.parse('2026-1-01'), throwsFormatException);
      expect(LocalDate.tryParse('kemarin'), isNull);
    });

    test('leap years', () {
      expect(LocalDate.parse('2024-02-29').addDays(1), LocalDate(2024, 3, 1));
      expect(LocalDate.isLeapYear(2000), isTrue);
      expect(LocalDate.isLeapYear(1900), isFalse);
      expect(LocalDate(2024, 2, 1).lastOfMonth, LocalDate(2024, 2, 29));
      expect(LocalDate(2025, 2, 1).lastOfMonth, LocalDate(2025, 2, 28));
    });

    test('month and year boundaries', () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2027, 1, 1).addDays(-1), LocalDate(2026, 12, 31));
      expect(LocalDate(2026, 1, 31).addMonths(1), LocalDate(2026, 2, 28));
      expect(LocalDate(2026, 12, 15).addMonths(1), LocalDate(2027, 1, 15));
      expect(LocalDate(2026, 1, 15).addMonths(-1), LocalDate(2025, 12, 15));
    });

    test('day arithmetic is calendar based across DST-sized gaps', () {
      // 2026-03-29 is a DST transition day in many European zones; calendar
      // arithmetic must still move exactly one day at a time.
      var d = LocalDate(2026, 3, 27);
      for (var i = 0; i < 5; i++) {
        d = d.addDays(1);
      }
      expect(d, LocalDate(2026, 4, 1));
      expect(LocalDate(2026, 1, 1).daysUntil(LocalDate(2027, 1, 1)), 365);
      expect(LocalDate(2024, 1, 1).daysUntil(LocalDate(2025, 1, 1)), 366);
    });

    test('weekday and start of week', () {
      final wed = LocalDate(2026, 10, 21);
      expect(wed.weekday, DateTime.wednesday);
      expect(wed.startOfWeek(1), LocalDate(2026, 10, 19));
      expect(wed.startOfWeek(7), LocalDate(2026, 10, 18));
      expect(wed.startOfWeek(6), LocalDate(2026, 10, 17));
      expect(LocalDate(2026, 10, 19).startOfWeek(1), LocalDate(2026, 10, 19));
    });

    test('date key is taken from local wall clock, not UTC', () {
      // 23:30 local time stays on the same local date even when the UTC
      // instant falls on the next day.
      final local = DateTime(2026, 10, 21, 23, 30);
      expect(LocalDate.fromDateTime(local).key, '2026-10-21');
    });
  });

  group('DateRange', () {
    test('length, contains and previous period', () {
      final r = DateRange(LocalDate(2026, 10, 1), LocalDate(2026, 10, 7));
      expect(r.lengthInDays, 7);
      expect(r.contains(LocalDate(2026, 10, 7)), isTrue);
      expect(r.contains(LocalDate(2026, 10, 8)), isFalse);
      expect(r.previous, DateRange(LocalDate(2026, 9, 24), LocalDate(2026, 9, 30)));
      expect(r.days.length, 7);
    });

    test('rejects an end before the start', () {
      expect(() => DateRange(LocalDate(2026, 10, 2), LocalDate(2026, 10, 1)), throwsArgumentError);
    });
  });

  group('MinuteOfDay', () {
    test('format and parse', () {
      expect(MinuteOfDay.format(0), '00:00');
      expect(MinuteOfDay.format(1439), '23:59');
      expect(MinuteOfDay.parse('04:35'), 275);
      expect(MinuteOfDay.parse('24:00'), isNull);
      expect(MinuteOfDay.parse('7:5'), isNull);
    });
  });
}
