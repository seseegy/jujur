import '../../../core/date/local_date.dart';
import '../../activities/domain/activity_status.dart';
import '../../habits/domain/habit_enums.dart';
import '../../prayers/domain/prayer.dart';
import '../../worship/domain/worship_enums.dart';
import 'insights.dart';

/// Pure statistics over persisted records. Missing records are reported as
/// "belum dicatat" and never counted as done or as missed.
abstract final class InsightsCalculator {
  /// Days of [range] that are on or before [today].
  static DateRange? elapsed(DateRange range, LocalDate today) {
    if (range.start.isAfter(today)) return null;
    final end = range.end.isAfter(today) ? today : range.end;
    return DateRange(range.start, end);
  }

  static ActivityInsights activities(InsightsSource s) {
    final byStatus = <ActivityStatus, int>{};
    final categoryNames = {for (final c in s.categories) c.id: c.name};
    final counts = <String?, int>{};
    final minutes = <String?, int>{};
    var totalMinutes = 0;
    var timed = 0;
    for (final a in s.activities) {
      byStatus.update(a.status, (v) => v + 1, ifAbsent: () => 1);
      counts.update(a.categoryId, (v) => v + 1, ifAbsent: () => 1);
      final d = a.durationMinutes;
      final counted = a.status == ActivityStatus.done || a.status == ActivityStatus.partial;
      if (d != null && counted) {
        totalMinutes += d;
        timed++;
        minutes.update(a.categoryId, (v) => v + d, ifAbsent: () => d);
      }
    }
    final categories = [
      for (final e in counts.entries)
        CategoryUsage(
          categoryId: e.key,
          name: e.key == null ? 'Tanpa kategori' : (categoryNames[e.key] ?? 'Kategori terhapus'),
          count: e.value,
          minutes: minutes[e.key] ?? 0,
        ),
    ]..sort((a, b) => b.count != a.count ? b.count.compareTo(a.count) : a.name.compareTo(b.name));
    return ActivityInsights(
      total: s.activities.length,
      byStatus: byStatus,
      categories: categories,
      totalMinutes: totalMinutes,
      timedCount: timed,
    );
  }

  static List<HabitInsight> habits(InsightsSource s, DateRange range, LocalDate today) {
    final window = elapsed(range, today);
    final recordsByHabit = <String, Map<LocalDate, ({HabitStatus status, double? value})>>{};
    for (final r in s.habitRecords) {
      recordsByHabit.putIfAbsent(r.habitId, () => {})[LocalDate.parse(r.dateKey)] =
          (status: r.status, value: r.value);
    }
    final result = <HabitInsight>[];
    for (final def in s.habitDefinitions) {
      final records = recordsByHabit[def.habit.id] ?? const {};
      final scheduled = window == null ? const <LocalDate>[] : def.plan.scheduledDays(window).toList();
      if (def.habit.archived && records.isEmpty) continue;
      if (scheduled.isEmpty && records.isEmpty) continue;
      final byStatus = <HabitStatus, int>{};
      var total = 0.0;
      for (final r in records.values) {
        byStatus.update(r.status, (v) => v + 1, ifAbsent: () => 1);
        total += r.value ?? 0;
      }
      final unrecorded = scheduled.where((d) => !records.containsKey(d)).length;
      result.add(
        HabitInsight(
          habitId: def.habit.id,
          name: def.habit.name,
          archived: def.habit.archived,
          scheduledDays: scheduled.length,
          byStatus: byStatus,
          unrecordedScheduled: unrecorded,
          unit: def.habit.targetUnit,
          totalValue: total,
        ),
      );
    }
    return result;
  }

  static PrayerInsights prayers(InsightsSource s, DateRange range, LocalDate today) {
    final window = elapsed(range, today);
    final byStatus = <PrayerStatus, int>{};
    final byPrayer = <Prayer, Map<PrayerStatus, int>>{};
    final recordedInWindow = <Prayer, int>{};
    var jamaah = 0;
    for (final r in s.prayerRecords) {
      byStatus.update(r.status, (v) => v + 1, ifAbsent: () => 1);
      byPrayer.putIfAbsent(r.prayer, () => {}).update(r.status, (v) => v + 1, ifAbsent: () => 1);
      if (r.jamaah == true) jamaah++;
      if (window != null && window.contains(LocalDate.parse(r.dateKey))) {
        recordedInWindow.update(r.prayer, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final days = window?.lengthInDays ?? 0;
    final unrecordedByPrayer = {
      for (final p in Prayer.values) p: days - (recordedInWindow[p] ?? 0),
    };
    return PrayerInsights(
      days: days,
      byStatus: byStatus,
      byPrayer: byPrayer,
      jamaah: jamaah,
      unrecorded: unrecordedByPrayer.values.fold(0, (a, b) => a + b),
      unrecordedByPrayer: unrecordedByPrayer,
    );
  }

  static List<WorshipInsight> worship(InsightsSource s) {
    final byItem = <String, List<({WorshipStatus status, double? value})>>{};
    for (final r in s.worshipRecords) {
      byItem.putIfAbsent(r.itemId, () => []).add((status: r.status, value: r.value));
    }
    return [
      for (final item in s.worshipItems)
        if (byItem[item.id] case final records?)
          WorshipInsight(
            itemId: item.id,
            name: item.name,
            type: item.trackingType,
            unit: item.unit,
            doneDays: records.where((r) => r.status == WorshipStatus.done).length,
            notDoneDays: records.where((r) => r.status == WorshipStatus.notDone).length,
            totalValue: records
                .where((r) => r.status == WorshipStatus.done)
                .fold(0.0, (a, r) => a + (r.value ?? 0)),
          ),
    ];
  }

  static PeriodTotals totals(InsightsSource s) => PeriodTotals(
    activitiesDone: s.activities.where((a) => a.status == ActivityStatus.done).length,
    habitsDone: s.habitRecords.where((r) => r.status == HabitStatus.done).length,
    prayersPerformed: s.prayerRecords
        .where((r) => r.status == PrayerStatus.done || r.status == PrayerStatus.qadha)
        .length,
    reflectionDays: s.reflectionDates.length,
  );

  static int daysWithRecords(InsightsSource s) => {
    ...s.activities.map((a) => a.dateKey),
    ...s.habitRecords.map((r) => r.dateKey),
    ...s.prayerRecords.map((r) => r.dateKey),
    ...s.worshipRecords.map((r) => r.dateKey),
    ...s.reflectionDates.map((d) => d.key),
  }.length;

  static InsightsReport report({
    required DateRange range,
    required LocalDate today,
    required InsightsSource current,
    required InsightsSource previous,
  }) => InsightsReport(
    range: range,
    effectiveDays: elapsed(range, today)?.lengthInDays ?? 0,
    activities: activities(current),
    habits: habits(current, range, today),
    prayers: prayers(current, range, today),
    worship: worship(current),
    reflectionDates: current.reflectionDates,
    daysWithRecords: daysWithRecords(current),
    current: totals(current),
    previous: totals(previous),
  );
}
