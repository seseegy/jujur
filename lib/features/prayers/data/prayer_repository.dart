import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../../core/date/time_of_day_minutes.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/util/ids.dart';
import '../domain/prayer.dart';

/// Records for the five prayers of one date. A prayer without a record is
/// "Belum dicatat" — never "Terlewat".
class DayPrayers {
  const DayPrayers(this.date, this.records);

  final LocalDate date;
  final Map<Prayer, PrayerRecord> records;

  PrayerRecord? operator [](Prayer p) => records[p];
  int get recordedCount => records.length;
  int count(PrayerStatus s) => records.values.where((r) => r.status == s).length;
  int get unrecordedCount => Prayer.values.length - records.length;
}

class PrayerRepository {
  PrayerRepository(this._db);

  final AppDatabase _db;

  Stream<DayPrayers> watchDay(LocalDate date) =>
      (_db.select(_db.prayerRecords)..where((t) => t.dateKey.equals(date.key)))
          .watch()
          .map((rows) => DayPrayers(date, {for (final r in rows) r.prayer: r}));

  Future<PrayerRecord?> find(Prayer prayer, LocalDate date) =>
      (_db.select(_db.prayerRecords)
            ..where((t) => t.prayer.equalsValue(prayer) & t.dateKey.equals(date.key)))
          .getSingleOrNull();

  /// Creates or updates the record for [prayer] on [date]. Only an explicit
  /// user action reaches this method; nothing is inferred from the clock.
  Future<void> setStatus({
    required Prayer prayer,
    required LocalDate date,
    required PrayerStatus status,
    Value<int?> performedMinute = const Value.absent(),
    Value<bool?> jamaah = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) async {
    if (performedMinute.present && !MinuteOfDay.isValid(performedMinute.value)) {
      throw const ValidationFailure('Waktu pelaksanaan tidak valid.');
    }
    final cleanNote = note.present ? Value(_blank(note.value)) : note;
    await _db.transaction(() async {
      final now = nowUtcMillis();
      final existing = await find(prayer, date);
      // Completion details only make sense for performed prayers.
      final performed = status == PrayerStatus.done || status == PrayerStatus.qadha;
      if (existing == null) {
        await _db
            .into(_db.prayerRecords)
            .insert(
              PrayerRecordsCompanion.insert(
                id: newId(),
                prayer: prayer,
                dateKey: date.key,
                status: status,
                performedMinute: performed ? performedMinute : const Value(null),
                jamaah: performed ? jamaah : const Value(null),
                note: cleanNote,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.prayerRecords)..where((t) => t.id.equals(existing.id)))
            .write(
              PrayerRecordsCompanion(
                status: Value(status),
                performedMinute: performed ? performedMinute : const Value(null),
                jamaah: performed ? jamaah : const Value(null),
                note: cleanNote,
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  /// Removes the record: the prayer returns to "Belum dicatat".
  Future<void> clear(Prayer prayer, LocalDate date) =>
      (_db.delete(_db.prayerRecords)
            ..where((t) => t.prayer.equalsValue(prayer) & t.dateKey.equals(date.key)))
          .go();

  /// Restores an earlier state of one prayer (used by undo).
  Future<void> restore(Prayer prayer, LocalDate date, PrayerRecord? previous) =>
      _db.transaction(() async {
        await clear(prayer, date);
        if (previous != null) await _db.into(_db.prayerRecords).insert(previous);
      });

  static String? _blank(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();
}
