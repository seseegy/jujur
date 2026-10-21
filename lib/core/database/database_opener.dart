import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'app_database.dart';

const databaseFileName = 'jujur.sqlite';

/// Opens the application database stored in [directory].
///
/// Before a schema upgrade, the existing file is copied to
/// `jujur.sqlite.v<old>.bak` so that a failed migration can never destroy the
/// only copy of the user's records. The database is never deleted or reset.
Future<AppDatabase> openAppDatabase({
  required Directory directory,
  String? tempDirectory,
}) async {
  if (tempDirectory != null) {
    sqlite3.tempDirectory = tempDirectory;
  }
  final file = File(p.join(directory.path, databaseFileName));
  await preserveBeforeUpgrade(file, AppDatabase.currentSchemaVersion);
  final db = AppDatabase(
    NativeDatabase.createInBackground(file, setup: configureConnection),
  );
  // Force opening now so that migration errors surface during bootstrap.
  await db.customSelect('SELECT 1').get();
  return db;
}

/// Pragmas applied to every connection.
void configureConnection(Database database) {
  database.execute('PRAGMA foreign_keys = ON;');
  database.execute('PRAGMA journal_mode = WAL;');
  database.execute('PRAGMA synchronous = NORMAL;');
}

/// Reads the stored schema version without opening the file through drift.
int readSchemaVersion(File file) {
  final raw = sqlite3.open(file.path, mode: OpenMode.readOnly);
  try {
    return raw.select('PRAGMA user_version').first.values.first as int;
  } finally {
    raw.close();
  }
}

/// Copies [file] next to itself when its schema is older than [target].
/// Returns the copy, or null when no upgrade is pending.
Future<File?> preserveBeforeUpgrade(File file, int target) async {
  if (!await file.exists()) return null;
  final version = readSchemaVersion(file);
  if (version == 0 || version >= target) return null;

  // Fold the WAL into the main file so the copy is self-contained.
  final raw = sqlite3.open(file.path);
  try {
    raw.execute('PRAGMA wal_checkpoint(TRUNCATE);');
  } finally {
    raw.close();
  }
  final copy = File('${file.path}.v$version.bak');
  if (!await copy.exists()) {
    await file.copy(copy.path);
  }
  return copy;
}

/// In-memory database for tests.
AppDatabase openInMemoryDatabase() =>
    AppDatabase(NativeDatabase.memory(setup: configureConnection));

/// Wraps an existing executor (used by tests that reopen a file).
AppDatabase openDatabaseFile(File file) =>
    AppDatabase(NativeDatabase(file, setup: configureConnection));
