import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/date/local_date.dart';
import '../../activities/domain/activity_status.dart';

enum SearchScope {
  all('Semua'),
  activities('Aktivitas'),
  habits('Kebiasaan'),
  notes('Catatan'),
  reflections('Refleksi');

  const SearchScope(this.label);
  final String label;
}

enum SearchHitKind { activity, habit, habitNote, prayerNote, worshipNote, reflection }

class SearchHit {
  const SearchHit({
    required this.kind,
    required this.id,
    required this.title,
    this.date,
    this.snippet,
    this.subtitle,
  });

  final SearchHitKind kind;
  final String id;
  final LocalDate? date;
  final String title;
  final String? snippet;
  final String? subtitle;
}

class SearchQuery {
  const SearchQuery({
    this.text = '',
    this.scope = SearchScope.all,
    this.range,
    this.categoryId,
    this.activityStatus,
  });

  final String text;
  final SearchScope scope;
  final DateRange? range;
  final String? categoryId;
  final ActivityStatus? activityStatus;

  bool get hasFilters => range != null || categoryId != null || activityStatus != null;
  bool get isEmpty => text.trim().isEmpty && !hasFilters;

  SearchQuery copyWith({
    String? text,
    SearchScope? scope,
    DateRange? Function()? range,
    String? Function()? categoryId,
    ActivityStatus? Function()? activityStatus,
  }) => SearchQuery(
    text: text ?? this.text,
    scope: scope ?? this.scope,
    range: range != null ? range() : this.range,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    activityStatus: activityStatus != null ? activityStatus() : this.activityStatus,
  );
}

/// Local, indexed search. Every query is bounded by [limit]; nothing loads the
/// whole database into memory.
class SearchRepository {
  SearchRepository(this._db);

  final AppDatabase _db;

  static String _pattern(String text) {
    final escaped = text
        .trim()
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return '%$escaped%';
  }

  Future<List<SearchHit>> search(SearchQuery query, {int limit = 50}) async {
    if (query.isEmpty) return const [];
    final hits = <SearchHit>[];
    final scope = query.scope;
    final activityOnlyFilter = query.categoryId != null || query.activityStatus != null;

    if (scope == SearchScope.all || scope == SearchScope.activities) {
      hits.addAll(await _activities(query, limit));
    }
    if (!activityOnlyFilter) {
      if (scope == SearchScope.all || scope == SearchScope.habits) {
        hits.addAll(await _habits(query, limit));
      }
      if (scope == SearchScope.all || scope == SearchScope.notes) {
        hits.addAll(await _notes(query, limit));
      }
      if (scope == SearchScope.all || scope == SearchScope.reflections) {
        hits.addAll(await _reflections(query, limit));
      }
    }
    hits.sort((a, b) {
      final ad = a.date, bd = b.date;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return hits.take(limit).toList();
  }

  String _rangeSql(String column, DateRange? range, List<Variable> vars) {
    if (range == null) return '';
    vars
      ..add(Variable(range.start.key))
      ..add(Variable(range.end.key));
    return ' AND $column BETWEEN ? AND ?';
  }

  Future<List<SearchHit>> _activities(SearchQuery q, int limit) async {
    final vars = <Variable>[];
    var where = '1=1';
    if (q.text.trim().isNotEmpty) {
      final p = _pattern(q.text);
      where += " AND (a.title LIKE ? ESCAPE '\\' OR a.description LIKE ? ESCAPE '\\' "
          "OR a.notes LIKE ? ESCAPE '\\' OR a.tags LIKE ? ESCAPE '\\' OR c.name LIKE ? ESCAPE '\\')";
      vars.addAll(List.filled(5, Variable(p)));
    }
    where += _rangeSql('a.date_key', q.range, vars);
    if (q.categoryId != null) {
      where += ' AND a.category_id = ?';
      vars.add(Variable(q.categoryId));
    }
    if (q.activityStatus != null) {
      where += ' AND a.status = ?';
      vars.add(Variable(q.activityStatus!.name));
    }
    vars.add(Variable(limit));
    final rows = await _db
        .customSelect(
          'SELECT a.id, a.title, a.date_key, a.notes, a.description, a.status, c.name AS category '
          'FROM activities a LEFT JOIN categories c ON c.id = a.category_id '
          'WHERE $where ORDER BY a.date_key DESC LIMIT ?',
          variables: vars,
          readsFrom: {_db.activities, _db.categories},
        )
        .get();
    return [
      for (final r in rows)
        SearchHit(
          kind: SearchHitKind.activity,
          id: r.read<String>('id'),
          title: r.read<String>('title'),
          date: LocalDate.parse(r.read<String>('date_key')),
          subtitle: [
            r.readNullable<String>('category'),
            ActivityStatus.values.byName(r.read<String>('status')).label,
          ].whereType<String>().join(' · '),
          snippet: r.readNullable<String>('notes') ?? r.readNullable<String>('description'),
        ),
    ];
  }

  Future<List<SearchHit>> _habits(SearchQuery q, int limit) async {
    if (q.text.trim().isEmpty) return const [];
    final p = _pattern(q.text);
    final rows = await _db
        .customSelect(
          "SELECT id, name, description, archived FROM habits "
          "WHERE name LIKE ? ESCAPE '\\' OR description LIKE ? ESCAPE '\\' "
          'ORDER BY sort_order LIMIT ?',
          variables: [Variable(p), Variable(p), Variable(limit)],
          readsFrom: {_db.habits},
        )
        .get();
    return [
      for (final r in rows)
        SearchHit(
          kind: SearchHitKind.habit,
          id: r.read<String>('id'),
          title: r.read<String>('name'),
          subtitle: r.read<bool>('archived') ? 'Kebiasaan · diarsipkan' : 'Kebiasaan',
          snippet: r.readNullable<String>('description'),
        ),
    ];
  }

  Future<List<SearchHit>> _notes(SearchQuery q, int limit) async {
    if (q.text.trim().isEmpty) return const [];
    final p = _pattern(q.text);
    final vars = <Variable>[Variable(p)];
    final habitRange = _rangeSql('r.date_key', q.range, vars);
    vars.add(Variable(p));
    final prayerRange = _rangeSql('date_key', q.range, vars);
    vars.add(Variable(p));
    final worshipRange = _rangeSql('r.date_key', q.range, vars);
    vars.add(Variable(limit));
    final rows = await _db
        .customSelect(
          '''
          SELECT 'h' AS kind, r.id, r.date_key, h.name AS title, r.note FROM habit_records r
            JOIN habits h ON h.id = r.habit_id WHERE r.note LIKE ? ESCAPE '\\' $habitRange
          UNION ALL
          SELECT 'p', id, date_key, prayer, note FROM prayer_records
            WHERE note LIKE ? ESCAPE '\\' $prayerRange
          UNION ALL
          SELECT 'w', r.id, r.date_key, i.name, r.note FROM worship_records r
            JOIN worship_items i ON i.id = r.item_id WHERE r.note LIKE ? ESCAPE '\\' $worshipRange
          ORDER BY 3 DESC LIMIT ?
          ''',
          variables: vars,
          readsFrom: {_db.habitRecords, _db.habits, _db.prayerRecords, _db.worshipRecords, _db.worshipItems},
        )
        .get();
    return [
      for (final r in rows)
        SearchHit(
          kind: switch (r.read<String>('kind')) {
            'h' => SearchHitKind.habitNote,
            'p' => SearchHitKind.prayerNote,
            _ => SearchHitKind.worshipNote,
          },
          id: r.read<String>('id'),
          date: LocalDate.parse(r.read<String>('date_key')),
          title: _titleCase(r.read<String>('title')),
          subtitle: 'Catatan',
          snippet: r.readNullable<String>('note'),
        ),
    ];
  }

  Future<List<SearchHit>> _reflections(SearchQuery q, int limit) async {
    final vars = <Variable>[];
    var where = '1=1';
    if (q.text.trim().isNotEmpty) {
      final p = _pattern(q.text);
      where += " AND (f.body LIKE ? ESCAPE '\\' OR EXISTS (SELECT 1 FROM reflection_answers a "
          "WHERE a.reflection_id = f.id AND a.answer LIKE ? ESCAPE '\\'))";
      vars.addAll([Variable(p), Variable(p)]);
    }
    where += _rangeSql('f.date_key', q.range, vars);
    vars.add(Variable(limit));
    final rows = await _db
        .customSelect(
          'SELECT f.id, f.date_key, f.body FROM reflections f WHERE $where '
          'ORDER BY f.date_key DESC LIMIT ?',
          variables: vars,
          readsFrom: {_db.reflections, _db.reflectionAnswers},
        )
        .get();
    final needle = q.text.trim().toLowerCase();
    final hits = <SearchHit>[];
    for (final r in rows) {
      var snippet = r.read<String>('body');
      if (needle.isNotEmpty && !snippet.toLowerCase().contains(needle)) {
        final answer = await _db
            .customSelect(
              "SELECT answer FROM reflection_answers WHERE reflection_id = ? AND answer LIKE ? ESCAPE '\\' LIMIT 1",
              variables: [Variable(r.read<String>('id')), Variable(_pattern(q.text))],
              readsFrom: {_db.reflectionAnswers},
            )
            .getSingleOrNull();
        snippet = answer?.read<String>('answer') ?? snippet;
      }
      hits.add(
        SearchHit(
          kind: SearchHitKind.reflection,
          id: r.read<String>('id'),
          date: LocalDate.parse(r.read<String>('date_key')),
          title: 'Refleksi',
          snippet: excerpt(snippet, needle),
        ),
      );
    }
    return hits;
  }

  /// A short excerpt around the first match.
  static String excerpt(String text, String needle, {int radius = 60}) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (needle.isEmpty) {
      return flat.length <= radius * 2 ? flat : '${flat.substring(0, radius * 2)}…';
    }
    final i = flat.toLowerCase().indexOf(needle);
    if (i < 0) return flat.length <= radius * 2 ? flat : '${flat.substring(0, radius * 2)}…';
    final start = (i - radius).clamp(0, flat.length);
    final end = (i + needle.length + radius).clamp(0, flat.length);
    return '${start > 0 ? '…' : ''}${flat.substring(start, end)}${end < flat.length ? '…' : ''}';
  }

  static String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
