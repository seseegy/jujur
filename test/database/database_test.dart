import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/backup/backup_schema.dart';
import 'package:jujur/core/database/app_database.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/core/errors/app_failure.dart';
import 'package:jujur/core/util/ids.dart';
import 'package:jujur/features/activities/domain/activity_status.dart';
import 'package:jujur/features/categories/data/category_repository.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/habits/domain/habit_draft.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/habits/domain/recurrence.dart';
import 'package:jujur/features/prayers/data/prayer_repository.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import '../helpers/fixtures.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('jujur_db_'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('records persist after closing and reopening the database file', () async {
    var db = await openAppDatabase(directory: dir);
    await populate(db);
    final before = await dumpTables(db);
    await db.close();

    db = await openAppDatabase(directory: dir);
    final after = await dumpTables(db);
    expect(after, before);
    final reflection = await db.select(db.reflections).getSingle();
    expect(reflection.body, indonesianText);
    await db.close();
  });

  test('foreign keys are enforced', () async {
    final db = openInMemoryDatabase();
    final now = nowUtcMillis();
    await expectLater(
      db.into(db.habitRecords).insert(
        HabitRecordsCompanion.insert(
          id: newId(),
          habitId: 'missing-habit',
          dateKey: '2026-10-01',
          status: HabitStatus.done,
          createdAt: now,
          updatedAt: now,
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
    await db.close();
  });

  test('unique constraint prevents duplicate prayer records for one date', () async {
    final db = openInMemoryDatabase();
    final now = nowUtcMillis();
    PrayerRecordsCompanion row() => PrayerRecordsCompanion.insert(
      id: newId(),
      prayer: Prayer.asar,
      dateKey: '2026-10-01',
      status: PrayerStatus.done,
      createdAt: now,
      updatedAt: now,
    );
    await db.into(db.prayerRecords).insert(row());
    await expectLater(db.into(db.prayerRecords).insert(row()), throwsA(isA<SqliteException>()));
    await db.close();
  });

  test('updating a record twice does not create duplicate daily records', () async {
    final db = openInMemoryDatabase();
    final repo = PrayerRepository(db);
    final d = LocalDate(2026, 10, 1);
    await repo.setStatus(prayer: Prayer.isya, date: d, status: PrayerStatus.missed);
    await repo.setStatus(prayer: Prayer.isya, date: d, status: PrayerStatus.qadha);
    final rows = await db.select(db.prayerRecords).get();
    expect(rows, hasLength(1));
    expect(rows.single.status, PrayerStatus.qadha);
    await db.close();
  });

  test('transactions roll back completely on failure', () async {
    final db = openInMemoryDatabase();
    final now = nowUtcMillis();
    await expectLater(
      db.transaction(() async {
        await db.into(db.activities).insert(
          ActivitiesCompanion.insert(
            id: 'a1',
            title: 'Satu',
            dateKey: '2026-10-01',
            status: ActivityStatus.done,
            createdAt: now,
            updatedAt: now,
          ),
        );
        throw StateError('gagal di tengah');
      }),
      throwsStateError,
    );
    expect(await db.select(db.activities).get(), isEmpty);
    await db.close();
  });

  test('archiving a habit keeps its historical records', () async {
    final db = openInMemoryDatabase();
    final repo = HabitRepository(db);
    final d = LocalDate(2026, 10, 1);
    final id = await repo.create(
      HabitDraft(name: 'Membaca', trackingType: HabitTrackingType.check, startDate: d, recurrence: RecurrenceType.daily),
    );
    await repo.setRecord(habitId: id, date: d, status: HabitStatus.done);
    await repo.setArchived(id, true);
    expect(await repo.recordCount(id), 1);
    // The archived habit still appears on the date it was recorded...
    final onDay = await repo.loadForDate(d);
    expect(onDay.single.record?.status, HabitStatus.done);
    // ...but not on later dates without records.
    expect(await repo.loadForDate(d.addDays(1)), isEmpty);
    await db.close();
  });

  test('editing a habit schedule keeps past schedule and records unchanged', () async {
    final db = openInMemoryDatabase();
    final repo = HabitRepository(db);
    final start = LocalDate(2026, 10, 1); // Thursday
    final id = await repo.create(
      HabitDraft(
        name: 'Membaca',
        trackingType: HabitTrackingType.quantity,
        targetValue: 10,
        startDate: start,
        recurrence: RecurrenceType.daily,
      ),
    );
    await repo.setRecord(habitId: id, date: start, status: HabitStatus.done, value: 10);

    final today = LocalDate(2026, 10, 10);
    await repo.update(
      id,
      HabitDraft(
        name: 'Membaca buku',
        trackingType: HabitTrackingType.quantity,
        targetValue: 20,
        startDate: start,
        recurrence: RecurrenceType.weekdays,
        weekdaysMask: WeekdayMask.of([1]),
      ),
      today: today,
    );
    final def = (await repo.findDefinition(id))!;
    expect(def.schedules, hasLength(2));
    // Before the change: daily with target 10.
    expect(def.plan.isScheduledOn(LocalDate(2026, 10, 3)), isTrue);
    expect(def.plan.targetOn(LocalDate(2026, 10, 3)), 10);
    // After: Mondays only, target 20.
    expect(def.plan.isScheduledOn(LocalDate(2026, 10, 11)), isFalse);
    expect(def.plan.isScheduledOn(LocalDate(2026, 10, 12)), isTrue);
    expect(def.plan.targetOn(LocalDate(2026, 10, 12)), 20);
    final record = await (db.select(db.habitRecords)).getSingle();
    expect(record.targetSnapshot, 10);
    expect(record.value, 10);
    await db.close();
  });

  test('tracking type cannot change once records exist', () async {
    final db = openInMemoryDatabase();
    final repo = HabitRepository(db);
    final d = LocalDate(2026, 10, 1);
    final id = await repo.create(
      HabitDraft(name: 'Lari', trackingType: HabitTrackingType.check, startDate: d, recurrence: RecurrenceType.daily),
    );
    await repo.setRecord(habitId: id, date: d, status: HabitStatus.done);
    await expectLater(
      repo.update(
        id,
        HabitDraft(name: 'Lari', trackingType: HabitTrackingType.duration, startDate: d, recurrence: RecurrenceType.daily),
        today: d,
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await db.close();
  });

  test('category used by activities cannot be deleted, only archived', () async {
    final db = openInMemoryDatabase();
    await populate(db);
    final repo = CategoryRepository(db);
    await expectLater(repo.delete('cat-belajar'), throwsA(isA<AppFailure>()));
    await repo.setArchived('cat-belajar', true);
    expect((await db.select(db.activities).get()).where((a) => a.categoryId == 'cat-belajar'), hasLength(1));
    await db.close();
  });

  test('backup schema matches the database columns exactly', () async {
    final db = openInMemoryDatabase();
    for (final spec in backupTables) {
      final info = await db.customSelect('PRAGMA table_info(${spec.name})').get();
      final dbColumns = {for (final r in info) r.read<String>('name')};
      expect(spec.columns.map((c) => c.name).toSet(), dbColumns, reason: spec.name);
      for (final r in info) {
        final c = spec.columns.firstWhere((c) => c.name == r.read<String>('name'));
        expect(c.nullable, r.read<int>('notnull') == 0, reason: '${spec.name}.${c.name}');
      }
    }
    await db.close();
  });
}
