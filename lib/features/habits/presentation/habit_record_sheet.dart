import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/status_mark.dart';
import '../data/habit_repository.dart';
import '../domain/habit_draft.dart';
import '../domain/habit_enums.dart';

Future<void> showHabitRecordSheet(BuildContext context, {required HabitForDay item}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => HabitRecordSheet(item: item),
);

/// Records a habit for one date: status, measured value and note.
class HabitRecordSheet extends ConsumerStatefulWidget {
  const HabitRecordSheet({super.key, required this.item});

  final HabitForDay item;

  @override
  ConsumerState<HabitRecordSheet> createState() => _HabitRecordSheetState();
}

class _HabitRecordSheetState extends ConsumerState<HabitRecordSheet> {
  late HabitStatus? _status = widget.item.record?.status;
  late final _value = TextEditingController(
    text: widget.item.record?.value == null ? '' : formatNumber(widget.item.record!.value!),
  );
  late final _note = TextEditingController(text: widget.item.record?.note ?? '');
  bool _statusTouched = false;
  bool _saving = false;
  String? _valueError;

  bool get _measured => widget.item.habit.trackingType != HabitTrackingType.check;

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  double? _parsedValue() {
    final text = _value.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _onValueChanged(String _) {
    final v = _parsedValue();
    setState(() {
      _valueError = _value.text.trim().isNotEmpty && v == null ? 'Masukkan angka.' : null;
      // Suggest a status from the value until the user picks one.
      if (!_statusTouched && v != null) _status = statusForValue(v, widget.item.target);
    });
  }

  Future<void> _save() async {
    final status = _status;
    if (status == null || _saving) return;
    if (_valueError != null) return;
    setState(() => _saving = true);
    final ok = await runGuarded(
      context,
      () => ref.read(habitRepositoryProvider).setRecord(
        habitId: widget.item.habit.id,
        date: widget.item.date,
        status: status,
        value: _measured ? _parsedValue() : null,
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
    final repo = ref.read(habitRepositoryProvider);
    final previous = widget.item.record;
    final ok = await runGuarded(context, () => repo.clearRecord(widget.item.habit.id, widget.item.date));
    if (!mounted || !ok) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    showUndoWith(
      messenger,
      '${widget.item.habit.name} kembali ke "Belum dicatat".',
      () => repo.restoreRecord(widget.item.habit.id, widget.item.date, previous),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = widget.item.habit;
    final target = widget.item.target;
    final statuses = [
      HabitStatus.done,
      if (_measured) HabitStatus.partial,
      HabitStatus.skipped,
      HabitStatus.notDone,
    ];
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
                  Text(habit.name, style: theme.textTheme.titleLarge),
                  Text(
                    [
                      formatLongDate(widget.item.date),
                      if (target != null) 'Target ${formatNumber(target)} ${habit.targetUnit ?? ''}'.trim(),
                    ].join(' · '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (_measured)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
                child: TextField(
                  controller: _value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: InputDecoration(
                    labelText: habit.trackingType == HabitTrackingType.duration
                        ? 'Durasi (menit)'
                        : 'Jumlah${habit.targetUnit == null ? '' : ' (${habit.targetUnit})'}',
                    errorText: _valueError,
                    helperText: 'Status disarankan dari jumlah ini. Anda tetap dapat memilihnya sendiri.',
                  ),
                  onChanged: _onValueChanged,
                ),
              ),
            const SizedBox(height: Space.sm),
            RadioGroup<HabitStatus>(
              groupValue: _status,
              onChanged: (v) => setState(() {
                _status = v;
                _statusTouched = true;
              }),
              child: Column(
                children: [
                  for (final s in statuses)
                    RadioListTile<HabitStatus>(
                      value: s,
                      title: Row(
                        children: [
                          StatusMark(Mark.habit(s), size: 20),
                          const SizedBox(width: Space.sm),
                          Text(s.label),
                        ],
                      ),
                      subtitle: s == HabitStatus.skipped
                          ? const Text('Sengaja tidak dilakukan, misalnya karena sakit atau bepergian.')
                          : null,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
              child: TextField(
                controller: _note,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: Space.lg),
            Padding(
              padding: Space.pageInsets,
              child: Row(
                children: [
                  if (widget.item.record != null)
                    TextButton(onPressed: _saving ? null : _clear, child: const Text('Hapus catatan'))
                  else
                    TextButton(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
                        router.push('/habits/${habit.id}');
                      },
                      child: const Text('Lihat kebiasaan'),
                    ),
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
