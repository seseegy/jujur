import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

/// A user-facing failure with an actionable Indonesian message.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppFailure: $message';
}

/// Input that violates a domain rule. Shown next to the relevant field.
class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {this.field});
  final String? field;
}

/// Converts any error into a message suitable for the user. Stack traces and
/// record contents are never included.
String describeError(Object error) {
  if (error is AppFailure) return error.message;
  if (error is SqliteException) {
    final code = error.extendedResultCode;
    if (error.resultCode == 13) {
      return 'Penyimpanan perangkat penuh. Kosongkan sebagian ruang lalu coba lagi.';
    }
    if (error.resultCode == 19) {
      return _constraintMessage(code);
    }
    if (error.resultCode == 11 || error.resultCode == 26) {
      return 'Berkas database rusak atau tidak dapat dibaca.';
    }
    return 'Terjadi kesalahan database. Data sebelumnya tidak diubah.';
  }
  if (error is DriftWrappedException) {
    final cause = error.cause;
    if (cause != null) return describeError(cause);
  }
  if (error is InvalidDataException) {
    return 'Data tidak valid: periksa kembali isian Anda.';
  }
  if (error is FileSystemException) {
    if (error.osError?.errorCode == 28) {
      return 'Penyimpanan perangkat penuh. Kosongkan sebagian ruang lalu coba lagi.';
    }
    return 'Berkas tidak dapat dibaca atau ditulis.';
  }
  return 'Terjadi kesalahan yang tidak terduga. Data sebelumnya tidak diubah.';
}

String _constraintMessage(int extendedCode) {
  switch (extendedCode) {
    case 787: // SQLITE_CONSTRAINT_FOREIGNKEY
      return 'Data masih digunakan oleh catatan lain sehingga tidak dapat dihapus.';
    case 2067: // SQLITE_CONSTRAINT_UNIQUE
    case 1555: // SQLITE_CONSTRAINT_PRIMARYKEY
      return 'Catatan yang sama sudah ada.';
    default:
      return 'Data tidak memenuhi aturan penyimpanan.';
  }
}

/// Logs an error for debugging without personal content. Only the error type
/// and a short context label are printed, and only in debug builds.
void logError(String context, Object error) {
  if (kDebugMode) {
    debugPrint('[jujur] $context: ${error.runtimeType}');
  }
}
