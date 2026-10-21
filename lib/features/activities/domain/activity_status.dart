/// Status of a logged activity.
///
/// Enum names are persisted in the database and in backups; do not rename.
enum ActivityStatus {
  /// The user confirms the activity was done.
  done('Selesai'),

  /// Partially done.
  partial('Sebagian'),

  /// Planned or intended, but not yet confirmed.
  planned('Direncanakan'),

  /// The user consciously records that it did not happen.
  notDone('Tidak dilakukan');

  const ActivityStatus(this.label);
  final String label;
}
