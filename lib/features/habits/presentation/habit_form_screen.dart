import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/states.dart';
import '../../today/presentation/day_providers.dart';
import '../domain/habit_draft.dart';
import '../domain/habit_enums.dart';
import '../domain/recurrence.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});
  final String? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _unit = TextEditingController();
  final _target = TextEditingController();
  final _interval = TextEditingController(text: '2');
  HabitTrackingType _type = HabitTrackingType.check;
  RecurrenceType _recurrence = RecurrenceType.daily;
  int _mask = WeekdayMask.all;
  late LocalDate _start = ref.read(todayProvider);
  LocalDate? _end;
  String? _categoryId;
  int? _reminder;
  bool _loading = false;
  bool _saving = false;
  bool _hasRecords = false;
  ValidationFailure? _error;

  bool get _editing => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(habitRepositoryProvider);
    final def = await repo.findDefinition(widget.habitId!);
    final count = await repo.recordCount(widget.habitId!);
    if (!mounted || def == null) {
      setState(() => _loading = false);
      return;
    }
    final h = def.habit;
    final rule = def.plan.ruleFor(ref.read(todayProvider));
    _name.text = h.name;
    _description.text = h.description ?? '';
    _unit.text = h.targetUnit ?? '';
    _target.text = rule.targetValue == null ? '' : formatNumber(rule.targetValue!);
    _interval.text = '${rule.intervalDays ?? 2}';
    setState(() {
      _type = h.trackingType;
      _recurrence = rule.recurrence;
      _mask = rule.recurrence == RecurrenceType.weekdays ? rule.weekdaysMask : WeekdayMask.all;
      _start = LocalDate.parse(h.startDate);
      _end = LocalDate.tryParse(h.endDate);
      _categoryId = h.categoryId;
      _reminder = h.reminderMinute;
      _hasRecords = count > 0;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _unit, _target, _interval]) {
      c.dispose();
    }
    super.dispose();
  }

  HabitDraft _draft() => HabitDraft(
    name: _name.text,
    description: _description.text,
    categoryId: _categoryId,
    trackingType: _type,
    targetUnit: _unit.text,
    startDate: _start,
    endDate: _recurrence == RecurrenceType.once ? null : _end,
    recurrence: _recurrence,
    weekdaysMask: _mask,
    intervalDays: int.tryParse(_interval.text),
    targetValue: _type == HabitTrackingType.check ? null : double.tryParse(_target.text.replaceAll(',', '.')),
    reminderMinute: _reminder,
  );

  Future<void> _save() async {
    if (_saving) return;
    final draft = _draft();
    try {
      draft.validate();
    } on ValidationFailure catch (e) {
      setState(() => _error = e);
      return;
    }
    if (_reminder != null) {
      final allowed = await ref.read(notificationServiceProvider).requestPermission();
      if (!allowed && mounted) {
        showMessage(context, 'Izin notifikasi ditolak. Kebiasaan tetap disimpan tanpa pengingat yang dapat tampil.');
      }
    }
    if (!mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(habitRepositoryProvider);
    final ok = await runGuarded(context, () async {
      if (_editing) {
        await repo.update(widget.habitId!, draft, today: ref.read(todayProvider));
      } else {
        await repo.create(draft);
      }
    });
    if (ok) {
      try {
        await ref.read(reminderSyncProvider)();
      } on Object catch (e) {
        if (mounted) showMessage(context, 'Kebiasaan tersimpan, tetapi pengingat gagal dijadwalkan.');
        logError('habit reminders', e);
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showMessage(context, 'Kebiasaan tersimpan.');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = (ref.watch(categoriesProvider).value ?? const []).where((c) => !c.archived || c.id == _categoryId);
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Ubah kebiasaan' : 'Kebiasaan baru')),
      body: _loading
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xxxl),
              children: [
                if (_editing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.lg),
                    child: Text(
                      'Perubahan jadwal dan target berlaku mulai hari ini. Catatan dan jadwal pada tanggal '
                      'sebelumnya tidak berubah.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                TextField(
                  controller: _name,
                  autofocus: !_editing,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Nama kebiasaan',
                    hintText: 'Misalnya: Membaca 15 menit',
                    errorText: _error?.field == 'name' ? _error!.message : null,
                  ),
                ),
                TextField(
                  controller: _description,
                  minLines: 1,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                ),
                const SizedBox(height: Space.lg),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Kategori (opsional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tanpa kategori')),
                    for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: Space.xl),
                Text('Cara mencatat', style: theme.textTheme.titleSmall),
                if (_hasRecords)
                  Text('Tidak dapat diubah karena sudah ada catatan.', style: theme.textTheme.bodySmall),
                const SizedBox(height: Space.sm),
                SegmentedButton<HabitTrackingType>(
                  segments: [
                    for (final t in HabitTrackingType.values)
                      ButtonSegment(value: t, label: Text(t == HabitTrackingType.duration ? 'Durasi' : t.label)),
                  ],
                  selected: {_type},
                  onSelectionChanged: _hasRecords ? null : (s) => setState(() => _type = s.first),
                ),
                if (_type != HabitTrackingType.check) ...[
                  const SizedBox(height: Space.lg),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _target,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                          decoration: InputDecoration(
                            labelText: 'Target harian (opsional)',
                            errorText: _error?.field == 'target' ? _error!.message : null,
                          ),
                        ),
                      ),
                      if (_type == HabitTrackingType.quantity) ...[
                        const SizedBox(width: Space.md),
                        Expanded(
                          child: TextField(
                            controller: _unit,
                            decoration: const InputDecoration(labelText: 'Satuan', hintText: 'halaman'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: Space.xl),
                Text('Jadwal', style: theme.textTheme.titleSmall),
                const SizedBox(height: Space.sm),
                DropdownButtonFormField<RecurrenceType>(
                  isExpanded: true,
                  initialValue: _recurrence,
                  decoration: const InputDecoration(labelText: 'Pengulangan'),
                  items: [for (final r in RecurrenceType.values) DropdownMenuItem(value: r, child: Text(r.label))],
                  onChanged: (v) => setState(() => _recurrence = v ?? _recurrence),
                ),
                if (_recurrence == RecurrenceType.weekdays) ...[
                  const SizedBox(height: Space.md),
                  Wrap(
                    spacing: Space.sm,
                    runSpacing: Space.sm,
                    children: [
                      for (var d = 1; d <= 7; d++)
                        FilterChip(
                          label: Text(shortWeekdayNames[d - 1]),
                          tooltip: weekdayNames[d - 1],
                          selected: WeekdayMask.contains(_mask, d),
                          onSelected: (s) => setState(() => _mask = s ? _mask | (1 << (d - 1)) : _mask & ~(1 << (d - 1))),
                        ),
                    ],
                  ),
                ],
                if (_recurrence == RecurrenceType.interval) ...[
                  const SizedBox(height: Space.md),
                  TextField(
                    controller: _interval,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Setiap berapa hari', helperText: 'Dihitung dari tanggal mulai.'),
                  ),
                ],
                if (_error?.field == 'recurrence')
                  Padding(
                    padding: const EdgeInsets.only(top: Space.sm),
                    child: Text(_error!.message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                  ),
                const SizedBox(height: Space.lg),
                _DateRow(
                  label: _recurrence == RecurrenceType.once ? 'Tanggal' : 'Mulai',
                  value: _start,
                  onPick: (d) => setState(() => _start = d),
                ),
                if (_recurrence != RecurrenceType.once)
                  _DateRow(
                    label: 'Berakhir (opsional)',
                    value: _end,
                    error: _error?.field == 'endDate' ? _error!.message : null,
                    onPick: (d) => setState(() => _end = d),
                    onClear: () => setState(() => _end = null),
                  ),
                const SizedBox(height: Space.xl),
                Text('Pengingat (opsional)', style: theme.textTheme.titleSmall),
                const SizedBox(height: Space.sm),
                TimeField(label: 'Waktu pengingat', value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
                Padding(
                  padding: const EdgeInsets.only(top: Space.xs),
                  child: Text(
                    _reminder == null
                        ? 'Tanpa pengingat.'
                        : 'Pengingat pada ${MinuteOfDay.format(_reminder!)} di hari terjadwal. Android dapat '
                              'mengirimkannya beberapa menit lebih lambat. Pengingat tidak menandai apa pun sebagai selesai.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: Space.xxl),
                FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Menyimpan…' : 'Simpan')),
              ],
            ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value, required this.onPick, this.onClear, this.error});

  final String label;
  final LocalDate? value;
  final ValueChanged<LocalDate> onPick;
  final VoidCallback? onClear;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          suffixIcon: value != null && onClear != null
              ? IconButton(tooltip: 'Hapus $label', icon: const Icon(Icons.close), onPressed: onClear)
              : null,
        ),
        child: InkWell(
          onTap: () async {
            final picked = await pickDate(context, initial: value ?? LocalDate.today());
            if (picked != null) onPick(picked);
          },
          child: Text(value == null ? 'Tidak ada' : formatLongDate(value!)),
        ),
      ),
    );
  }
}
