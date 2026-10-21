import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/states.dart';
import '../../today/presentation/day_providers.dart';
import '../domain/activity_draft.dart';
import '../domain/activity_status.dart';

/// Create or edit an activity. Common fields first; the rest are disclosed
/// on demand.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({
    super.key,
    required this.date,
    this.activityId,
    this.initialTitle,
    this.initialCategoryId,
  });

  final LocalDate date;
  final String? activityId;
  final String? initialTitle;
  final String? initialCategoryId;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  final _tags = TextEditingController();
  final _duration = TextEditingController();
  late LocalDate _date = widget.date;
  String? _categoryId;
  ActivityStatus _status = ActivityStatus.done;
  int? _start;
  int? _end;
  bool _endsNextDay = false;
  bool _showMore = false;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  Activity? _original;
  ValidationFailure? _error;

  bool get _editing => widget.activityId != null;

  @override
  void initState() {
    super.initState();
    _title.text = widget.initialTitle ?? '';
    _categoryId = widget.initialCategoryId;
    if (_editing) _load();
    for (final c in [_title, _description, _notes, _tags, _duration]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() {
    // Rebuild once so PopScope starts guarding against losing the edit.
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final a = await ref.read(activityRepositoryProvider).find(widget.activityId!);
    if (!mounted) return;
    if (a == null) {
      setState(() => _loading = false);
      return;
    }
    _original = a;
    _title.text = a.title;
    _description.text = a.description ?? '';
    _notes.text = a.notes ?? '';
    _tags.text = a.tags ?? '';
    _duration.text = a.startMinute == null && a.durationMinutes != null ? '${a.durationMinutes}' : '';
    setState(() {
      _date = LocalDate.parse(a.dateKey);
      _categoryId = a.categoryId;
      _status = a.status;
      _start = a.startMinute;
      _end = a.endMinute;
      _endsNextDay = a.endsNextDay;
      _showMore = (a.description ?? '').isNotEmpty || (a.tags ?? '').isNotEmpty;
      _loading = false;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _description, _notes, _tags, _duration]) {
      c.dispose();
    }
    super.dispose();
  }

  ActivityDraft _draft() => ActivityDraft(
    title: _title.text,
    description: _description.text,
    categoryId: _categoryId,
    date: _date,
    startMinute: _start,
    endMinute: _end,
    endsNextDay: _start != null && _end != null && _endsNextDay,
    durationMinutes: _start == null ? int.tryParse(_duration.text.trim()) : null,
    status: _status,
    notes: _notes.text,
    tags: _tags.text.split(','),
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
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(activityRepositoryProvider);
    final ok = await runGuarded(context, () async {
      if (_editing) {
        await repo.update(widget.activityId!, draft);
      } else {
        await repo.create(draft);
      }
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _dirty = false;
      showMessage(context, 'Aktivitas tersimpan.');
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final original = _original;
    if (original == null) return;
    final repo = ref.read(activityRepositoryProvider);
    final ok = await runGuarded(context, () => repo.delete(original.id));
    if (!ok || !mounted) return;
    _dirty = false;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    showUndoWith(messenger, 'Aktivitas dihapus.', () => repo.restore(original));
  }

  Future<void> _duplicate() async {
    if (_original == null) return;
    final ok = await runGuarded(context, () => ref.read(activityRepositoryProvider).duplicate(_original!.id));
    if (ok && mounted) {
      showMessage(context, 'Salinan dibuat pada tanggal yang sama.');
      Navigator.of(context).pop();
    }
  }

  Future<bool> _confirmDiscard() => confirmAction(
    context,
    title: 'Buang perubahan?',
    message: 'Perubahan yang belum disimpan akan hilang.',
    confirmLabel: 'Buang',
    destructive: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = (ref.watch(categoriesProvider).value ?? const <Category>[])
        .where((c) => !c.archived || c.id == _categoryId)
        .toList();
    final timeError = _error?.field == 'time' ? _error!.message : null;
    final showNextDayToggle = _start != null && _end != null && (_end! < _start! || _endsNextDay);
    final computed = _start != null && _end != null
        ? ActivityDraft.computeDuration(_start!, _end!, endsNextDay: _endsNextDay)
        : null;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          _dirty = false;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing ? 'Ubah aktivitas' : 'Aktivitas baru'),
          actions: [
            if (_editing && _original != null)
              PopupMenuButton<String>(
                tooltip: 'Pilihan lain',
                onSelected: (v) => v == 'dup' ? _duplicate() : _delete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'dup', child: Text('Duplikat')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
          ],
        ),
        body: _loading
            ? const LoadingView()
            : _editing && _original == null
            ? const EmptyState(
                icon: Icons.search_off,
                title: 'Aktivitas tidak ditemukan',
                message: 'Aktivitas ini mungkin sudah dihapus.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xxxl),
                children: [
                  TextField(
                    controller: _title,
                    autofocus: !_editing && _title.text.isEmpty,
                    maxLength: ActivityDraft.maxTitleLength,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Judul',
                      errorText: _error?.field == 'title' ? _error!.message : null,
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tanpa kategori')),
                      for (final c in categories) DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (v) => setState(() {
                      _categoryId = v;
                      _dirty = true;
                    }),
                  ),
                  const SizedBox(height: Space.lg),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Tanggal'),
                    child: InkWell(
                      onTap: () async {
                        final picked = await pickDate(context, initial: _date);
                        if (picked != null) {
                          setState(() {
                            _date = picked;
                            _dirty = true;
                          });
                        }
                      },
                      child: Text(formatLongDate(_date), style: theme.textTheme.bodyLarge),
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  Text('Status', style: theme.textTheme.bodySmall),
                  const SizedBox(height: Space.xs),
                  SegmentedButton<ActivityStatus>(
                    showSelectedIcon: false,
                    segments: [
                      for (final s in ActivityStatus.values) ButtonSegment(value: s, label: Text(s.label, maxLines: 1)),
                    ],
                    selected: {_status},
                    onSelectionChanged: (s) => setState(() {
                      _status = s.first;
                      _dirty = true;
                    }),
                  ),
                  const SizedBox(height: Space.xl),
                  Text('Waktu (opsional)', style: theme.textTheme.titleSmall),
                  const SizedBox(height: Space.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TimeField(
                          label: 'Mulai',
                          value: _start,
                          onChanged: (v) => setState(() {
                            _start = v;
                            _dirty = true;
                          }),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: TimeField(
                          label: 'Selesai',
                          value: _end,
                          onChanged: (v) => setState(() {
                            _end = v;
                            _dirty = true;
                          }),
                        ),
                      ),
                    ],
                  ),
                  if (showNextDayToggle)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Berakhir keesokan hari'),
                      subtitle: const Text('Aktifkan jika aktivitas melewati tengah malam.'),
                      value: _endsNextDay,
                      onChanged: (v) => setState(() {
                        _endsNextDay = v;
                        _dirty = true;
                      }),
                    ),
                  if (timeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.sm),
                      child: Text(timeError, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    )
                  else if (computed != null && computed > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.sm),
                      child: Text('Durasi: ${formatDuration(computed)}', style: theme.textTheme.bodySmall),
                    ),
                  if (_start == null) ...[
                    const SizedBox(height: Space.md),
                    TextField(
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Durasi dalam menit (opsional)',
                        helperText: 'Isi jika Anda tidak mencatat jam mulai.',
                        errorText: _error?.field == 'duration' ? _error!.message : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: Space.lg),
                  TextField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                  ),
                  if (!_showMore)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => setState(() => _showMore = true),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Deskripsi dan tag'),
                      ),
                    )
                  else ...[
                    const SizedBox(height: Space.lg),
                    TextField(
                      controller: _description,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                    ),
                    const SizedBox(height: Space.lg),
                    TextField(
                      controller: _tags,
                      decoration: const InputDecoration(
                        labelText: 'Tag (opsional)',
                        helperText: 'Pisahkan dengan koma, misalnya: kantor, fokus',
                      ),
                    ),
                  ],
                  const SizedBox(height: Space.xxl),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Menyimpan…' : 'Simpan'),
                  ),
                ],
              ),
      ),
    );
  }
}
