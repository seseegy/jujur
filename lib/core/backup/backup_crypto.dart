import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'backup_format.dart';

/// Optional password protection for backups.
///
/// - Key derivation: PBKDF2-HMAC-SHA256 with a random 16-byte salt.
/// - Encryption: AES-256-GCM (authenticated) with a random 12-byte nonce.
///
/// The password is never stored. Losing it makes the backup unrecoverable.
abstract final class BackupCrypto {
  static const algorithm = 'AES-256-GCM';
  static const kdf = 'PBKDF2-HMAC-SHA256';

  /// OWASP's 2023 recommendation for PBKDF2-HMAC-SHA256.
  static const defaultIterations = 600000;
  static const minIterations = 10000;
  static const maxIterations = 10000000;

  static Uint8List _random(int length) {
    final r = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => r.nextInt(256)));
  }

  static Future<SecretKey> _deriveKey(String password, List<int> salt, int iterations) {
    // Runs in a background isolate: key stretching takes seconds on phones.
    return Isolate.run(() async {
      final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
      final key = await pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);
      return SecretKeyData(await key.extractBytes());
    });
  }

  static Future<(Uint8List, BackupEncryptionInfo)> encrypt(
    List<int> plain,
    String password, {
    int iterations = defaultIterations,
  }) async {
    final salt = _random(16);
    final nonce = _random(12);
    final key = await _deriveKey(password, salt, iterations);
    final box = await AesGcm.with256bits().encrypt(plain, secretKey: key, nonce: nonce);
    final out = Uint8List.fromList([...box.cipherText, ...box.mac.bytes]);
    return (
      out,
      BackupEncryptionInfo(
        algorithm: algorithm,
        kdf: kdf,
        iterations: iterations,
        salt: base64Encode(salt),
        nonce: base64Encode(nonce),
      ),
    );
  }

  static Future<Uint8List> decrypt(
    List<int> data,
    String password,
    BackupEncryptionInfo info,
  ) async {
    if (info.algorithm != algorithm || info.kdf != kdf) {
      throw const BackupException(
        BackupErrorCode.unsupportedFormat,
        'Metode enkripsi cadangan tidak didukung.',
      );
    }
    if (info.iterations < minIterations || info.iterations > maxIterations) {
      throw const BackupException(
        BackupErrorCode.invalidManifest,
        'Parameter enkripsi cadangan tidak valid.',
      );
    }
    final List<int> salt;
    final List<int> nonce;
    try {
      salt = base64Decode(info.salt);
      nonce = base64Decode(info.nonce);
    } on FormatException {
      throw const BackupException(
        BackupErrorCode.invalidManifest,
        'Parameter enkripsi cadangan tidak valid.',
      );
    }
    if (data.length < 16 || nonce.length != 12) {
      throw const BackupException(BackupErrorCode.missingData, 'Isi cadangan terenkripsi tidak lengkap.');
    }
    final key = await _deriveKey(password, salt, info.iterations);
    final cipherText = data.sublist(0, data.length - 16);
    final mac = Mac(data.sublist(data.length - 16));
    try {
      final plain = await AesGcm.with256bits().decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: key,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const BackupException(
        BackupErrorCode.wrongPassword,
        'Kata sandi salah, atau berkas cadangan telah berubah.',
      );
    }
  }
}
