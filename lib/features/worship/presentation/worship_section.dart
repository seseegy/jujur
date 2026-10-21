import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/status_mark.dart';
import '../../../core/widgets/track_row.dart';
import '../../prayers/domain/prayer.dart';
import '../../today/presentation/day_providers.dart';
import '../data/worship_repository.dart';
import '../domain/worship_enums.dart';

class WorshipRows extends ConsumerWidget {
  const WorshipRows({super.key, required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(dayWorshipProvider(date)),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            compact: true,
            icon: Icons.auto_awesome_outlined,
            title: 'Belum ada ibadah yang ditampilkan',
            message: 'Pilih ibadah tambahan yang ingin Anda catat. Semuanya opsional.',
            actionLabel: 'Pilih ibadah',
            onAction: () => context.push('/settings/worship'),
          );
        }
        return Column(
          children: [for (final w in items) _WorshipRow(key: ValueKey('worship-${w.item.id}'), entry: w, date: date)],
        );
      },
    );
  }
}

class _WorshipRow extends ConsumerWidget {
  const _WorshipRow({super.key, required this.entry, required this.date});

  final WorshipForDay entry;
  final LocalDate date;

  String? _subtitle() {
    final r = entry.record;
    if (r == null) return null;
    final unit = entry.item.unit ?? '';
    return [
      if (r.value != null) '${formatNumber(r.value!)} $unit'.trim(),
      if (r.note != null) r.note!,
    ].join(' · ').ifEmpty();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = entry.record?.status;
    final isCheck = entry.item.trackingType == WorshipTrackingType.check;
    return TrackRow(
      mark: Mark.worship(status),
      title: entry.item.name,
      subtitle: _subtitle(),
      statusLabel: status?.label ?? notRecordedLabel,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => WorshipRecordSheet(entry: entry, date: date),
      ),
      trailing: isCheck && (status == null || status == WorshipStatus.done)
          ? QuickCheckButton(
              checked: status == WorshipStatus.done,
              label: status == null ? 'Tandai ${entry.item.name} dilakukan' : 'Batalkan catatan ${entry.item.name}',
              onPressed: () async {
                final repo = ref.read(worshipRepositoryProvider);
                final previous = entry.record;
                final ok = await runGuarded(context, () async {
                  if (previous == null) {
                    await repo.setRecord(item: entry.item, date: date, status: WorshipStatus.done);
                  } else {
                    await repo.clearRecord(entry.item.id, date);
                  }
                });
                if (ok && context.mounted) {
                  showUndo(
                    context,
                    previous == null ? '${entry.item.name} dicatat.' : 'Catatan ${entry.item.name} dihapus.',
                    () => repo.restoreRecord(entry.item.id, date, previous),
                  );
                }
              },
            )
          : null,
    );
  }
}

extension on String {
  String? ifEmpty() => isEmpty ? null : this;
}

class WorshipRecordSheet extends ConsumerStatefulWidget {
  const WorshipRecordSheet({super.key, required this.entry, required this.date});

  final WorshipForDay entry;
  final LocalDate date;

  @override
  ConsumerState<WorshipRecordSheet> createState() => _WorshipRecordSheetState();
}

class _WorshipRecordSheetState extends ConsumerState<WorshipRecordSheet> {
  late WorshipStatus? _status = widget.entry.record?.status;
  late final _value = TextEditingController(
    text: widget.entry.record?.value == null ? '' : formatNumber(widget.entry.record!.value!),
  );
  late final _note = TextEditingController(text: widget.entry.record?.note ?? '');
  bool _saving = false;

  WorshipTrackingType get _type => widget.entry.item.trackingType;
  bool get _hasValue => _type == WorshipTrackingType.count || _type == WorshipTrackingType.duration;

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final status = _status;
    if (status == null || _saving) return;
    setState(() => _saving = true);
    final ok = await runGuarded(
      context,
      () => ref.read(worshipRepositoryProvider).setRecord(
        item: widget.entry.item,
        date: widget.date,
        status: status,
        value: double.tryParse(_value.text.trim().replaceAll(',', '.')),
        note: _note.text,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      showMessageWith(messenger, 'Catatan tersimpan.');
    }
  }

  Future<void> _clear() async {
    final repo = ref.read(worshipRepositoryProvider);
    final previous = widget.entry.record;
    final ok = await runGuarded(context, () => repo.clearRecord(widget.entry.item.id, widget.date));
    if (!mounted || !ok) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    showUndoWith(messenger, 'Kembali ke "Belum dicatat".', () => repo.restoreRecord(widget.entry.item.id, widget.date, previous));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.entry.item;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: Space.pageInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleLarge),
                  Text(formatLongDate(widget.date), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            RadioGroup<WorshipStatus>(
              groupValue: _status,
              onChanged: (v) => setState(() => _status = v),
              child: Column(
                children: [
                  for (final s in WorshipStatus.values)
                    RadioListTile<WorshipStatus>(
                      value: s,
                      title: Row(
                        children: [
                          StatusMark(Mark.worship(s), size: 20),
                          const SizedBox(width: Space.sm),
                          Text(s.label),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_hasValue && _status == WorshipStatus.done)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
                child: TextField(
                  controller: _value,
                  keyboardType: TextInputType.numberWithOptions(decimal: _type == WorshipTrackingType.duration),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: InputDecoration(labelText: _type == WorshipTrackingType.duration ? 'Durasi (menit)' : 'Jumlah (${item.unit ?? 'kali'})'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
              child: TextField(
                controller: _note,
                decoration: InputDecoration(
                  labelText: _type == WorshipTrackingType.note ? 'Catatan' : 'Catatan (opsional)',
                ),
                minLines: _type == WorshipTrackingType.note ? 3 : 1,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: Space.lg),
            Padding(
              padding: Space.pageInsets,
              child: Row(
                children: [
                  if (widget.entry.record != null)
                    TextButton(onPressed: _saving ? null : _clear, child: const Text('Hapus catatan')),
                  const Spacer(),
                  FilledButton(onPressed: _status == null || _saving ? null : _save, child: const Text('Simpan')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
