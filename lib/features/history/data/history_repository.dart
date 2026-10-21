import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch.dart';
import '../../../core/date/local_date.dart';

/// Which kinds of records exist on a date. Used for restrained calendar
/// indicators; it says nothing about success or failure.
class DayMarker {
  const DayMarker({
    this.activities = 0,
    this.prayers = 0,
    this.habits = 0,
    this.worship = 0,
    this.reflection = false,
  });

  final int activities;
  final int prayers;
  final int habits;
  final int worship;
  final bool reflection;

  bool get hasAny =>
      activities > 0 || prayers > 0 || habits > 0 || worship > 0 || reflection;

  int get total => activities + prayers + habits + worship + (reflection ? 1 : 0);
}

class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  Future<Map<LocalDate, DayMarker>> markers(DateRange range) async {
    final rows = await _db
        .customSelect(
          '''
          SELECT date_key, kind, COUNT(*) AS n FROM (
            SELECT date_key, 'a' AS kind FROM activities WHERE date_key BETWEEN ?1 AND ?2
            UNION ALL
            SELECT date_key, 'p' FROM prayer_records WHERE date_key BETWEEN ?1 AND ?2
            UNION ALL
            SELECT date_key, 'h' FROM habit_records WHERE date_key BETWEEN ?1 AND ?2
            UNION ALL
            SELECT date_key, 'w' FROM worship_records WHERE date_key BETWEEN ?1 AND ?2
            UNION ALL
            SELECT date_key, 'r' FROM reflections WHERE date_key BETWEEN ?1 AND ?2
          ) GROUP BY date_key, kind
          ''',
          variables: [Variable(range.start.key), Variable(range.end.key)],
          readsFrom: {
            _db.activities,
            _db.prayerRecords,
            _db.habitRecords,
            _db.worshipRecords,
            _db.reflections,
          },
        )
        .get();
    final counts = <LocalDate, Map<String, int>>{};
    for (final row in rows) {
      final date = LocalDate.parse(row.read<String>('date_key'));
      counts.putIfAbsent(date, () => {})[row.read<String>('kind')] = row.read<int>('n');
    }
    return counts.map(
      (date, c) => MapEntry(
        date,
        DayMarker(
          activities: c['a'] ?? 0,
          prayers: c['p'] ?? 0,
          habits: c['h'] ?? 0,
          worship: c['w'] ?? 0,
          reflection: (c['r'] ?? 0) > 0,
        ),
      ),
    );
  }

  Stream<Map<LocalDate, DayMarker>> watchMarkers(DateRange range) => _db.watchTables(
    {
      _db.activities,
      _db.prayerRecords,
      _db.habitRecords,
      _db.worshipRecords,
      _db.reflections,
    },
    () => markers(range),
  );
}
