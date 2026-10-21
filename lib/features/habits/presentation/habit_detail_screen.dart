import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_mark.dart';
import '../data/habit_repository.dart';
import '../domain/streak.dart';
import 'habits_screen.dart';

final _definitionProvider = StreamProvider.autoDispose.family<HabitDefinition?, String>(
  (ref, id) => ref
      .watch(habitRepositoryProvider)
      .watchDefinitions()
      .map((all) => all.where((d) => d.habit.id == id).firstOrNull),
);

final _recordsProvider = StreamProvider.autoDispose.family<List<HabitRecord>, String>(
  (ref, id) => ref.watch(habitRepositoryProvider).watchRecords(id, limit: 90),
);

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});
  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = ref.watch(_definitionProvider(habitId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail kebiasaan'),
        actions: [
          if (def.value != null) ...[
            IconButton(
              tooltip: 'Ubah',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/habits/$habitId/edit'),
            ),
            PopupMenuButton<String>(
              tooltip: 'Pilihan lain',
              onSelected: (v) => _onAction(context, ref, v, def.value!),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'archive', child: Text(def.value!.habit.archived ? 'Aktifkan kembali' : 'Arsipkan')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus permanen')),
              ],
            ),
          ],
        ],
      ),
      body: AsyncView(
        value: def,
        data: (d) => d == null
            ? const EmptyState(icon: Icons.search_off, title: 'Kebiasaan tidak ditemukan', message: 'Kebiasaan ini mungkin sudah dihapus.')
            : _Body(definition: d),
      ),
    );
  }

  Future<void> _onAction(BuildContext context, WidgetRef ref, String action, HabitDefinition d) async {
    final repo = ref.read(habitRepositoryProvider);
    if (action == 'archive') {
      final archive = !d.habit.archived;
      final ok = await runGuarded(
        context,
        () => repo.setArchived(habitId, archive),
        success: archive
            ? 'Kebiasaan diarsipkan. Riwayatnya tetap tersimpan.'
            : 'Kebiasaan aktif kembali.',
      );
      if (ok) await ref.read(reminderSyncProvider)().catchError((_) => 0);
      return;
    }
    final count = await repo.recordCount(habitId);
    if (!context.mounted) return;
    final confirmed = await confirmAction(
      context,
      title: 'Hapus kebiasaan permanen?',
      message: count == 0
          ? '"${d.habit.name}" akan dihapus. Belum ada catatan untuk kebiasaan ini.'
          : '"${d.habit.name}" beserta $count catatannya akan dihapus permanen dan tidak dapat dikembalikan. '
                'Jika Anda hanya ingin berhenti melacaknya, pilih Arsipkan agar riwayat tetap tersimpan.',
      confirmLabel: 'Hapus permanen',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await runGuarded(context, () => repo.deletePermanently(habitId), success: 'Kebiasaan dihapus.');
    if (ok) {
      await ref.read(reminderSyncProvider)().catchError((_) => 0);
      if (context.mounted) context.pop();
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.definition});
  final HabitDefinition definition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habit = definition.habit;
    final today = ref.watch(todayProvider);
    final showStreaks = ref.watch(prefsProvider.select((p) => p.showStreaks));
    final records = ref.watch(_recordsProvider(habit.id));
    return ListView(
      padding: const EdgeInsets.only(bottom: Space.xxxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (habit.color != null) ...[HabitColorDot(colorId: habit.color, size: 14), const SizedBox(width: Space.sm)],
                  Expanded(child: Text(habit.name, style: theme.textTheme.headlineSmall)),
                ],
              ),
              if (habit.description != null) ...[
                const SizedBox(height: Space.xs),
                Text(habit.description!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: Space.md),
              Text(habitSummary(definition), style: theme.textTheme.bodyMedium),
              Text(
                [
                  'Mulai ${formatDate(LocalDate.parse(habit.startDate))}',
                  if (habit.endDate != null) 'berakhir ${formatDate(LocalDate.parse(habit.endDate!))}',
                  if (habit.reminderMinute != null) 'pengingat ${MinuteOfDay.format(habit.reminderMinute!)}',
                  if (habit.archived) 'diarsipkan',
                ].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (showStreaks)
          FutureBuilder(
            future: ref.read(habitRepositoryProvider).statusHistory(habit.id),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final streak = currentStreak(plan: definition.plan, records: snap.data!, today: today);
              return Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rangkaian saat ini: $streak hari terjadwal', style: theme.textTheme.titleSmall),
                    Text(
                      'Dihitung dari hari terjadwal berturut-turut yang tercatat "Selesai". Hari yang tidak '
                      'dijadwalkan dan catatan "Dilewati" diabaikan. Hari ini tidak memutus rangkaian selama '
                      'belum dicatat. Hari lampau tanpa catatan mengakhiri rangkaian.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        if (definition.schedules.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
            child: Text(
              'Jadwal pernah diubah ${definition.schedules.length - 1} kali. Tanggal sebelum perubahan tetap memakai jadwal lamanya.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SectionHeader(title: 'Catatan terakhir'),
        AsyncView(
          value: records,
          data: (rows) => rows.isEmpty
              ? const EmptyState(
                  compact: true,
                  icon: Icons.history,
                  title: 'Belum ada catatan',
                  message: 'Catat kebiasaan ini dari halaman Hari ini atau dari tanggal di Riwayat.',
                )
              : Column(
                  children: [
                    for (final r in rows)
                      ListTile(
                        key: ValueKey(r.id),
                        leading: StatusMark(Mark.habit(r.status)),
                        title: Text(formatLongDate(LocalDate.parse(r.dateKey))),
                        subtitle: Text(
                          [
                            r.status.label,
                            if (r.value != null)
                              '${formatNumber(r.value!)}${r.targetSnapshot != null ? ' dari ${formatNumber(r.targetSnapshot!)}' : ''} ${habit.targetUnit ?? ''}'.trim(),
                            ?r.note,
                          ].join(' · '),
                        ),
                        onTap: () => context.push('/day/${r.dateKey}'),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
