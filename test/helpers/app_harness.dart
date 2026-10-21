import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jujur/app/app.dart';
import 'package:jujur/app/providers.dart';
import 'package:jujur/core/database/app_database.dart';
import 'package:jujur/core/notifications/notification_service.dart';
import 'package:jujur/features/settings/data/settings_repository.dart';
import 'package:jujur/features/settings/domain/preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Fixed "now" for widget tests: Wednesday 21 October 2026, 09:30 local.
final testNow = DateTime(2026, 10, 21, 9, 30);

Future<void> setUpTestEnvironment() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await initializeDateFormatting('id_ID');
  tzdata.initializeTimeZones();
}

/// Any attempt to open a network connection fails the test.
class NoNetworkHttpOverrides extends HttpOverrides {
  int attempts = 0;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw const SocketException('Jaringan tidak tersedia (simulasi).');
  }
}

Future<void> markOnboarded(AppDatabase db) => SettingsRepository(db).set(SettingKeys.onboardingDone, 'true');

/// Pumps the real app on [db].
Future<NoopNotificationService> pumpApp(
  WidgetTester tester,
  AppDatabase db, {
  DateTime? now,
  Size size = const Size(412, 915),
}) async {
  tester.view.physicalSize = size * 2.625;
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  final notifications = NoopNotificationService();
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
        clockProvider.overrideWithValue(() => now ?? testNow),
      ],
      child: const JujurApp(),
    ),
  );
  await settle(tester);
  return notifications;
}

/// Lets database streams deliver and animations finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// Removes the app so timers and streams are disposed before the test ends.
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

/// Scrolls the main list until [finder] is visible ([up] scrolls back).
Future<void> scrollTo(WidgetTester tester, Finder finder, {bool up = false}) async {
  await tester.scrollUntilVisible(finder, up ? -200 : 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}
