import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/backup/backup_schema.dart';
import '../../../core/database/watch.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/section.dart';
import '../domain/preferences.dart';

final _notificationsAllowedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationServiceProvider).areEnabled(),
);

final dataCountsProvider = StreamProvider.autoDispose<Map<String, int>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTables({db.activities, db.habits, db.habitRecords, db.prayerRecords, db.worshipRecords, db.reflections}, () async {
    final result = <String, int>{};
    for (final t in backupTables) {
      final row = await db.customSelect('SELECT COUNT(*) AS n FROM ${t.name}').getSingle();
      result[t.name] = row.read<int>('n');
    }
    return result;
  });
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _set(BuildContext context, WidgetRef ref, String key, String value) =>
      runGuarded(context, () => ref.read(settingsRepositoryProvider).set(key, value));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(prefsProvider);
    final allowed = ref.watch(_notificationsAllowedProvider).value;
    final counts = ref.watch(dataCountsProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xxxl),
        children: [
          const SectionHeader(title: 'Tampilan'),
          Padding(
            padding: Space.pageInsets,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistem'), icon: Icon(Icons.brightness_auto_outlined)),
                ButtonSegment(value: ThemeMode.light, label: Text('Terang'), icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Gelap'), icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) => _set(context, ref, SettingKeys.themeMode, s.first.name),
            ),
          ),
          const SizedBox(height: Space.sm),
          ListTile(
            title: const Text('Bahasa'),
            subtitle: const Text('Bahasa Indonesia. Bahasa lain belum tersedia.'),
            trailing: const Icon(Icons.check),
            onTap: () => _set(context, ref, SettingKeys.language, 'id'),
          ),
          ListTile(
            title: const Text('Awal minggu'),
            subtitle: Text(switch (prefs.weekStart) {
              6 => 'Sabtu',
              7 => 'Minggu',
              _ => 'Senin',
            }),
            trailing: DropdownButton<int>(
              value: prefs.weekStart,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Senin')),
                DropdownMenuItem(value: 6, child: Text('Sabtu')),
                DropdownMenuItem(value: 7, child: Text('Minggu')),
              ],
              onChanged: (v) => _set(context, ref, SettingKeys.weekStart, '$v'),
            ),
          ),
          const SectionHeader(title: 'Pencatatan'),
          ListTile(
            leading: const Icon(Icons.mosque_outlined),
            title: const Text('Salat'),
            subtitle: Text(prefs.prayerEnabled ? 'Aktif · ${prefs.prayerTimesMode.label.toLowerCase()}' : 'Tidak ditampilkan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/prayer'),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('Ibadah lainnya'),
            subtitle: const Text('Pilih yang ditampilkan di Hari ini'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/worship'),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('Kebiasaan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/habits'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.linear_scale),
            title: const Text('Tampilkan rangkaian kebiasaan'),
            subtitle: const Text('Jumlah hari terjadwal berturut-turut yang selesai. Bukan ukuran keberhasilan.'),
            value: prefs.showStreaks,
            onChanged: (v) => _set(context, ref, SettingKeys.showStreaks, '$v'),
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('Kategori aktivitas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Pertanyaan refleksi'),
            subtitle: Text('${prefs.reflectionPrompts.length} pertanyaan opsional'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/prompts'),
          ),
          const SectionHeader(title: 'Pengingat'),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Izin notifikasi'),
            subtitle: Text(switch (allowed) {
              null => 'Memeriksa…',
              true => 'Diizinkan. Pengingat salat ${prefs.prayerRemindersEnabled ? 'aktif' : 'nonaktif'}.',
              false => 'Tidak diizinkan. Aplikasi tetap berfungsi penuh tanpa pengingat.',
            }),
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Perbarui jadwal pengingat'),
            subtitle: const Text('Jadwalkan ulang setelah mengubah zona waktu atau izin.'),
            onTap: () async {
              try {
                final n = await ref.read(reminderSyncProvider)();
                ref.invalidate(_notificationsAllowedProvider);
                if (context.mounted) {
                  showMessage(context, n == 0 ? 'Tidak ada pengingat yang perlu dijadwalkan.' : '$n pengingat dijadwalkan untuk 7 hari ke depan.');
                }
              } on Object catch (e) {
                if (context.mounted) showError(context, e);
              }
            },
          ),
          const SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Cadangan & pemulihan'),
            subtitle: Text(prefs.lastBackupAt == null ? 'Belum ada cadangan' : 'Terakhir ${formatDateTime(prefs.lastBackupAt!)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Ekspor data (CSV/JSON)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/export'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
            child: Text(
              counts == null
                  ? 'Menghitung data…'
                  : 'Tersimpan di perangkat: ${counts['activities']} aktivitas, ${counts['habits']} kebiasaan, '
                        '${counts['habit_records']} catatan kebiasaan, ${counts['prayer_records']} catatan salat, '
                        '${counts['worship_records']} catatan ibadah, ${counts['reflections']} refleksi. '
                        'Versi skema database ${ref.read(databaseProvider).schemaVersion}.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SectionHeader(title: 'Tentang'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Jujur'),
            subtitle: Text('Versi ${ref.watch(appConfigProvider).appVersion}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/about'),
          ),
        ],
      ),
    );
  }
}
