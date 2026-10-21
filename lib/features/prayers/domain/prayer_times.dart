import 'package:adhan/adhan.dart' as adhan;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/date/local_date.dart';
import '../../settings/domain/preferences.dart';
import 'prayer.dart';

/// A calculation method the user can choose. None is selected by default.
class CalcMethod {
  const CalcMethod(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;
}

const calcMethods = [
  CalcMethod('kemenag', 'Kemenag RI', 'Subuh 20°, Isya 18°, ditambah ihtiyat 2 menit.'),
  CalcMethod('muslim_world_league', 'Muslim World League', 'Subuh 18°, Isya 17°.'),
  CalcMethod('singapore', 'MUIS Singapura', 'Subuh 20°, Isya 18°.'),
  CalcMethod('egyptian', 'Egyptian General Authority', 'Subuh 19,5°, Isya 17,5°.'),
  CalcMethod('umm_al_qura', 'Umm al-Qura (Makkah)', 'Subuh 18,5°, Isya 90 menit setelah Magrib.'),
  CalcMethod('karachi', 'University of Islamic Sciences, Karachi', 'Subuh 18°, Isya 18°.'),
  CalcMethod('dubai', 'Dubai', 'Subuh 18,2°, Isya 18,2°.'),
  CalcMethod('kuwait', 'Kuwait', 'Subuh 18°, Isya 17,5°.'),
  CalcMethod('qatar', 'Qatar', 'Subuh 18°, Isya 90 menit setelah Magrib.'),
  CalcMethod('turkey', 'Diyanet (Turki)', 'Metode resmi Turki.'),
  CalcMethod('moon_sighting_committee', 'Moonsighting Committee', 'Subuh 18°, Isya 18° dengan penyesuaian musim.'),
  CalcMethod('north_america', 'ISNA', 'Subuh 15°, Isya 15°.'),
];

CalcMethod? calcMethodById(String? id) => calcMethods.where((m) => m.id == id).firstOrNull;

enum PrayerTimeSource { manual, calculated }

/// Prayer times for one date, as local wall-clock minutes in [location] and
/// as absolute instants for scheduling reminders.
class DayPrayerTimes {
  const DayPrayerTimes(this.source, this.minutes, this.instants);
  final PrayerTimeSource source;
  final Map<Prayer, int> minutes;
  final Map<Prayer, DateTime> instants;
}

/// Why prayer times are unavailable, in user-facing words.
class PrayerTimesUnavailable {
  const PrayerTimesUnavailable(this.reason);
  final String reason;
}

/// Computes prayer times locally (no network).
///
/// [location] is the timezone used for display and scheduling: either the
/// zone chosen in settings or the device zone.
abstract final class PrayerTimesCalculator {
  static Object compute(Preferences prefs, LocalDate date, tz.Location location) {
    switch (prefs.prayerTimesMode) {
      case PrayerTimesMode.off:
        return const PrayerTimesUnavailable('Waktu salat tidak ditampilkan.');
      case PrayerTimesMode.manual:
        final manual = prefs.manualPrayerTimes;
        if (manual.isEmpty) {
          return const PrayerTimesUnavailable('Waktu salat manual belum diatur.');
        }
        return DayPrayerTimes(PrayerTimeSource.manual, manual, {
          for (final e in manual.entries)
            e.key: tz.TZDateTime(location, date.year, date.month, date.day, e.value ~/ 60, e.value % 60),
        });
      case PrayerTimesMode.calculated:
        final method = calcMethodById(prefs.prayerCalcMethod);
        final lat = prefs.prayerLatitude;
        final lng = prefs.prayerLongitude;
        if (method == null) return const PrayerTimesUnavailable('Pilih metode perhitungan terlebih dahulu.');
        if (lat == null || lng == null) return const PrayerTimesUnavailable('Isi koordinat lokasi terlebih dahulu.');
        return calculate(
          date: date,
          location: location,
          methodId: method.id,
          latitude: lat,
          longitude: lng,
          madhab: prefs.prayerMadhab,
          adjustments: prefs.prayerAdjustments,
        );
    }
  }

  static DayPrayerTimes calculate({
    required LocalDate date,
    required tz.Location location,
    required String methodId,
    required double latitude,
    required double longitude,
    String madhab = 'shafi',
    Map<Prayer, int> adjustments = const {},
  }) {
    final params = _parameters(methodId)
      ..madhab = madhab == 'hanafi' ? adhan.Madhab.hanafi : adhan.Madhab.shafi
      ..adjustments = adhan.PrayerAdjustments(
        fajr: adjustments[Prayer.subuh] ?? 0,
        dhuhr: adjustments[Prayer.zuhur] ?? 0,
        asr: adjustments[Prayer.asar] ?? 0,
        maghrib: adjustments[Prayer.magrib] ?? 0,
        isha: adjustments[Prayer.isya] ?? 0,
      );
    final times = adhan.PrayerTimes.utc(
      adhan.Coordinates(latitude, longitude),
      adhan.DateComponents(date.year, date.month, date.day),
      params,
    );
    final utc = {
      Prayer.subuh: times.fajr,
      Prayer.zuhur: times.dhuhr,
      Prayer.asar: times.asr,
      Prayer.magrib: times.maghrib,
      Prayer.isya: times.isha,
    };
    final instants = <Prayer, DateTime>{};
    final minutes = <Prayer, int>{};
    for (final e in utc.entries) {
      final local = tz.TZDateTime.from(e.value.toUtc(), location);
      instants[e.key] = local;
      minutes[e.key] = local.hour * 60 + local.minute;
    }
    return DayPrayerTimes(PrayerTimeSource.calculated, minutes, instants);
  }

  static adhan.CalculationParameters _parameters(String id) {
    if (id == 'kemenag') {
      return adhan.CalculationParameters(
        fajrAngle: 20,
        ishaAngle: 18,
        methodAdjustments: adhan.PrayerAdjustments(fajr: 2, dhuhr: 2, asr: 2, maghrib: 2, isha: 2),
      );
    }
    final method = adhan.CalculationMethod.values.firstWhere((m) => m.name == id);
    return method.getParameters();
  }
}
