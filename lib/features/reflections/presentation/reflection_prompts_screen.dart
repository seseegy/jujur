import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../../settings/domain/preferences.dart';

/// Edit the optional reflection prompts. Changing prompts never alters past
/// reflections: answers keep the prompt text they were written for.
class ReflectionPromptsScreen extends ConsumerWidget {
  const ReflectionPromptsScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref, List<String> prompts) =>
      runGuarded(context, () => ref.read(settingsRepositoryProvider).setJson(SettingKeys.reflectionPrompts, prompts));

  Future<String?> _edit(BuildContext context, {String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial.isEmpty ? 'Pertanyaan baru' : 'Ubah pertanyaan'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 200,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(context, text);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(prefsProvider.select((p) => p.reflectionPrompts));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertanyaan refleksi'),
        actions: [
          TextButton(
            onPressed: () => _save(context, ref, defaultReflectionPrompts),
            child: const Text('Kembalikan bawaan'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah pertanyaan',
        onPressed: () async {
          final text = await _edit(context);
          if (text != null && context.mounted && !prompts.contains(text)) {
            await _save(context, ref, [...prompts, text]);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: prompts.isEmpty
          ? const EmptyState(
              icon: Icons.help_outline,
              title: 'Tidak ada pertanyaan',
              message: 'Refleksi tetap dapat ditulis bebas. Tambahkan pertanyaan jika Anda ingin panduan.',
            )
          : ReorderableListView(
              padding: const EdgeInsets.only(bottom: 96),
              header: Padding(
                padding: const EdgeInsets.all(Space.page),
                child: Text(
                  'Pertanyaan bersifat opsional. Mengubah daftar ini tidak mengubah refleksi yang sudah ditulis.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              onReorderItem: (from, to) {
                final list = [...prompts];
                final item = list.removeAt(from);
                list.insert(to, item);
                _save(context, ref, list);
              },
              children: [
                for (final p in prompts)
                  ListTile(
                    key: ValueKey(p),
                    title: Text(p),
                    onTap: () async {
                      final text = await _edit(context, initial: p);
                      if (text != null && context.mounted) {
                        await _save(context, ref, [for (final x in prompts) x == p ? text : x]);
                      }
                    },
                    trailing: IconButton(
                      tooltip: 'Hapus pertanyaan',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _save(context, ref, [...prompts]..remove(p)),
                    ),
                  ),
              ],
            ),
    );
  }
}
