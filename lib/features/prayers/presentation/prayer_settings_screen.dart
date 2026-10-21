import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/notifications/reminder_sync.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/section.dart';
import '../../settings/domain/preferences.dart';
import '../domain/prayer.dart';
import '../domain/prayer_times.dart';
import 'prayer_section.dart';

class PrayerSettingsScreen extends ConsumerStatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  ConsumerState<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends ConsumerState<PrayerSettingsScreen> {
  late final _lat = TextEditingController(text: ref.read(prefsProvider).prayerLatitude?.toString() ?? '');
  late final _lng = TextEditingController(text: ref.read(prefsProvider).prayerLongitude?.toString() ?? '');
  String? _coordError;

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _set(Map<String, String?> values, {bool resync = true}) async {
    final ok = await runGuarded(context, () => ref.read(settingsRepositoryProvider).setAll(values));
    if (ok && resync) await _resync();
  }

  Future<void> _resync() async {
    try {
      await ref.read(reminderSyncProvider)();
    } on Object {
      if (mounted) showMessage(context, 'Pengaturan tersimpan, tetapi pengingat gagal dijadwalkan.');
    }
  }

  Future<void> _saveCoordinates() async {
    final lat = double.tryParse(_lat.text.trim().replaceAll(',', '.'));
    final lng = double.tryParse(_lng.text.trim().replaceAll(',', '.'));
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) {
      setState(() => _coordError = 'Lintang harus antara -90 dan 90, bujur antara -180 dan 180.');
      return;
    }
    setState(() => _coordError = null);
    await _set({SettingKeys.prayerLatitude: '$lat', SettingKeys.prayerLongitude: '$lng'});
    if (mounted) showMessage(context, 'Koordinat tersimpan.');
  }

  Future<void> _toggleReminders(bool enable) async {
    if (enable) {
      final granted = await ref.read(notificationServiceProvider).requestPermission();
      if (!granted) {
        if (mounted) {
          showMessage(context, 'Izin notifikasi tidak diberikan. Anda dapat mengizinkannya di pengaturan Android.');
        }
        return;
      }
    }
    await _set({SettingKeys.prayerRemindersEnabled: '$enable'});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(prefsProvider);
    final mode = prefs.prayerTimesMode;
    final today = ref.watch(todayProvider);
    final preview = ref.watch(dayPrayerTimesProvider(today));
    final unavailable = PrayerTimesCalculator.compute(prefs, today, prayerLocation(prefs));

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan salat')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Space.xxxl),
        children: [
          SwitchListTile(
            title: const Text('Catat salat lima waktu'),
            subtitle: const Text('Tampilkan bagian salat di halaman Hari ini.'),
            value: prefs.prayerEnabled,
            onChanged: (v) => _set({SettingKeys.prayerEnabled: '$v'}),
          ),
          SwitchListTile(
            title: const Text('Catat berjamaah'),
            subtitle: const Text('Tampilkan pilihan berjamaah saat mencatat salat.'),
            value: prefs.prayerTrackJamaah,
            onChanged: (v) => _set({SettingKeys.prayerTrackJamaah: '$v'}, resync: false),
          ),
          const SectionHeader(title: 'Waktu salat'),
          Padding(
            padding: Space.pageInsets,
            child: Text(
              'Opsional. Waktu salat hanya ditampilkan sebagai jadwal dan untuk pengingat. Status salat '
              'tidak pernah ditentukan dari jam.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          RadioGroup<PrayerTimesMode>(
            groupValue: mode,
            onChanged: (v) => _set({SettingKeys.prayerTimesMode: v?.name}),
            child: Column(
              children: [
                for (final m in PrayerTimesMode.values) RadioListTile<PrayerTimesMode>(value: m, title: Text(m.label)),
              ],
            ),
          ),
          if (mode == PrayerTimesMode.manual) ...[
            for (final p in Prayer.values)
              ListTile(
                title: Text(p.label),
                trailing: Text(
                  prefs.manualPrayerTimes[p] == null ? 'Belum diatur' : MinuteOfDay.format(prefs.manualPrayerTimes[p]!),
                  style: theme.textTheme.bodyMedium,
                ),
                onTap: () async {
                  final picked = await pickTime(context, initial: prefs.manualPrayerTimes[p], helpText: 'Waktu ${p.label}');
                  if (picked == null) return;
                  final map = {for (final e in prefs.manualPrayerTimes.entries) e.key.name: e.value, p.name: picked};
                  await ref.read(settingsRepositoryProvider).setJson(SettingKeys.prayerManualTimes, map);
                  await _resync();
                },
              ),
          ],
          if (mode == PrayerTimesMode.calculated) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: calcMethodById(prefs.prayerCalcMethod)?.id,
                decoration: const InputDecoration(labelText: 'Metode perhitungan', helperText: 'Pilih metode yang Anda ikuti.'),
                items: [
                  for (final m in calcMethods)
                    DropdownMenuItem(value: m.id, child: Text(m.label, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) => _set({SettingKeys.prayerCalcMethod: v}),
              ),
            ),
            if (calcMethodById(prefs.prayerCalcMethod) case final m?)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, 0),
                child: Text(m.description, style: theme.textTheme.bodySmall),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi diisi manual dan tidak memerlukan izin lokasi atau internet. Anda dapat menyalin '
                    'koordinat dari peta, misalnya Jakarta: -6.2, 106.8.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: Space.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _lat,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
                          decoration: const InputDecoration(labelText: 'Lintang'),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: TextField(
                          controller: _lng,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
                          decoration: const InputDecoration(labelText: 'Bujur'),
                        ),
                      ),
                    ],
                  ),
                  if (_coordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.xs),
                      child: Text(_coordError!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _saveCoordinates, child: const Text('Simpan koordinat')),
                  ),
                ],
              ),
            ),
            Padding(
              padding: Space.pageInsets,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: prefs.prayerMadhab,
                decoration: const InputDecoration(labelText: 'Perhitungan Asar'),
                items: const [
                  DropdownMenuItem(value: 'shafi', child: Text('Jumhur (Syafi\'i, Maliki, Hanbali)')),
                  DropdownMenuItem(value: 'hanafi', child: Text('Hanafi')),
                ],
                onChanged: (v) => _set({SettingKeys.prayerMadhab: v}),
              ),
            ),
            const SizedBox(height: Space.sm),
            ExpansionTile(
              title: const Text('Penyesuaian menit'),
              subtitle: const Text('Tambah atau kurangi hasil perhitungan.'),
              tilePadding: Space.pageInsets,
              children: [
                for (final p in Prayer.values)
                  ListTile(
                    title: Text(p.label),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Kurangi satu menit ${p.label}',
                          icon: const Icon(Icons.remove),
                          onPressed: () => _adjust(prefs, p, -1),
                        ),
                        SizedBox(width: 40, child: Text('${prefs.prayerAdjustments[p] ?? 0}', textAlign: TextAlign.center)),
                        IconButton(
                          tooltip: 'Tambah satu menit ${p.label}',
                          icon: const Icon(Icons.add),
                          onPressed: () => _adjust(prefs, p, 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (mode != PrayerTimesMode.off) ...[
            ListTile(
              title: const Text('Zona waktu'),
              subtitle: Text(prefs.prayerTimezone ?? 'Mengikuti perangkat (${tz.local.name})'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickTimezone(prefs),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
              child: Text(
                preview == null
                    ? (unavailable is PrayerTimesUnavailable ? unavailable.reason : '')
                    : 'Hari ini: ${Prayer.values.map((p) => '${p.label} ${preview.minutes[p] == null ? '–' : MinuteOfDay.format(preview.minutes[p]!)}').join(' · ')}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          const SectionHeader(title: 'Pengingat'),
          SwitchListTile(
            title: const Text('Pengingat waktu salat'),
            subtitle: Text(
              mode == PrayerTimesMode.off
                  ? 'Atur waktu salat terlebih dahulu.'
                  : 'Pengingat tidak menandai salat sebagai dilaksanakan.',
            ),
            value: prefs.prayerRemindersEnabled,
            onChanged: mode == PrayerTimesMode.off ? null : _toggleReminders,
          ),
          if (prefs.prayerRemindersEnabled && mode != PrayerTimesMode.off) ...[
            Padding(
              padding: Space.pageInsets,
              child: Wrap(
                spacing: Space.sm,
                children: [
                  for (final p in Prayer.values)
                    FilterChip(
                      label: Text(p.label),
                      selected: prefs.prayerReminderPrayers.contains(p),
                      onSelected: (s) {
                        final set = {...prefs.prayerReminderPrayers};
                        s ? set.add(p) : set.remove(p);
                        _set({SettingKeys.prayerReminderPrayers: Prayer.values.where(set.contains).map((e) => e.name).join(',')});
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            Padding(
              padding: Space.pageInsets,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: const [0, 5, 10, 15, 30].contains(prefs.prayerReminderOffset) ? prefs.prayerReminderOffset : 0,
                decoration: const InputDecoration(labelText: 'Waktu pengingat'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Tepat saat waktu salat')),
                  DropdownMenuItem(value: 5, child: Text('5 menit setelahnya')),
                  DropdownMenuItem(value: 10, child: Text('10 menit setelahnya')),
                  DropdownMenuItem(value: 15, child: Text('15 menit setelahnya')),
                  DropdownMenuItem(value: 30, child: Text('30 menit setelahnya')),
                ],
                onChanged: (v) => _set({SettingKeys.prayerReminderOffset: '${v ?? 0}'}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
              child: Text(
                'Pengingat dijadwalkan untuk 7 hari ke depan dan diperbarui setiap kali aplikasi dibuka. '
                'Android dapat menunda pengingat beberapa menit untuk menghemat baterai.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _adjust(Preferences prefs, Prayer p, int delta) async {
    final current = prefs.prayerAdjustments[p] ?? 0;
    final next = (current + delta).clamp(-30, 30);
    final map = {for (final e in prefs.prayerAdjustments.entries) e.key.name: e.value, p.name: next};
    await runGuarded(context, () => ref.read(settingsRepositoryProvider).setJson(SettingKeys.prayerAdjustments, map));
    await _resync();
  }

  Future<void> _pickTimezone(Preferences prefs) async {
    final zones = tz.timeZoneDatabase.locations.keys.where((z) => z.contains('/')).toList()..sort();
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TimezonePicker(zones: zones),
    );
    if (picked == null) return;
    await _set({SettingKeys.prayerTimezone: picked.isEmpty ? null : picked});
  }
}

class _TimezonePicker extends StatefulWidget {
  const _TimezonePicker({required this.zones});
  final List<String> zones;

  @override
  State<_TimezonePicker> createState() => _TimezonePickerState();
}

class _TimezonePickerState extends State<_TimezonePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    const common = ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'];
    final filtered = widget.zones.where((z) => z.toLowerCase().contains(_query.toLowerCase())).toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: Space.pageInsets,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Cari zona waktu', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_query.isEmpty) ...[
                  ListTile(title: const Text('Mengikuti perangkat'), onTap: () => Navigator.pop(context, '')),
                  for (final z in common)
                    ListTile(
                      title: Text(z),
                      subtitle: Text(switch (z) {
                        'Asia/Jakarta' => 'WIB',
                        'Asia/Makassar' => 'WITA',
                        _ => 'WIT',
                      }),
                      onTap: () => Navigator.pop(context, z),
                    ),
                  const Divider(),
                ],
                for (final z in filtered) ListTile(title: Text(z), onTap: () => Navigator.pop(context, z)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
