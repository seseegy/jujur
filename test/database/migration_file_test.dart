import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/database/database_opener.dart';

import 'generated/jujur/generated/schema_v1.dart' as v1;

/// File-level migration behavior: a copy of the old database is kept, data
/// survives a successful upgrade, and a failed upgrade leaves the original
/// file untouched instead of resetting it.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late File file;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('jujur_mig_');
    file = File('${dir.path}/$databaseFileName');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> createV1({bool sabotage = false}) async {
    final old = v1.DatabaseAtV1(NativeDatabase(file));
    await old.customStatement('PRAGMA user_version = 1');
    await old.into(old.activities).insert(
      const v1.ActivitiesData(
        id: 'a1',
        title: 'Tetap ada',
        dateKey: '2026-10-01',
        endsNextDay: 0,
        status: 'done',
        createdAt: 1,
        updatedAt: 1,
      ),
    );
    if (sabotage) {
      // A column the v1→v2 step will try to add already exists, so the
      // upgrade throws.
      await old.customStatement('ALTER TABLE activities ADD COLUMN tags TEXT');
    }
    await old.close();
  }

  Future<int> userVersion(File f) async {
    final db = v1.DatabaseAtV1(NativeDatabase(f));
    final v = (await db.customSelect('PRAGMA user_version').getSingle()).read<int>('user_version');
    await db.close();
    return v;
  }

  test('upgrade keeps data and leaves a pre-upgrade copy', () async {
    await createV1();
    final db = await openAppDatabase(directory: dir);
    final activity = await db.select(db.activities).getSingle();
    expect(activity.title, 'Tetap ada');
    expect(activity.tags, isNull);
    await db.close();
    final copy = File('${file.path}.v1.bak');
    expect(copy.existsSync(), isTrue);
    expect(await userVersion(copy), 1);
  });

  test('failed upgrade does not reset or delete the database', () async {
    await createV1(sabotage: true);
    await expectLater(openAppDatabase(directory: dir), throwsA(anything));
    expect(file.existsSync(), isTrue);
    expect(await userVersion(file), 1);
    final old = v1.DatabaseAtV1(NativeDatabase(file));
    final rows = await old.customSelect("SELECT title FROM activities WHERE id = 'a1'").get();
    expect(rows.single.read<String>('title'), 'Tetap ada');
    await old.close();
    expect(File('${file.path}.v1.bak').existsSync(), isTrue);
  });
}
