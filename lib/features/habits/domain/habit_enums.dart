/// Enum names are persisted in the database and in backups; do not rename.
library;

enum HabitTrackingType {
  /// Done / not done.
  check('Centang'),

  /// A countable amount, e.g. pages.
  quantity('Jumlah'),

  /// Minutes.
  duration('Durasi (menit)');

  const HabitTrackingType(this.label);
  final String label;
}

enum RecurrenceType {
  daily('Setiap hari'),
  weekdays('Hari tertentu'),
  interval('Setiap beberapa hari'),
  once('Sekali saja');

  const RecurrenceType(this.label);
  final String label;
}

/// Recorded status of a habit for one date. "Not recorded" is the absence of
/// a record, never a stored value.
enum HabitStatus {
  done('Selesai'),
  partial('Sebagian'),
  skipped('Dilewati'),
  notDone('Tidak dilakukan');

  const HabitStatus(this.label);
  final String label;
}
