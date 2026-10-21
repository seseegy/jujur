import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../activities/domain/activity_status.dart';
import '../../habits/data/habit_repository.dart';
import '../../habits/domain/habit_enums.dart';
import '../../prayers/data/prayer_repository.dart';
import '../../prayers/domain/prayer.dart';

/// Compact, factual summary of one day. Each line states exactly what it
/// counts; nothing is combined into a score.
class DayOverview extends StatelessWidget {
  const DayOverview({
    super.key,
    required this.prayers,
    required this.habits,
    required this.activities,
    required this.reflectionWritten,
    required this.showPrayers,
    required this.isFuture,
  });

  final DayPrayers? prayers;
  final List<HabitForDay> habits;
  final List<Activity> activities;
  final bool reflectionWritten;
  final bool showPrayers;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = prayers;
    final scheduledHabits = habits.where((h) => h.scheduled).toList();
    final anyRecorded =
        (p?.recordedCount ?? 0) > 0 || habits.any((h) => h.record != null) || activities.isNotEmpty || reflectionWritten;

    if (!anyRecorded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
        child: Text(
          isFuture
              ? 'Tanggal ini belum tiba. Anda tetap dapat merencanakan aktivitas.'
              : 'Belum ada catatan untuk tanggal ini. Anda dapat mencatatnya kapan saja.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    final rows = <(String, String)>[
      if (showPrayers && p != null) ('Salat', _prayerSummary(p)),
      if (scheduledHabits.isNotEmpty) ('Kebiasaan', _habitSummary(scheduledHabits)),
      ('Aktivitas', _activitySummary(activities)),
      ('Refleksi', reflectionWritten ? 'Sudah ditulis' : 'Belum ditulis'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 96, child: Text(label, style: theme.textTheme.bodySmall)),
                    Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _prayerSummary(DayPrayers p) {
    final performed = p.count(PrayerStatus.done) + p.count(PrayerStatus.qadha);
    final parts = <String>[
      if (performed > 0) '$performed dilaksanakan',
      if (p.count(PrayerStatus.missed) > 0) '${p.count(PrayerStatus.missed)} terlewat',
      if (p.count(PrayerStatus.excused) > 0) '${p.count(PrayerStatus.excused)} tidak berlaku',
      if (p.unrecordedCount > 0) '${p.unrecordedCount} belum dicatat',
    ];
    return parts.join(' · ');
  }

  static String _habitSummary(List<HabitForDay> scheduled) {
    final done = scheduled.where((h) => h.record?.status == HabitStatus.done).length;
    final unrecorded = scheduled.where((h) => h.record == null).length;
    return [
      '$done dari ${scheduled.length} selesai',
      if (unrecorded > 0) '$unrecorded belum dicatat',
    ].join(' · ');
  }

  static String _activitySummary(List<Activity> activities) {
    if (activities.isEmpty) return 'Belum ada';
    final done = activities.where((a) => a.status == ActivityStatus.done).length;
    return done == activities.length
        ? '${activities.length} dicatat'
        : '${activities.length} dicatat · $done selesai';
  }
}
