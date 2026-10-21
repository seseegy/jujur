import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/database/app_database.dart';
import '../core/database/database_opener.dart';
import '../core/errors/app_failure.dart';
import '../core/notifications/notification_service.dart';
import 'app.dart';
import 'providers.dart';
import 'startup_error_app.dart';

/// Initializes local services, opens the database and starts the app.
///
/// If the database cannot be opened (for example a failed migration or a
/// full disk), a dedicated error screen is shown. The database file is never
/// deleted or reset to recover.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  await _initTimezone();

  final AppDatabase db;
  try {
    final dir = await getApplicationSupportDirectory();
    final temp = await getTemporaryDirectory();
    db = await openAppDatabase(directory: dir, tempDirectory: temp.path);
  } on Object catch (e) {
    logError('open database', e);
    runApp(StartupErrorApp(error: e));
    return;
  }

  final notifications = LocalNotificationService();
  try {
    await notifications.initialize();
  } on Object catch (e) {
    logError('init notifications', e);
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const JujurApp(),
    ),
  );
}

Future<void> _initTimezone() async {
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } on Object catch (e) {
    // Keep UTC as the scheduling zone; dates are still taken from the
    // device's local clock, so records are unaffected.
    logError('timezone', e);
  }
}
