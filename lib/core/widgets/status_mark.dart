import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/activities/domain/activity_status.dart';
import '../../features/habits/domain/habit_enums.dart';
import '../../features/prayers/domain/prayer.dart';
import '../../features/worship/domain/worship_enums.dart';

/// Visual vocabulary for statuses. Every status has a distinct icon shape
/// and a text label, so color is never the only indicator.
enum Mark {
  done(Icons.check_circle, 'Selesai'),
  partial(Icons.timelapse, 'Sebagian'),
  notDone(Icons.cancel_outlined, 'Tidak dilakukan'),
  skipped(Icons.remove_circle_outline, 'Dilewati'),
  notApplicable(Icons.do_not_disturb_on_outlined, 'Tidak berlaku'),
  late(Icons.history, 'Diqada'),
  planned(Icons.schedule, 'Direncanakan'),
  unrecorded(Icons.radio_button_unchecked, 'Belum dicatat');

  const Mark(this.icon, this.defaultLabel);
  final IconData icon;
  final String defaultLabel;

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = StatusColors.of(context);
    return switch (this) {
      Mark.done => status.success,
      Mark.partial || Mark.late => status.warning,
      Mark.notDone => scheme.error,
      Mark.planned => scheme.primary,
      Mark.skipped || Mark.notApplicable || Mark.unrecorded => status.muted,
    };
  }

  static Mark activity(ActivityStatus s) => switch (s) {
    ActivityStatus.done => Mark.done,
    ActivityStatus.partial => Mark.partial,
    ActivityStatus.planned => Mark.planned,
    ActivityStatus.notDone => Mark.notDone,
  };

  static Mark habit(HabitStatus? s) => switch (s) {
    null => Mark.unrecorded,
    HabitStatus.done => Mark.done,
    HabitStatus.partial => Mark.partial,
    HabitStatus.skipped => Mark.skipped,
    HabitStatus.notDone => Mark.notDone,
  };

  static Mark prayer(PrayerStatus? s) => switch (s) {
    null => Mark.unrecorded,
    PrayerStatus.done => Mark.done,
    PrayerStatus.qadha => Mark.late,
    PrayerStatus.missed => Mark.notDone,
    PrayerStatus.excused => Mark.notApplicable,
  };

  static Mark worship(WorshipStatus? s) => switch (s) {
    null => Mark.unrecorded,
    WorshipStatus.done => Mark.done,
    WorshipStatus.notDone => Mark.notDone,
  };
}

class StatusMark extends StatelessWidget {
  const StatusMark(this.mark, {super.key, this.size = 22});

  final Mark mark;
  final double size;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: Icon(mark.icon, size: size, color: mark.color(context)));
}
