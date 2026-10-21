import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/seed_data.dart';
import '../../../core/widgets/feedback.dart';
import '../../settings/domain/preferences.dart';

/// Short first-launch introduction with optional setup. Nothing here is
/// required: "Lewati" finishes onboarding with defaults.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  ThemeMode _theme = ThemeMode.system;
  int _weekStart = 1;
  bool _prayer = true;
  bool _streaks = false;
  final Set<String> _worship = {'wsp-tilawah', 'wsp-dzikir-pagi', 'wsp-dzikir-petang'};
  bool _saving = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool applySetup}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await runGuarded(context, () async {
      if (applySetup) {
        await ref.read(worshipRepositoryProvider).setShownItems(_worship);
      }
      await ref.read(settingsRepositoryProvider).setAll({
        if (applySetup) ...{
          SettingKeys.themeMode: _theme.name,
          SettingKeys.weekStart: '$_weekStart',
          SettingKeys.prayerEnabled: '$_prayer',
          SettingKeys.showStreaks: '$_streaks',
        },
        SettingKeys.language: 'id',
        SettingKeys.onboardingDone: 'true',
      });
    });
    if (mounted && !ok) setState(() => _saving = false);
  }

  void _next() => _pages.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intro = [
      (
        'Catatan harian yang jujur',
        'Jujur membantu Anda melihat apa yang benar-benar Anda lakukan setiap hari: aktivitas, kebiasaan, '
            'salat, ibadah, dan refleksi. Tanpa skor dan tanpa penilaian.',
      ),
      (
        'Belum dicatat bukan berarti gagal',
        'Aplikasi tidak pernah menganggap sesuatu terlewat hanya karena belum diisi. Anda yang menentukan: '
            'selesai, tidak dilakukan, atau tidak berlaku.',
      ),
      (
        'Data Anda tetap di perangkat ini',
        'Tidak perlu akun dan tidak perlu internet. Karena itu, menyimpan cadangan di tempat lain adalah '
            'tanggung jawab Anda. Menu Cadangan tersedia di Pengaturan.',
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saving ? null : () => _finish(applySetup: false),
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final (title, body) in intro)
                    Padding(
                      padding: const EdgeInsets.all(Space.page),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(header: true, child: Text(title, style: theme.textTheme.headlineSmall)),
                          const SizedBox(height: Space.lg),
                          Text(body, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  _setupPage(theme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.page),
              child: Row(
                children: [
                  Semantics(
                    label: 'Halaman ${_page + 1} dari 4',
                    child: Row(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: i == _page ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _page ? theme.colorScheme.primary : theme.colorScheme.outline,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_page < 3)
                    FilledButton(onPressed: _next, child: const Text('Lanjut'))
                  else
                    FilledButton(
                      onPressed: _saving ? null : () => _finish(applySetup: true),
                      child: const Text('Mulai'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setupPage(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Space.page),
      children: [
        Padding(
          padding: Space.pageInsets,
          child: Text('Pengaturan awal (opsional)', style: theme.textTheme.headlineSmall),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.lg),
          child: Text('Semua dapat diubah nanti di Pengaturan.', style: theme.textTheme.bodySmall),
        ),
        Padding(
          padding: Space.pageInsets,
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
              ButtonSegment(value: ThemeMode.light, label: Text('Terang')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Gelap')),
            ],
            selected: {_theme},
            onSelectionChanged: (s) => setState(() => _theme = s.first),
          ),
        ),
        ListTile(
          title: const Text('Bahasa'),
          subtitle: const Text('Bahasa Indonesia'),
        ),
        ListTile(
          title: const Text('Awal minggu'),
          trailing: DropdownButton<int>(
            value: _weekStart,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Senin')),
              DropdownMenuItem(value: 6, child: Text('Sabtu')),
              DropdownMenuItem(value: 7, child: Text('Minggu')),
            ],
            onChanged: (v) => setState(() => _weekStart = v ?? 1),
          ),
        ),
        SwitchListTile(
          title: const Text('Catat salat lima waktu'),
          value: _prayer,
          onChanged: (v) => setState(() => _prayer = v),
        ),
        SwitchListTile(
          title: const Text('Tampilkan rangkaian kebiasaan'),
          subtitle: const Text('Bisa diaktifkan nanti.'),
          value: _streaks,
          onChanged: (v) => setState(() => _streaks = v),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, Space.sm),
          child: Text('Ibadah lain yang ingin ditampilkan', style: theme.textTheme.titleSmall),
        ),
        Padding(
          padding: Space.pageInsets,
          child: Wrap(
            spacing: Space.sm,
            runSpacing: Space.xs,
            children: [
              for (final (id, name, _, _) in SeedData.worshipItems)
                FilterChip(
                  label: Text(name),
                  selected: _worship.contains(id),
                  onSelected: (s) => setState(() => s ? _worship.add(id) : _worship.remove(id)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
          child: Text(
            'Kebiasaan dapat dibuat kapan saja dari halaman Hari ini. Izin notifikasi hanya diminta jika Anda '
            'mengaktifkan pengingat.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
