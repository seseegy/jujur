import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/watch.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../../prayers/domain/prayer.dart';
import '../domain/insights.dart';
import 'insights_widgets.dart';

enum RangePreset {
  week('7 hari'),
  month('30 hari'),
  thisMonth('Bulan ini'),
  lastMonth('Bulan lalu'),
  custom('Pilih…');

  const RangePreset(this.label);
  final String label;

  DateRange resolve(LocalDate today) => switch (this) {
    RangePreset.week => DateRange(today.addDays(-6), today),
    RangePreset.month => DateRange(today.addDays(-29), today),
    RangePreset.thisMonth => DateRange(today.firstOfMonth, today.lastOfMonth),
    RangePreset.lastMonth => DateRange(today.firstOfMonth.addMonths(-1), today.firstOfMonth.addDays(-1)),
    RangePreset.custom => DateRange(today.addDays(-6), today),
  };
}

final _reportProvider = StreamProvider.autoDispose.family<InsightsReport, (DateRange, LocalDate)>((ref, args) {
  final db = ref.watch(databaseProvider);
  final repo = ref.watch(insightsRepositoryProvider);
  return db.watchTables(
    {db.activities, db.habitRecords, db.habits, db.habitSchedules, db.prayerRecords, db.worshipRecords, db.reflections},
    () => repo.report(args.$1, args.$2),
  );
});

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  RangePreset _preset = RangePreset.week;
  DateRange? _custom;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final range = _preset == RangePreset.custom && _custom != null ? _custom! : _preset.resolve(today);
    final report = ref.watch(_reportProvider((range, today)));
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xxxl),
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: Space.pageInsets,
              children: [
                for (final p in RangePreset.values)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.sm),
                    child: ChoiceChip(
                      label: Text(p == RangePreset.custom && _custom != null && _preset == p ? formatRange(_custom!) : p.label),
                      selected: _preset == p,
                      onSelected: (_) async {
                        if (p == RangePreset.custom) {
                          final picked = await pickRange(context, initial: _custom ?? range);
                          if (picked == null) return;
                          setState(() => _custom = picked);
                        }
                        setState(() => _preset = p);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
            child: Text(formatRange(range), style: Theme.of(context).textTheme.titleMedium),
          ),
          AsyncView(
            value: report,
            data: (r) => r.isEmpty
                ? EmptyState(
                    icon: Icons.insights_outlined,
                    title: 'Belum ada catatan pada periode ini',
                    message: 'Ringkasan dihitung dari catatan yang Anda simpan. Tidak ada angka yang dibuat-buat.',
                    actionLabel: 'Catat hari ini',
                    onAction: () => context.go('/today'),
                  )
                : _ReportView(report: r),
          ),
        ],
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report});
  final InsightsReport report;

  String _searchUri({String? category}) => Uri(
    path: '/search',
    queryParameters: {
      'start': report.range.start.key,
      'end': report.range.end.key,
      'category': ?category,
      'scope': 'activities',
    },
  ).toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = report.activities;
    final p = report.prayers;
    final reading = a.categories.where((c) => c.categoryId == 'cat-membaca').firstOrNull;
    final maxCount = a.categories.fold(0, (m, c) => c.count > m ? c.count : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
          child: Text(_narrative(report), style: theme.textTheme.bodyLarge),
        ),
        const SectionHeader(title: 'Dibanding periode sebelumnya'),
        Padding(
          padding: Space.pageInsets,
          child: Column(
            children: [
              MetricRow(label: 'Aktivitas selesai', value: describeChange(report.current.activitiesDone, report.previous.activitiesDone)),
              MetricRow(label: 'Kebiasaan selesai', value: describeChange(report.current.habitsDone, report.previous.habitsDone)),
              MetricRow(label: 'Salat dilaksanakan', value: describeChange(report.current.prayersPerformed, report.previous.prayersPerformed)),
              MetricRow(label: 'Hari dengan refleksi', value: describeChange(report.current.reflectionDays, report.previous.reflectionDays)),
            ],
          ),
        ),
        SectionHeader(
          title: 'Aktivitas',
          summary: '${a.total} dicatat',
          trailing: a.total == 0
              ? null
              : TextButton(onPressed: () => context.push(_searchUri()), child: const Text('Lihat')),
        ),
        if (a.total == 0)
          const NoDataLine('Tidak ada aktivitas pada periode ini.')
        else ...[
          Padding(
            padding: Space.pageInsets,
            child: Column(
              children: [
                MetricRow(
                  label: 'Status',
                  value: [for (final e in a.byStatus.entries) '${e.value} ${e.key.label.toLowerCase()}'].join(' · '),
                ),
                MetricRow(label: 'Total durasi tercatat', value: a.totalMinutes == 0 ? 'Tidak ada durasi' : formatDuration(a.totalMinutes)),
                if (a.averageMinutes != null)
                  MetricRow(label: 'Rata-rata durasi', value: '${formatDuration(a.averageMinutes!)} (dari ${a.timedCount} aktivitas berdurasi)'),
                if (reading != null && reading.minutes > 0)
                  MetricRow(label: 'Durasi membaca', value: formatDuration(reading.minutes)),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          for (final c in a.categories)
            CategoryBar(
              usage: c,
              fraction: maxCount == 0 ? 0 : c.count / maxCount,
              onTap: c.categoryId == null ? null : () => context.push(_searchUri(category: c.categoryId)),
            ),
        ],
        SectionHeader(title: 'Salat', summary: '${p.recorded} dicatat dari ${p.days * 5} waktu'),
        if (p.days == 0)
          const NoDataLine('Periode ini belum dimulai.')
        else ...[
          PrayerTable(insights: p),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
            child: Text(
              '"Belum dicatat" berarti tidak ada catatan, bukan terlewat. Angka ini menggambarkan apa yang '
              'Anda catat, bukan seluruh ibadah yang Anda lakukan.${p.jamaah > 0 ? ' ${p.jamaah} salat dicatat berjamaah.' : ''}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
        const SectionHeader(title: 'Kebiasaan'),
        if (report.habits.isEmpty)
          const NoDataLine('Tidak ada kebiasaan terjadwal atau tercatat pada periode ini.')
        else
          for (final h in report.habits) HabitInsightRow(insight: h, onTap: () => context.push('/habits/${h.habitId}')),
        const SectionHeader(title: 'Ibadah lainnya'),
        if (report.worship.isEmpty)
          const NoDataLine('Belum ada catatan ibadah tambahan pada periode ini.')
        else
          Padding(
            padding: Space.pageInsets,
            child: Column(
              children: [
                for (final w in report.worship)
                  MetricRow(
                    label: w.name,
                    value: [
                      '${w.doneDays} hari dilakukan',
                      if (w.totalValue > 0) 'total ${formatNumber(w.totalValue)} ${w.unit ?? ''}'.trim(),
                      if (w.notDoneDays > 0) '${w.notDoneDays} hari tidak',
                    ].join(' · '),
                  ),
              ],
            ),
          ),
        SectionHeader(title: 'Refleksi', summary: '${report.reflectionDates.length} hari'),
        if (report.reflectionDates.isEmpty)
          const NoDataLine('Belum ada refleksi pada periode ini.')
        else
          Padding(
            padding: Space.pageInsets,
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.xs,
              children: [
                for (final d in report.reflectionDates)
                  ActionChip(
                    label: Text(formatShortDate(d)),
                    tooltip: 'Buka refleksi ${formatDate(d)}',
                    onPressed: () => context.push('/reflection/${d.key}'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: Space.lg),
        const ExpansionTile(
          tilePadding: Space.pageInsets,
          childrenPadding: EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.lg),
          title: Text('Cara angka dihitung'),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [MetricDefinitions()],
        ),
      ],
    );
  }

  static String _narrative(InsightsReport r) {
    final parts = <String>[];
    final a = r.activities;
    if (a.total > 0) parts.add('mencatat ${a.total} aktivitas (${a.done} selesai)');
    final performed = r.prayers.count(PrayerStatus.done) + r.prayers.count(PrayerStatus.qadha);
    if (r.prayers.recorded > 0) parts.add('mencatat $performed salat dilaksanakan');
    final habitsDone = r.habits.fold(0, (s, h) => s + h.done);
    if (habitsDone > 0) parts.add('menyelesaikan kebiasaan $habitsDone kali');
    if (r.reflectionDates.isNotEmpty) parts.add('menulis refleksi pada ${r.reflectionDates.length} hari');
    final body = switch (parts.length) {
      0 => 'belum mencatat aktivitas, salat, kebiasaan, atau refleksi',
      1 => parts.first,
      _ => '${parts.sublist(0, parts.length - 1).join(', ')}, dan ${parts.last}',
    };
    return 'Dalam ${r.effectiveDays} hari yang sudah berjalan, Anda $body. '
        'Ada catatan pada ${r.daysWithRecords} hari.';
  }
}
