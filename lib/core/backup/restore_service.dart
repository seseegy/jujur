import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../features/settings/domain/preferences.dart';
import '../database/app_database.dart';
import '../util/ids.dart';
import 'backup_data.dart';
import 'backup_schema.dart';

enum RestoreMode { replace, merge }

class TableMergeStats {
  int inserted = 0;
  int identical = 0;

  /// Same identifier or same natural key with different content. The local
  /// record is kept unchanged.
  int conflicts = 0;

  /// Skipped because the record it belongs to was a conflict.
  int skippedDependents = 0;
}

class RestoreResult {
  RestoreResult(this.mode);

  final RestoreMode mode;
  final Map<String, TableMergeStats> tables = {
    for (final t in backupTables) t.name: TableMergeStats(),
  };
  int settingsApplied = 0;

  int get inserted => tables.values.fold(0, (a, s) => a + s.inserted);
  int get identical => tables.values.fold(0, (a, s) => a + s.identical);
  int get conflicts => tables.values.fold(0, (a, s) => a + s.conflicts);
  int get skippedDependents => tables.values.fold(0, (a, s) => a + s.skippedDependents);
}

class _DryRunRollback implements Exception {
  const _DryRunRollback();
}

/// Applies a validated backup to the database inside a single transaction.
///
/// - [RestoreMode.replace] deletes all records and settings (except
///   device-local ones) and inserts the backup's records.
/// - [RestoreMode.merge] only adds records that do not exist yet. When a
///   record exists with different content (same id, or same natural key such
///   as habit + date), the local record is kept and counted as a conflict.
///   Local data is never overwritten by a merge.
///
/// If anything fails, the transaction rolls back and the database is left
/// exactly as it was.
class RestoreService {
  RestoreService(this._db, {@visibleForTesting this.beforeInsert});

  final AppDatabase _db;

  /// Test hook invoked before each row insert (used to simulate failures).
  final void Function(String table, int index)? beforeInsert;

  Future<RestoreResult> restore(BackupData data, RestoreMode mode) => switch (mode) {
    RestoreMode.replace => _replace(data),
    RestoreMode.merge => _merge(data, dryRun: false),
  };

  /// Computes what a merge would do without changing anything.
  Future<RestoreResult> previewMerge(BackupData data) => _merge(data, dryRun: true);

  Future<RestoreResult> _replace(BackupData data) async {
    final result = RestoreResult(RestoreMode.replace);
    await _db.transaction(() async {
      for (final spec in backupTables.reversed) {
        await _db.customStatement('DELETE FROM ${spec.name}');
      }
      await _db.customStatement(
        "DELETE FROM app_settings WHERE key NOT LIKE '${SettingKeys.localOnlyPrefix}%'",
      );
      for (final spec in backupTables) {
        for (final (i, row) in data.tables[spec.name]!.indexed) {
          await _insert(spec, row, i);
          result.tables[spec.name]!.inserted++;
        }
      }
      result.settingsApplied = await _insertSettings(data.settings, onlyMissing: false);
      await _checkForeignKeys();
    });
    return result;
  }

  Future<RestoreResult> _merge(BackupData data, {required bool dryRun}) async {
    final result = RestoreResult(RestoreMode.merge);
    try {
      await _db.transaction(() async {
        // Backup ids that will not exist locally after the merge.
        final unavailable = <String, Set<String>>{};
        for (final spec in backupTables) {
          final stats = result.tables[spec.name]!;
          final missing = unavailable.putIfAbsent(spec.name, () => {});
          for (final (i, row) in data.tables[spec.name]!.indexed) {
            final id = row['id']! as String;
            final local = await _localRow(spec, const ['id'], [id]);
            if (local != null) {
              if (_sameContent(spec, local, row, data.schemaVersion)) {
                stats.identical++;
              } else {
                stats.conflicts++;
              }
              continue;
            }
            final dependsOnMissing = spec.columns.any(
              (c) =>
                  c.references != null &&
                  row[c.name] != null &&
                  (unavailable[c.references]?.contains(row[c.name]) ?? false),
            );
            if (dependsOnMissing) {
              stats.skippedDependents++;
              missing.add(id);
              continue;
            }
            var naturalConflict = false;
            for (final cols in spec.naturalKeys) {
              final existing = await _localRow(spec, cols, [for (final c in cols) row[c]]);
              if (existing != null) {
                naturalConflict = true;
                break;
              }
            }
            if (naturalConflict) {
              stats.conflicts++;
              missing.add(id);
              continue;
            }
            await _insert(spec, row, i);
            stats.inserted++;
          }
        }
        result.settingsApplied = await _insertSettings(data.settings, onlyMissing: true);
        await _checkForeignKeys();
        if (dryRun) throw const _DryRunRollback();
      });
    } on _DryRunRollback {
      // Expected: preview changes were rolled back.
    }
    return result;
  }

  Future<Map<String, Object?>?> _localRow(
    TableSpec spec,
    List<String> columns,
    List<Object?> values,
  ) async {
    final where = columns.map((c) => '$c = ?').join(' AND ');
    final rows = await _db
        .customSelect(
          'SELECT * FROM ${spec.name} WHERE $where LIMIT 1',
          variables: [for (final v in values) _variable(v)],
        )
        .get();
    return rows.isEmpty ? null : rows.first.data;
  }

  bool _sameContent(TableSpec spec, Map<String, Object?> local, Map<String, Object?> backup, int schemaVersion) {
    for (final c in spec.columnsFor(schemaVersion)) {
      // Audit timestamps differ for identical seeded definitions.
      if (c.name == 'created_at' || c.name == 'updated_at') continue;
      final a = _normalize(c, local[c.name]);
      final b = _normalize(c, backup[c.name]);
      if (a != b) return false;
    }
    return true;
  }

  Object? _normalize(ColumnSpec c, Object? v) {
    if (v == null) return null;
    return switch (c.type) {
      ColumnType.boolean => v == true || v == 1,
      ColumnType.real => (v as num).toDouble(),
      _ => v,
    };
  }

  Future<void> _insert(TableSpec spec, Map<String, Object?> row, int index) async {
    beforeInsert?.call(spec.name, index);
    final cols = row.keys.toList();
    await _db.customInsert(
      'INSERT INTO ${spec.name} (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')})',
      variables: [for (final c in cols) _variable(row[c])],
    );
  }

  Future<int> _insertSettings(Map<String, String> settings, {required bool onlyMissing}) async {
    var applied = 0;
    final now = nowUtcMillis();
    for (final e in settings.entries) {
      if (e.key.startsWith(SettingKeys.localOnlyPrefix)) continue;
      final inserted = await _db.customInsert(
        onlyMissing
            ? 'INSERT OR IGNORE INTO app_settings (key, value, updated_at) VALUES (?, ?, ?)'
            : 'INSERT OR REPLACE INTO app_settings (key, value, updated_at) VALUES (?, ?, ?)',
        variables: [Variable(e.key), Variable(e.value), Variable(now)],
      );
      if (inserted > 0) applied++;
    }
    return applied;
  }

  Future<void> _checkForeignKeys() async {
    final problems = await _db.customSelect('PRAGMA foreign_key_check').get();
    if (problems.isNotEmpty) {
      throw StateError('Relasi data tidak konsisten setelah pemulihan.');
    }
  }

  static Variable _variable(Object? v) => switch (v) {
    null => const Variable(null),
    final bool b => Variable<bool>(b),
    final int i => Variable<int>(i),
    final double d => Variable<double>(d),
    final String s => Variable<String>(s),
    _ => throw ArgumentError('Unsupported value'),
  };
}
