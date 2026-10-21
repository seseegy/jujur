import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' show SecretKey;

import '../database/app_database.dart';
import '../date/local_date.dart';
import 'backup_crypto.dart';
import 'backup_data.dart';
import 'backup_format.dart';
import 'backup_schema.dart';

class ValidatedBackup {
  const ValidatedBackup(this.manifest, this.data);
  final BackupManifest manifest;
  final BackupData data;
}

/// Parses and validates a backup archive without touching the database.
///
/// Checks, in order: archive structure, manifest, supported versions,
/// payload checksum, decryption, JSON structure, column types and enum
/// values, identifier uniqueness, natural-key uniqueness, relationships and
/// record counts. Any failure throws a [BackupException].
abstract final class BackupReader {
  /// Reads only the manifest (to ask for a password before full validation).
  static BackupManifest readManifest(List<int> bytes) {
    final archive = _decodeArchive(bytes);
    return _parseManifest(archive);
  }

  /// [derivedKey] lets the backup writer verify an archive it just
  /// encrypted without repeating the slow key derivation.
  static Future<ValidatedBackup> read(List<int> bytes, {String? password, SecretKey? derivedKey}) async {
    final archive = _decodeArchive(bytes);
    final manifest = _parseManifest(archive);

    final file = archive.findFile(manifest.payloadFile);
    if (file == null || !file.isFile) {
      throw const BackupException(
        BackupErrorCode.missingData,
        'Berkas data tidak ditemukan di dalam cadangan.',
      );
    }
    if (file.size > BackupFormat.maxPayloadBytes) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Isi cadangan terlalu besar.');
    }
    final Uint8List payload;
    try {
      payload = file.content;
    } on Object catch (e) {
      throw BackupException(BackupErrorCode.notArchive, 'Arsip cadangan rusak.', cause: e);
    }
    if (payload.length != manifest.payloadBytes ||
        sha256.convert(payload).toString() != manifest.payloadSha256) {
      throw const BackupException(
        BackupErrorCode.checksumMismatch,
        'Pemeriksaan integritas gagal: isi cadangan tidak sesuai dengan manifesnya.',
      );
    }

    List<int> plain = payload;
    final encryption = manifest.encryption;
    if (encryption != null) {
      if (password == null || password.isEmpty) {
        throw const BackupException(
          BackupErrorCode.passwordRequired,
          'Cadangan ini dilindungi kata sandi.',
        );
      }
      plain = await BackupCrypto.decrypt(payload, password, encryption, derivedKey: derivedKey);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(plain));
    } on FormatException catch (e) {
      throw BackupException(BackupErrorCode.invalidJson, 'Data cadangan bukan JSON yang valid.', cause: e);
    }
    final data = validateData(decoded, manifest.schemaVersion);
    for (final entry in data.counts.entries) {
      final expected = manifest.counts[entry.key];
      if (expected != null && expected != entry.value) {
        throw BackupException(
          BackupErrorCode.countMismatch,
          'Jumlah catatan "${entry.key}" tidak sesuai dengan manifes.',
        );
      }
    }
    return ValidatedBackup(manifest, data);
  }

  static Archive _decodeArchive(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      if (archive.files.isEmpty) throw const FormatException('empty');
      return archive;
    } on Object catch (e) {
      throw BackupException(
        BackupErrorCode.notArchive,
        'Berkas ini bukan arsip cadangan Jujur yang valid.',
        cause: e,
      );
    }
  }

  static BackupManifest _parseManifest(Archive archive) {
    final file = archive.findFile(BackupFormat.manifestFile);
    if (file == null) {
      throw const BackupException(
        BackupErrorCode.missingManifest,
        'Manifes cadangan tidak ditemukan. Berkas ini mungkin bukan cadangan Jujur.',
      );
    }
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(file.content));
    } on Object catch (e) {
      throw BackupException(BackupErrorCode.invalidManifest, 'Manifes cadangan rusak.', cause: e);
    }
    if (json is! Map<String, dynamic>) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Manifes cadangan rusak.');
    }
    if (json['format'] != BackupFormat.formatId) {
      throw const BackupException(
        BackupErrorCode.unsupportedFormat,
        'Berkas ini bukan cadangan Jujur.',
      );
    }
    final formatVersion = json['formatVersion'];
    if (formatVersion is! int || formatVersion < 1) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Versi format cadangan tidak valid.');
    }
    if (formatVersion > BackupFormat.formatVersion) {
      throw const BackupException(
        BackupErrorCode.unsupportedVersion,
        'Cadangan dibuat dengan format yang lebih baru. Perbarui aplikasi Jujur terlebih dahulu.',
      );
    }
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion is! int || schemaVersion < 1) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Versi skema cadangan tidak valid.');
    }
    if (schemaVersion > AppDatabase.currentSchemaVersion) {
      throw const BackupException(
        BackupErrorCode.newerSchema,
        'Cadangan berasal dari versi aplikasi yang lebih baru. Perbarui aplikasi Jujur terlebih dahulu.',
      );
    }
    final payload = json['payload'];
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    if (payload is! Map<String, dynamic> ||
        payload['file'] is! String ||
        payload['sha256'] is! String ||
        payload['bytes'] is! int ||
        createdAt == null) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Manifes cadangan tidak lengkap.');
    }
    final payloadFile = payload['file'] as String;
    if (payloadFile != BackupFormat.dataFile && payloadFile != BackupFormat.encryptedDataFile) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Manifes cadangan tidak valid.');
    }
    final countsJson = json['counts'];
    final counts = <String, int>{};
    if (countsJson is Map<String, dynamic>) {
      for (final e in countsJson.entries) {
        if (e.value is int) counts[e.key] = e.value as int;
      }
    }
    BackupEncryptionInfo? encryption;
    final enc = json['encryption'];
    if (json['encrypted'] == true) {
      if (enc is! Map<String, dynamic> ||
          enc['algorithm'] is! String ||
          enc['kdf'] is! String ||
          enc['iterations'] is! int ||
          enc['salt'] is! String ||
          enc['nonce'] is! String) {
        throw const BackupException(BackupErrorCode.invalidManifest, 'Informasi enkripsi tidak lengkap.');
      }
      encryption = BackupEncryptionInfo(
        algorithm: enc['algorithm'] as String,
        kdf: enc['kdf'] as String,
        iterations: enc['iterations'] as int,
        salt: enc['salt'] as String,
        nonce: enc['nonce'] as String,
      );
    }
    if ((encryption != null) != (payloadFile == BackupFormat.encryptedDataFile)) {
      throw const BackupException(BackupErrorCode.invalidManifest, 'Manifes cadangan tidak konsisten.');
    }
    return BackupManifest(
      formatVersion: formatVersion,
      schemaVersion: schemaVersion,
      appVersion: json['appVersion']?.toString() ?? '',
      createdAt: createdAt,
      payloadFile: payloadFile,
      payloadSha256: payload['sha256'] as String,
      payloadBytes: payload['bytes'] as int,
      counts: counts,
      encryption: encryption,
    );
  }

  /// Validates decoded payload JSON against the schema of [schemaVersion].
  static BackupData validateData(Object? decoded, int schemaVersion) {
    BackupException invalid(String message) =>
        BackupException(BackupErrorCode.invalidRecord, message);

    if (decoded is! Map<String, dynamic>) throw invalid('Struktur data cadangan tidak valid.');
    if (decoded['schemaVersion'] != schemaVersion) {
      throw invalid('Versi skema data tidak sesuai dengan manifes.');
    }
    final tablesJson = decoded['tables'];
    if (tablesJson is! Map<String, dynamic>) throw invalid('Daftar tabel cadangan tidak ditemukan.');
    for (final name in tablesJson.keys) {
      if (!backupTablesByName.containsKey(name)) {
        throw invalid('Cadangan berisi tabel yang tidak dikenal: $name.');
      }
    }

    final tables = <String, List<Map<String, Object?>>>{};
    final ids = <String, Set<String>>{};
    for (final spec in backupTables) {
      final rowsJson = tablesJson[spec.name];
      if (rowsJson is! List) throw invalid('Tabel "${spec.name}" tidak ada atau rusak.');
      final columns = spec.columnsFor(schemaVersion).toList();
      final tableIds = <String>{};
      final naturalKeys = [for (final _ in spec.naturalKeys) <String>{}];
      final rows = <Map<String, Object?>>[];
      for (final (index, rowJson) in rowsJson.indexed) {
        String where() => '${spec.name} baris ${index + 1}';
        if (rowJson is! Map<String, dynamic>) throw invalid('Format ${where()} tidak valid.');
        for (final key in rowJson.keys) {
          if (!columns.any((c) => c.name == key)) {
            throw invalid('${where()} memiliki kolom tidak dikenal "$key".');
          }
        }
        final row = <String, Object?>{};
        for (final c in columns) {
          final value = rowJson[c.name];
          if (value == null) {
            if (!c.nullable) throw invalid('${where()}: kolom "${c.name}" wajib diisi.');
            row[c.name] = null;
            continue;
          }
          final ok = switch (c.type) {
            ColumnType.text => value is String,
            ColumnType.integer => value is int,
            ColumnType.real => value is num,
            ColumnType.boolean => value is bool,
          };
          if (!ok) throw invalid('${where()}: tipe kolom "${c.name}" tidak valid.');
          if (c.enumValues != null && !c.enumValues!.contains(value)) {
            throw invalid('${where()}: nilai "${c.name}" tidak dikenal.');
          }
          if (c.isDateKey && LocalDate.tryParse(value as String) == null) {
            throw invalid('${where()}: tanggal "${c.name}" tidak valid.');
          }
          row[c.name] = c.type == ColumnType.real ? (value as num).toDouble() : value;
        }
        final id = row['id'];
        if (id is! String || id.isEmpty) throw invalid('${where()}: ID tidak valid.');
        if (!tableIds.add(id)) {
          throw BackupException(
            BackupErrorCode.duplicateId,
            'ID ganda ditemukan pada tabel "${spec.name}".',
          );
        }
        for (final (k, cols) in spec.naturalKeys.indexed) {
          final key = cols.map((c) => row[c]).join('\u0000');
          if (!naturalKeys[k].add(key)) {
            throw BackupException(
              BackupErrorCode.duplicateId,
              'Catatan ganda ditemukan pada tabel "${spec.name}".',
            );
          }
        }
        rows.add(row);
      }
      tables[spec.name] = rows;
      ids[spec.name] = tableIds;
    }

    // Relationships: every reference must point to a row in the backup.
    for (final spec in backupTables) {
      for (final c in spec.columns.where((c) => c.references != null)) {
        for (final row in tables[spec.name]!) {
          final ref = row[c.name];
          if (ref != null && !ids[c.references]!.contains(ref)) {
            throw BackupException(
              BackupErrorCode.brokenRelation,
              'Relasi data rusak: "${spec.name}" merujuk ke data "${c.references}" yang tidak ada.',
            );
          }
        }
      }
    }

    final settingsJson = decoded['settings'] ?? const <String, dynamic>{};
    if (settingsJson is! Map<String, dynamic>) throw invalid('Pengaturan cadangan tidak valid.');
    final settings = <String, String>{};
    for (final e in settingsJson.entries) {
      if (e.value is! String) throw invalid('Pengaturan "${e.key}" tidak valid.');
      settings[e.key] = e.value as String;
    }

    return BackupData(schemaVersion: schemaVersion, tables: tables, settings: settings);
  }
}
