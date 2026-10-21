import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_mark.dart';
import '../../../core/widgets/track_row.dart';
import '../../prayers/domain/prayer.dart';
import '../../today/presentation/day_providers.dart';
import '../data/habit_repository.dart';
import '../domain/habit_enums.dart';
import 'habit_record_sheet.dart';

class HabitRows extends ConsumerWidget {
  const HabitRows({super.key, required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(dayHabitsProvider(date));
    return AsyncView(
      value: value,
      data: (habits) {
        if (habits.isEmpty) {
          return EmptyState(
            compact: true,
            icon: Icons.repeat,
            title: 'Tidak ada kebiasaan terjadwal',
            message: 'Kebiasaan yang Anda buat akan muncul pada hari yang dijadwalkan.',
            actionLabel: 'Kelola kebiasaan',
            onAction: () => context.push('/habits'),
          );
        }
        return Column(
          children: [for (final h in habits) _HabitRow(key: ValueKey('habit-${h.habit.id}'), item: h)],
        );
      },
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({super.key, required this.item});

  final HabitForDay item;

  String? _subtitle() {
    final habit = item.habit;
    final record = item.record;
    final target = item.target;
    final unit = habit.targetUnit ?? '';
    final parts = <String>[
      if (habit.trackingType != HabitTrackingType.check)
        if (record?.value != null)
          target != null
              ? '${formatNumber(record!.value!)} dari ${formatNumber(target)} $unit'.trim()
              : '${formatNumber(record!.value!)} $unit'.trim()
        else if (target != null)
          'Target ${formatNumber(target)} $unit'.trim(),
      if (!item.scheduled) 'Tidak terjadwal hari ini',
      if (habit.archived) 'Diarsipkan',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item.record?.status;
    final isCheck = item.habit.trackingType == HabitTrackingType.check;
    return TrackRow(
      mark: Mark.habit(status),
      title: item.habit.name,
      subtitle: _subtitle(),
      statusLabel: status?.label ?? notRecordedLabel,
      onTap: () => showHabitRecordSheet(context, item: item),
      trailing: isCheck && (status == null || status == HabitStatus.done)
          ? QuickCheckButton(
              checked: status == HabitStatus.done,
              label: status == null ? 'Tandai ${item.habit.name} selesai' : 'Batalkan catatan ${item.habit.name}',
              onPressed: () => _toggle(context, ref),
            )
          : null,
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(habitRepositoryProvider);
    final previous = item.record;
    final ok = await runGuarded(context, () async {
      if (previous == null) {
        await repo.setRecord(habitId: item.habit.id, date: item.date, status: HabitStatus.done);
      } else {
        await repo.clearRecord(item.habit.id, item.date);
      }
    });
    if (ok && context.mounted) {
      showUndo(
        context,
        previous == null ? '${item.habit.name} ditandai selesai.' : 'Catatan ${item.habit.name} dihapus.',
        () => repo.restoreRecord(item.habit.id, item.date, previous),
      );
    }
  }
}
