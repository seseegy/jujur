import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../errors/app_failure.dart';
import 'reminder_planner.dart';

abstract class NotificationService {
  Future<void> initialize();

  /// Whether the system currently allows this app to post notifications.
  Future<bool> areEnabled();

  /// Asks for permission (Android 13+). Only call after a user action.
  Future<bool> requestPermission();

  /// Replaces all pending reminders with [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// Opens Android's notification settings for this app (sound, vibration,
  /// per-channel importance).
  Future<void> openSystemSettings();
}

class NoopNotificationService implements NotificationService {
  final List<PlannedReminder> scheduled = [];
  bool permission = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> areEnabled() async => permission;

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    scheduled
      ..clear()
      ..addAll(reminders);
  }

  @override
  Future<void> openSystemSettings() async {}
}

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> areEnabled() async => await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> requestPermission() async => await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<void> openSystemSettings() async {
    await initialize();
    await _plugin.openAppNotificationSettings();
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await initialize();
    await _plugin.cancelAllPendingNotifications();
    for (final r in reminders) {
      try {
        await _plugin.zonedSchedule(
          id: r.id,
          scheduledDate: r.at,
          title: r.title,
          body: r.body,
          notificationDetails: NotificationDetails(
            android: switch (r.channel) {
              ReminderChannel.prayer => const AndroidNotificationDetails(
                'prayer_reminders',
                'Pengingat salat',
                channelDescription: 'Pengingat waktu salat yang Anda aktifkan.',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
                category: AndroidNotificationCategory.reminder,
              ),
              ReminderChannel.habit => const AndroidNotificationDetails(
                'habit_reminders',
                'Pengingat kebiasaan',
                channelDescription: 'Pengingat kebiasaan yang Anda atur.',
                importance: Importance.defaultImportance,
                priority: Priority.defaultPriority,
                category: AndroidNotificationCategory.reminder,
              ),
            },
          ),
          // Inexact by design: no exact-alarm permission is requested, so
          // Android may deliver a reminder a few minutes late.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } on Object catch (e) {
        logError('schedule reminder', e);
        throw AppFailure('Pengingat gagal dijadwalkan.', cause: e);
      }
    }
  }
}
