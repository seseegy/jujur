import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../../features/habits/data/habit_repository.dart';
import '../database/app_database.dart';
import '../date/local_date.dart';
import '../date/time_of_day_minutes.dart';
import 'csv_writer.dart';

enum ExportRecordType {
  activities('Aktivitas'),
  habits('Kebiasaan & catatannya'),
  prayers('Catatan salat'),
  worship('Catatan ibadah'),
  reflections('Refleksi');

  const ExportRecordType(this.label);
  final String label;
}

enum ExportFormat { csv, json }

class ExportOptions {
  const ExportOptions({
    required this.range,
    required this.types,
    this.includeNotes = true,
    this.categoryIds,
    this.format = ExportFormat.csv,
  });

  final DateRange range;
  final Set<ExportRecordType> types;
  final bool includeNotes;

  /// Restricts activities to these categories; null means all.
  final Set<String>? categoryIds;
  final ExportFormat format;
}

class ExportFile {
  const ExportFile(this.fileName, this.mimeType, this.bytes, this.counts);
  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final Map<ExportRecordType, int> counts;
}

/// Exports selected records for portability and analysis. Unlike a backup,
/// an export is filtered and human-oriented, and cannot be restored.
class ExportService {
  ExportService(this._db, this._habits, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final HabitRepository _habits;
  final DateTime Function() _clock;

  static const exportFormatVersion = 1;

  Future<_Snapshot> _load(ExportOptions o) async {
    final from = o.range.start.key, to = o.range.end.key;
    final categories = await _db.select(_db.categories).get();
    var activities = <Activity>[];
    if (o.types.contains(ExportRecordType.activities)) {
      final q = _db.select(_db.activities)
        ..where((t) => t.dateKey.isBetweenValues(from, to))
        ..orderBy([(t) => OrderingTerm(expression: t.dateKey), (t) => OrderingTerm(expression: t.startMinute)]);
      if (o.categoryIds != null) q.where((t) => t.categoryId.isIn(o.categoryIds!));
      activities = await q.get();
    }
    var habitRecords = <HabitRecord>[];
    var definitions = <HabitDefinition>[];
    if (o.types.contains(ExportRecordType.habits)) {
      definitions = await _habits.loadDefinitions();
      habitRecords = await (_db.select(_db.habitRecords)
            ..where((t) => t.dateKey.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm(expression: t.dateKey)]))
          .get();
    }
    var prayers = <PrayerRecord>[];
    if (o.types.contains(ExportRecordType.prayers)) {
      prayers = await (_db.select(_db.prayerRecords)
            ..where((t) => t.dateKey.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm(expression: t.dateKey)]))
          .get();
      prayers.sort((a, b) {
        final c = a.dateKey.compareTo(b.dateKey);
        return c != 0 ? c : a.prayer.index.compareTo(b.prayer.index);
      });
    }
    var worshipItems = <WorshipItem>[];
    var worship = <WorshipRecord>[];
    if (o.types.contains(ExportRecordType.worship)) {
      worshipItems = await _db.select(_db.worshipItems).get();
      worship = await (_db.select(_db.worshipRecords)
            ..where((t) => t.dateKey.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm(expression: t.dateKey)]))
          .get();
    }
    var reflections = <Reflection>[];
    var answers = <ReflectionAnswer>[];
    if (o.types.contains(ExportRecordType.reflections)) {
      reflections = await (_db.select(_db.reflections)
            ..where((t) => t.dateKey.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm(expression: t.dateKey)]))
          .get();
      if (reflections.isNotEmpty) {
        answers = await (_db.select(_db.reflectionAnswers)
              ..where((t) => t.reflectionId.isIn(reflections.map((r) => r.id)))
              ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
            .get();
      }
    }
    return _Snapshot(
      categories: {for (final c in categories) c.id: c},
      activities: activities,
      habits: {for (final d in definitions) d.habit.id: d.habit},
      habitRecords: habitRecords,
      prayers: prayers,
      worshipItems: {for (final w in worshipItems) w.id: w},
      worship: worship,
      reflections: reflections,
      answers: answers,
    );
  }

  /// Counts of records that match [options], for the export preview.
  Future<Map<ExportRecordType, int>> preview(ExportOptions options) async =>
      (await _load(options)).counts(options.types);

  Future<ExportFile> export(ExportOptions options) async {
    final s = await _load(options);
    final stamp = _stamp(_clock());
    final counts = s.counts(options.types);
    if (options.format == ExportFormat.json) {
      final json = _json(s, options);
      return ExportFile(
        'jujur-ekspor-$stamp.json',
        'application/json',
        Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(json))),
        counts,
      );
    }
    final files = <String, CsvWriter>{
      if (options.types.contains(ExportRecordType.activities)) 'aktivitas.csv': _activitiesCsv(s, options),
      if (options.types.contains(ExportRecordType.habits)) ...{
        'kebiasaan.csv': _habitsCsv(s),
        'catatan-kebiasaan.csv': _habitRecordsCsv(s, options),
      },
      if (options.types.contains(ExportRecordType.prayers)) 'salat.csv': _prayersCsv(s, options),
      if (options.types.contains(ExportRecordType.worship)) 'ibadah.csv': _worshipCsv(s, options),
      if (options.types.contains(ExportRecordType.reflections)) 'refleksi.csv': _reflectionsCsv(s),
    };
    if (files.length == 1) {
      final entry = files.entries.single;
      return ExportFile(
        'jujur-${entry.key.replaceAll('.csv', '')}-$stamp.csv',
        'text/csv',
        entry.value.toBytes(),
        counts,
      );
    }
    final archive = Archive();
    for (final e in files.entries) {
      archive.add(ArchiveFile.bytes(e.key, e.value.toBytes()));
    }
    return ExportFile('jujur-ekspor-csv-$stamp.zip', 'application/zip', ZipEncoder().encodeBytes(archive), counts);
  }

  static String _stamp(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}';
  }

  static String? _time(int? minute) => minute == null ? null : MinuteOfDay.format(minute);

  CsvWriter _activitiesCsv(_Snapshot s, ExportOptions o) {
    final w = CsvWriter([
      'id', 'tanggal', 'judul', 'deskripsi', 'kategori', 'mulai', 'selesai',
      'berakhir_keesokan_hari', 'durasi_menit', 'status', 'catatan', 'tag',
    ]);
    for (final a in s.activities) {
      w.addRow([
        CsvCell.text(a.id),
        CsvCell.text(a.dateKey),
        CsvCell.userText(a.title),
        CsvCell.userText(a.description),
        CsvCell.userText(s.categories[a.categoryId]?.name),
        CsvCell.text(_time(a.startMinute)),
        CsvCell.text(_time(a.endMinute)),
        CsvCell.boolean(a.endsNextDay),
        CsvCell.number(a.durationMinutes),
        CsvCell.text(a.status.label),
        CsvCell.userText(o.includeNotes ? a.notes : null),
        CsvCell.userText(a.tags),
      ]);
    }
    return w;
  }

  CsvWriter _habitsCsv(_Snapshot s) {
    final w = CsvWriter(['id', 'nama', 'deskripsi', 'jenis', 'satuan', 'mulai', 'berakhir', 'diarsipkan']);
    for (final h in s.habits.values) {
      w.addRow([
        CsvCell.text(h.id),
        CsvCell.userText(h.name),
        CsvCell.userText(h.description),
        CsvCell.text(h.trackingType.label),
        CsvCell.userText(h.targetUnit),
        CsvCell.text(h.startDate),
        CsvCell.text(h.endDate),
        CsvCell.boolean(h.archived),
      ]);
    }
    return w;
  }

  CsvWriter _habitRecordsCsv(_Snapshot s, ExportOptions o) {
    final w = CsvWriter(['id', 'kebiasaan_id', 'kebiasaan', 'tanggal', 'status', 'nilai', 'target', 'catatan']);
    for (final r in s.habitRecords) {
      w.addRow([
        CsvCell.text(r.id),
        CsvCell.text(r.habitId),
        CsvCell.userText(s.habits[r.habitId]?.name),
        CsvCell.text(r.dateKey),
        CsvCell.text(r.status.label),
        CsvCell.number(r.value),
        CsvCell.number(r.targetSnapshot),
        CsvCell.userText(o.includeNotes ? r.note : null),
      ]);
    }
    return w;
  }

  CsvWriter _prayersCsv(_Snapshot s, ExportOptions o) {
    final w = CsvWriter(['id', 'tanggal', 'salat', 'status', 'waktu_pelaksanaan', 'berjamaah', 'catatan']);
    for (final r in s.prayers) {
      w.addRow([
        CsvCell.text(r.id),
        CsvCell.text(r.dateKey),
        CsvCell.text(r.prayer.label),
        CsvCell.text(r.status.label),
        CsvCell.text(_time(r.performedMinute)),
        CsvCell.boolean(r.jamaah),
        CsvCell.userText(o.includeNotes ? r.note : null),
      ]);
    }
    return w;
  }

  CsvWriter _worshipCsv(_Snapshot s, ExportOptions o) {
    final w = CsvWriter(['id', 'tanggal', 'ibadah', 'status', 'nilai', 'satuan', 'catatan']);
    for (final r in s.worship) {
      final item = s.worshipItems[r.itemId];
      w.addRow([
        CsvCell.text(r.id),
        CsvCell.text(r.dateKey),
        CsvCell.userText(item?.name),
        CsvCell.text(r.status.label),
        CsvCell.number(r.value),
        CsvCell.userText(item?.unit),
        CsvCell.userText(o.includeNotes ? r.note : null),
      ]);
    }
    return w;
  }

  CsvWriter _reflectionsCsv(_Snapshot s) {
    final w = CsvWriter(['id', 'tanggal', 'bagian', 'isi']);
    for (final r in s.reflections) {
      if (r.body.trim().isNotEmpty) {
        w.addRow([CsvCell.text(r.id), CsvCell.text(r.dateKey), const CsvCell.text('Catatan bebas'), CsvCell.userText(r.body)]);
      }
      for (final a in s.answers.where((a) => a.reflectionId == r.id)) {
        w.addRow([CsvCell.text(r.id), CsvCell.text(r.dateKey), CsvCell.userText(a.prompt), CsvCell.userText(a.answer)]);
      }
    }
    return w;
  }

  Map<String, Object?> _json(_Snapshot s, ExportOptions o) {
    String? note(String? v) => o.includeNotes ? v : null;
    return {
      'format': 'jujur-export',
      'formatVersion': exportFormatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': _clock().toUtc().toIso8601String(),
      'range': {'start': o.range.start.key, 'end': o.range.end.key},
      'includesNotes': o.includeNotes,
      if (o.types.contains(ExportRecordType.activities))
        'activities': [
          for (final a in s.activities)
            {
              'id': a.id,
              'date': a.dateKey,
              'title': a.title,
              'description': a.description,
              'category': a.categoryId == null
                  ? null
                  : {'id': a.categoryId, 'name': s.categories[a.categoryId]?.name},
              'start': _time(a.startMinute),
              'end': _time(a.endMinute),
              'endsNextDay': a.endsNextDay,
              'durationMinutes': a.durationMinutes,
              'status': a.status.name,
              'notes': note(a.notes),
              'tags': a.tags?.split(', '),
            },
        ],
      if (o.types.contains(ExportRecordType.habits)) ...{
        'habits': [
          for (final h in s.habits.values)
            {
              'id': h.id,
              'name': h.name,
              'description': h.description,
              'trackingType': h.trackingType.name,
              'unit': h.targetUnit,
              'startDate': h.startDate,
              'endDate': h.endDate,
              'archived': h.archived,
            },
        ],
        'habitRecords': [
          for (final r in s.habitRecords)
            {
              'id': r.id,
              'habitId': r.habitId,
              'date': r.dateKey,
              'status': r.status.name,
              'value': r.value,
              'target': r.targetSnapshot,
              'note': note(r.note),
            },
        ],
      },
      if (o.types.contains(ExportRecordType.prayers))
        'prayerRecords': [
          for (final r in s.prayers)
            {
              'id': r.id,
              'date': r.dateKey,
              'prayer': r.prayer.name,
              'status': r.status.name,
              'performedAt': _time(r.performedMinute),
              'jamaah': r.jamaah,
              'note': note(r.note),
            },
        ],
      if (o.types.contains(ExportRecordType.worship)) ...{
        'worshipItems': [
          for (final i in s.worshipItems.values)
            {'id': i.id, 'name': i.name, 'trackingType': i.trackingType.name, 'unit': i.unit},
        ],
        'worshipRecords': [
          for (final r in s.worship)
            {
              'id': r.id,
              'itemId': r.itemId,
              'date': r.dateKey,
              'status': r.status.name,
              'value': r.value,
              'note': note(r.note),
            },
        ],
      },
      if (o.types.contains(ExportRecordType.reflections))
        'reflections': [
          for (final r in s.reflections)
            {
              'id': r.id,
              'date': r.dateKey,
              'body': r.body,
              'answers': [
                for (final a in s.answers.where((a) => a.reflectionId == r.id))
                  {'prompt': a.prompt, 'answer': a.answer},
              ],
            },
        ],
    };
  }
}

class _Snapshot {
  _Snapshot({
    required this.categories,
    required this.activities,
    required this.habits,
    required this.habitRecords,
    required this.prayers,
    required this.worshipItems,
    required this.worship,
    required this.reflections,
    required this.answers,
  });

  final Map<String, Category> categories;
  final List<Activity> activities;
  final Map<String, Habit> habits;
  final List<HabitRecord> habitRecords;
  final List<PrayerRecord> prayers;
  final Map<String, WorshipItem> worshipItems;
  final List<WorshipRecord> worship;
  final List<Reflection> reflections;
  final List<ReflectionAnswer> answers;

  Map<ExportRecordType, int> counts(Set<ExportRecordType> types) => {
    for (final t in types)
      t: switch (t) {
        ExportRecordType.activities => activities.length,
        ExportRecordType.habits => habitRecords.length,
        ExportRecordType.prayers => prayers.length,
        ExportRecordType.worship => worship.length,
        ExportRecordType.reflections => reflections.length,
      },
  };
}
