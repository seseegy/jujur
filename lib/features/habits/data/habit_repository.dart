import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch.dart';
import '../../../core/date/local_date.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/util/ids.dart';
import '../domain/habit_draft.dart';
import '../domain/habit_enums.dart';
import '../domain/recurrence.dart';

/// A habit definition together with its schedule versions.
class HabitDefinition {
  HabitDefinition(this.habit, List<HabitSchedule> schedules)
    : schedules = schedules,
      plan = HabitSchedulePlan(
        startDate: LocalDate.parse(habit.startDate),
        endDate: LocalDate.tryParse(habit.endDate),
        rules: [for (final s in schedules) ruleFromRow(s)],
      );

  final Habit habit;
  final List<HabitSchedule> schedules;
  final HabitSchedulePlan plan;

  ScheduleRule get currentRule => plan.rules.last;

  static ScheduleRule ruleFromRow(HabitSchedule s) => ScheduleRule(
    effectiveFrom: LocalDate.parse(s.effectiveFrom),
    recurrence: s.recurrence,
    weekdaysMask: s.weekdaysMask,
    intervalDays: s.intervalDays,
    targetValue: s.targetValue,
  );
}

/// A habit as it applies to one date.
class HabitForDay {
  const HabitForDay({
    required this.definition,
    required this.date,
    required this.scheduled,
    required this.record,
  });

  final HabitDefinition definition;
  final LocalDate date;
  final bool scheduled;
  final HabitRecord? record;

  Habit get habit => definition.habit;
  double? get target => record?.targetSnapshot ?? definition.plan.targetOn(date);
}

class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;

  Future<List<HabitDefinition>> loadDefinitions({bool? archived}) async {
    final q = _db.select(_db.habits)
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    if (archived != null) q.where((t) => t.archived.equals(archived));
    final habits = await q.get();
    if (habits.isEmpty) return const [];
    final schedules = await (_db.select(_db.habitSchedules)
          ..where((t) => t.habitId.isIn(habits.map((h) => h.id))))
        .get();
    final byHabit = <String, List<HabitSchedule>>{};
    for (final s in schedules) {
      byHabit.putIfAbsent(s.habitId, () => []).add(s);
    }
    return [
      for (final h in habits)
        if (byHabit[h.id] != null) HabitDefinition(h, byHabit[h.id]!),
    ];
  }

  Stream<List<HabitDefinition>> watchDefinitions({bool? archived}) =>
      _db.watchTables({_db.habits, _db.habitSchedules}, () => loadDefinitions(archived: archived));

  Future<HabitDefinition?> findDefinition(String id) async {
    final habit = await (_db.select(_db.habits)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (habit == null) return null;
    final schedules = await (_db.select(_db.habitSchedules)
          ..where((t) => t.habitId.equals(id)))
        .get();
    return HabitDefinition(habit, schedules);
  }

  /// Habits relevant on [date]: active habits scheduled that day, plus any
  /// habit (including archived ones) that already has a record on that date.
  Future<List<HabitForDay>> loadForDate(LocalDate date) async {
    final definitions = await loadDefinitions();
    final records = await (_db.select(_db.habitRecords)
          ..where((t) => t.dateKey.equals(date.key)))
        .get();
    final recordByHabit = {for (final r in records) r.habitId: r};
    final result = <HabitForDay>[];
    for (final d in definitions) {
      final scheduled = d.plan.isScheduledOn(date);
      final record = recordByHabit[d.habit.id];
      if ((scheduled && !d.habit.archived) || record != null) {
        result.add(
          HabitForDay(definition: d, date: date, scheduled: scheduled, record: record),
        );
      }
    }
    return result;
  }

  Stream<List<HabitForDay>> watchForDate(LocalDate date) => _db.watchTables(
    {_db.habits, _db.habitSchedules, _db.habitRecords},
    () => loadForDate(date),
  );

  Future<Map<LocalDate, HabitStatus>> statusHistory(String habitId) async {
    final rows = await (_db.select(_db.habitRecords)
          ..where((t) => t.habitId.equals(habitId)))
        .get();
    return {for (final r in rows) LocalDate.parse(r.dateKey): r.status};
  }

  Stream<List<HabitRecord>> watchRecords(String habitId, {int limit = 60}) =>
      (_db.select(_db.habitRecords)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([(t) => OrderingTerm.desc(t.dateKey)])
            ..limit(limit))
          .watch();

  Future<String> create(HabitDraft draft) async {
    draft.validate();
    final now = nowUtcMillis();
    final id = newId();
    await _db.transaction(() async {
      final order = await _nextSortOrder();
      await _db
          .into(_db.habits)
          .insert(
            HabitsCompanion.insert(
              id: id,
              name: draft.name.trim(),
              description: Value(_blank(draft.description)),
              categoryId: Value(draft.categoryId),
              icon: Value(draft.icon),
              color: Value(draft.color),
              trackingType: draft.trackingType,
              targetUnit: Value(_unit(draft)),
              startDate: draft.startDate.key,
              endDate: Value(draft.normalizedEndDate?.key),
              sortOrder: Value(order),
              reminderMinute: Value(draft.reminderMinute),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _insertSchedule(id, draft.toRule(draft.startDate), now);
    });
    return id;
  }

  /// Updates a habit definition.
  ///
  /// Name, description, category, icon, unit and reminder change in place.
  /// A changed recurrence or target becomes a new schedule version effective
  /// from [today] (or the start date if later); earlier dates keep the rule
  /// that applied to them and existing records are never modified.
  Future<void> update(String id, HabitDraft draft, {required LocalDate today}) async {
    draft.validate();
    await _db.transaction(() async {
      final current = await findDefinition(id);
      if (current == null) throw const AppFailure('Kebiasaan tidak ditemukan.');
      if (current.habit.trackingType != draft.trackingType &&
          await _recordCount(id) > 0) {
        throw const ValidationFailure(
          'Jenis pencatatan tidak dapat diubah karena kebiasaan ini sudah '
          'memiliki catatan. Buat kebiasaan baru jika perlu.',
        );
      }
      final now = nowUtcMillis();
      await (_db.update(_db.habits)..where((t) => t.id.equals(id))).write(
        HabitsCompanion(
          name: Value(draft.name.trim()),
          description: Value(_blank(draft.description)),
          categoryId: Value(draft.categoryId),
          icon: Value(draft.icon),
          color: Value(draft.color),
          trackingType: Value(draft.trackingType),
          targetUnit: Value(_unit(draft)),
          startDate: Value(draft.startDate.key),
          endDate: Value(draft.normalizedEndDate?.key),
          reminderMinute: Value(draft.reminderMinute),
          updatedAt: Value(now),
        ),
      );

      final effective = draft.startDate.isAfter(today) ? draft.startDate : today;
      final applying = current.plan.ruleFor(effective);
      final next = draft.toRule(effective);
      if (_sameRule(applying, next)) return;

      // Versions starting after the new effective date are superseded.
      await (_db.delete(_db.habitSchedules)
            ..where(
              (t) =>
                  t.habitId.equals(id) &
                  t.effectiveFrom.isBiggerThanValue(effective.key),
            ))
          .go();
      final sameDay = current.schedules
          .where((s) => s.effectiveFrom == effective.key)
          .firstOrNull;
      if (sameDay != null) {
        await (_db.update(_db.habitSchedules)
              ..where((t) => t.id.equals(sameDay.id)))
            .write(_scheduleFields(next, now));
      } else {
        await _insertSchedule(id, next, now);
      }
    });
  }

  Future<void> setArchived(String id, bool archived) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id))).write(
        HabitsCompanion(archived: Value(archived), updatedAt: Value(nowUtcMillis())),
      );

  Future<int> recordCount(String id) => _recordCount(id);

  /// Permanently deletes the habit and all of its records.
  Future<void> deletePermanently(String id) => _db.transaction(() async {
    await (_db.delete(_db.habitRecords)..where((t) => t.habitId.equals(id))).go();
    await (_db.delete(_db.habitSchedules)..where((t) => t.habitId.equals(id))).go();
    await (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();
  });

  Future<void> reorder(List<String> orderedIds) => _db.transaction(() async {
    final now = nowUtcMillis();
    for (final (i, id) in orderedIds.indexed) {
      await (_db.update(_db.habits)..where((t) => t.id.equals(id))).write(
        HabitsCompanion(sortOrder: Value(i), updatedAt: Value(now)),
      );
    }
  });

  /// Creates or updates the single record for a habit on [date].
  Future<void> setRecord({
    required String habitId,
    required LocalDate date,
    required HabitStatus status,
    double? value,
    String? note,
  }) async {
    if (value != null && (value < 0 || value > 1000000)) {
      throw const ValidationFailure('Nilai harus 0 atau lebih.');
    }
    await _db.transaction(() async {
      final definition = await findDefinition(habitId);
      if (definition == null) throw const AppFailure('Kebiasaan tidak ditemukan.');
      if (definition.habit.trackingType == HabitTrackingType.check) value = null;
      final now = nowUtcMillis();
      final existing = await _record(habitId, date);
      if (existing == null) {
        await _db
            .into(_db.habitRecords)
            .insert(
              HabitRecordsCompanion.insert(
                id: newId(),
                habitId: habitId,
                dateKey: date.key,
                status: status,
                value: Value(value),
                targetSnapshot: Value(definition.plan.targetOn(date)),
                note: Value(_blank(note)),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.habitRecords)
              ..where((t) => t.id.equals(existing.id)))
            .write(
              HabitRecordsCompanion(
                status: Value(status),
                value: Value(value),
                note: Value(_blank(note)),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  /// Removes the record so the date returns to "Belum dicatat".
  Future<void> clearRecord(String habitId, LocalDate date) =>
      (_db.delete(_db.habitRecords)
            ..where((t) => t.habitId.equals(habitId) & t.dateKey.equals(date.key)))
          .go();

  /// Restores a previous record state (used by undo).
  Future<void> restoreRecord(String habitId, LocalDate date, HabitRecord? previous) =>
      _db.transaction(() async {
        await clearRecord(habitId, date);
        if (previous != null) {
          await _db.into(_db.habitRecords).insert(previous);
        }
      });

  Future<HabitRecord?> _record(String habitId, LocalDate date) =>
      (_db.select(_db.habitRecords)
            ..where((t) => t.habitId.equals(habitId) & t.dateKey.equals(date.key)))
          .getSingleOrNull();

  Future<int> _recordCount(String id) async {
    final count = _db.habitRecords.id.count();
    return (await (_db.selectOnly(_db.habitRecords)
              ..addColumns([count])
              ..where(_db.habitRecords.habitId.equals(id)))
            .map((r) => r.read(count))
            .getSingle()) ??
        0;
  }

  Future<int> _nextSortOrder() async {
    final max = _db.habits.sortOrder.max();
    final value = await (_db.selectOnly(_db.habits)..addColumns([max]))
        .map((r) => r.read(max))
        .getSingle();
    return value == null ? 0 : value + 1;
  }

  Future<void> _insertSchedule(String habitId, ScheduleRule rule, int now) =>
      _db
          .into(_db.habitSchedules)
          .insert(
            HabitSchedulesCompanion.insert(
              id: newId(),
              habitId: habitId,
              effectiveFrom: rule.effectiveFrom.key,
              recurrence: rule.recurrence,
              weekdaysMask: Value(rule.weekdaysMask),
              intervalDays: Value(rule.intervalDays),
              targetValue: Value(rule.targetValue),
              createdAt: now,
              updatedAt: now,
            ),
          );

  HabitSchedulesCompanion _scheduleFields(ScheduleRule rule, int now) =>
      HabitSchedulesCompanion(
        recurrence: Value(rule.recurrence),
        weekdaysMask: Value(rule.weekdaysMask),
        intervalDays: Value(rule.intervalDays),
        targetValue: Value(rule.targetValue),
        updatedAt: Value(now),
      );

  static bool _sameRule(ScheduleRule a, ScheduleRule b) =>
      a.recurrence == b.recurrence &&
      a.weekdaysMask == b.weekdaysMask &&
      a.intervalDays == b.intervalDays &&
      a.targetValue == b.targetValue;

  static String? _blank(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  static String? _unit(HabitDraft d) => switch (d.trackingType) {
    HabitTrackingType.check => null,
    HabitTrackingType.duration => 'menit',
    HabitTrackingType.quantity => _blank(d.targetUnit),
  };
}
