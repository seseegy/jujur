import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/util/ids.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Category>> watchAll({bool includeArchived = true}) {
    final q = _db.select(_db.categories)
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder), (t) => OrderingTerm(expression: t.name)]);
    if (!includeArchived) q.where((t) => t.archived.equals(false));
    return q.watch();
  }

  Future<String> create(String name, {String? description}) async {
    final trimmed = _validateName(name);
    await _ensureUniqueName(trimmed);
    final now = nowUtcMillis();
    final maxOrder = await _maxSortOrder();
    final id = newId();
    await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            name: trimmed,
            description: Value(description?.trim().isEmpty ?? true ? null : description!.trim()),
            sortOrder: Value(maxOrder + 1),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> rename(String id, String name) async {
    final trimmed = _validateName(name);
    await _ensureUniqueName(trimmed, exceptId: id);
    await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(name: Value(trimmed), updatedAt: Value(nowUtcMillis())),
    );
  }

  Future<void> setArchived(String id, bool archived) =>
      (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(
          archived: Value(archived),
          updatedAt: Value(nowUtcMillis()),
        ),
      );

  Future<int> usageCount(String id) async {
    final activities = _db.activities.id.count();
    final a = await (_db.selectOnly(_db.activities)
          ..addColumns([activities])
          ..where(_db.activities.categoryId.equals(id)))
        .map((r) => r.read(activities)!)
        .getSingle();
    return a;
  }

  /// Deletes an unused category. Categories used by activities can only be
  /// archived, so that no activity loses its category.
  Future<void> delete(String id) async {
    if (await usageCount(id) > 0) {
      throw const AppFailure(
        'Kategori ini masih dipakai oleh aktivitas. Arsipkan saja agar riwayat tetap utuh.',
      );
    }
    await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
  }

  String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Nama kategori wajib diisi.');
    }
    if (trimmed.length > 60) {
      throw const ValidationFailure('Nama kategori maksimal 60 karakter.');
    }
    return trimmed;
  }

  Future<void> _ensureUniqueName(String name, {String? exceptId}) async {
    final existing = await (_db.select(_db.categories)
          ..where((t) => t.name.lower().equals(name.toLowerCase())))
        .get();
    if (existing.any((c) => c.id != exceptId)) {
      throw const ValidationFailure('Kategori dengan nama ini sudah ada.');
    }
  }

  Future<int> _maxSortOrder() async {
    final max = _db.categories.sortOrder.max();
    return await (_db.selectOnly(_db.categories)..addColumns([max]))
            .map((r) => r.read(max))
            .getSingle() ??
        0;
  }
}
