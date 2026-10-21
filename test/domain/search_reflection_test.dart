import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/features/activities/domain/activity_status.dart';
import 'package:jujur/features/reflections/data/reflection_repository.dart';
import 'package:jujur/features/search/data/search_repository.dart';

import '../helpers/fixtures.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final d = LocalDate(2026, 10, 19);

  group('search', () {
    test('finds activities, notes, habits and reflections locally', () async {
      final db = openInMemoryDatabase();
      await populate(db);
      final repo = SearchRepository(db);
      final flutter = await repo.search(const SearchQuery(text: 'flutter'));
      expect(flutter.map((h) => h.kind), contains(SearchHitKind.activity));
      final habit = await repo.search(const SearchQuery(text: 'membaca', scope: SearchScope.habits));
      expect(habit.single.title, 'Membaca buku');
      final notes = await repo.search(const SearchQuery(text: 'jalan', scope: SearchScope.notes));
      expect(notes.single.kind, SearchHitKind.prayerNote);
      final reflection = await repo.search(const SearchQuery(text: 'keluarga sehat', scope: SearchScope.reflections));
      expect(reflection.single.kind, SearchHitKind.reflection);
      expect(reflection.single.snippet, contains('Keluarga sehat'));
      await db.close();
    });

    test('category name, status and date filters', () async {
      final db = openInMemoryDatabase();
      await populate(db);
      final repo = SearchRepository(db);
      final byCategoryName = await repo.search(const SearchQuery(text: 'belajar', scope: SearchScope.activities));
      expect(byCategoryName, hasLength(1));
      final planned = await repo.search(const SearchQuery(activityStatus: ActivityStatus.planned));
      expect(planned.single.title, '=SUM(A1:A9)');
      final outside = await repo.search(
        SearchQuery(text: 'flutter', range: DateRange(LocalDate(2025, 1, 1), LocalDate(2025, 1, 31))),
      );
      expect(outside, isEmpty);
      await db.close();
    });

    test('LIKE wildcards in user input are treated literally', () async {
      final db = openInMemoryDatabase();
      await populate(db);
      // Only the two texts that really contain "100%" match.
      final percent = await SearchRepository(db).search(const SearchQuery(text: '%'));
      expect(percent.map((h) => h.kind).toSet(), {SearchHitKind.activity, SearchHitKind.reflection});
      expect(await SearchRepository(db).search(const SearchQuery(text: '_')), isEmpty);
      await db.close();
    });
  });

  group('reflections', () {
    test('saving keeps answers matched to their prompt text', () async {
      final db = openInMemoryDatabase();
      final repo = ReflectionRepository(db);
      await repo.save(d, body: 'Isi', answers: {'Apa yang berjalan baik?': 'Belajar', 'Apa yang saya syukuri?': ''});
      var content = await repo.load(d);
      expect(content.answers, {'Apa yang berjalan baik?': 'Belajar'});
      // Editing again with a different prompt list does not remove the old
      // answer unless the editor passes it with empty text.
      await repo.save(d, body: 'Isi baru', answers: {'Apa yang berjalan baik?': 'Belajar lagi'});
      content = await repo.load(d);
      expect(content.body, 'Isi baru');
      expect(content.answers['Apa yang berjalan baik?'], 'Belajar lagi');
      expect(await db.select(db.reflections).get(), hasLength(1));
      await db.close();
    });

    test('an emptied reflection is removed and does not count as written', () async {
      final db = openInMemoryDatabase();
      final repo = ReflectionRepository(db);
      await repo.save(d, body: 'Sementara', answers: const {});
      await repo.save(d, body: '   ', answers: const {});
      expect(await db.select(db.reflections).get(), isEmpty);
      expect((await repo.load(d)).id, isNull);
      await db.close();
    });

    test('delete removes the reflection and its answers', () async {
      final db = openInMemoryDatabase();
      final repo = ReflectionRepository(db);
      await repo.save(d, body: 'x', answers: {'P': 'J'});
      await repo.delete(d);
      expect(await db.select(db.reflections).get(), isEmpty);
      expect(await db.select(db.reflectionAnswers).get(), isEmpty);
      await db.close();
    });
  });
}
