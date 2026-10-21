import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/date/local_date.dart';
import '../features/activities/presentation/activity_form_screen.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/export/presentation/export_screen.dart';
import '../features/habits/presentation/habit_detail_screen.dart';
import '../features/habits/presentation/habit_form_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/prayers/presentation/prayer_day_screen.dart';
import '../features/prayers/presentation/prayer_settings_screen.dart';
import '../features/reflections/presentation/reflection_list_screen.dart';
import '../features/reflections/presentation/reflection_prompts_screen.dart';
import '../features/reflections/presentation/reflection_screen.dart';
import '../features/search/data/search_repository.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/today/presentation/day_screen.dart';
import '../features/today/presentation/today_screen.dart';
import '../features/worship/presentation/worship_settings_screen.dart';
import 'providers.dart';
import 'shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

LocalDate _date(GoRouterState s, String name) =>
    LocalDate.tryParse(s.pathParameters[name] ?? s.uri.queryParameters[name]) ?? LocalDate.today();

SearchQuery? _searchQuery(Map<String, String> q) {
  if (q.isEmpty) return null;
  final start = LocalDate.tryParse(q['start']);
  final end = LocalDate.tryParse(q['end']);
  return SearchQuery(
    scope: SearchScope.values.where((s) => s.name == q['scope']).firstOrNull ?? SearchScope.all,
    range: start != null && end != null && !end.isBefore(start) ? DateRange(start, end) : null,
    categoryId: q['category'],
  );
}

/// Routes. Feature routes are pushed above the bottom navigation so that
/// back navigation returns to the tab the user came from.
final routerProvider = Provider<GoRouter>((ref) {
  final onboarding = ValueNotifier<bool?>(null);
  ref.listen(preferencesProvider, (_, next) {
    final done = next.value?.onboardingDone;
    if (done != null) onboarding.value = done;
  }, fireImmediately: true);
  ref.onDispose(onboarding.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    refreshListenable: onboarding,
    redirect: (context, state) {
      final done = onboarding.value;
      if (done == null) return null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!done && !atOnboarding) return '/onboarding';
      if (done && atOnboarding) return '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/today', builder: (_, _) => const TodayScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, _) => const HistoryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/insights', builder: (_, _) => const InsightsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())]),
        ],
      ),
      GoRoute(path: '/day/:date', builder: (_, s) => DayScreen(date: _date(s, 'date'))),
      GoRoute(
        path: '/activity/new',
        builder: (_, s) => ActivityFormScreen(
          date: _date(s, 'date'),
          initialTitle: s.uri.queryParameters['title'],
          initialCategoryId: s.uri.queryParameters['category'],
        ),
      ),
      GoRoute(
        path: '/activity/:id',
        builder: (_, s) => ActivityFormScreen(activityId: s.pathParameters['id'], date: LocalDate.today()),
      ),
      GoRoute(path: '/habits', builder: (_, _) => const HabitsScreen()),
      GoRoute(path: '/habits/new', builder: (_, _) => const HabitFormScreen()),
      GoRoute(path: '/habits/:id', builder: (_, s) => HabitDetailScreen(habitId: s.pathParameters['id']!)),
      GoRoute(path: '/habits/:id/edit', builder: (_, s) => HabitFormScreen(habitId: s.pathParameters['id'])),
      GoRoute(path: '/prayers/:date', builder: (_, s) => PrayerDayScreen(date: _date(s, 'date'))),
      GoRoute(path: '/reflection/:date', builder: (_, s) => ReflectionScreen(date: _date(s, 'date'))),
      GoRoute(path: '/reflections', builder: (_, _) => const ReflectionListScreen()),
      GoRoute(path: '/search', builder: (_, s) => SearchScreen(initial: _searchQuery(s.uri.queryParameters))),
      GoRoute(path: '/settings/categories', builder: (_, _) => const CategoriesScreen()),
      GoRoute(path: '/settings/worship', builder: (_, _) => const WorshipSettingsScreen()),
      GoRoute(path: '/settings/prompts', builder: (_, _) => const ReflectionPromptsScreen()),
      GoRoute(path: '/settings/prayer', builder: (_, _) => const PrayerSettingsScreen()),
      GoRoute(path: '/settings/backup', builder: (_, _) => const BackupScreen()),
      GoRoute(path: '/settings/export', builder: (_, _) => const ExportScreen()),
      GoRoute(path: '/settings/about', builder: (_, _) => const AboutScreen()),
      GoRoute(path: '/settings/privacy', builder: (_, _) => const PrivacyScreen()),
    ],
  );
});
