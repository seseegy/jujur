import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../../core/util/ids.dart';
import '../domain/activity_draft.dart';

class ActivityRepository {
  ActivityRepository(this._db);

  final AppDatabase _db;

  Stream<List<Activity>> watchByDate(LocalDate date) {
    final q = _db.select(_db.activities)
      ..where((t) => t.dateKey.equals(date.key))
      ..orderBy([
        (t) => OrderingTerm(
          expression: t.startMinute,
          nulls: NullsOrder.last,
        ),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    return q.watch();
  }

  Future<Activity?> find(String id) =>
      (_db.select(_db.activities)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<Activity?> watchOne(String id) =>
      (_db.select(_db.activities)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<String> create(ActivityDraft draft) async {
    final duration = draft.validate();
    final now = nowUtcMillis();
    final id = newId();
    await _db
        .into(_db.activities)
        .insert(
          ActivitiesCompanion.insert(
            id: id,
            title: draft.title.trim(),
            description: Value(_blankToNull(draft.description)),
            categoryId: Value(draft.categoryId),
            dateKey: draft.date.key,
            startMinute: Value(draft.startMinute),
            endMinute: Value(draft.endMinute),
            endsNextDay: Value(draft.endsNextDay),
            durationMinutes: Value(duration),
            status: draft.status,
            notes: Value(_blankToNull(draft.notes)),
            tags: Value(_tags(draft.tags)),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> update(String id, ActivityDraft draft) async {
    final duration = draft.validate();
    final count =
        await (_db.update(_db.activities)..where((t) => t.id.equals(id))).write(
          ActivitiesCompanion(
            title: Value(draft.title.trim()),
            description: Value(_blankToNull(draft.description)),
            categoryId: Value(draft.categoryId),
            dateKey: Value(draft.date.key),
            startMinute: Value(draft.startMinute),
            endMinute: Value(draft.endMinute),
            endsNextDay: Value(draft.endsNextDay),
            durationMinutes: Value(duration),
            status: Value(draft.status),
            notes: Value(_blankToNull(draft.notes)),
            tags: Value(_tags(draft.tags)),
            updatedAt: Value(nowUtcMillis()),
          ),
        );
    if (count != 1) {
      throw StateError('Aktivitas tidak ditemukan.');
    }
  }

  /// Copies an activity (optionally to another date) with a new identifier.
  Future<String> duplicate(String id, {LocalDate? toDate}) async {
    final source = await find(id);
    if (source == null) throw StateError('Aktivitas tidak ditemukan.');
    final now = nowUtcMillis();
    final newIdValue = newId();
    await _db
        .into(_db.activities)
        .insert(
          source.copyWith(
            id: newIdValue,
            dateKey: toDate?.key ?? source.dateKey,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return newIdValue;
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.activities)..where((t) => t.id.equals(id))).go();

  /// Re-inserts a deleted activity exactly as it was (used by "Urungkan").
  Future<void> restore(Activity activity) =>
      _db.into(_db.activities).insert(activity, mode: InsertMode.insertOrIgnore);

  static String? _blankToNull(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  static String? _tags(List<String> tags) {
    final normalized = ActivityDraft.normalizeTags(tags);
    return normalized.isEmpty ? null : normalized.join(', ');
  }
}
