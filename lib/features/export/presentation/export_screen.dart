import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/export/export_service.dart';
import '../../../core/files/file_io.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/section.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../today/presentation/day_providers.dart';

/// Export selected records as CSV or JSON for use in other applications.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  late DateRange _range = DateRange(ref.read(todayProvider).firstOfMonth, ref.read(todayProvider));
  Set<ExportRecordType> _types = ExportRecordType.values.toSet();
  Set<String>? _categories;
  bool _notes = true;
  ExportFormat _format = ExportFormat.csv;
  Map<ExportRecordType, int>? _preview;
  bool _busy = false;
  int _previewGeneration = 0;

  ExportOptions get _options => ExportOptions(
    range: _range,
    types: _types,
    includeNotes: _notes,
    categoryIds: _categories,
    format: _format,
  );

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final generation = ++_previewGeneration;
    setState(() => _preview = null);
    try {
      final counts = await ref.read(exportServiceProvider).preview(_options);
      if (mounted && generation == _previewGeneration) setState(() => _preview = counts);
    } on Object catch (e) {
      logError('export preview', e);
      if (mounted) showError(context, e);
    }
  }

  void _change(VoidCallback update) {
    setState(update);
    _refreshPreview();
  }

  Future<void> _export({required bool share}) async {
    if (_busy || _types.isEmpty) return;
    setState(() => _busy = true);
    try {
      final file = await ref.read(exportServiceProvider).export(_options);
      final io = ref.read(fileIoProvider);
      if (share) {
        final shared = await io.share(file.fileName, file.mimeType, file.bytes, subject: 'Ekspor Jujur');
        if (mounted) showMessage(context, shared ? 'Ekspor diserahkan ke aplikasi yang Anda pilih.' : 'Berbagi dibatalkan.');
      } else {
        final outcome = await io.saveAs(file.fileName, file.mimeType, file.bytes);
        if (!mounted) return;
        switch (outcome) {
          case FileCancelled():
            showMessage(context, 'Penyimpanan dibatalkan.');
          case FileSaved(:final location):
            showMessage(context, 'Ekspor tersimpan sebagai $location.');
        }
      }
    } on Object catch (e) {
      logError('export', e);
      if (mounted) showMessage(context, 'Ekspor gagal. ${describeError(e)}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final total = _preview?.values.fold(0, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(title: const Text('Ekspor data')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.only(bottom: Space.xxxl),
          children: [
            if (_busy) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
              child: Text(
                'Ekspor untuk dibuka di aplikasi lain, misalnya spreadsheet. Ekspor bukan cadangan dan tidak dapat '
                'dipulihkan ke aplikasi. Gunakan menu Cadangan untuk itu.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SectionHeader(title: 'Rentang tanggal'),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(formatRange(_range)),
              subtitle: Text('${_range.lengthInDays} hari'),
              onTap: () async {
                final picked = await pickRange(context, initial: _range);
                if (picked != null) _change(() => _range = picked);
              },
            ),
            const SectionHeader(title: 'Jenis catatan'),
            for (final t in ExportRecordType.values)
              CheckboxListTile(
                title: Text(t.label),
                subtitle: _preview == null || !_types.contains(t) ? null : Text('${_preview![t] ?? 0} catatan'),
                value: _types.contains(t),
                onChanged: (v) => _change(() => _types = v! ? {..._types, t} : ({..._types}..remove(t))),
              ),
            if (_types.contains(ExportRecordType.activities))
              ListTile(
                title: const Text('Kategori aktivitas'),
                subtitle: Text(_categories == null ? 'Semua kategori' : '${_categories!.length} kategori dipilih'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDialog<Set<String>?>(
                    context: context,
                    builder: (_) => _CategoryDialog(categories: {for (final c in categories) c.id: c.name}, selected: _categories),
                  );
                  if (picked != null) _change(() => _categories = picked.isEmpty ? null : picked);
                },
              ),
            SwitchListTile(
              title: const Text('Sertakan catatan'),
              subtitle: const Text('Catatan pada aktivitas, kebiasaan, salat, dan ibadah.'),
              value: _notes,
              onChanged: (v) => _change(() => _notes = v),
            ),
            const SectionHeader(title: 'Format'),
            RadioGroup<ExportFormat>(
              groupValue: _format,
              onChanged: (v) => _change(() => _format = v!),
              child: const Column(
                children: [
                  RadioListTile(
                    value: ExportFormat.csv,
                    title: Text('CSV'),
                    subtitle: Text('Satu berkas per jenis catatan (dalam ZIP jika lebih dari satu). UTF-8.'),
                  ),
                  RadioListTile(
                    value: ExportFormat.json,
                    title: Text('JSON'),
                    subtitle: Text('Satu berkas terstruktur dengan ID yang stabil dan versi format.'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
              child: Text(
                _types.isEmpty
                    ? 'Pilih minimal satu jenis catatan.'
                    : total == null
                    ? 'Menghitung…'
                    : total == 0
                    ? 'Tidak ada catatan yang cocok. Berkas tetap dapat dibuat, tetapi kosong.'
                    : '$total catatan akan diekspor. Teks yang diawali =, +, - atau @ diberi tanda kutip di CSV agar '
                          'tidak dijalankan sebagai rumus; data asli tidak berubah.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _types.isEmpty ? null : () => _export(share: true),
                      child: const Text('Bagikan'),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: _types.isEmpty ? null : () => _export(share: false),
                      child: const Text('Simpan ke berkas'),
                    ),
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

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.categories, required this.selected});
  final Map<String, String> categories;
  final Set<String>? selected;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final Set<String> _selected = {...?widget.selected};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kategori'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in widget.categories.entries)
              CheckboxListTile(
                title: Text(e.value),
                value: _selected.contains(e.key),
                onChanged: (v) => setState(() => v! ? _selected.add(e.key) : _selected.remove(e.key)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, <String>{}), child: const Text('Semua')),
        FilledButton(onPressed: () => Navigator.pop(context, _selected), child: const Text('Pakai')),
      ],
    );
  }
}
