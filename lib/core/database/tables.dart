// Drift column checks reference their own getter by design.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../../features/activities/domain/activity_status.dart';
import '../../features/habits/domain/habit_enums.dart';
import '../../features/prayers/domain/prayer.dart';
import '../../features/worship/domain/worship_enums.dart';

// Conventions (see docs/DATA_MODEL.md):
// - `id` columns are UUID v4 text, stable across backups.
// - `*_key` / `date_key` columns are local calendar dates as `YYYY-MM-DD`.
// - `created_at` / `updated_at` are UTC milliseconds since epoch.
// - "Not recorded" is always represented by the absence of a row.

mixin AuditColumns on Table {
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// Lightweight key/value settings, kept apart from tracking records.
@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('Category')
class Categories extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Activity')
@TableIndex(name: 'activities_date_key', columns: {#dateKey})
@TableIndex(name: 'activities_category', columns: {#categoryId})
class Activities extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get dateKey => text().withLength(min: 10, max: 10)();
  IntColumn get startMinute => integer().nullable().check(
    startMinute.isBetweenValues(0, 1439),
  )();
  IntColumn get endMinute =>
      integer().nullable().check(endMinute.isBetweenValues(0, 1439))();

  /// True when the end time belongs to the following calendar day.
  BoolColumn get endsNextDay => boolean().withDefault(const Constant(false))();

  /// Explicit duration in minutes, used when no start/end times are given.
  IntColumn get durationMinutes => integer().nullable().check(
    durationMinutes.isBetweenValues(0, 24 * 60),
  )();
  TextColumn get status => textEnum<ActivityStatus>()();
  TextColumn get notes => text().nullable()();

  /// Comma-separated, normalized tags. Added in schema version 2.
  TextColumn get tags => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Habit')
class Habits extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get trackingType => textEnum<HabitTrackingType>()();
  TextColumn get targetUnit => text().nullable()();
  TextColumn get startDate => text().withLength(min: 10, max: 10)();
  TextColumn get endDate => text().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Local minute-of-day for an optional reminder.
  IntColumn get reminderMinute =>
      integer().nullable().check(reminderMinute.isBetweenValues(0, 1439))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Versioned recurrence and target of a habit.
///
/// Editing a habit's schedule or target inserts a new version effective from
/// a date instead of rewriting the old one, so past days keep the schedule
/// that applied to them.
@DataClassName('HabitSchedule')
class HabitSchedules extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get effectiveFrom => text().withLength(min: 10, max: 10)();
  TextColumn get recurrence => textEnum<RecurrenceType>()();

  /// Bit mask of ISO weekdays: bit 0 = Monday ... bit 6 = Sunday.
  IntColumn get weekdaysMask => integer().withDefault(const Constant(0))();
  IntColumn get intervalDays => integer().nullable()();
  RealColumn get targetValue => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, effectiveFrom},
  ];
}

@DataClassName('HabitRecord')
@TableIndex(name: 'habit_records_date_key', columns: {#dateKey})
class HabitRecords extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get dateKey => text().withLength(min: 10, max: 10)();
  TextColumn get status => textEnum<HabitStatus>()();
  RealColumn get value => real().nullable()();

  /// The target that applied when this record was written.
  RealColumn get targetSnapshot => real().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, dateKey},
  ];
}

@DataClassName('PrayerRecord')
@TableIndex(name: 'prayer_records_date_key', columns: {#dateKey})
class PrayerRecords extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get prayer => textEnum<Prayer>()();

  /// The local date the prayer belongs to (not derived from a UTC timestamp).
  TextColumn get dateKey => text().withLength(min: 10, max: 10)();
  TextColumn get status => textEnum<PrayerStatus>()();

  /// Optional local wall-clock time the prayer was performed.
  IntColumn get performedMinute =>
      integer().nullable().check(performedMinute.isBetweenValues(0, 1439))();

  /// Null means "not recorded".
  BoolColumn get jamaah => boolean().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {prayer, dateKey},
  ];
}

@DataClassName('WorshipItem')
class WorshipItems extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get trackingType => textEnum<WorshipTrackingType>()();
  TextColumn get unit => text().nullable()();
  RealColumn get targetValue => real().nullable()();
  BoolColumn get showOnToday => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorshipRecord')
@TableIndex(name: 'worship_records_date_key', columns: {#dateKey})
class WorshipRecords extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(WorshipItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get dateKey => text().withLength(min: 10, max: 10)();
  TextColumn get status => textEnum<WorshipStatus>()();
  RealColumn get value => real().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {itemId, dateKey},
  ];
}

/// One reflection document per local date.
@DataClassName('Reflection')
class Reflections extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get dateKey => text().withLength(min: 10, max: 10).unique()();
  TextColumn get body => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Answers to optional prompts. The prompt text is stored with the answer so
/// later edits to the prompt list never change past reflections.
@DataClassName('ReflectionAnswer')
class ReflectionAnswers extends Table with AuditColumns {
  TextColumn get id => text()();
  TextColumn get reflectionId =>
      text().references(Reflections, #id, onDelete: KeyAction.cascade)();
  TextColumn get prompt => text()();
  TextColumn get answer => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {reflectionId, prompt},
  ];
}
