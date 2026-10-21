import 'package:drift/drift.dart';

import 'app_database.dart';

extension WatchTables on AppDatabase {
  /// Emits [load]'s result now and again whenever one of [tables] changes.
  ///
  /// Used for views that combine several tables, where a single drift query
  /// stream would be awkward. Loads are serialized, so results arrive in order.
  Stream<T> watchTables<T>(
    Set<ResultSetImplementation> tables,
    Future<T> Function() load,
  ) async* {
    yield await load();
    await for (final _ in tableUpdates(TableUpdateQuery.onAllTables(tables))) {
      yield await load();
    }
  }
}
