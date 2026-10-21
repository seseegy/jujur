import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a stable, globally unique record identifier (UUID v4).
///
/// Stable identifiers make backups mergeable across devices.
String newId() => _uuid.v4();

/// Current time as UTC milliseconds since epoch, used for audit metadata.
int nowUtcMillis([DateTime Function()? clock]) =>
    (clock ?? DateTime.now)().toUtc().millisecondsSinceEpoch;
