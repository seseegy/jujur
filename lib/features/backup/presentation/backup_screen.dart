import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/backup/backup_format.dart';
import '../../../core/backup/backup_reader.dart';
import '../../../core/backup/backup_writer.dart';
import '../../../core/backup/restore_service.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/files/file_io.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/util/ids.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/section.dart';
import '../../settings/domain/preferences.dart';
import 'restore_dialogs.dart';

final fileIoProvider = Provider<FileIo>((ref) => const FileIo());

/// Full backup and restore.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  String? _busyLabel;
  CreatedBackup? _lastCreated;

  Future<T?> _guard<T>(String label, Future<T> Function() action) async {
    if (_busy) return null;
    setState(() {
      _busy = true;
      _busyLabel = label;
    });
    try {
      return await action();
    } on Object catch (e) {
      logError(label, e);
      if (mounted) showError(context, e);
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _busyLabel = null;
        });
      }
    }
  }

  Future<void> _create({required bool share}) async {
    final password = await askBackupPassword(context);
    if (password == null || !mounted) return; // cancelled
    final created = await _guard('Membuat cadangan…', () async {
      final writer = BackupWriter(
        ref.read(databaseProvider),
        appVersion: ref.read(appConfigProvider).appVersion,
        clock: ref.read(clockProvider),
      );
      return writer.create(password: password.isEmpty ? null : password);
    });
    if (created == null || !mounted) return;
    setState(() => _lastCreated = created);
    await _deliver(created, share: share);
  }

  Future<void> _deliver(CreatedBackup created, {required bool share}) async {
    final io = ref.read(fileIoProvider);
    final outcome = await _guard('Menyimpan berkas…', () async {
      if (share) {
        return await io.share(created.fileName, BackupFormat.mimeType, created.bytes, subject: 'Cadangan Jujur')
            ? const FileSaved('share')
            : const FileCancelled();
      }
      return io.saveAs(created.fileName, BackupFormat.mimeType, created.bytes);
    });
    if (!mounted || outcome == null) return;
    switch (outcome) {
      case FileCancelled():
        showMessage(context, share ? 'Berbagi dibatalkan. Cadangan belum disimpan di mana pun.' : 'Penyimpanan dibatalkan.');
      case FileSaved(:final location):
        await ref.read(settingsRepositoryProvider).set(SettingKeys.lastBackupAt, '${nowUtcMillis()}');
        if (mounted) {
          showMessage(
            context,
            share
                ? 'Cadangan diserahkan ke aplikasi yang Anda pilih. Pastikan berkasnya tersimpan di sana.'
                : 'Cadangan tersimpan sebagai $location.',
          );
        }
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    final (String, Uint8List)? picked;
    try {
      picked = await ref.read(fileIoProvider).pickBytes();
    } on Object catch (e) {
      logError('pick backup', e);
      if (mounted) showMessage(context, 'Berkas tidak dapat dibaca. ${describeError(e)}');
      return;
    }
    if (!mounted) return;
    if (picked == null) {
      showMessage(context, 'Pemilihan berkas dibatalkan. Tidak ada data yang diubah.');
      return;
    }
    await _restoreBytes(picked.$2);
  }

  Future<void> _restoreBytes(Uint8List bytes) async {
    BackupManifest manifest;
    try {
      manifest = BackupReader.readManifest(bytes);
    } on BackupException catch (e) {
      showMessage(context, e.message);
      return;
    }
    String? password;
    if (manifest.encrypted) {
      password = await askRestorePassword(context);
      if (password == null || !mounted) return;
    }
    final validated = await _guard('Memeriksa cadangan…', () => BackupReader.read(bytes, password: password));
    if (validated == null || !mounted) return;

    final service = ref.read(restoreServiceProvider);
    final preview = await _guard('Membandingkan data…', () => service.previewMerge(validated.data));
    if (preview == null || !mounted) return;

    final mode = await chooseRestoreMode(context, validated, preview);
    if (mode == null || !mounted) return;
    if (mode == RestoreMode.replace) {
      final confirmed = await confirmAction(
        context,
        title: 'Ganti semua data?',
        message: 'Semua catatan dan pengaturan di perangkat ini akan dihapus lalu diganti dengan isi cadangan '
            '(${formatDateTime(validated.manifest.createdAt.toLocal())}). Tindakan ini tidak dapat dibatalkan. '
            'Buat cadangan data saat ini terlebih dahulu jika ragu.',
        confirmLabel: 'Ganti data',
        destructive: true,
      );
      if (!confirmed || !mounted) return;
    }
    final result = await _guard('Memulihkan…', () => service.restore(validated.data, mode));
    if (result == null || !mounted) return;
    try {
      await ref.read(reminderSyncProvider)();
    } on Object catch (e) {
      logError('reminders after restore', e);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pemulihan selesai'),
        content: Text(
          mode == RestoreMode.replace
              ? '${result.inserted} data dipulihkan dari cadangan.'
              : '${result.inserted} data baru ditambahkan. ${result.identical} sudah ada dan sama. '
                    '${result.conflicts + result.skippedDependents} berbeda dari data di perangkat dan tidak '
                    'diubah, sehingga data di perangkat ini tetap dipakai.',
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = ref.watch(prefsProvider.select((p) => p.lastBackupAt));
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Cadangan & pemulihan')),
        body: AbsorbPointer(
          absorbing: _busy,
          child: ListView(
            padding: const EdgeInsets.only(bottom: Space.xxxl),
            children: [
              if (_busy) LinearProgressIndicator(semanticsLabel: _busyLabel),
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
                child: Text(
                  'Semua catatan hanya tersimpan di perangkat ini. Jika aplikasi dihapus atau perangkat hilang, '
                  'catatan ikut hilang kecuali Anda menyimpan cadangan di tempat lain. Menjaga cadangan adalah '
                  'tanggung jawab Anda.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
                child: Text(
                  last == null ? 'Belum pernah membuat cadangan di perangkat ini.' : 'Cadangan terakhir: ${formatDateTime(last)}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SectionHeader(title: 'Buat cadangan'),
              Padding(
                padding: Space.pageInsets,
                child: Text(
                  'Berkas ZIP berisi semua aktivitas, kategori, kebiasaan dan catatannya, catatan salat, ibadah, '
                  'refleksi, serta pengaturan. Isi berkas diperiksa ulang sebelum dinyatakan berhasil.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('Simpan cadangan ke berkas'),
                subtitle: const Text('Pilih folder melalui pemilih berkas Android.'),
                onTap: () => _create(share: false),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Bagikan cadangan'),
                subtitle: const Text('Kirim ke aplikasi lain, misalnya penyimpanan awan pilihan Anda.'),
                onTap: () => _create(share: true),
              ),
              if (_lastCreated != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
                  child: Text(
                    'Cadangan dibuat ${formatDateTime(_lastCreated!.manifest.createdAt.toLocal())} · '
                    '${_lastCreated!.manifest.encrypted ? 'terenkripsi' : 'tidak terenkripsi'} · '
                    '${(_lastCreated!.bytes.length / 1024).toStringAsFixed(1)} KB',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SectionHeader(title: 'Pulihkan'),
              Padding(
                padding: Space.pageInsets,
                child: Text(
                  'Berkas diperiksa sepenuhnya sebelum data diubah. Jika pemeriksaan atau pemulihan gagal, data '
                  'di perangkat ini tetap seperti semula.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings_backup_restore),
                title: const Text('Pulihkan dari berkas cadangan'),
                onTap: _restore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
