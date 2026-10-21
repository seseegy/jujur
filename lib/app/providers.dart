import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/backup/restore_service.dart';
import '../core/database/app_database.dart';
import '../core/date/local_date.dart';
import '../core/export/export_service.dart';
import '../core/notifications/notification_service.dart';
import '../features/activities/data/activity_repository.dart';
import '../features/categories/data/category_repository.dart';
import '../features/habits/data/habit_repository.dart';
import '../features/history/data/history_repository.dart';
import '../features/insights/data/insights_repository.dart';
import '../features/prayers/data/prayer_repository.dart';
import '../features/reflections/data/reflection_repository.dart';
import '../features/search/data/search_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/preferences.dart';
import '../features/worship/data/worship_repository.dart';
import 'app_config.dart';

/// Overridden in bootstrap with the opened database.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

/// Overridden in bootstrap; tests use a fake.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NoopNotificationService(),
);

final appConfigProvider = Provider<AppConfig>((ref) => const AppConfig());

/// Device clock, replaceable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));
final activityRepositoryProvider = Provider((ref) => ActivityRepository(ref.watch(databaseProvider)));
final categoryRepositoryProvider = Provider((ref) => CategoryRepository(ref.watch(databaseProvider)));
final habitRepositoryProvider = Provider((ref) => HabitRepository(ref.watch(databaseProvider)));
final prayerRepositoryProvider = Provider((ref) => PrayerRepository(ref.watch(databaseProvider)));
final worshipRepositoryProvider = Provider((ref) => WorshipRepository(ref.watch(databaseProvider)));
final reflectionRepositoryProvider = Provider((ref) => ReflectionRepository(ref.watch(databaseProvider)));
final historyRepositoryProvider = Provider((ref) => HistoryRepository(ref.watch(databaseProvider)));
final searchRepositoryProvider = Provider((ref) => SearchRepository(ref.watch(databaseProvider)));
final insightsRepositoryProvider = Provider(
  (ref) => InsightsRepository(ref.watch(databaseProvider), ref.watch(habitRepositoryProvider)),
);
final exportServiceProvider = Provider(
  (ref) => ExportService(ref.watch(databaseProvider), ref.watch(habitRepositoryProvider), clock: ref.watch(clockProvider)),
);
final restoreServiceProvider = Provider((ref) => RestoreService(ref.watch(databaseProvider)));

/// Persisted preferences, updated whenever the settings table changes.
final preferencesProvider = StreamProvider<Preferences>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Current preferences, or defaults while loading.
final prefsProvider = Provider<Preferences>(
  (ref) => ref.watch(preferencesProvider).value ?? Preferences.empty,
);

/// Today's local date. Refreshes at local midnight and whenever the app
/// returns to the foreground (which also covers timezone changes).
final todayProvider = NotifierProvider<TodayNotifier, LocalDate>(TodayNotifier.new);

class TodayNotifier extends Notifier<LocalDate> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  LocalDate build() {
    final clock = ref.watch(clockProvider);
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });
    _scheduleMidnight(clock);
    return LocalDate.today(clock);
  }

  void _scheduleMidnight(DateTime Function() clock) {
    _timer?.cancel();
    final now = clock();
    final next = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(next.difference(now) + const Duration(seconds: 1), refresh);
  }

  void refresh() {
    final clock = ref.read(clockProvider);
    final today = LocalDate.today(clock);
    if (today != state) state = today;
    _scheduleMidnight(clock);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }
}
