import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../database/app_database.dart';
import 'backup_crypto.dart';
import 'backup_data.dart';
import 'backup_format.dart';
import 'backup_reader.dart';

class CreatedBackup {
  const CreatedBackup({
    required this.bytes,
    required this.manifest,
    required this.fileName,
  });

  final Uint8List bytes;
  final BackupManifest manifest;
  final String fileName;
}

/// Builds a complete backup archive and verifies it by reading it back.
class BackupWriter {
  BackupWriter(this._db, {required this.appVersion, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final String appVersion;
  final DateTime Function() _clock;

  Future<CreatedBackup> create({String? password, int? iterations}) async {
    final data = await readBackupData(_db);
    final createdAt = _clock().toUtc();
    final plain = utf8.encode(jsonEncode(data.toJson()));

    Uint8List payload;
    BackupEncryptionInfo? encryption;
    if (password != null && password.isNotEmpty) {
      final (cipher, info) = await BackupCrypto.encrypt(
        plain,
        password,
        iterations: iterations ?? BackupCrypto.defaultIterations,
      );
      payload = cipher;
      encryption = info;
    } else {
      payload = Uint8List.fromList(plain);
    }

    final manifest = BackupManifest(
      formatVersion: BackupFormat.formatVersion,
      schemaVersion: data.schemaVersion,
      appVersion: appVersion,
      createdAt: createdAt,
      payloadFile: encryption == null ? BackupFormat.dataFile : BackupFormat.encryptedDataFile,
      payloadSha256: sha256.convert(payload).toString(),
      payloadBytes: payload.length,
      counts: data.counts,
      encryption: encryption,
    );

    final archive = Archive()
      ..add(ArchiveFile.string(
        BackupFormat.manifestFile,
        const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
      ))
      ..add(ArchiveFile.bytes(manifest.payloadFile, payload));
    final bytes = ZipEncoder().encodeBytes(archive);

    // Never report success for an archive that cannot be restored: parse and
    // fully validate what was just produced.
    final check = await BackupReader.read(bytes, password: password);
    if (check.data.recordCount != data.recordCount) {
      throw const BackupException(
        BackupErrorCode.countMismatch,
        'Verifikasi cadangan gagal. Cadangan tidak disimpan.',
      );
    }

    return CreatedBackup(bytes: bytes, manifest: manifest, fileName: fileNameFor(_clock()));
  }

  static String fileNameFor(DateTime local) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'jujur-cadangan-${local.year}${two(local.month)}${two(local.day)}-'
        '${two(local.hour)}${two(local.minute)}${two(local.second)}.${BackupFormat.fileExtension}';
  }
}
