import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch.dart';
import '../../../core/date/local_date.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/util/ids.dart';
import '../domain/worship_enums.dart';

class WorshipForDay {
  const WorshipForDay(this.item, this.record);
  final WorshipItem item;
  final WorshipRecord? record;
}

class WorshipRepository {
  WorshipRepository(this._db);

  final AppDatabase _db;

  Stream<List<WorshipItem>> watchItems({bool includeArchived = true}) {
    final q = _db.select(_db.worshipItems)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
    if (!includeArchived) q.where((t) => t.archived.equals(false));
    return q.watch();
  }

  /// Items shown on the day view: active items marked for Today, plus any
  /// item (even hidden or archived) that already has a record on [date].
  Future<List<WorshipForDay>> loadForDate(LocalDate date) async {
    final items = await (_db.select(_db.worshipItems)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    final records = await (_db.select(_db.worshipRecords)
          ..where((t) => t.dateKey.equals(date.key)))
        .get();
    final byItem = {for (final r in records) r.itemId: r};
    return [
      for (final item in items)
        if ((item.showOnToday && !item.archived) || byItem[item.id] != null)
          WorshipForDay(item, byItem[item.id]),
    ];
  }

  Stream<List<WorshipForDay>> watchForDate(LocalDate date) => _db.watchTables(
    {_db.worshipItems, _db.worshipRecords},
    () => loadForDate(date),
  );

  /// Validates a value according to the item's tracking type.
  static void validateRecord(
    WorshipItem item,
    WorshipStatus status,
    double? value,
    String? note,
  ) {
    if (status == WorshipStatus.notDone) return;
    switch (item.trackingType) {
      case WorshipTrackingType.check:
        return;
      case WorshipTrackingType.count:
        if (value == null || value <= 0 || value != value.roundToDouble()) {
          throw const ValidationFailure('Isi jumlah berupa bilangan bulat lebih dari 0.');
        }
      case WorshipTrackingType.duration:
        if (value == null || value <= 0 || value > 24 * 60) {
          throw const ValidationFailure('Isi durasi antara 1 dan 1440 menit.');
        }
      case WorshipTrackingType.note:
        if (note == null || note.trim().isEmpty) {
          throw const ValidationFailure('Catatan wajib diisi untuk jenis ini.');
        }
    }
  }

  Future<void> setRecord({
    required WorshipItem item,
    required LocalDate date,
    required WorshipStatus status,
    double? value,
    String? note,
  }) async {
    validateRecord(item, status, value, note);
    final storedValue =
        status == WorshipStatus.notDone ||
            item.trackingType == WorshipTrackingType.check ||
            item.trackingType == WorshipTrackingType.note
        ? null
        : value;
    final cleanNote = (note == null || note.trim().isEmpty) ? null : note.trim();
    await _db.transaction(() async {
      final now = nowUtcMillis();
      final existing = await _record(item.id, date);
      if (existing == null) {
        await _db
            .into(_db.worshipRecords)
            .insert(
              WorshipRecordsCompanion.insert(
                id: newId(),
                itemId: item.id,
                dateKey: date.key,
                status: status,
                value: Value(storedValue),
                note: Value(cleanNote),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.worshipRecords)..where((t) => t.id.equals(existing.id)))
            .write(
              WorshipRecordsCompanion(
                status: Value(status),
                value: Value(storedValue),
                note: Value(cleanNote),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }

  Future<void> clearRecord(String itemId, LocalDate date) =>
      (_db.delete(_db.worshipRecords)
            ..where((t) => t.itemId.equals(itemId) & t.dateKey.equals(date.key)))
          .go();

  Future<void> restoreRecord(String itemId, LocalDate date, WorshipRecord? previous) =>
      _db.transaction(() async {
        await clearRecord(itemId, date);
        if (previous != null) await _db.into(_db.worshipRecords).insert(previous);
      });

  Future<WorshipRecord?> _record(String itemId, LocalDate date) =>
      (_db.select(_db.worshipRecords)
            ..where((t) => t.itemId.equals(itemId) & t.dateKey.equals(date.key)))
          .getSingleOrNull();

  Future<String> createItem({
    required String name,
    required WorshipTrackingType type,
    String? unit,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationFailure('Nama ibadah wajib diisi.');
    if (trimmed.length > 80) throw const ValidationFailure('Nama maksimal 80 karakter.');
    final now = nowUtcMillis();
    final max = _db.worshipItems.sortOrder.max();
    final order = await (_db.selectOnly(_db.worshipItems)..addColumns([max]))
        .map((r) => r.read(max))
        .getSingle();
    final id = newId();
    await _db
        .into(_db.worshipItems)
        .insert(
          WorshipItemsCompanion.insert(
            id: id,
            name: trimmed,
            trackingType: type,
            unit: Value(_unitFor(type, unit)),
            showOnToday: const Value(true),
            sortOrder: Value((order ?? 0) + 1),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateItem(String id, {required String name, String? unit}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const ValidationFailure('Nama ibadah wajib diisi.');
    final item = await (_db.select(_db.worshipItems)..where((t) => t.id.equals(id)))
        .getSingle();
    await (_db.update(_db.worshipItems)..where((t) => t.id.equals(id))).write(
      WorshipItemsCompanion(
        name: Value(trimmed),
        unit: Value(_unitFor(item.trackingType, unit)),
        updatedAt: Value(nowUtcMillis()),
      ),
    );
  }

  Future<void> setShowOnToday(String id, bool show) =>
      (_db.update(_db.worshipItems)..where((t) => t.id.equals(id))).write(
        WorshipItemsCompanion(showOnToday: Value(show), updatedAt: Value(nowUtcMillis())),
      );

  Future<void> setShownItems(Set<String> ids) => _db.transaction(() async {
    final now = nowUtcMillis();
    final items = await _db.select(_db.worshipItems).get();
    for (final item in items) {
      final show = ids.contains(item.id);
      if (item.showOnToday != show) {
        await (_db.update(_db.worshipItems)..where((t) => t.id.equals(item.id)))
            .write(WorshipItemsCompanion(showOnToday: Value(show), updatedAt: Value(now)));
      }
    }
  });

  Future<void> setArchived(String id, bool archived) =>
      (_db.update(_db.worshipItems)..where((t) => t.id.equals(id))).write(
        WorshipItemsCompanion(
          archived: Value(archived),
          showOnToday: archived ? const Value(false) : const Value.absent(),
          updatedAt: Value(nowUtcMillis()),
        ),
      );

  Future<int> recordCount(String id) async {
    final count = _db.worshipRecords.id.count();
    return (await (_db.selectOnly(_db.worshipRecords)
              ..addColumns([count])
              ..where(_db.worshipRecords.itemId.equals(id)))
            .map((r) => r.read(count))
            .getSingle()) ??
        0;
  }

  Future<void> deletePermanently(String id) => _db.transaction(() async {
    await (_db.delete(_db.worshipRecords)..where((t) => t.itemId.equals(id))).go();
    await (_db.delete(_db.worshipItems)..where((t) => t.id.equals(id))).go();
  });

  static String? _unitFor(WorshipTrackingType type, String? unit) => switch (type) {
    WorshipTrackingType.count =>
      (unit == null || unit.trim().isEmpty) ? 'kali' : unit.trim(),
    WorshipTrackingType.duration => 'menit',
    _ => null,
  };
}
