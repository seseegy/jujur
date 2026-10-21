import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/backup/backup_data.dart';
import 'package:jujur/core/backup/backup_format.dart';
import 'package:jujur/core/backup/backup_reader.dart';
import 'package:jujur/core/backup/backup_writer.dart';
import 'package:jujur/core/backup/restore_service.dart';
import 'package:jujur/core/database/app_database.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/prayers/data/prayer_repository.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';

import '../helpers/fixtures.dart';

/// Rebuilds a ZIP with a modified manifest and/or payload, recomputing the
/// checksum unless [keepChecksum] is set.
Uint8List rebuild(
  Uint8List zip, {
  Map<String, Object?> Function(Map<String, Object?>)? manifest,
  List<int> Function(List<int>)? payload,
  bool keepChecksum = false,
  bool dropManifest = false,
  bool dropPayload = false,
}) {
  final archive = ZipDecoder().decodeBytes(zip);
  var m = jsonDecode(utf8.decode(archive.findFile(BackupFormat.manifestFile)!.content)) as Map<String, Object?>;
  final payloadName = (m['payload']! as Map)['file'] as String;
  var data = archive.findFile(payloadName)!.content.toList();
  if (payload != null) {
    data = payload(data);
    if (!keepChecksum) {
      m = {
        ...m,
        'payload': {'file': payloadName, 'sha256': sha256.convert(data).toString(), 'bytes': data.length},
      };
    }
  }
  if (manifest != null) m = manifest(m);
  final out = Archive();
  if (!dropManifest) out.add(ArchiveFile.string(BackupFormat.manifestFile, jsonEncode(m)));
  if (!dropPayload) out.add(ArchiveFile.bytes(payloadName, data));
  return ZipEncoder().encodeBytes(out);
}

List<int> editData(List<int> bytes, void Function(Map<String, dynamic> json) edit) {
  final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  edit(json);
  return utf8.encode(jsonEncode(json));
}

Map<String, List<Map<String, Object?>>> withoutAudit(Map<String, List<Map<String, Object?>>> dump) => {
  for (final e in dump.entries)
    e.key: [
      for (final r in e.value) {...r}..remove('created_at')..remove('updated_at'),
    ],
};

Matcher throwsBackup(BackupErrorCode code) =>
    throwsA(isA<BackupException>().having((e) => e.code, 'code', code));

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase source;
  late Uint8List backup;
  late Map<String, List<Map<String, Object?>>> sourceDump;

  setUp(() async {
    source = openInMemoryDatabase();
    await populate(source);
    sourceDump = await dumpTables(source);
    backup = (await BackupWriter(source, appVersion: 'test').create()).bytes;
  });
  tearDown(() => source.close());

  group('creation', () {
    test('contains a manifest, versions, counts and a valid checksum', () async {
      final archive = ZipDecoder().decodeBytes(backup);
      final manifest = jsonDecode(utf8.decode(archive.findFile('manifest.json')!.content)) as Map;
      expect(manifest['format'], 'jujur-backup');
      expect(manifest['formatVersion'], 1);
      expect(manifest['schemaVersion'], AppDatabase.currentSchemaVersion);
      expect(manifest['encrypted'], isFalse);
      expect((manifest['counts'] as Map)['activities'], 2);
      expect((manifest['counts'] as Map)['prayer_records'], 2);
      final data = archive.findFile('data.json')!.content;
      expect((manifest['payload'] as Map)['sha256'], sha256.convert(data).toString());
    });

    test('excludes device-local settings and includes synchronized ones', () async {
      final v = await BackupReader.read(backup);
      expect(v.data.settings['week_start'], '7');
      expect(v.data.settings.keys.where((k) => k.startsWith('local.')), isEmpty);
    });
  });

  group('restore', () {
    test('valid backup restores into an empty database exactly', () async {
      final target = openInMemoryDatabase();
      await target.customStatement('DELETE FROM categories');
      await target.customStatement('DELETE FROM worship_items');
      final v = await BackupReader.read(backup);
      await RestoreService(target).restore(v.data, RestoreMode.replace);
      expect(await dumpTables(target), sourceDump);
      final reflection = await target.select(target.reflections).getSingle();
      expect(reflection.body, indonesianText);
      await target.close();
    });

    test('replace over an existing database removes old records', () async {
      final target = openInMemoryDatabase();
      await PrayerRepository(target).setStatus(prayer: Prayer.isya, date: LocalDate(2020, 1, 1), status: PrayerStatus.done);
      final v = await BackupReader.read(backup);
      await RestoreService(target).restore(v.data, RestoreMode.replace);
      expect(await dumpTables(target), sourceDump);
      await target.close();
    });

    test('restoring an empty backup into a populated database is explicit replace', () async {
      final empty = openInMemoryDatabase();
      await empty.customStatement('DELETE FROM categories');
      await empty.customStatement('DELETE FROM worship_items');
      final emptyBackup = (await BackupWriter(empty, appVersion: 'test').create()).bytes;
      final v = await BackupReader.read(emptyBackup);
      expect(v.data.recordCount, 0);
      final target = openInMemoryDatabase();
      await populate(target);
      await RestoreService(target).restore(v.data, RestoreMode.replace);
      expect((await dumpTables(target)).values.every((rows) => rows.isEmpty), isTrue);
      await empty.close();
      await target.close();
    });

    test('merge adds new records and never overwrites conflicting local data', () async {
      final target = openInMemoryDatabase();
      final v = await BackupReader.read(backup);
      // Seeded categories/worship items are identical; everything else is new.
      var result = await RestoreService(target).restore(v.data, RestoreMode.merge);
      expect(result.conflicts, 0);
      expect(result.identical, 9 + 9);
      // Seeded definitions keep their local timestamps; all content matches.
      expect(withoutAudit(await dumpTables(target)), withoutAudit(sourceDump));

      // Change a local record, then merge again: local value must survive.
      final d = LocalDate(2026, 10, 19);
      await PrayerRepository(target).setStatus(prayer: Prayer.magrib, date: d, status: PrayerStatus.qadha);
      result = await RestoreService(target).restore(v.data, RestoreMode.merge);
      expect(result.inserted, 0);
      expect(result.conflicts, 1);
      final magrib = await PrayerRepository(target).find(Prayer.magrib, d);
      expect(magrib!.status, PrayerStatus.qadha);
      await target.close();
    });

    test('merge treats same habit and date with different ids as a conflict', () async {
      final target = openInMemoryDatabase();
      final v = await BackupReader.read(backup);
      await RestoreService(target).restore(v.data, RestoreMode.merge);
      // Re-create the record under a new id locally.
      final habitId = (await target.select(target.habits).get()).firstWhere((h) => h.name == 'Olahraga').id;
      final d = LocalDate(2026, 10, 19);
      await HabitRepository(target).clearRecord(habitId, d);
      await HabitRepository(target).setRecord(habitId: habitId, date: d, status: HabitStatus.notDone);
      final result = await RestoreService(target).restore(v.data, RestoreMode.merge);
      expect(result.tables['habit_records']!.conflicts, 1);
      final record = await (target.select(target.habitRecords)..where((t) => t.habitId.equals(habitId))).getSingle();
      expect(record.status, HabitStatus.notDone);
      await target.close();
    });

    test('merge preview changes nothing', () async {
      final target = openInMemoryDatabase();
      final before = await dumpTables(target);
      final v = await BackupReader.read(backup);
      final preview = await RestoreService(target).previewMerge(v.data);
      expect(preview.inserted, greaterThan(0));
      expect(await dumpTables(target), before);
      await target.close();
    });

    test('interrupted restore rolls back and keeps existing data', () async {
      final target = openInMemoryDatabase();
      await populate(target, day: LocalDate(2025, 1, 1));
      final before = await dumpTables(target);
      final v = await BackupReader.read(backup);
      final failing = RestoreService(
        target,
        beforeInsert: (table, index) {
          if (table == 'prayer_records' && index == 1) throw StateError('simulasi gangguan');
        },
      );
      await expectLater(failing.restore(v.data, RestoreMode.replace), throwsStateError);
      expect(await dumpTables(target), before);
      await expectLater(failing.restore(v.data, RestoreMode.merge), throwsStateError);
      expect(await dumpTables(target), before);
      await target.close();
    });

    test('failed database write during restore leaves data unchanged', () async {
      final target = openInMemoryDatabase();
      await populate(target, day: LocalDate(2025, 1, 1));
      final before = await dumpTables(target);
      final v = await BackupReader.read(backup);
      // Corrupt one row after validation so the INSERT violates a CHECK.
      final rows = v.data.tables['activities']!;
      rows[1] = {...rows[1], 'start_minute': 5000};
      await expectLater(RestoreService(target).restore(v.data, RestoreMode.replace), throwsA(anything));
      expect(await dumpTables(target), before);
      await target.close();
    });

    test('backup from an older schema version (v1) restores with defaults', () async {
      final v = await BackupReader.read(backup);
      final json = v.data.toJson();
      json['schemaVersion'] = 1;
      for (final row in (json['tables']! as Map)['activities'] as List) {
        (row as Map).remove('tags');
      }
      final old = BackupReader.validateData(jsonDecode(jsonEncode(json)), 1);
      final target = openInMemoryDatabase();
      await RestoreService(target).restore(old, RestoreMode.replace);
      final activities = await target.select(target.activities).get();
      expect(activities, hasLength(2));
      expect(activities.every((a) => a.tags == null), isTrue);
      await target.close();
    });
  });

  group('validation rejects', () {
    test('a file that is not an archive', () {
      expect(BackupReader.read(utf8.encode('bukan zip')), throwsBackup(BackupErrorCode.notArchive));
    });

    test('an archive without a manifest', () {
      expect(BackupReader.read(rebuild(backup, dropManifest: true)), throwsBackup(BackupErrorCode.missingManifest));
    });

    test('an archive without the data file', () {
      expect(BackupReader.read(rebuild(backup, dropPayload: true)), throwsBackup(BackupErrorCode.missingData));
    });

    test('an unsupported format version', () {
      final bytes = rebuild(backup, manifest: (m) => {...m, 'formatVersion': 99});
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.unsupportedVersion));
    });

    test('a newer schema version', () {
      final bytes = rebuild(backup, manifest: (m) => {...m, 'schemaVersion': 99});
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.newerSchema));
    });

    test('a different file format', () {
      final bytes = rebuild(backup, manifest: (m) => {...m, 'format': 'other-app'});
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.unsupportedFormat));
    });

    test('a payload whose checksum does not match', () {
      final bytes = rebuild(backup, payload: (d) => [...d]..[10] = d[10] ^ 1, keepChecksum: true);
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.checksumMismatch));
    });

    test('corrupted JSON', () {
      final bytes = rebuild(backup, payload: (d) => d.sublist(0, d.length ~/ 2));
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.invalidJson));
    });

    test('duplicate identifiers', () {
      final bytes = rebuild(backup, payload: (d) => editData(d, (json) {
        final rows = json['tables']['activities'] as List;
        rows.add(Map<String, dynamic>.from(rows.first as Map)..['date_key'] = '2026-01-01');
      }), manifest: (m) => {...m, 'counts': {}});
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.duplicateId));
    });

    test('duplicate natural keys (same prayer on same date)', () {
      final bytes = rebuild(backup, payload: (d) => editData(d, (json) {
        final rows = json['tables']['prayer_records'] as List;
        rows.add(Map<String, dynamic>.from(rows.first as Map)..['id'] = 'other-id');
      }), manifest: (m) => {...m, 'counts': {}});
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.duplicateId));
    });

    test('broken relationships', () {
      final bytes = rebuild(backup, payload: (d) => editData(d, (json) {
        ((json['tables']['habit_records'] as List).first as Map)['habit_id'] = 'tidak-ada';
      }));
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.brokenRelation));
    });

    test('wrong data types and unknown enum values', () {
      final wrongType = rebuild(backup, payload: (d) => editData(d, (json) {
        ((json['tables']['activities'] as List).first as Map)['created_at'] = 'kemarin';
      }));
      expect(BackupReader.read(wrongType), throwsBackup(BackupErrorCode.invalidRecord));
      final badEnum = rebuild(backup, payload: (d) => editData(d, (json) {
        ((json['tables']['prayer_records'] as List).first as Map)['status'] = 'mungkin';
      }));
      expect(BackupReader.read(badEnum), throwsBackup(BackupErrorCode.invalidRecord));
      final badDate = rebuild(backup, payload: (d) => editData(d, (json) {
        ((json['tables']['prayer_records'] as List).first as Map)['date_key'] = '2026-02-30';
      }));
      expect(BackupReader.read(badDate), throwsBackup(BackupErrorCode.invalidRecord));
    });

    test('counts that do not match the manifest', () {
      final bytes = rebuild(backup, payload: (d) => editData(d, (json) {
        (json['tables']['activities'] as List).removeLast();
      }));
      expect(BackupReader.read(bytes), throwsBackup(BackupErrorCode.countMismatch));
    });

    test('and leaves the database unchanged', () async {
      final target = openInMemoryDatabase();
      await populate(target, day: LocalDate(2025, 1, 1));
      final before = await dumpTables(target);
      final bytes = rebuild(backup, payload: (d) => d.sublist(0, 20));
      Future<void> attempt() async {
        final v = await BackupReader.read(bytes);
        await RestoreService(target).restore(v.data, RestoreMode.replace);
      }

      await expectLater(attempt(), throwsA(isA<BackupException>()));
      expect(await dumpTables(target), before);
      await target.close();
    });
  });

  group('encryption', () {
    test('encrypted backup round-trips with the right password only', () async {
      final created = await BackupWriter(source, appVersion: 'test').create(password: 'rahasia-123', iterations: 10000);
      final manifest = BackupReader.readManifest(created.bytes);
      expect(manifest.encrypted, isTrue);
      expect(manifest.encryption!.algorithm, 'AES-256-GCM');
      // Plain text must not appear in the archive.
      expect(utf8.decode(created.bytes, allowMalformed: true).contains('Alhamdulillah'), isFalse);

      await expectLater(BackupReader.read(created.bytes), throwsBackup(BackupErrorCode.passwordRequired));
      await expectLater(
        BackupReader.read(created.bytes, password: 'salah'),
        throwsBackup(BackupErrorCode.wrongPassword),
      );
      final v = await BackupReader.read(created.bytes, password: 'rahasia-123');
      final target = openInMemoryDatabase();
      await RestoreService(target).restore(v.data, RestoreMode.replace);
      expect(await dumpTables(target), sourceDump);
      await target.close();
    });

    test('two encrypted backups use different salts and nonces', () async {
      final a = BackupReader.readManifest((await BackupWriter(source, appVersion: 't').create(password: 'x', iterations: 10000)).bytes);
      final b = BackupReader.readManifest((await BackupWriter(source, appVersion: 't').create(password: 'x', iterations: 10000)).bytes);
      expect(a.encryption!.salt, isNot(b.encryption!.salt));
      expect(a.encryption!.nonce, isNot(b.encryption!.nonce));
    });
  });

  test('BackupData JSON uses snake_case columns and booleans', () async {
    final data = await readBackupData(source);
    final activity = data.tables['activities']!.firstWhere((r) => r['title'] == 'Belajar Flutter, bab "state"');
    expect(activity['ends_next_day'], isTrue);
    expect(activity['date_key'], '2026-10-19');
    expect(activity['duration_minutes'], 150);
  });
}
