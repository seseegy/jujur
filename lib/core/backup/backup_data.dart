import '../database/app_database.dart';
import '../../features/settings/domain/preferences.dart';
import 'backup_schema.dart';

/// All backed-up records, as JSON-ready rows keyed by table name.
class BackupData {
  const BackupData({required this.schemaVersion, required this.tables, required this.settings});

  final int schemaVersion;
  final Map<String, List<Map<String, Object?>>> tables;

  /// Synchronizable settings (device-local keys are excluded).
  final Map<String, String> settings;

  Map<String, int> get counts => {
    for (final t in backupTables) t.name: tables[t.name]?.length ?? 0,
    'settings': settings.length,
  };

  int get recordCount => tables.values.fold(0, (a, rows) => a + rows.length);

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'tables': {for (final t in backupTables) t.name: tables[t.name] ?? const []},
    'settings': settings,
  };
}

/// Reads a consistent snapshot of every backed-up table.
Future<BackupData> readBackupData(AppDatabase db) => db.transaction(() async {
  final tables = <String, List<Map<String, Object?>>>{};
  for (final spec in backupTables) {
    final rows = await db
        .customSelect('SELECT * FROM ${spec.name} ORDER BY id')
        .get();
    tables[spec.name] = [
      for (final row in rows)
        {
          for (final c in spec.columnsFor(db.schemaVersion))
            c.name: _toJsonValue(c, row.data[c.name]),
        },
    ];
  }
  final settingsRows = await db.select(db.appSettings).get();
  return BackupData(
    schemaVersion: db.schemaVersion,
    tables: tables,
    settings: {
      for (final s in settingsRows)
        if (!s.key.startsWith(SettingKeys.localOnlyPrefix)) s.key: s.value,
    },
  );
});

Object? _toJsonValue(ColumnSpec c, Object? value) {
  if (value == null) return null;
  return switch (c.type) {
    ColumnType.boolean => value == 1 || value == true,
    ColumnType.real => (value as num).toDouble(),
    _ => value,
  };
}
