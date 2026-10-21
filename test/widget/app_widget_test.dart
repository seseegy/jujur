import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jujur/core/database/app_database.dart';
import 'package:jujur/core/database/database_opener.dart';
import 'package:jujur/core/date/local_date.dart';
import 'package:jujur/features/activities/domain/activity_status.dart';
import 'package:jujur/features/habits/data/habit_repository.dart';
import 'package:jujur/features/habits/domain/habit_draft.dart';
import 'package:jujur/features/habits/domain/habit_enums.dart';
import 'package:jujur/features/prayers/data/prayer_repository.dart';
import 'package:jujur/features/prayers/domain/prayer.dart';
import 'package:jujur/features/settings/data/settings_repository.dart';
import 'package:jujur/features/settings/domain/preferences.dart';

import '../helpers/app_harness.dart';

void main() {
  setUpAll(setUpTestEnvironment);

  late AppDatabase db;
  final today = LocalDate.fromDateTime(testNow);

  setUp(() => db = openInMemoryDatabase());
  tearDown(() => db.close());

  testWidgets('first launch shows onboarding, which can be skipped', (tester) async {
    await pumpApp(tester, db);
    expect(find.text('Catatan harian yang jujur'), findsOneWidget);
    await tester.tap(find.text('Lewati'));
    await settle(tester);
    expect(find.text('Hari ini · Rabu'), findsOneWidget);
    expect((await SettingsRepository(db).load()).onboardingDone, isTrue);
    await unmountApp(tester);
  });

  testWidgets('main navigation reaches all four destinations', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    expect(find.text('21 Oktober 2026'), findsOneWidget);
    for (final (tab, title) in [('Riwayat', 'Riwayat'), ('Ringkasan', 'Ringkasan'), ('Pengaturan', 'Pengaturan')]) {
      await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)));
      await settle(tester);
      expect(find.descendant(of: find.byType(AppBar), matching: find.text(title)), findsOneWidget);
    }
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Hari ini')));
    await settle(tester);
    expect(find.text('21 Oktober 2026'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('empty Today shows useful empty states instead of zeros', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    expect(find.textContaining('Belum ada catatan untuk tanggal ini'), findsOneWidget);
    // All five prayers are "Belum dicatat", never "Terlewat".
    expect(find.text('Belum dicatat'), findsNWidgets(5));
    expect(find.text('Terlewat'), findsNothing);
    await scrollTo(tester, find.text('Belum ada aktivitas pada tanggal ini'));
    expect(find.text('Tidak ada kebiasaan terjadwal'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('prayer quick check records and undo restores "Belum dicatat"', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.byTooltip('Tandai Subuh dilaksanakan'));
    await settle(tester);
    expect((await PrayerRepository(db).find(Prayer.subuh, today))?.status, PrayerStatus.done);
    expect(find.text('Dilaksanakan'), findsOneWidget);
    await tester.tap(find.text('Urungkan'));
    await settle(tester);
    expect(await PrayerRepository(db).find(Prayer.subuh, today), isNull);
    await unmountApp(tester);
  });

  testWidgets('prayer sheet records an explicit missed status', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Asar, Belum dicatat')));
    await settle(tester);
    await tester.tap(find.text('Terlewat'));
    await tester.pump();
    await tester.tap(find.text('Simpan'));
    await settle(tester);
    expect((await PrayerRepository(db).find(Prayer.asar, today))?.status, PrayerStatus.missed);
    await unmountApp(tester);
  });

  testWidgets('habit completion from Today persists', (tester) async {
    await markOnboarded(db);
    await HabitRepository(db).create(
      HabitDraft(name: 'Membaca', trackingType: HabitTrackingType.check, startDate: today, recurrence: RecurrenceType.daily),
    );
    await pumpApp(tester, db);
    await scrollTo(tester, find.byTooltip('Tandai Membaca selesai'));
    await tester.tap(find.byTooltip('Tandai Membaca selesai'));
    await settle(tester);
    final records = await db.select(db.habitRecords).get();
    expect(records.single.status, HabitStatus.done);
    expect(records.single.dateKey, today.key);
    await unmountApp(tester);
  });

  testWidgets('quick add validates and creates an activity', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.text('Catat'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await settle(tester);
    expect(find.text('Judul aktivitas wajib diisi.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Apa yang Anda lakukan?'), 'Membaca Al-Kahfi');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Membaca'));
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await settle(tester);
    final activity = await db.select(db.activities).getSingle();
    expect(activity.title, 'Membaca Al-Kahfi');
    expect(activity.categoryId, 'cat-membaca');
    expect(activity.status, ActivityStatus.done);
    await scrollTo(tester, find.text('Membaca Al-Kahfi'));
    expect(find.text('Membaca Al-Kahfi'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('activity form shows time validation and edits an activity', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.text('Catat'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Apa yang Anda lakukan?'), 'Belajar');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await settle(tester);
    await scrollTo(tester, find.text('Belajar'));
    await tester.tap(find.text('Belajar'));
    await settle(tester);
    expect(find.text('Ubah aktivitas'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Judul'), 'Belajar Dart');
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await settle(tester);
    expect((await db.select(db.activities).getSingle()).title, 'Belajar Dart');
    await unmountApp(tester);
  });

  testWidgets('reflection autosaves and persists after leaving the screen', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.byTooltip('Refleksi hari ini'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Catatan bebas'), 'Hari ini cukup tenang, alhamdulillah.');
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.textContaining('Tersimpan'), findsWidgets);
    final saved = await db.select(db.reflections).getSingle();
    expect(saved.body, 'Hari ini cukup tenang, alhamdulillah.');
    // Edits made right before leaving are flushed on pop.
    await tester.enterText(find.widgetWithText(TextField, 'Catatan bebas'), 'Diubah sebelum keluar.');
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect((await db.select(db.reflections).getSingle()).body, 'Diubah sebelum keluar.');
    await unmountApp(tester);
  });

  testWidgets('theme setting switches to dark and persists', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Pengaturan')));
    await settle(tester);
    await tester.tap(find.text('Gelap'));
    await settle(tester);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect((await SettingsRepository(db).load()).themeMode, ThemeMode.dark);
    await unmountApp(tester);
  });

  testWidgets('critical controls have accessible labels', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp(r'^Subuh, Belum dicatat')), findsOneWidget);
    expect(find.byTooltip('Hari sebelumnya'), findsOneWidget);
    expect(find.byTooltip('Hari berikutnya'), findsOneWidget);
    expect(find.byTooltip('Pilih tanggal'), findsOneWidget);
    expect(find.byTooltip('Tandai Isya dilaksanakan'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
    await unmountApp(tester);
  });

  testWidgets('date navigation shows previous days without inventing records', (tester) async {
    await markOnboarded(db);
    await PrayerRepository(db).setStatus(prayer: Prayer.isya, date: today.addDays(-1), status: PrayerStatus.done);
    await pumpApp(tester, db);
    await tester.tap(find.byTooltip('Hari sebelumnya'));
    await settle(tester);
    expect(find.text('Kemarin · Selasa'), findsOneWidget);
    expect(find.text('Dilaksanakan'), findsOneWidget);
    expect(find.text('Belum dicatat'), findsNWidgets(4));
    await tester.tap(find.text('Kembali ke hari ini'));
    await settle(tester);
    expect(find.text('Hari ini · Rabu'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('history and insights show honest empty states', (tester) async {
    await markOnboarded(db);
    await pumpApp(tester, db);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Ringkasan')));
    await settle(tester);
    expect(find.text('Belum ada catatan pada periode ini'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('Riwayat')));
    await settle(tester);
    expect(find.text('Belum ada catatan pada tanggal ini'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('small screen with large text does not overflow on Today', (tester) async {
    await markOnboarded(db);
    await SettingsRepository(db).set(SettingKeys.weekStart, '1');
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, db, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    await scrollTo(tester, find.text('Tulis refleksi'));
    expect(tester.takeException(), isNull);
    await unmountApp(tester);
  });
}
