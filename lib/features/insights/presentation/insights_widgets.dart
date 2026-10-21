import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/status_mark.dart';
import '../../habits/domain/habit_enums.dart';
import '../../prayers/domain/prayer.dart';
import '../domain/insights.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: Text(label, style: theme.textTheme.bodySmall)),
            const SizedBox(width: Space.md),
            Expanded(flex: 3, child: Text(value, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

class NoDataLine extends StatelessWidget {
  const NoDataLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: Space.pageInsets,
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}

/// One category with a proportional bar. The number is always printed; the
/// bar only aids comparison.
class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key, required this.usage, required this.fraction, this.onTap});

  final CategoryUsage usage;
  final double fraction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = '${usage.count} aktivitas${usage.minutes > 0 ? ' · ${formatDuration(usage.minutes)}' : ''}';
    return Semantics(
      label: '${usage.name}: $detail',
      button: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(usage.name, style: theme.textTheme.bodyMedium)),
                  Text(detail, style: theme.textTheme.bodySmall?.tabular),
                ],
              ),
              const SizedBox(height: Space.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(value: fraction, minHeight: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerTable extends StatelessWidget {
  const PrayerTable({super.key, required this.insights});
  final PrayerInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.tabular;
    final head = theme.textTheme.labelSmall;
    const columns = [PrayerStatus.done, PrayerStatus.qadha, PrayerStatus.missed, PrayerStatus.excused];
    Widget cell(String text, {TextStyle? s, String? semantics}) => Semantics(
      label: semantics,
      excludeSemantics: semantics != null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(text, textAlign: TextAlign.center, style: s ?? style),
      ),
    );
    // Rows are statuses and columns are prayers, so long status labels get
    // a full-width column instead of wrapping in narrow headers.
    Widget statusLabel(Mark mark, String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          StatusMark(mark, size: 16),
          const SizedBox(width: Space.sm),
          Flexible(child: Text(label, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
    return Padding(
      padding: Space.pageInsets,
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2.2)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              for (final p in Prayer.values) cell(p.label, s: head),
            ],
          ),
          for (final s in columns)
            TableRow(
              children: [
                statusLabel(Mark.prayer(s), s.label),
                for (final p in Prayer.values)
                  cell(
                    '${insights.byPrayer[p]?[s] ?? 0}',
                    semantics: '${p.label} ${s.label}: ${insights.byPrayer[p]?[s] ?? 0}',
                  ),
              ],
            ),
          TableRow(
            children: [
              statusLabel(Mark.unrecorded, notRecordedLabel),
              for (final p in Prayer.values)
                cell(
                  '${insights.unrecordedByPrayer[p] ?? 0}',
                  semantics: '${p.label} belum dicatat: ${insights.unrecordedByPrayer[p] ?? 0}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class HabitInsightRow extends StatelessWidget {
  const HabitInsightRow({super.key, required this.insight, required this.onTap});
  final HabitInsight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = insight;
    final parts = <String>[
      if (h.scheduledDays > 0) 'Selesai ${h.done} dari ${h.scheduledDays} hari terjadwal' else 'Selesai ${h.done} kali',
      if ((h.byStatus[HabitStatus.partial] ?? 0) > 0) '${h.byStatus[HabitStatus.partial]} sebagian',
      if ((h.byStatus[HabitStatus.skipped] ?? 0) > 0) '${h.byStatus[HabitStatus.skipped]} dilewati',
      if ((h.byStatus[HabitStatus.notDone] ?? 0) > 0) '${h.byStatus[HabitStatus.notDone]} tidak dilakukan',
      if (h.unrecordedScheduled > 0) '${h.unrecordedScheduled} belum dicatat',
      if (h.totalValue > 0) 'total ${formatNumber(h.totalValue)} ${h.unit ?? ''}'.trim(),
    ];
    return ListTile(
      title: Text(h.archived ? '${h.name} (diarsipkan)' : h.name),
      subtitle: Text(parts.join(' · ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class MetricDefinitions extends StatelessWidget {
  const MetricDefinitions({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    const items = [
      'Semua angka dihitung dari catatan yang tersimpan di perangkat ini.',
      'Hari yang belum tiba tidak dihitung sebagai "belum dicatat".',
      'Salat "Belum dicatat" berarti tidak ada catatan. Ini tidak pernah dihitung sebagai terlewat.',
      'Kebiasaan hanya dihitung pada hari yang dijadwalkan. Hari tanpa jadwal bukan kegagalan.',
      'Durasi dijumlahkan dari aktivitas berstatus selesai atau sebagian yang memiliki durasi.',
      'Rata-rata durasi hanya ditampilkan jika ada minimal 3 aktivitas berdurasi.',
      'Perbandingan memakai periode dengan panjang yang sama tepat sebelum periode ini. Perbedaan angka tidak '
          'menjelaskan penyebabnya.',
      'Tidak ada skor gabungan: salat, kebiasaan, dan aktivitas tidak digabung menjadi satu nilai.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in items)
          Padding(padding: const EdgeInsets.only(bottom: Space.sm), child: Text('• $t', style: style)),
      ],
    );
  }
}
