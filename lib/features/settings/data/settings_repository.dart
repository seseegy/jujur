import 'dart:convert';


import '../../../core/database/app_database.dart';
import '../../../core/util/ids.dart';
import '../domain/preferences.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<Preferences> watch() => _db
      .select(_db.appSettings)
      .watch()
      .map((rows) => Preferences({for (final r in rows) r.key: r.value}));

  Future<Preferences> load() async {
    final rows = await _db.select(_db.appSettings).get();
    return Preferences({for (final r in rows) r.key: r.value});
  }

  Future<void> set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.appSettings)..where((t) => t.key.equals(key))).go();
      return;
    }
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: nowUtcMillis(),
          ),
        );
  }

  Future<void> setAll(Map<String, String?> values) =>
      _db.transaction(() async {
        for (final e in values.entries) {
          await set(e.key, e.value);
        }
      });

  Future<void> setBool(String key, bool value) => set(key, value.toString());

  Future<void> setJson(String key, Object value) => set(key, jsonEncode(value));
}
