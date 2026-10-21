/// Enum names are persisted in the database and in backups; do not rename.
library;

enum WorshipTrackingType {
  check('Centang'),
  count('Jumlah'),
  duration('Durasi (menit)'),
  note('Catatan');

  const WorshipTrackingType(this.label);
  final String label;
}

/// "Not recorded" is the absence of a record.
enum WorshipStatus {
  done('Dilakukan'),
  notDone('Tidak dilakukan');

  const WorshipStatus(this.label);
  final String label;
}
