import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../domain/worship_enums.dart';

final worshipItemsProvider = StreamProvider.autoDispose<List<WorshipItem>>(
  (ref) => ref.watch(worshipRepositoryProvider).watchItems(),
);

/// Choose which optional worship items appear on Today, and manage custom
/// items. None of these are treated as daily obligations.
class WorshipSettingsScreen extends ConsumerWidget {
  const WorshipSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ibadah lainnya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah ibadah'),
      ),
      body: AsyncView(
        value: ref.watch(worshipItemsProvider),
        data: (items) {
          final active = items.where((i) => !i.archived).toList();
          final archived = items.where((i) => i.archived).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
                child: Text(
                  'Semua pilihan ini opsional dan bukan kewajiban harian. Pilih yang ingin Anda catat di '
                  'halaman Hari ini. Menyembunyikan atau mengarsipkan tidak menghapus riwayat.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SectionHeader(title: 'Tampilkan di Hari ini'),
              for (final item in active)
                SwitchListTile(
                  key: ValueKey(item.id),
                  title: Text(item.name),
                  subtitle: Text(item.trackingType.label + (item.unit == null ? '' : ' · ${item.unit}')),
                  value: item.showOnToday,
                  onChanged: (v) => runGuarded(context, () => ref.read(worshipRepositoryProvider).setShowOnToday(item.id, v)),
                  secondary: PopupMenuButton<String>(
                    tooltip: 'Pilihan untuk ${item.name}',
                    onSelected: (v) => _action(context, ref, item, v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Ubah nama')),
                      PopupMenuItem(value: 'archive', child: Text('Arsipkan')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus permanen')),
                    ],
                  ),
                ),
              if (archived.isNotEmpty) ...[
                const SectionHeader(title: 'Diarsipkan'),
                for (final item in archived)
                  ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: const Text('Riwayat tetap tersimpan'),
                    trailing: TextButton(
                      onPressed: () => runGuarded(context, () => ref.read(worshipRepositoryProvider).setArchived(item.id, false)),
                      child: const Text('Pulihkan'),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _action(BuildContext context, WidgetRef ref, WorshipItem item, String action) async {
    final repo = ref.read(worshipRepositoryProvider);
    switch (action) {
      case 'rename':
        final name = await _askName(context, item.name);
        if (name != null && context.mounted) {
          await runGuarded(context, () => repo.updateItem(item.id, name: name, unit: item.unit));
        }
      case 'archive':
        await runGuarded(context, () => repo.setArchived(item.id, true), success: '${item.name} diarsipkan.');
      case 'delete':
        final count = await repo.recordCount(item.id);
        if (!context.mounted) return;
        final ok = await confirmAction(
          context,
          title: 'Hapus ${item.name}?',
          message: count == 0
              ? 'Belum ada catatan untuk ibadah ini.'
              : '$count catatan akan ikut terhapus permanen. Pilih Arsipkan jika ingin menyimpan riwayatnya.',
          confirmLabel: 'Hapus permanen',
          destructive: true,
        );
        if (ok && context.mounted) {
          await runGuarded(context, () => repo.deletePermanently(item.id), success: 'Dihapus.');
        }
    }
  }

  Future<String?> _askName(BuildContext context, String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nama ibadah'),
        content: TextField(controller: controller, autofocus: true, maxLength: 80),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Simpan')),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, WorshipTrackingType, String?)>(
      context: context,
      builder: (_) => const _NewWorshipDialog(),
    );
    if (result == null || !context.mounted) return;
    await runGuarded(
      context,
      () => ref.read(worshipRepositoryProvider).createItem(name: result.$1, type: result.$2, unit: result.$3),
      success: 'Ibadah ditambahkan dan ditampilkan di Hari ini.',
    );
  }
}

class _NewWorshipDialog extends StatefulWidget {
  const _NewWorshipDialog();

  @override
  State<_NewWorshipDialog> createState() => _NewWorshipDialogState();
}

class _NewWorshipDialogState extends State<_NewWorshipDialog> {
  final _name = TextEditingController();
  final _unit = TextEditingController();
  WorshipTrackingType _type = WorshipTrackingType.check;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ibadah baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: 'Nama', errorText: _error),
            ),
            DropdownButtonFormField<WorshipTrackingType>(
              isExpanded: true,
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Cara mencatat'),
              items: [for (final t in WorshipTrackingType.values) DropdownMenuItem(value: t, child: Text(t.label))],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            if (_type == WorshipTrackingType.count) ...[
              const SizedBox(height: Space.md),
              TextField(controller: _unit, decoration: const InputDecoration(labelText: 'Satuan', hintText: 'kali')),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) {
              setState(() => _error = 'Nama wajib diisi.');
              return;
            }
            Navigator.pop(context, (_name.text.trim(), _type, _unit.text.trim().isEmpty ? null : _unit.text.trim()));
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
