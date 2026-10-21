import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_mark.dart';
import '../../today/presentation/day_providers.dart';

class ActivityRows extends ConsumerWidget {
  const ActivityRows({super.key, required this.date, required this.onAdd});

  final LocalDate date;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.id: c};
    return AsyncView(
      value: ref.watch(dayActivitiesProvider(date)),
      data: (activities) {
        if (activities.isEmpty) {
          return EmptyState(
            compact: true,
            icon: Icons.event_note_outlined,
            title: 'Belum ada aktivitas pada tanggal ini',
            message: 'Catat apa yang Anda lakukan, sesingkat apa pun. Tidak perlu mencatat setiap menit.',
            actionLabel: 'Tambah aktivitas',
            onAction: onAdd,
          );
        }
        return Column(
          children: [
            for (final a in activities)
              ActivityRow(key: ValueKey('activity-${a.id}'), activity: a, categoryName: categories[a.categoryId]?.name),
          ],
        );
      },
    );
  }
}

/// One activity: time column, title, category and status.
class ActivityRow extends ConsumerWidget {
  const ActivityRow({super.key, required this.activity, this.categoryName});

  final Activity activity;
  final String? categoryName;

  String get _time {
    final s = activity.startMinute;
    final e = activity.endMinute;
    if (s != null && e != null) return '${MinuteOfDay.format(s)}–${MinuteOfDay.format(e)}${activity.endsNextDay ? ' (+1)' : ''}';
    if (s != null) return MinuteOfDay.format(s);
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mark = Mark.activity(activity.status);
    final duration = activity.durationMinutes;
    final meta = [
      ?categoryName,
      if (duration != null) formatDuration(duration),
      activity.status.label,
    ].join(' · ');
    return Semantics(
      button: true,
      label: '${activity.title}. ${_time.isEmpty ? '' : 'Pukul $_time. '}$meta',
      hint: 'Ketuk untuk mengubah',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push('/activity/${activity.id}'),
        onLongPress: () => _showActions(context, ref),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.sm, Space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  _time.isEmpty ? '—' : _time.split('–').first,
                  style: theme.textTheme.bodySmall?.tabular,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StatusMark(mark, size: 14),
                        const SizedBox(width: Space.xs),
                        Expanded(child: Text(meta, style: theme.textTheme.bodySmall)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Pilihan untuk ${activity.title}',
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showActions(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Ubah'), onTap: () => Navigator.pop(context, 'edit')),
            ListTile(leading: const Icon(Icons.copy_outlined), title: const Text('Duplikat ke tanggal yang sama'), onTap: () => Navigator.pop(context, 'dup')),
            ListTile(leading: const Icon(Icons.event_repeat_outlined), title: const Text('Duplikat ke hari ini'), onTap: () => Navigator.pop(context, 'dup-today')),
            ListTile(leading: const Icon(Icons.delete_outline), title: const Text('Hapus'), onTap: () => Navigator.pop(context, 'delete')),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final repo = ref.read(activityRepositoryProvider);
    switch (action) {
      case 'edit':
        await context.push('/activity/${activity.id}');
      case 'dup':
        await runGuarded(context, () => repo.duplicate(activity.id), success: 'Aktivitas diduplikat.');
      case 'dup-today':
        await runGuarded(context, () => repo.duplicate(activity.id, toDate: ref.read(todayProvider)), success: 'Aktivitas diduplikat ke hari ini.');
      case 'delete':
        final ok = await runGuarded(context, () => repo.delete(activity.id));
        if (ok && context.mounted) {
          showUndo(context, 'Aktivitas dihapus.', () => repo.restore(activity));
        }
    }
  }
}
