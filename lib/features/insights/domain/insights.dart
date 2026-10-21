import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../activities/domain/activity_status.dart';
import '../../habits/data/habit_repository.dart';
import '../../habits/domain/habit_enums.dart';
import '../../prayers/domain/prayer.dart';
import '../../worship/domain/worship_enums.dart';

class CategoryUsage {
  const CategoryUsage({
    required this.categoryId,
    required this.name,
    required this.count,
    required this.minutes,
  });
  final String? categoryId;
  final String name;
  final int count;
  final int minutes;
}

class ActivityInsights {
  const ActivityInsights({
    required this.total,
    required this.byStatus,
    required this.categories,
    required this.totalMinutes,
    required this.timedCount,
  });

  final int total;
  final Map<ActivityStatus, int> byStatus;
  final List<CategoryUsage> categories;

  /// Sum of recorded durations for done or partial activities.
  final int totalMinutes;

  /// Number of done/partial activities that have a duration.
  final int timedCount;

  int get done => byStatus[ActivityStatus.done] ?? 0;

  /// Average duration, only meaningful with at least 3 timed activities.
  int? get averageMinutes => timedCount >= 3 ? (totalMinutes / timedCount).round() : null;
}

class HabitInsight {
  const HabitInsight({
    required this.habitId,
    required this.name,
    required this.archived,
    required this.scheduledDays,
    required this.byStatus,
    required this.unrecordedScheduled,
    required this.unit,
    required this.totalValue,
  });

  final String habitId;
  final String name;
  final bool archived;

  /// Scheduled days in the range up to and including today.
  final int scheduledDays;
  final Map<HabitStatus, int> byStatus;

  /// Scheduled days (up to today) without any record.
  final int unrecordedScheduled;
  final String? unit;
  final double totalValue;

  int get done => byStatus[HabitStatus.done] ?? 0;
}

class PrayerInsights {
  const PrayerInsights({
    required this.days,
    required this.byStatus,
    required this.byPrayer,
    required this.jamaah,
    required this.unrecorded,
    required this.unrecordedByPrayer,
  });

  /// Days in the range up to and including today.
  final int days;
  final Map<PrayerStatus, int> byStatus;
  final Map<Prayer, Map<PrayerStatus, int>> byPrayer;
  final int jamaah;

  /// Prayer slots up to today without any record. These are not "missed".
  final int unrecorded;
  final Map<Prayer, int> unrecordedByPrayer;

  int get recorded => byStatus.values.fold(0, (a, b) => a + b);
  int count(PrayerStatus s) => byStatus[s] ?? 0;
}

class WorshipInsight {
  const WorshipInsight({
    required this.itemId,
    required this.name,
    required this.type,
    required this.unit,
    required this.doneDays,
    required this.notDoneDays,
    required this.totalValue,
  });

  final String itemId;
  final String name;
  final WorshipTrackingType type;
  final String? unit;
  final int doneDays;
  final int notDoneDays;
  final double totalValue;
}

class PeriodTotals {
  const PeriodTotals({
    required this.activitiesDone,
    required this.habitsDone,
    required this.prayersPerformed,
    required this.reflectionDays,
  });

  final int activitiesDone;
  final int habitsDone;

  /// Prayers recorded as "Dilaksanakan" or "Diqada".
  final int prayersPerformed;
  final int reflectionDays;
}

class InsightsReport {
  const InsightsReport({
    required this.range,
    required this.effectiveDays,
    required this.activities,
    required this.habits,
    required this.prayers,
    required this.worship,
    required this.reflectionDates,
    required this.daysWithRecords,
    required this.current,
    required this.previous,
  });

  final DateRange range;

  /// Days in the range that are not in the future.
  final int effectiveDays;
  final ActivityInsights activities;
  final List<HabitInsight> habits;
  final PrayerInsights prayers;
  final List<WorshipInsight> worship;
  final List<LocalDate> reflectionDates;
  final int daysWithRecords;
  final PeriodTotals current;
  final PeriodTotals previous;

  bool get isEmpty => daysWithRecords == 0;
}

/// Raw rows for one period, loaded by the repository.
class InsightsSource {
  const InsightsSource({
    required this.activities,
    required this.categories,
    required this.habitDefinitions,
    required this.habitRecords,
    required this.prayerRecords,
    required this.worshipItems,
    required this.worshipRecords,
    required this.reflectionDates,
  });

  final List<Activity> activities;
  final List<Category> categories;
  final List<HabitDefinition> habitDefinitions;
  final List<HabitRecord> habitRecords;
  final List<PrayerRecord> prayerRecords;
  final List<WorshipItem> worshipItems;
  final List<WorshipRecord> worshipRecords;
  final List<LocalDate> reflectionDates;
}
