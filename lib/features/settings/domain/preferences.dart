import 'dart:convert';

import 'package:flutter/material.dart';

import '../../prayers/domain/prayer.dart';

/// Keys stored in the `app_settings` table.
///
/// Keys starting with [SettingKeys.localOnlyPrefix] describe this device only
/// (UI state, last backup time) and are excluded from backups.
abstract final class SettingKeys {
  static const localOnlyPrefix = 'local.';

  static const onboardingDone = 'onboarding_done';
  static const themeMode = 'theme_mode';
  static const language = 'language';
  static const weekStart = 'week_start';
  static const showStreaks = 'habits.show_streaks';
  static const prayerEnabled = 'prayer.enabled';
  static const prayerTrackJamaah = 'prayer.track_jamaah';
  static const reflectionPrompts = 'reflection.prompts';

  static const prayerTimesMode = 'prayer_times.mode';
  static const prayerManualTimes = 'prayer_times.manual';
  static const prayerCalcMethod = 'prayer_times.method';
  static const prayerLatitude = 'prayer_times.latitude';
  static const prayerLongitude = 'prayer_times.longitude';
  static const prayerMadhab = 'prayer_times.madhab';
  static const prayerAdjustments = 'prayer_times.adjustments';
  static const prayerTimezone = 'prayer_times.timezone';

  static const prayerRemindersEnabled = 'reminders.prayer.enabled';
  static const prayerReminderPrayers = 'reminders.prayer.prayers';
  static const prayerReminderOffset = 'reminders.prayer.offset_minutes';

  static String collapsed(String section) =>
      '${localOnlyPrefix}today.collapsed.$section';
  static const lastBackupAt = '${localOnlyPrefix}backup.last_created_at';
}

enum PrayerTimesMode {
  off('Tidak ditampilkan'),
  manual('Diatur manual'),
  calculated('Dihitung di perangkat');

  const PrayerTimesMode(this.label);
  final String label;
}

const defaultReflectionPrompts = [
  'Apa yang berjalan baik hari ini?',
  'Apa yang belum berjalan sesuai rencana?',
  'Apa yang saya pelajari hari ini?',
  'Apa yang ingin saya perbaiki besok?',
  'Hal apa yang saya syukuri hari ini?',
];

/// Typed, immutable view over the raw settings map.
class Preferences {
  const Preferences(this.raw);

  static const empty = Preferences({});

  final Map<String, String> raw;

  bool _bool(String key, bool fallback) => switch (raw[key]) {
    'true' => true,
    'false' => false,
    _ => fallback,
  };

  int _int(String key, int fallback) => int.tryParse(raw[key] ?? '') ?? fallback;

  bool get onboardingDone => _bool(SettingKeys.onboardingDone, false);

  ThemeMode get themeMode => switch (raw[SettingKeys.themeMode]) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  String get language => raw[SettingKeys.language] ?? 'id';

  /// ISO weekday the week starts on: 1 (Senin), 6 (Sabtu) or 7 (Minggu).
  int get weekStart {
    final v = _int(SettingKeys.weekStart, 1);
    return const {1, 6, 7}.contains(v) ? v : 1;
  }

  bool get showStreaks => _bool(SettingKeys.showStreaks, false);
  bool get prayerEnabled => _bool(SettingKeys.prayerEnabled, true);
  bool get prayerTrackJamaah => _bool(SettingKeys.prayerTrackJamaah, true);

  List<String> get reflectionPrompts {
    final value = raw[SettingKeys.reflectionPrompts];
    if (value == null) return defaultReflectionPrompts;
    try {
      return (jsonDecode(value) as List).cast<String>();
    } on Object {
      return defaultReflectionPrompts;
    }
  }

  PrayerTimesMode get prayerTimesMode => PrayerTimesMode.values.firstWhere(
    (m) => m.name == raw[SettingKeys.prayerTimesMode],
    orElse: () => PrayerTimesMode.off,
  );

  /// Manually configured times as minutes of day.
  Map<Prayer, int> get manualPrayerTimes =>
      _prayerIntMap(SettingKeys.prayerManualTimes);

  /// Per-prayer adjustments in minutes for calculated times.
  Map<Prayer, int> get prayerAdjustments =>
      _prayerIntMap(SettingKeys.prayerAdjustments);

  Map<Prayer, int> _prayerIntMap(String key) {
    final value = raw[key];
    if (value == null) return const {};
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      return {
        for (final p in Prayer.values)
          if (map[p.name] is int) p: map[p.name] as int,
      };
    } on Object {
      return const {};
    }
  }

  String? get prayerCalcMethod => raw[SettingKeys.prayerCalcMethod];
  double? get prayerLatitude => double.tryParse(raw[SettingKeys.prayerLatitude] ?? '');
  double? get prayerLongitude =>
      double.tryParse(raw[SettingKeys.prayerLongitude] ?? '');
  String get prayerMadhab => raw[SettingKeys.prayerMadhab] ?? 'shafi';

  /// IANA timezone name, or null to follow the device.
  String? get prayerTimezone {
    final v = raw[SettingKeys.prayerTimezone];
    return (v == null || v.isEmpty) ? null : v;
  }

  bool get prayerRemindersEnabled =>
      _bool(SettingKeys.prayerRemindersEnabled, false);

  Set<Prayer> get prayerReminderPrayers {
    final value = raw[SettingKeys.prayerReminderPrayers];
    if (value == null) return Prayer.values.toSet();
    return {
      for (final name in value.split(','))
        ...Prayer.values.where((p) => p.name == name),
    };
  }

  /// Minutes after the prayer time (0–120).
  int get prayerReminderOffset =>
      _int(SettingKeys.prayerReminderOffset, 0).clamp(0, 120);

  bool isCollapsed(String section) =>
      _bool(SettingKeys.collapsed(section), false);

  DateTime? get lastBackupAt {
    final ms = int.tryParse(raw[SettingKeys.lastBackupAt] ?? '');
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
  }
}
