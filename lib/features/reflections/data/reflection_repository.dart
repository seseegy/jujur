import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/watch.dart';
import '../../../core/date/local_date.dart';
import '../../../core/util/ids.dart';

/// The reflection for one date: free text plus optional prompt answers.
class ReflectionContent {
  const ReflectionContent({
    this.id,
    this.body = '',
    this.answers = const {},
    this.updatedAt,
  });

  final String? id;
  final String body;

  /// Prompt text → answer, in display order.
  final Map<String, String> answers;
  final DateTime? updatedAt;

  bool get isEmpty =>
      body.trim().isEmpty && answers.values.every((a) => a.trim().isEmpty);
}

class ReflectionSummary {
  const ReflectionSummary(this.date, this.preview);
  final LocalDate date;
  final String preview;
}

class ReflectionRepository {
  ReflectionRepository(this._db);

  final AppDatabase _db;

  Future<ReflectionContent> load(LocalDate date) async {
    final row = await (_db.select(_db.reflections)
          ..where((t) => t.dateKey.equals(date.key)))
        .getSingleOrNull();
    if (row == null) return const ReflectionContent();
    final answers = await (_db.select(_db.reflectionAnswers)
          ..where((t) => t.reflectionId.equals(row.id))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
    return ReflectionContent(
      id: row.id,
      body: row.body,
      answers: {for (final a in answers) a.prompt: a.answer},
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true).toLocal(),
    );
  }

  Stream<ReflectionContent> watch(LocalDate date) =>
      _db.watchTables({_db.reflections, _db.reflectionAnswers}, () => load(date));

  Stream<bool> watchExists(LocalDate date) =>
      (_db.select(_db.reflections)..where((t) => t.dateKey.equals(date.key)))
          .watchSingleOrNull()
          .map((r) => r != null);

  /// Saves the reflection for [date] atomically.
  ///
  /// Answers are matched by prompt text; empty answers are removed. When the
  /// whole reflection is empty the row is removed, so an empty editor never
  /// counts as a saved reflection.
  Future<void> save(LocalDate date, {required String body, required Map<String, String> answers}) =>
      _db.transaction(() async {
        final now = nowUtcMillis();
        final existing = await (_db.select(_db.reflections)
              ..where((t) => t.dateKey.equals(date.key)))
            .getSingleOrNull();
        final content = ReflectionContent(body: body, answers: answers);
        if (content.isEmpty) {
          if (existing != null) await _deleteRow(existing.id);
          return;
        }
        final String id;
        if (existing == null) {
          id = newId();
          await _db
              .into(_db.reflections)
              .insert(
                ReflectionsCompanion.insert(
                  id: id,
                  dateKey: date.key,
                  body: Value(body),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        } else {
          id = existing.id;
          await (_db.update(_db.reflections)..where((t) => t.id.equals(id))).write(
            ReflectionsCompanion(body: Value(body), updatedAt: Value(now)),
          );
        }

        final current = await (_db.select(_db.reflectionAnswers)
              ..where((t) => t.reflectionId.equals(id)))
            .get();
        final byPrompt = {for (final a in current) a.prompt: a};
        var order = 0;
        for (final entry in answers.entries) {
          final prompt = entry.key;
          final answer = entry.value;
          final row = byPrompt.remove(prompt);
          if (answer.trim().isEmpty) {
            if (row != null) {
              await (_db.delete(_db.reflectionAnswers)..where((t) => t.id.equals(row.id))).go();
            }
            continue;
          }
          if (row == null) {
            await _db
                .into(_db.reflectionAnswers)
                .insert(
                  ReflectionAnswersCompanion.insert(
                    id: newId(),
                    reflectionId: id,
                    prompt: prompt,
                    answer: answer,
                    sortOrder: Value(order),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
          } else if (row.answer != answer || row.sortOrder != order) {
            await (_db.update(_db.reflectionAnswers)..where((t) => t.id.equals(row.id)))
                .write(
                  ReflectionAnswersCompanion(
                    answer: Value(answer),
                    sortOrder: Value(order),
                    updatedAt: Value(now),
                  ),
                );
          }
          order++;
        }
        // Answers to prompts not present in [answers] are kept untouched:
        // the editor always passes every answered prompt it displays.
      });

  Future<void> delete(LocalDate date) => _db.transaction(() async {
    final row = await (_db.select(_db.reflections)
          ..where((t) => t.dateKey.equals(date.key)))
        .getSingleOrNull();
    if (row != null) await _deleteRow(row.id);
  });

  Future<void> _deleteRow(String id) async {
    await (_db.delete(_db.reflectionAnswers)..where((t) => t.reflectionId.equals(id))).go();
    await (_db.delete(_db.reflections)..where((t) => t.id.equals(id))).go();
  }

  /// Most recent reflections first, paginated, with a short preview.
  Future<List<ReflectionSummary>> recent({int limit = 30, int offset = 0}) async {
    final rows = await (_db.select(_db.reflections)
          ..orderBy([(t) => OrderingTerm.desc(t.dateKey)])
          ..limit(limit, offset: offset))
        .get();
    final result = <ReflectionSummary>[];
    for (final r in rows) {
      var text = r.body.trim();
      if (text.isEmpty) {
        final first = await (_db.select(_db.reflectionAnswers)
              ..where((t) => t.reflectionId.equals(r.id))
              ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
        text = first?.answer.trim() ?? '';
      }
      result.add(ReflectionSummary(LocalDate.parse(r.dateKey), _preview(text)));
    }
    return result;
  }

  static String _preview(String text) {
    final single = text.replaceAll(RegExp(r'\s+'), ' ');
    return single.length <= 140 ? single : '${single.substring(0, 140)}…';
  }
}
