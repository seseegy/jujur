import '../errors/app_failure.dart';

/// Constants of the documented backup format (docs/BACKUP_FORMAT.md).
abstract final class BackupFormat {
  static const formatId = 'jujur-backup';
  static const formatVersion = 1;
  static const manifestFile = 'manifest.json';
  static const dataFile = 'data.json';
  static const encryptedDataFile = 'data.json.enc';
  static const fileExtension = 'zip';
  static const mimeType = 'application/zip';

  /// Upper bound protecting against decompression bombs (200 MB).
  static const maxPayloadBytes = 200 * 1024 * 1024;
}

/// Reason a backup was rejected. The existing data is never touched when one
/// of these is thrown.
enum BackupErrorCode {
  notArchive,
  missingManifest,
  invalidManifest,
  unsupportedFormat,
  unsupportedVersion,
  newerSchema,
  missingData,
  checksumMismatch,
  passwordRequired,
  wrongPassword,
  invalidJson,
  invalidRecord,
  duplicateId,
  brokenRelation,
  countMismatch,
}

class BackupException extends AppFailure {
  const BackupException(this.code, super.message, {super.cause});
  final BackupErrorCode code;

  @override
  String toString() => 'BackupException(${code.name}): $message';
}

class BackupEncryptionInfo {
  const BackupEncryptionInfo({
    required this.algorithm,
    required this.kdf,
    required this.iterations,
    required this.salt,
    required this.nonce,
  });

  final String algorithm;
  final String kdf;
  final int iterations;
  final String salt;
  final String nonce;

  Map<String, Object> toJson() => {
    'algorithm': algorithm,
    'kdf': kdf,
    'iterations': iterations,
    'salt': salt,
    'nonce': nonce,
  };
}

class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.payloadFile,
    required this.payloadSha256,
    required this.payloadBytes,
    required this.counts,
    this.encryption,
  });

  final int formatVersion;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final String payloadFile;
  final String payloadSha256;
  final int payloadBytes;
  final Map<String, int> counts;
  final BackupEncryptionInfo? encryption;

  bool get encrypted => encryption != null;

  Map<String, Object?> toJson() => {
    'format': BackupFormat.formatId,
    'formatVersion': formatVersion,
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'encrypted': encrypted,
    'payload': {'file': payloadFile, 'sha256': payloadSha256, 'bytes': payloadBytes},
    'counts': counts,
    'encryption': encryption?.toJson(),
  };
}
