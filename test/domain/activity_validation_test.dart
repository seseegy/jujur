import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/core/errors/app_failure.dart';
import 'package:jujur/features/activities/domain/activity_draft.dart';

void main() {
  final d = LocalDate(2026, 10, 21);
  ActivityDraft draft({String title = 'Belajar', int? start, int? end, bool next = false, int? duration}) =>
      ActivityDraft(title: title, date: d, startMinute: start, endMinute: end, endsNextDay: next, durationMinutes: duration);

  Matcher failsOn(String field) =>
      throwsA(isA<ValidationFailure>().having((e) => e.field, 'field', field));

  test('title is required and trimmed length limited', () {
    expect(() => draft(title: '   ').validate(), failsOn('title'));
    expect(() => draft(title: 'a' * 121).validate(), failsOn('title'));
  });

  test('activities without times are valid', () {
    expect(draft().validate(), isNull);
    expect(draft(duration: 45).validate(), 45);
  });

  test('duration derived from start and end', () {
    expect(draft(start: 8 * 60, end: 9 * 60 + 30).validate(), 90);
  });

  test('end before start is rejected unless explicitly crossing midnight', () {
    expect(() => draft(start: 23 * 60, end: 60).validate(), failsOn('time'));
    expect(draft(start: 23 * 60, end: 60, next: true).validate(), 120);
  });

  test('ends-next-day with end after start would exceed a day', () {
    expect(() => draft(start: 60, end: 120, next: true).validate(), failsOn('time'));
  });

  test('end time without start, equal times, and bad durations are rejected', () {
    expect(() => draft(end: 60).validate(), failsOn('time'));
    expect(() => draft(start: 60, end: 60).validate(), failsOn('time'));
    expect(() => draft(duration: 0).validate(), failsOn('duration'));
    expect(() => draft(duration: 24 * 60 + 1).validate(), failsOn('duration'));
  });

  test('tags are normalized and de-duplicated', () {
    expect(ActivityDraft.normalizeTags([' Kerja ', 'kerja', '', 'fokus  pagi']), ['Kerja', 'fokus pagi']);
    expect(ActivityDraft.parseTags('a, b'), ['a', 'b']);
    expect(ActivityDraft.parseTags(null), isEmpty);
  });
}
