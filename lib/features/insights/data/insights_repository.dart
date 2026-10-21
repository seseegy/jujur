import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../habits/data/habit_repository.dart';
import '../domain/insights.dart';
import '../domain/insights_calculator.dart';

class InsightsRepository {
  InsightsRepository(this._db, this._habits);

  final AppDatabase _db;
  final HabitRepository _habits;

  Future<InsightsSource> loadSource(DateRange range) async {
    final from = range.start.key;
    final to = range.end.key;
    final activities = await (_db.select(_db.activities)
          ..where((t) => t.dateKey.isBetweenValues(from, to)))
        .get();
    final habitRecords = await (_db.select(_db.habitRecords)
          ..where((t) => t.dateKey.isBetweenValues(from, to)))
        .get();
    final prayerRecords = await (_db.select(_db.prayerRecords)
          ..where((t) => t.dateKey.isBetweenValues(from, to)))
        .get();
    final worshipRecords = await (_db.select(_db.worshipRecords)
          ..where((t) => t.dateKey.isBetweenValues(from, to)))
        .get();
    final reflections = await (_db.selectOnly(_db.reflections)
          ..addColumns([_db.reflections.dateKey])
          ..where(_db.reflections.dateKey.isBetweenValues(from, to)))
        .map((r) => LocalDate.parse(r.read(_db.reflections.dateKey)!))
        .get();
    return InsightsSource(
      activities: activities,
      categories: await _db.select(_db.categories).get(),
      habitDefinitions: await _habits.loadDefinitions(),
      habitRecords: habitRecords,
      prayerRecords: prayerRecords,
      worshipItems: await _db.select(_db.worshipItems).get(),
      worshipRecords: worshipRecords,
      reflectionDates: reflections..sort(),
    );
  }

  Future<InsightsReport> report(DateRange range, LocalDate today) async {
    final current = await loadSource(range);
    final previous = await loadSource(range.previous);
    return InsightsCalculator.report(
      range: range,
      today: today,
      current: current,
      previous: previous,
    );
  }
}
