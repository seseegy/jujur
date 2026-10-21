import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_config.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final version = ref.watch(appConfigProvider).appVersion;
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          Text(AppConfig.appName, style: theme.textTheme.headlineSmall),
          Text('Versi $version · skema data ${ref.read(databaseProvider).schemaVersion}', style: theme.textTheme.bodySmall),
          const SizedBox(height: Space.lg),
          Text(
            'Jujur membantu Anda melihat hari-hari Anda apa adanya: apa yang sudah dilakukan, apa yang belum '
            'dicatat, dan bagaimana waktu Anda terpakai, tanpa rasa malu, tekanan, atau ketergantungan pada internet.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: Space.lg),
          Text('Prinsip', style: theme.textTheme.titleMedium),
          const SizedBox(height: Space.sm),
          for (final t in const [
            'Jujur, bukan sempurna. Catatan yang belum diisi tidak pernah dianggap sebagai kegagalan.',
            'Privat. Semua catatan disimpan di perangkat ini.',
            'Luring. Semua fitur bekerja tanpa internet.',
            'Tidak menghakimi. Tidak ada skor, peringkat, atau pesan yang mempermalukan.',
            'Data milik Anda. Ekspor dan cadangan tersedia kapan saja.',
          ])
            Padding(padding: const EdgeInsets.only(bottom: Space.sm), child: Text('• $t', style: theme.textTheme.bodyMedium)),
          const SizedBox(height: Space.lg),
          OutlinedButton(
            onPressed: () => showLicensePage(context: context, applicationName: AppConfig.appName, applicationVersion: version),
            child: const Text('Lisensi perangkat lunak'),
          ),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const sections = [
      ('Tempat data disimpan', 'Semua catatan disimpan dalam database di penyimpanan internal aplikasi pada perangkat ini. '
          'Tidak ada akun, server, atau sinkronisasi awan.'),
      ('Internet', 'Aplikasi tidak meminta izin internet dan tidak mengirim data ke mana pun. Perhitungan waktu salat '
          'dilakukan di perangkat.'),
      ('Analitik dan iklan', 'Tidak ada analitik, pelacakan perilaku, iklan, atau layanan AI.'),
      ('Notifikasi', 'Pengingat dijadwalkan di perangkat. Isi notifikasi tidak pernah memuat refleksi atau catatan '
          'pribadi, dan notifikasi tidak menandai apa pun sebagai selesai.'),
      ('Lokasi', 'Aplikasi tidak meminta izin lokasi. Koordinat untuk waktu salat Anda isi sendiri jika ingin.'),
      ('Cadangan dan ekspor', 'Data hanya meninggalkan aplikasi jika Anda membuat cadangan atau ekspor lalu memilih '
          'tempat penyimpanannya. Cadangan tanpa kata sandi dapat dibaca siapa pun yang memegang berkasnya.'),
      ('Menghapus data', 'Menghapus aplikasi akan menghapus semua catatan di perangkat ini. Simpan cadangan di tempat '
          'lain jika Anda ingin menyimpannya.'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Privasi')),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          for (final (title, body) in sections) ...[
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: Space.xs),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Space.xl),
          ],
        ],
      ),
    );
  }
}
