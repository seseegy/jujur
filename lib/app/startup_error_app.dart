import 'package:flutter/material.dart';

import '../core/errors/app_failure.dart';
import 'theme/app_spacing.dart';
import 'theme/app_theme.dart';

/// Shown when the database cannot be opened. Data is left untouched.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(Space.page),
                children: [
                  const SizedBox(height: Space.xxxl),
                  Icon(Icons.storage_outlined, size: 32, color: theme.colorScheme.error),
                  const SizedBox(height: Space.lg),
                  Text('Data tidak dapat dibuka', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: Space.md),
                  Text(describeError(error), style: theme.textTheme.bodyLarge),
                  const SizedBox(height: Space.md),
                  Text(
                    'Catatan Anda tidak dihapus. Jika aplikasi baru saja diperbarui, salinan database '
                    'sebelum pembaruan disimpan di penyimpanan aplikasi. Coba tutup lalu buka kembali '
                    'aplikasi, pastikan ruang penyimpanan cukup, atau pasang versi aplikasi yang lebih baru.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
