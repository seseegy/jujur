import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/backup/backup_reader.dart';
import '../../../core/backup/restore_service.dart';
import '../../../core/formatters/formatters.dart';

/// Asks whether to protect the backup with a password.
/// Returns '' for no password, the password, or null when cancelled.
Future<String?> askBackupPassword(BuildContext context) => showDialog<String>(
  context: context,
  builder: (_) => const _BackupPasswordDialog(),
);

class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog();

  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  bool _encrypt = false;
  bool _obscure = true;
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Buat cadangan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Lindungi dengan kata sandi'),
              value: _encrypt,
              onChanged: (v) => setState(() => _encrypt = v),
            ),
            if (!_encrypt)
              Text(
                'Tanpa kata sandi, isi cadangan dapat dibaca siapa pun yang memegang berkasnya, termasuk refleksi Anda.',
                style: theme.textTheme.bodySmall,
              )
            else ...[
              TextField(
                controller: _password,
                obscureText: _obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Kata sandi',
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _confirm,
                obscureText: _obscure,
                decoration: InputDecoration(labelText: 'Ulangi kata sandi', errorText: _error),
              ),
              const SizedBox(height: Space.md),
              Text(
                'Kata sandi tidak disimpan di mana pun. Jika lupa, cadangan ini tidak dapat dipulihkan. '
                'Enkripsi memakai AES-256-GCM dan dapat memerlukan beberapa detik.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            if (!_encrypt) return Navigator.pop(context, '');
            if (_password.text.length < 8) {
              setState(() => _error = 'Gunakan minimal 8 karakter.');
            } else if (_password.text != _confirm.text) {
              setState(() => _error = 'Kata sandi tidak sama.');
            } else {
              Navigator.pop(context, _password.text);
            }
          },
          child: const Text('Lanjut'),
        ),
      ],
    );
  }
}

Future<String?> askRestorePassword(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cadangan terenkripsi'),
      content: TextField(
        controller: controller,
        obscureText: true,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Kata sandi cadangan'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Buka')),
      ],
    ),
  ).whenComplete(controller.dispose);
}

/// Shows what the backup contains and lets the user choose replace or merge.
Future<RestoreMode?> chooseRestoreMode(BuildContext context, ValidatedBackup backup, RestoreResult preview) {
  final counts = backup.manifest.counts;
  String c(String key) => '${counts[key] ?? 0}';
  return showDialog<RestoreMode>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Cadangan valid'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Dibuat ${formatDateTime(backup.manifest.createdAt.toLocal())}', style: theme.textTheme.bodyMedium),
              Text(
                '${backup.manifest.encrypted ? 'Terenkripsi' : 'Tidak terenkripsi'} · versi skema ${backup.manifest.schemaVersion}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: Space.md),
              Text(
                'Isi: ${c('activities')} aktivitas, ${c('habits')} kebiasaan, ${c('habit_records')} catatan kebiasaan, '
                '${c('prayer_records')} catatan salat, ${c('worship_records')} catatan ibadah, ${c('reflections')} refleksi.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: Space.lg),
              Text('Gabungkan', style: theme.textTheme.titleSmall),
              Text(
                'Menambahkan ${preview.inserted} data baru. ${preview.identical} data sudah sama. '
                '${preview.conflicts + preview.skippedDependents} data berbeda dengan data di perangkat; data di '
                'perangkat tetap dipakai dan tidak ditimpa.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: Space.md),
              Text('Ganti semua', style: theme.textTheme.titleSmall),
              Text(
                'Menghapus semua data di perangkat ini lalu memakai isi cadangan.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, RestoreMode.replace), child: const Text('Ganti semua')),
          FilledButton(onPressed: () => Navigator.pop(context, RestoreMode.merge), child: const Text('Gabungkan')),
        ],
      );
    },
  );
}
