import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../data/habit_repository.dart';
import '../domain/habit_enums.dart';
import '../domain/recurrence.dart';

final activeHabitsProvider = StreamProvider.autoDispose<List<HabitDefinition>>(
  (ref) => ref.watch(habitRepositoryProvider).watchDefinitions(archived: false),
);
final archivedHabitsProvider = StreamProvider.autoDispose<List<HabitDefinition>>(
  (ref) => ref.watch(habitRepositoryProvider).watchDefinitions(archived: true),
);

String habitSummary(HabitDefinition d) {
  final rule = d.currentRule;
  final unit = d.habit.targetUnit ?? '';
  return [
    describeRule(rule),
    if (rule.targetValue != null) 'Target ${formatNumber(rule.targetValue!)} $unit'.trim(),
    if (d.habit.trackingType != HabitTrackingType.check && rule.targetValue == null) d.habit.trackingType.label,
  ].join(' · ');
}

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kebiasaan'),
          bottom: const TabBar(tabs: [Tab(text: 'Aktif'), Tab(text: 'Diarsipkan')]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/habits/new'),
          icon: const Icon(Icons.add),
          label: const Text('Kebiasaan baru'),
        ),
        body: TabBarView(
          children: [
            AsyncView(
              value: ref.watch(activeHabitsProvider),
              data: (habits) => habits.isEmpty
                  ? EmptyState(
                      icon: Icons.repeat,
                      title: 'Belum ada kebiasaan',
                      message: 'Buat kebiasaan untuk hal yang ingin Anda lakukan secara rutin. '
                          'Hari yang tidak dijadwalkan tidak dihitung sebagai kegagalan.',
                      actionLabel: 'Buat kebiasaan',
                      onAction: () => context.push('/habits/new'),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 96),
                      header: Padding(
                        padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, Space.sm),
                        child: Text('Tahan dan geser untuk mengubah urutan.', style: Theme.of(context).textTheme.bodySmall),
                      ),
                      itemCount: habits.length,
                      onReorderItem: (from, to) {
                        final ids = habits.map((h) => h.habit.id).toList();
                        final id = ids.removeAt(from);
                        ids.insert(to, id);
                        runGuarded(context, () => ref.read(habitRepositoryProvider).reorder(ids));
                      },
                      itemBuilder: (context, i) {
                        final d = habits[i];
                        return ListTile(
                          key: ValueKey(d.habit.id),
                          title: Text(d.habit.name),
                          subtitle: Text(habitSummary(d)),
                          onTap: () => context.push('/habits/${d.habit.id}'),
                        );
                      },
                    ),
            ),
            AsyncView(
              value: ref.watch(archivedHabitsProvider),
              data: (habits) => habits.isEmpty
                  ? const EmptyState(
                      icon: Icons.archive_outlined,
                      title: 'Tidak ada kebiasaan yang diarsipkan',
                      message: 'Kebiasaan yang diarsipkan berhenti muncul di halaman Hari ini, tetapi riwayatnya tetap tersimpan.',
                    )
                  : ListView(
                      children: [
                        for (final d in habits)
                          ListTile(
                            key: ValueKey(d.habit.id),
                            title: Text(d.habit.name),
                            subtitle: Text(habitSummary(d)),
                            onTap: () => context.push('/habits/${d.habit.id}'),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
