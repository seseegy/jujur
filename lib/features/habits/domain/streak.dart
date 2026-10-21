import '../../../core/date/local_date.dart';
import 'habit_enums.dart';
import 'recurrence.dart';

/// Streak definition (shown to the user in the habit detail):
///
/// The number of consecutive *scheduled* days, counting back from [today],
/// whose record is "Selesai". Unscheduled days are ignored. Today does not
/// break the streak while it is still unrecorded. A "Dilewati" (skipped)
/// record neither breaks nor extends the streak. Any other status, or a
/// missing record on an earlier scheduled day, ends the streak — a missing
/// record is never counted as done.
int currentStreak({
  required HabitSchedulePlan plan,
  required Map<LocalDate, HabitStatus> records,
  required LocalDate today,
  int maxLookbackDays = 3650,
}) {
  var streak = 0;
  for (var i = 0; i < maxLookbackDays; i++) {
    final date = today.addDays(-i);
    if (date.isBefore(plan.startDate)) break;
    if (!plan.isScheduledOn(date)) continue;
    final status = records[date];
    if (status == null) {
      if (date == today) continue;
      break;
    }
    switch (status) {
      case HabitStatus.done:
        streak++;
      case HabitStatus.skipped:
        continue;
      case HabitStatus.partial:
      case HabitStatus.notDone:
        return streak;
    }
  }
  return streak;
}
