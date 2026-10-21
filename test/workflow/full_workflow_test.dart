import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/backup/backup_reader.dart';
import 'package:jujur/core/backup/backup_writer.dart';
import 'package:jujur/core/backup/restore_service.dart';
import 'package:jujur/core/database/app_database.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/core/export/export_service.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/prayers/data/prayer_repository.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';

import '../helpers/app_harness.dart';
import '../helpers/fixtures.dart' show dumpTables;

/// End-to-end workflow from the specification (section 22.4), driven through
/// the real UI on a real database file, with all network access blocked.
///
/// The system file picker cannot be driven from widget tests, so the backup
/// file is produced and restored through the same services the backup screen
/// calls.
void main() {
  setUpAll(setUpTestEnvironment);

  testWidgets('complete offline workflow survives restart, backup, restore and export', (tester) async {
    final network = NoNetworkHttpOverrides();
    HttpOverrides.global = network;
    addTearDown(() => HttpOverrides.global = null);

    final dir = Directory.systemTemp.createTempSync('jujur_flow_');
    addTearDown(() => dir.deleteSync(recursive: true));
    // Synchronous connection on a real file: widget tests run in fake time,
    // where a background isolate could not answer.
    AppDatabase open() => openDatabaseFile(File('${dir.path}/$databaseFileName'));
    final today = LocalDate.fromDateTime(testNow);
    final yesterday = today.addDays(-1);

    // 1. Launch the application (first run).
    var db = open();
    await pumpApp(tester, db);
    await tester.tap(find.text('Lewati'));
    await settle(tester);

    // 2. Create a habit through the UI.
    await scrollTo(tester, find.text('Kelola kebiasaan'));
    await tester.tap(find.text('Kelola kebiasaan'));
    await settle(tester);
    await tester.tap(find.text('Kebiasaan baru').last);
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Nama kebiasaan'), 'Membaca buku');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await settle(tester);
    expect(find.text('Membaca buku'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);

    // 3. Record today's completion.
    await scrollTo(tester, find.byTooltip('Tandai Membaca buku selesai'));
    await tester.tap(find.byTooltip('Tandai Membaca buku selesai'));
    await settle(tester);

    // 4. Close and reopen the application (new database connection).
    await unmountApp(tester);
    await tester.runAsync(db.close);
    db = open();
    await pumpApp(tester, db);

    // 5. Verify the record still exists, in the UI and in the database.
    await scrollTo(tester, find.byTooltip('Batalkan catatan Membaca buku'));
    expect(find.bySemanticsLabel(RegExp(r'^Membaca buku, Selesai')), findsOneWidget);
    final habitRecord = (await tester.runAsync(() => db.select(db.habitRecords).getSingle()))!;
    expect(habitRecord.status, HabitStatus.done);
    expect(habitRecord.dateKey, today.key);

    // 6. Edit a historical prayer record (yesterday's Magrib).
    await scrollTo(tester, find.byTooltip('Hari sebelumnya'), up: true);
    await tester.tap(find.byTooltip('Hari sebelumnya'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Magrib, Belum dicatat')));
    await settle(tester);
    await tester.tap(find.text('Diqada'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await settle(tester);
    final magrib = await tester.runAsync(() => PrayerRepository(db).find(Prayer.magrib, yesterday));
    expect(magrib?.status, PrayerStatus.qadha);
    // Other prayers of that day remain unrecorded, not missed.
    expect(await tester.runAsync(() => PrayerRepository(db).find(Prayer.isya, yesterday)), isNull);

    // 7. Write a daily reflection.
    await tester.tap(find.text('Kembali ke hari ini'));
    await settle(tester);
    await tester.tap(find.byTooltip('Refleksi hari ini'));
    await settle(tester);
    const text = 'Syukur hari ini: keluarga sehat, "belajar" lancar.\nBesok — lebih awal.';
    await tester.enterText(find.widgetWithText(TextField, 'Catatan bebas'), text);
    await tester.binding.handlePopRoute();
    await settle(tester);
    await unmountApp(tester);

    // 8. Create a full backup.
    final backup = (await tester.runAsync(() => BackupWriter(db, appVersion: 'test').create()))!;
    final before = (await tester.runAsync(() => dumpTables(db)))!;
    await tester.runAsync(db.close);

    // 9. Clear the data in a controlled test environment.
    for (final f in dir.listSync()) {
      f.deleteSync();
    }
    db = open();
    expect((await tester.runAsync(() => db.select(db.habits).get()))!, isEmpty);

    // 10. Restore the backup.
    await tester.runAsync(() async {
      final validated = await BackupReader.read(backup.bytes);
      await RestoreService(db).restore(validated.data, RestoreMode.replace);
    });

    // 11. Verify the restored records.
    expect(await tester.runAsync(() => dumpTables(db)), before);
    await pumpApp(tester, db);
    await scrollTo(tester, find.byTooltip('Batalkan catatan Membaca buku'));
    expect(find.text('Refleksi tersimpan'), findsOneWidget);
    await unmountApp(tester);

    // 12. Export selected records to CSV.
    final export = (await tester.runAsync(
      () => ExportService(db, HabitRepository(db), clock: () => testNow).export(
        ExportOptions(
          range: DateRange(yesterday, today),
          types: {ExportRecordType.prayers, ExportRecordType.habits, ExportRecordType.reflections},
        ),
      ),
    ))!;

    // 13. Verify the exported content.
    expect(export.counts[ExportRecordType.prayers], 1);
    expect(export.counts[ExportRecordType.habits], 1);
    expect(export.counts[ExportRecordType.reflections], 1);
    expect(export.fileName, endsWith('.zip'));
    final archive = ZipDecoder().decodeBytes(export.bytes);
    String csv(String name) => utf8.decode(archive.findFile(name)!.content.sublist(3));
    expect(csv('salat.csv'), contains('${yesterday.key},Magrib,Diqada'));
    expect(csv('catatan-kebiasaan.csv'), contains('Membaca buku,${today.key},Selesai'));
    expect(csv('refleksi.csv'), contains('"Syukur hari ini: keluarga sehat, ""belajar"" lancar.\nBesok — lebih awal."'));

    // No network access was attempted at any point.
    expect(network.attempts, 0);
    await tester.runAsync(db.close);
  });
}
