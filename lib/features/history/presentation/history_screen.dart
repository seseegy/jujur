import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../data/history_repository.dart';
import 'month_calendar.dart';

enum MarkerFilter {
  all('Semua'),
  activities('Aktivitas'),
  prayers('Salat'),
  habits('Kebiasaan'),
  worship('Ibadah'),
  reflection('Refleksi');

  const MarkerFilter(this.label);
  final String label;

  bool matches(DayMarker m) => switch (this) {
    MarkerFilter.all => m.hasAny,
    MarkerFilter.activities => m.activities > 0,
    MarkerFilter.prayers => m.prayers > 0,
    MarkerFilter.habits => m.habits > 0,
    MarkerFilter.worship => m.worship > 0,
    MarkerFilter.reflection => m.reflection,
  };
}

final _markersProvider = StreamProvider.autoDispose.family<Map<LocalDate, DayMarker>, DateRange>(
  (ref, range) => ref.watch(historyRepositoryProvider).watchMarkers(range),
);

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late LocalDate _month = ref.read(todayProvider).firstOfMonth;
  late LocalDate _selected = ref.read(todayProvider);
  MarkerFilter _filter = MarkerFilter.all;

  void _select(LocalDate d) => setState(() {
    _selected = d;
    _month = d.firstOfMonth;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = ref.watch(todayProvider);
    final weekStart = ref.watch(prefsProvider.select((p) => p.weekStart));
    final range = DateRange(_month.startOfWeek(weekStart), _month.lastOfMonth.addDays(6));
    final markers = ref.watch(_markersProvider(range));
    final data = markers.value ?? const <LocalDate, DayMarker>{};
    final week = DateRange(_selected.startOfWeek(weekStart), _selected.startOfWeek(weekStart).addDays(6));
    final month = DateRange(_month, _month.lastOfMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(tooltip: 'Cari catatan', icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
          IconButton(
            tooltip: 'Semua refleksi',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => context.push('/reflections'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.sm, 0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(header: true, child: Text(formatMonthYear(_month), style: theme.textTheme.titleLarge)),
                ),
                IconButton(
                  tooltip: 'Bulan sebelumnya',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _month = _month.addMonths(-1)),
                ),
                IconButton(
                  tooltip: 'Bulan berikutnya',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _month = _month.addMonths(1)),
                ),
              ],
            ),
          ),
          if (_month != today.firstOfMonth)
            Padding(
              padding: Space.pageInsets,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => _select(today),
                  child: const Text('Kembali ke bulan ini'),
                ),
              ),
            ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: Space.pageInsets,
              children: [
                for (final f in MarkerFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.sm),
                    child: ChoiceChip(
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          MonthCalendar(
            month: _month,
            weekStart: weekStart,
            today: today,
            selected: _selected,
            hasMarker: (d) => data[d] != null && _filter.matches(data[d]!),
            onSelect: _select,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
            child: Text(
              'Titik menandakan ada catatan pada tanggal itu, bukan berhasil atau gagal.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          SectionHeader(title: formatLongDate(_selected)),
          _DaySummary(date: _selected, marker: data[_selected]),
          SectionHeader(title: 'Minggu ini', summary: formatRange(week)),
          _PeriodSummary(range: week),
          SectionHeader(title: 'Bulan ini', summary: formatMonthYear(_month)),
          _PeriodSummary(range: month),
        ],
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.date, required this.marker});
  final LocalDate date;
  final DayMarker? marker;

  @override
  Widget build(BuildContext context) {
    final m = marker;
    final parts = m == null
        ? const <String>[]
        : [
            if (m.activities > 0) '${m.activities} aktivitas',
            if (m.prayers > 0) '${m.prayers} salat dicatat',
            if (m.habits > 0) '${m.habits} catatan kebiasaan',
            if (m.worship > 0) '${m.worship} catatan ibadah',
            if (m.reflection) 'refleksi',
          ];
    return ListTile(
      title: Text(parts.isEmpty ? 'Belum ada catatan pada tanggal ini' : parts.join(' · ')),
      subtitle: const Text('Buka untuk melihat atau mengubah catatan.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/day/${date.key}'),
    );
  }
}

class _PeriodSummary extends ConsumerWidget {
  const _PeriodSummary({required this.range});
  final DateRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AsyncView(
      value: ref.watch(_markersProvider(range)),
      data: (markers) {
        if (markers.isEmpty) {
          return Padding(
            padding: Space.pageInsets,
            child: Text('Belum ada catatan pada periode ini.', style: theme.textTheme.bodyMedium),
          );
        }
        final values = markers.values;
        int sum(int Function(DayMarker) f) => values.fold(0, (a, m) => a + f(m));
        final rows = [
          ('Hari dengan catatan', '${markers.length} dari ${range.lengthInDays} hari'),
          ('Aktivitas', '${sum((m) => m.activities)}'),
          ('Salat dicatat', '${sum((m) => m.prayers)}'),
          ('Catatan kebiasaan', '${sum((m) => m.habits)}'),
          ('Catatan ibadah', '${sum((m) => m.worship)}'),
          ('Refleksi', '${values.where((m) => m.reflection).length} hari'),
        ];
        return Padding(
          padding: Space.pageInsets,
          child: Column(
            children: [
              for (final (label, value) in rows)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
                        Text(value, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
