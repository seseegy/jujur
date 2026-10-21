import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_mark.dart';
import '../../../core/widgets/track_row.dart';
import '../../settings/domain/preferences.dart';
import '../../today/presentation/day_providers.dart';
import '../domain/prayer.dart';
import '../domain/prayer_times.dart';
import 'prayer_sheet.dart';

/// Prayer times for a date, if configured.
final dayPrayerTimesProvider = Provider.autoDispose.family<DayPrayerTimes?, LocalDate>((ref, date) {
  final prefs = ref.watch(prefsProvider);
  if (prefs.prayerTimesMode == PrayerTimesMode.off) return null;
  final result = PrayerTimesCalculator.compute(prefs, date, prayerLocation(prefs));
  return result is DayPrayerTimes ? result : null;
});

/// The five prayers for [date] as rows. Used on Today and on the prayer
/// detail screen.
class PrayerRows extends ConsumerWidget {
  const PrayerRows({super.key, required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(dayPrayersProvider(date));
    final times = ref.watch(dayPrayerTimesProvider(date));
    return AsyncView(
      value: value,
      data: (day) => Column(
        children: [
          for (final prayer in Prayer.values)
            _PrayerRow(
              key: ValueKey('prayer-${prayer.name}'),
              prayer: prayer,
              date: date,
              status: day[prayer]?.status,
              detail: _detail(day[prayer]?.performedMinute, day[prayer]?.jamaah, times, prayer),
            ),
        ],
      ),
    );
  }

  static String? _detail(int? performed, bool? jamaah, DayPrayerTimes? times, Prayer prayer) {
    final parts = <String>[
      if (times?.minutes[prayer] case final t?)
        '${times!.source == PrayerTimeSource.calculated ? 'Perkiraan' : 'Jadwal'} ${MinuteOfDay.format(t)}',
      if (performed != null) 'Dicatat ${MinuteOfDay.format(performed)}',
      if (jamaah == true) 'Berjamaah',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}

class _PrayerRow extends ConsumerWidget {
  const _PrayerRow({super.key, required this.prayer, required this.date, required this.status, required this.detail});

  final Prayer prayer;
  final LocalDate date;
  final PrayerStatus? status;
  final String? detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackRow(
      mark: Mark.prayer(status),
      title: prayer.label,
      subtitle: detail,
      statusLabel: status?.label ?? notRecordedLabel,
      onTap: () => showPrayerSheet(context, prayer: prayer, date: date),
      trailing: status == null || status == PrayerStatus.done
          ? QuickCheckButton(
              checked: status == PrayerStatus.done,
              label: status == null
                  ? 'Tandai ${prayer.label} dilaksanakan'
                  : 'Batalkan catatan ${prayer.label}',
              onPressed: () => _quickToggle(context, ref),
            )
          : null,
    );
  }

  Future<void> _quickToggle(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(prayerRepositoryProvider);
    final previous = await repo.find(prayer, date);
    if (!context.mounted) return;
    final ok = await runGuarded(context, () async {
      if (previous == null) {
        await repo.setStatus(prayer: prayer, date: date, status: PrayerStatus.done, jamaah: const Value(null));
      } else {
        await repo.clear(prayer, date);
      }
    });
    if (ok && context.mounted) {
      showUndo(
        context,
        previous == null ? '${prayer.label} dicatat dilaksanakan.' : 'Catatan ${prayer.label} dihapus.',
        () => repo.restore(prayer, date, previous),
      );
    }
  }
}

/// Today-screen section with a link to the full prayer screen.
class PrayerSectionLink extends StatelessWidget {
  const PrayerSectionLink({super.key, required this.date});
  final LocalDate date;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Detail salat',
    icon: const Icon(Icons.open_in_new),
    onPressed: () => context.push('/prayers/${date.key}'),
  );
}
