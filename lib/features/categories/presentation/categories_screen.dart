import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../../today/presentation/day_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<String?> _askName(BuildContext context, {String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial.isEmpty ? 'Kategori baru' : 'Ubah nama kategori'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Simpan')),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(categoryRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori aktivitas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await _askName(context);
          if (name != null && context.mounted) {
            await runGuarded(context, () => repo.create(name), success: 'Kategori ditambahkan.');
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Kategori baru'),
      ),
      body: AsyncView(
        value: ref.watch(categoriesProvider),
        data: (all) {
          final active = all.where((c) => !c.archived).toList();
          final archived = all.where((c) => c.archived).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
                child: Text(
                  'Kategori yang sudah dipakai tidak dapat dihapus agar riwayat tetap utuh, tetapi dapat diarsipkan.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SectionHeader(title: 'Aktif'),
              for (final c in active) _CategoryTile(category: c, onRename: () => _rename(context, ref, c)),
              if (archived.isNotEmpty) ...[
                const SectionHeader(title: 'Diarsipkan'),
                for (final c in archived) _CategoryTile(category: c, onRename: () => _rename(context, ref, c)),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Category c) async {
    final name = await _askName(context, initial: c.name);
    if (name != null && context.mounted) {
      await runGuarded(context, () => ref.read(categoryRepositoryProvider).rename(c.id, name));
    }
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category, required this.onRename});
  final Category category;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(categoryRepositoryProvider);
    return ListTile(
      key: ValueKey(category.id),
      title: Text(category.name),
      onTap: onRename,
      trailing: PopupMenuButton<String>(
        tooltip: 'Pilihan untuk ${category.name}',
        onSelected: (v) async {
          switch (v) {
            case 'archive':
              await runGuarded(context, () => repo.setArchived(category.id, !category.archived));
            case 'delete':
              final ok = await confirmAction(
                context,
                title: 'Hapus kategori?',
                message: 'Kategori "${category.name}" akan dihapus. Ini hanya dapat dilakukan jika belum dipakai.',
                confirmLabel: 'Hapus',
                destructive: true,
              );
              if (ok && context.mounted) await runGuarded(context, () => repo.delete(category.id), success: 'Kategori dihapus.');
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'archive', child: Text(category.archived ? 'Aktifkan kembali' : 'Arsipkan')),
          const PopupMenuItem(value: 'delete', child: Text('Hapus')),
        ],
      ),
    );
  }
}
