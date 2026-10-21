import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../errors/app_failure.dart';

sealed class FileOutcome {
  const FileOutcome();
}

class FileSaved extends FileOutcome {
  const FileSaved(this.location);
  final String location;
}

class FileCancelled extends FileOutcome {
  const FileCancelled();
}

/// File access through the Android Storage Access Framework and the system
/// share sheet. No storage permission is required.
class FileIo {
  const FileIo();

  /// Writes [bytes] to a private temporary file using write-then-rename, so
  /// the file is either complete or absent.
  Future<File> writeTemp(String fileName, Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final exportDir = Directory(p.join(dir.path, 'exports'));
    await exportDir.create(recursive: true);
    final target = File(p.join(exportDir.path, fileName));
    final partial = File('${target.path}.part');
    try {
      await partial.writeAsBytes(bytes, flush: true);
      if (await partial.length() != bytes.length) {
        throw const AppFailure('Berkas tidak tertulis lengkap.');
      }
      return await partial.rename(target.path);
    } on FileSystemException catch (e) {
      if (await partial.exists()) await partial.delete();
      throw AppFailure(describeError(e), cause: e);
    }
  }

  /// Lets the user choose where to save via the system file picker.
  Future<FileOutcome> saveAs(String fileName, String mimeType, Uint8List bytes) async {
    final uri = await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType, dialogTitle: 'Simpan berkas');
    if (uri == null) return const FileCancelled();
    return FileSaved(uri.pathSegments.isEmpty ? fileName : Uri.decodeComponent(uri.pathSegments.last));
  }

  /// Opens the share sheet with the file. Returns false when dismissed.
  Future<bool> share(String fileName, String mimeType, Uint8List bytes, {String? subject}) async {
    final file = await writeTemp(fileName, bytes);
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType, name: fileName)], subject: subject),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  /// Picks a file and returns its bytes, or null if the user cancelled.
  Future<(String name, Uint8List bytes)?> pickBytes() async {
    final file = await FilePicker.pickFile(dialogTitle: 'Pilih berkas cadangan');
    if (file == null) return null;
    return (file.name, await file.xFile.readAsBytes());
  }
}
