import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/status_mark.dart';
import '../../../core/widgets/states.dart';
import '../../habits/domain/recurrence.dart' show shortWeekdayNames;
import '../../settings/domain/preferences.dart';
import '../../today/presentation/date_header.dart';
import '../../today/presentation/day_providers.dart';
import '../domain/prayer.dart';
import '../domain/prayer_times.dart';
import 'prayer_section.dart';

class PrayerDayScreen extends ConsumerStatefulWidget {
  const PrayerDayScreen({super.key, required this.date});
  final LocalDate date;

  @override
  ConsumerState<PrayerDayScreen> createState() => _PrayerDayScreenState();
}

class _PrayerDayScreenState extends ConsumerState<PrayerDayScreen> {
  late LocalDate _date = widget.date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final prefs = ref.watch(prefsProvider);
    final times = ref.watch(dayPrayerTimesProvider(_date));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salat'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan salat',
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/settings/prayer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xxxl),
        children: [
          DateHeader(date: _date, today: today, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: Space.sm),
          PrayerRows(date: _date),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
            child: Text(
              switch ((prefs.prayerTimesMode, times?.source)) {
                (PrayerTimesMode.off, _) =>
                  'Status tidak ditentukan dari jam. Salat yang belum dicatat tetap "Belum dicatat", bukan "Terlewat".',
                (_, PrayerTimeSource.calculated) =>
                  'Jadwal dihitung di perangkat (${calcMethodById(prefs.prayerCalcMethod)?.label}). '
                      'Jadwal tidak memengaruhi status: Anda yang menentukan catatannya.',
                (_, PrayerTimeSource.manual) => 'Jadwal diatur manual. Jadwal tidak memengaruhi status.',
                _ => 'Waktu salat belum lengkap diatur.',
              },
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SectionHeader(title: '7 hari terakhir'),
          _WeekTable(end: _date, onOpen: (d) => setState(() => _date = d)),
        ],
      ),
    );
  }
}

/// Compact table: rows are prayers, columns are days. Icons differ by
/// shape, and each cell has a spoken label.
class _WeekTable extends ConsumerWidget {
  const _WeekTable({required this.end, required this.onOpen});

  final LocalDate end;
  final ValueChanged<LocalDate> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final days = [for (var i = 6; i >= 0; i--) end.addDays(-i)];
    final values = [for (final d in days) ref.watch(dayPrayersProvider(d))];
    if (values.any((v) => v.isLoading && !v.hasValue)) return const LoadingView();
    return Padding(
      padding: Space.pageInsets,
      child: Table(
        columnWidths: const {0: FixedColumnWidth(72)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              for (final d in days)
                InkWell(
                  onTap: () => onOpen(d),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.sm),
                    child: Text(
                      '${shortWeekdayNames[d.weekday - 1]}\n${d.day}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: d == end ? FontWeight.w700 : null,
                        color: d == end ? theme.colorScheme.onSurface : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final p in Prayer.values)
            TableRow(
              children: [
                Text(p.label, style: theme.textTheme.bodySmall),
                for (final (i, d) in days.indexed)
                  Builder(
                    builder: (context) {
                      final status = values[i].value?[p]?.status;
                      return Semantics(
                        label: '${p.label}, ${formatDate(d)}: ${status?.label ?? notRecordedLabel}',
                        child: SizedBox(height: 36, child: Center(child: StatusMark(Mark.prayer(status), size: 18))),
                      );
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
