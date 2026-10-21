import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/providers.dart';
import '../../features/settings/domain/preferences.dart';
import '../errors/app_failure.dart';
import 'reminder_planner.dart';

/// Resolves the timezone used for prayer times: the configured IANA zone, or
/// the device zone.
tz.Location prayerLocation(Preferences prefs) {
  final name = prefs.prayerTimezone;
  if (name != null) {
    try {
      return tz.getLocation(name);
    } on Object {
      // Fall back to the device zone if the stored name is unknown.
    }
  }
  return tz.local;
}

/// Re-plans all reminders from the current preferences and habits.
Future<int> syncReminders(Ref ref) async {
  final prefs = await ref.read(settingsRepositoryProvider).load();
  final habits = await ref.read(habitRepositoryProvider).loadDefinitions(archived: false);
  final now = tz.TZDateTime.from(ref.read(clockProvider)(), tz.local);
  final reminders = ReminderPlanner.plan(
    prefs: prefs,
    habits: habits,
    now: now,
    prayerLocation: prayerLocation(prefs),
  );
  final service = ref.read(notificationServiceProvider);
  if (reminders.isNotEmpty && !await service.areEnabled()) {
    // Permission was revoked in system settings; nothing can be delivered.
    await service.replaceAll(const []);
    return 0;
  }
  await service.replaceAll(reminders);
  return reminders.length;
}

/// Exposes reminder syncing to widgets.
final reminderSyncProvider = Provider<Future<int> Function()>((ref) {
  return () async {
    try {
      return await syncReminders(ref);
    } on Object catch (e) {
      logError('sync reminders', e);
      rethrow;
    }
  };
});
