import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/core/export/csv_writer.dart';
import 'package:jujur/core/export/export_service.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';

import '../helpers/fixtures.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('CsvWriter', () {
    test('escapes commas, quotes and newlines', () {
      expect(CsvWriter.escape('a,b'), '"a,b"');
      expect(CsvWriter.escape('kata "kunci"'), '"kata ""kunci"""');
      expect(CsvWriter.escape('baris\ndua'), '"baris\ndua"');
      expect(CsvWriter.escape('biasa'), 'biasa');
    });

    test('neutralizes spreadsheet formulas only for user text', () {
      final w = CsvWriter(['a', 'b', 'c'])
        ..addRow([const CsvCell.userText('=1+1'), CsvCell.number(-5), const CsvCell.userText('@cmd')]);
      expect(w.text.split('\r\n')[1], "'=1+1,-5,'@cmd");
    });

    test('writes UTF-8 with BOM and CRLF, preserving Indonesian text', () {
      final w = CsvWriter(['isi'])..addRow([const CsvCell.userText('Syukur — “alhamdulillah” ✓')]);
      final bytes = w.toBytes();
      expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(bytes.sublist(3)), 'isi\r\nSyukur — “alhamdulillah” ✓\r\n');
    });

    test('rejects rows with the wrong number of cells', () {
      expect(() => CsvWriter(['a']).addRow([]), throwsArgumentError);
    });
  });

  group('ExportService', () {
    final range = DateRange(LocalDate(2026, 10, 1), LocalDate(2026, 10, 31));

    test('CSV export contains selected records and keeps stored text unchanged', () async {
      final db = openInMemoryDatabase();
      await populate(db);
      final service = ExportService(db, HabitRepository(db), clock: () => DateTime(2026, 10, 21, 9));
      final file = await service.export(ExportOptions(range: range, types: ExportRecordType.values.toSet()));
      expect(file.fileName, 'jujur-ekspor-csv-20261021-0900.zip');
      final archive = ZipDecoder().decodeBytes(file.bytes);
      expect(archive.files.map((f) => f.name).toSet(), {
        'aktivitas.csv', 'kebiasaan.csv', 'catatan-kebiasaan.csv', 'salat.csv', 'ibadah.csv', 'refleksi.csv',
      });
      final activities = utf8.decode(archive.findFile('aktivitas.csv')!.content.sublist(3));
      expect(activities, contains('"Belajar Flutter, bab ""state"""'));
      expect(activities, contains("'=SUM(A1:A9)"));
      expect(activities, contains("'+62 812"));
      expect(activities, contains('22:00,00:30,ya,150,Selesai'));
      final prayers = utf8.decode(archive.findFile('salat.csv')!.content.sublist(3));
      expect(prayers, contains('2026-10-19,Subuh,Dilaksanakan,04:45,ya'));
      expect(prayers, contains('Magrib,Terlewat'));
      // Stored text untouched.
      final stored = await db.select(db.activities).get();
      expect(stored.map((a) => a.title), contains('=SUM(A1:A9)'));
      await db.close();
    });

    test('single type exports a single CSV and respects the notes option and date range', () async {
      final db = openInMemoryDatabase();
      await populate(db);
      final service = ExportService(db, HabitRepository(db));
      final file = await service.export(
        ExportOptions(range: range, types: {ExportRecordType.prayers}, includeNotes: false),
      );
      expect(file.mimeType, 'text/csv');
      final text = utf8.decode(file.bytes.sublist(3));
      expect(text, isNot(contains('Di jalan')));
      final outside = await service.preview(
        ExportOptions(range: DateRange(LocalDate(2026, 11, 1), LocalDate(2026, 11, 30)), types: {ExportRecordType.prayers}),
      );
      expect(outside[ExportRecordType.prayers], 0);
      await db.close();
    });

    test('JSON export is versioned and includes stable ids', () async {
      final db = openInMemoryDatabase();
      final ids = await populate(db);
      final service = ExportService(db, HabitRepository(db));
      final file = await service.export(
        ExportOptions(range: range, types: ExportRecordType.values.toSet(), format: ExportFormat.json),
      );
      final json = jsonDecode(utf8.decode(file.bytes)) as Map<String, dynamic>;
      expect(json['format'], 'jujur-export');
      expect(json['formatVersion'], 1);
      expect(json['schemaVersion'], db.schemaVersion);
      expect((json['activities'] as List).map((a) => a['id']), contains(ids.activityId));
      expect((json['reflections'] as List).single['body'], indonesianText);
      await db.close();
    });

    test('category filter limits activities', () async {
      final db = openInMemoryDatabase();
      await populate(db);
      final counts = await ExportService(db, HabitRepository(db)).preview(
        ExportOptions(range: range, types: {ExportRecordType.activities}, categoryIds: {'cat-belajar'}),
      );
      expect(counts[ExportRecordType.activities], 1);
      await db.close();
    });
  });
}
