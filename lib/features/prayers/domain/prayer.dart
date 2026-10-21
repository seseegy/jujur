/// The five obligatory daily prayers.
///
/// Enum names are persisted in the database and in backups; do not rename.
enum Prayer {
  subuh('Subuh', 'Fajr'),
  zuhur('Zuhur', 'Dhuhr'),
  asar('Asar', 'Asr'),
  magrib('Magrib', 'Maghrib'),
  isya('Isya', 'Isha');

  const Prayer(this.label, this.arabicLatinName);

  /// Indonesian name (default).
  final String label;

  /// Commonly used transliteration, shown as secondary information.
  final String arabicLatinName;
}

/// Explicitly recorded prayer status. "Belum dicatat" (not recorded) is the
/// absence of a record and is never stored or inferred from the clock.
enum PrayerStatus {
  done('Dilaksanakan'),
  qadha('Diqada'),
  missed('Terlewat'),
  excused('Tidak berlaku');

  const PrayerStatus(this.label);
  final String label;

  String get description => switch (this) {
    PrayerStatus.done => 'Dilaksanakan pada waktunya.',
    PrayerStatus.qadha => 'Dilaksanakan di luar waktunya.',
    PrayerStatus.missed => 'Tidak dilaksanakan.',
    PrayerStatus.excused =>
      'Tidak berlaku pada hari ini, misalnya karena uzur syar\'i.',
  };
}

const notRecordedLabel = 'Belum dicatat';
