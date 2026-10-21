import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/status_mark.dart';
import '../domain/prayer.dart';

Future<void> showPrayerSheet(BuildContext context, {required Prayer prayer, required LocalDate date}) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PrayerSheet(prayer: prayer, date: date),
    );

/// Records or corrects one prayer. Nothing is inferred from the clock: the
/// user chooses the status explicitly.
class PrayerSheet extends ConsumerStatefulWidget {
  const PrayerSheet({super.key, required this.prayer, required this.date});

  final Prayer prayer;
  final LocalDate date;

  @override
  ConsumerState<PrayerSheet> createState() => _PrayerSheetState();
}

class _PrayerSheetState extends ConsumerState<PrayerSheet> {
  PrayerRecord? _existing;
  PrayerStatus? _status;
  int? _time;
  bool? _jamaah;
  final _note = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final record = await ref.read(prayerRepositoryProvider).find(widget.prayer, widget.date);
    if (!mounted) return;
    setState(() {
      _existing = record;
      _status = record?.status;
      _time = record?.performedMinute;
      _jamaah = record?.jamaah;
      _note.text = record?.note ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _performed => _status == PrayerStatus.done || _status == PrayerStatus.qadha;

  Future<void> _save() async {
    final status = _status;
    if (status == null || _saving) return;
    setState(() => _saving = true);
    final repo = ref.read(prayerRepositoryProvider);
    final ok = await runGuarded(
      context,
      () => repo.setStatus(
        prayer: widget.prayer,
        date: widget.date,
        status: status,
        performedMinute: Value(_performed ? _time : null),
        jamaah: Value(_performed ? _jamaah : null),
        note: Value(_note.text),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      showMessageWith(messenger, 'Catatan ${widget.prayer.label} tersimpan.');
    }
  }

  Future<void> _clear() async {
    final repo = ref.read(prayerRepositoryProvider);
    final previous = _existing;
    final ok = await runGuarded(context, () => repo.clear(widget.prayer, widget.date));
    if (!mounted || !ok) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    showUndoWith(messenger, '${widget.prayer.label} kembali ke "Belum dicatat".', () => repo.restore(widget.prayer, widget.date, previous));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackJamaah = ref.watch(prefsProvider.select((p) => p.prayerTrackJamaah));
    if (_loading) return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: Space.pageInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Salat ${widget.prayer.label}', style: theme.textTheme.titleLarge),
                  Text(formatLongDate(widget.date), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            RadioGroup<PrayerStatus>(
              groupValue: _status,
              onChanged: (v) => setState(() => _status = v),
              child: Column(
                children: [
                  for (final s in PrayerStatus.values)
                    RadioListTile<PrayerStatus>(
                      value: s,
                      title: Row(
                        children: [
                          StatusMark(Mark.prayer(s), size: 20),
                          const SizedBox(width: Space.sm),
                          Text(s.label),
                        ],
                      ),
                      subtitle: Text(s.description),
                    ),
                ],
              ),
            ),
            if (_performed) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TimeField(
                        label: 'Waktu pelaksanaan (opsional)',
                        value: _time,
                        onChanged: (v) => setState(() => _time = v),
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    TextButton(
                      onPressed: () => setState(() => _time = MinuteOfDay.fromDateTime(DateTime.now())),
                      child: const Text('Sekarang'),
                    ),
                  ],
                ),
              ),
              if (trackJamaah)
                SwitchListTile(
                  title: const Text('Berjamaah'),
                  subtitle: Text(_jamaah == null ? 'Tidak dicatat' : (_jamaah! ? 'Ya' : 'Tidak')),
                  value: _jamaah ?? false,
                  onChanged: (v) => setState(() => _jamaah = v),
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
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
                  if (_existing != null)
                    TextButton(onPressed: _saving ? null : _clear, child: const Text('Hapus catatan')),
                  const Spacer(),
                  FilledButton(
                    onPressed: _status == null || _saving ? null : _save,
                    child: const Text('Simpan'),
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
