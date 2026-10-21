import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../habits/data/habit_repository.dart';
import '../../prayers/data/prayer_repository.dart';
import '../../worship/data/worship_repository.dart';

final dayPrayersProvider = StreamProvider.autoDispose.family<DayPrayers, LocalDate>(
  (ref, date) => ref.watch(prayerRepositoryProvider).watchDay(date),
);

final dayHabitsProvider = StreamProvider.autoDispose.family<List<HabitForDay>, LocalDate>(
  (ref, date) => ref.watch(habitRepositoryProvider).watchForDate(date),
);

final dayWorshipProvider = StreamProvider.autoDispose.family<List<WorshipForDay>, LocalDate>(
  (ref, date) => ref.watch(worshipRepositoryProvider).watchForDate(date),
);

final dayActivitiesProvider = StreamProvider.autoDispose.family<List<Activity>, LocalDate>(
  (ref, date) => ref.watch(activityRepositoryProvider).watchByDate(date),
);

final dayReflectionExistsProvider = StreamProvider.autoDispose.family<bool, LocalDate>(
  (ref, date) => ref.watch(reflectionRepositoryProvider).watchExists(date),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

/// The date shown on the Today tab. Null follows the current date.
final todayTabDateProvider = NotifierProvider<TodayTabDate, LocalDate?>(TodayTabDate.new);

class TodayTabDate extends Notifier<LocalDate?> {
  @override
  LocalDate? build() => null;

  void show(LocalDate date) => state = date == ref.read(todayProvider) ? null : date;
  void reset() => state = null;
}
