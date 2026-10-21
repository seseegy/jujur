import 'package:timezone/timezone.dart' as tz;

import '../../features/habits/data/habit_repository.dart';
import '../../features/prayers/domain/prayer.dart';
import '../../features/prayers/domain/prayer_times.dart';
import '../../features/settings/domain/preferences.dart';
import '../date/local_date.dart';

class PlannedReminder {
  const PlannedReminder({required this.id, required this.at, required this.title, required this.body, required this.channel});

  final int id;
  final tz.TZDateTime at;
  final String title;
  final String body;
  final ReminderChannel channel;

  @override
  String toString() => 'PlannedReminder($id, $at, $title)';
}

enum ReminderChannel { prayer, habit }

/// Plans one-off reminders for the next [days] days.
///
/// Reminders are re-planned whenever the app starts, resumes, or a relevant
/// setting changes, and the previous set is cancelled first, so rescheduling
/// never duplicates notifications. Reminder text never contains reflections
/// or notes, and no reminder marks anything as done.
abstract final class ReminderPlanner {
  static const days = 7;

  static List<PlannedReminder> plan({
    required Preferences prefs,
    required List<HabitDefinition> habits,
    required tz.TZDateTime now,
    required tz.Location prayerLocation,
  }) {
    final result = <PlannedReminder>[];
    final today = LocalDate(now.year, now.month, now.day);

    void add(tz.TZDateTime at, String title, String body, ReminderChannel channel) {
      if (!at.isAfter(now)) return;
      result.add(PlannedReminder(id: result.length + 1, at: at, title: title, body: body, channel: channel));
    }

    for (var i = 0; i < days; i++) {
      final date = today.addDays(i);
      if (prefs.prayerEnabled && prefs.prayerRemindersEnabled) {
        final times = PrayerTimesCalculator.compute(prefs, date, prayerLocation);
        if (times is DayPrayerTimes) {
          for (final prayer in Prayer.values) {
            final instant = times.instants[prayer];
            if (instant == null || !prefs.prayerReminderPrayers.contains(prayer)) continue;
            final at = tz.TZDateTime.from(instant, now.location).add(Duration(minutes: prefs.prayerReminderOffset));
            add(
              at,
              'Waktu ${prayer.label}',
              'Catat salat ${prayer.label} jika sudah dilaksanakan.',
              ReminderChannel.prayer,
            );
          }
        }
      }
      for (final def in habits) {
        final minute = def.habit.reminderMinute;
        if (minute == null || def.habit.archived || !def.plan.isScheduledOn(date)) continue;
        add(
          tz.TZDateTime(now.location, date.year, date.month, date.day, minute ~/ 60, minute % 60),
          def.habit.name,
          'Pengingat kebiasaan. Tandai jika sudah dilakukan.',
          ReminderChannel.habit,
        );
      }
    }
    result.sort((a, b) => a.at.compareTo(b.at));
    return [
      for (final (i, r) in result.indexed)
        PlannedReminder(id: i + 1, at: r.at, title: r.title, body: r.body, channel: r.channel),
    ];
  }
}
