import '../../features/activities/domain/activity_status.dart';
import '../../features/habits/domain/habit_enums.dart';
import '../../features/prayers/domain/prayer.dart';
import '../../features/worship/domain/worship_enums.dart';

enum ColumnType { text, integer, real, boolean }

/// Column contract for backup rows. Mirrors the SQL schema.
class ColumnSpec {
  const ColumnSpec(
    this.name,
    this.type, {
    this.nullable = false,
    this.enumValues,
    this.isDateKey = false,
    this.references,
    this.sinceSchema = 1,
  });

  final String name;
  final ColumnType type;
  final bool nullable;
  final List<String>? enumValues;
  final bool isDateKey;

  /// Name of the referenced table (by `id`), if this is a foreign key.
  final String? references;

  /// Schema version that introduced the column. Older backups may omit it.
  final int sinceSchema;
}

class TableSpec {
  const TableSpec(this.name, this.columns, {this.naturalKeys = const []});

  final String name;
  final List<ColumnSpec> columns;

  /// Unique column combinations besides `id` (mirrors UNIQUE constraints).
  final List<List<String>> naturalKeys;

  Iterable<ColumnSpec> columnsFor(int schemaVersion) =>
      columns.where((c) => c.sinceSchema <= schemaVersion);
}

List<String> _names(List<Enum> values) => [for (final v in values) v.name];

const _audit = [
  ColumnSpec('created_at', ColumnType.integer),
  ColumnSpec('updated_at', ColumnType.integer),
];

/// Tables included in a backup, in parent-before-child order. Restores
/// insert in this order and delete in reverse.
final List<TableSpec> backupTables = [
  TableSpec('categories', [
    const ColumnSpec('id', ColumnType.text),
    const ColumnSpec('name', ColumnType.text),
    const ColumnSpec('description', ColumnType.text, nullable: true),
    const ColumnSpec('icon', ColumnType.text, nullable: true),
    const ColumnSpec('color', ColumnType.text, nullable: true),
    const ColumnSpec('sort_order', ColumnType.integer),
    const ColumnSpec('archived', ColumnType.boolean),
    ..._audit,
  ]),
  TableSpec('activities', [
    const ColumnSpec('id', ColumnType.text),
    const ColumnSpec('title', ColumnType.text),
    const ColumnSpec('description', ColumnType.text, nullable: true),
    const ColumnSpec('category_id', ColumnType.text, nullable: true, references: 'categories'),
    const ColumnSpec('date_key', ColumnType.text, isDateKey: true),
    const ColumnSpec('start_minute', ColumnType.integer, nullable: true),
    const ColumnSpec('end_minute', ColumnType.integer, nullable: true),
    const ColumnSpec('ends_next_day', ColumnType.boolean),
    const ColumnSpec('duration_minutes', ColumnType.integer, nullable: true),
    ColumnSpec('status', ColumnType.text, enumValues: _names(ActivityStatus.values)),
    const ColumnSpec('notes', ColumnType.text, nullable: true),
    const ColumnSpec('tags', ColumnType.text, nullable: true, sinceSchema: 2),
    ..._audit,
  ]),
  TableSpec('habits', [
    const ColumnSpec('id', ColumnType.text),
    const ColumnSpec('name', ColumnType.text),
    const ColumnSpec('description', ColumnType.text, nullable: true),
    const ColumnSpec('category_id', ColumnType.text, nullable: true, references: 'categories'),
    const ColumnSpec('icon', ColumnType.text, nullable: true),
    const ColumnSpec('color', ColumnType.text, nullable: true),
    ColumnSpec('tracking_type', ColumnType.text, enumValues: _names(HabitTrackingType.values)),
    const ColumnSpec('target_unit', ColumnType.text, nullable: true),
    const ColumnSpec('start_date', ColumnType.text, isDateKey: true),
    const ColumnSpec('end_date', ColumnType.text, nullable: true, isDateKey: true),
    const ColumnSpec('archived', ColumnType.boolean),
    const ColumnSpec('sort_order', ColumnType.integer),
    const ColumnSpec('reminder_minute', ColumnType.integer, nullable: true),
    ..._audit,
  ]),
  TableSpec(
    'habit_schedules',
    [
      const ColumnSpec('id', ColumnType.text),
      const ColumnSpec('habit_id', ColumnType.text, references: 'habits'),
      const ColumnSpec('effective_from', ColumnType.text, isDateKey: true),
      ColumnSpec('recurrence', ColumnType.text, enumValues: _names(RecurrenceType.values)),
      const ColumnSpec('weekdays_mask', ColumnType.integer),
      const ColumnSpec('interval_days', ColumnType.integer, nullable: true),
      const ColumnSpec('target_value', ColumnType.real, nullable: true),
      ..._audit,
    ],
    naturalKeys: [
      ['habit_id', 'effective_from'],
    ],
  ),
  TableSpec(
    'habit_records',
    [
      const ColumnSpec('id', ColumnType.text),
      const ColumnSpec('habit_id', ColumnType.text, references: 'habits'),
      const ColumnSpec('date_key', ColumnType.text, isDateKey: true),
      ColumnSpec('status', ColumnType.text, enumValues: _names(HabitStatus.values)),
      const ColumnSpec('value', ColumnType.real, nullable: true),
      const ColumnSpec('target_snapshot', ColumnType.real, nullable: true),
      const ColumnSpec('note', ColumnType.text, nullable: true),
      ..._audit,
    ],
    naturalKeys: [
      ['habit_id', 'date_key'],
    ],
  ),
  TableSpec(
    'prayer_records',
    [
      const ColumnSpec('id', ColumnType.text),
      ColumnSpec('prayer', ColumnType.text, enumValues: _names(Prayer.values)),
      const ColumnSpec('date_key', ColumnType.text, isDateKey: true),
      ColumnSpec('status', ColumnType.text, enumValues: _names(PrayerStatus.values)),
      const ColumnSpec('performed_minute', ColumnType.integer, nullable: true),
      const ColumnSpec('jamaah', ColumnType.boolean, nullable: true),
      const ColumnSpec('note', ColumnType.text, nullable: true),
      ..._audit,
    ],
    naturalKeys: [
      ['prayer', 'date_key'],
    ],
  ),
  TableSpec('worship_items', [
    const ColumnSpec('id', ColumnType.text),
    const ColumnSpec('name', ColumnType.text),
    ColumnSpec('tracking_type', ColumnType.text, enumValues: _names(WorshipTrackingType.values)),
    const ColumnSpec('unit', ColumnType.text, nullable: true),
    const ColumnSpec('target_value', ColumnType.real, nullable: true),
    const ColumnSpec('show_on_today', ColumnType.boolean),
    const ColumnSpec('archived', ColumnType.boolean),
    const ColumnSpec('sort_order', ColumnType.integer),
    ..._audit,
  ]),
  TableSpec(
    'worship_records',
    [
      const ColumnSpec('id', ColumnType.text),
      const ColumnSpec('item_id', ColumnType.text, references: 'worship_items'),
      const ColumnSpec('date_key', ColumnType.text, isDateKey: true),
      ColumnSpec('status', ColumnType.text, enumValues: _names(WorshipStatus.values)),
      const ColumnSpec('value', ColumnType.real, nullable: true),
      const ColumnSpec('note', ColumnType.text, nullable: true),
      ..._audit,
    ],
    naturalKeys: [
      ['item_id', 'date_key'],
    ],
  ),
  TableSpec(
    'reflections',
    [
      const ColumnSpec('id', ColumnType.text),
      const ColumnSpec('date_key', ColumnType.text, isDateKey: true),
      const ColumnSpec('body', ColumnType.text),
      ..._audit,
    ],
    naturalKeys: [
      ['date_key'],
    ],
  ),
  TableSpec(
    'reflection_answers',
    [
      const ColumnSpec('id', ColumnType.text),
      const ColumnSpec('reflection_id', ColumnType.text, references: 'reflections'),
      const ColumnSpec('prompt', ColumnType.text),
      const ColumnSpec('answer', ColumnType.text),
      const ColumnSpec('sort_order', ColumnType.integer),
      ..._audit,
    ],
    naturalKeys: [
      ['reflection_id', 'prompt'],
    ],
  ),
];

final Map<String, TableSpec> backupTablesByName = {
  for (final t in backupTables) t.name: t,
};
