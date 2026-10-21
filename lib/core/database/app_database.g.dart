// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  final int updatedAt;
  const SettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SettingRow copyWith({String? key, String? value, int? updatedAt}) =>
      SettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingRow copyWithCompanion(AppSettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    description,
    icon,
    color,
    sortOrder,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool archived;
  const Category({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      sortOrder: Value(sortOrder),
      archived: Value(archived),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Category copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    int? sortOrder,
    bool? archived,
  }) => Category(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    description,
    icon,
    color,
    sortOrder,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.archived == this.archived);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<int> sortOrder;
  final Value<bool> archived;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? icon,
    Value<String?>? color,
    Value<int>? sortOrder,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    true,
    check: () => ComparableExpr(startMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    true,
    check: () => ComparableExpr(endMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endsNextDayMeta = const VerificationMeta(
    'endsNextDay',
  );
  @override
  late final GeneratedColumn<bool> endsNextDay = GeneratedColumn<bool>(
    'ends_next_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ends_next_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    check: () => ComparableExpr(durationMinutes).isBetweenValues(0, 24 * 60),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActivityStatus>($ActivitiesTable.$converterstatus);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    title,
    description,
    categoryId,
    dateKey,
    startMinute,
    endMinute,
    endsNextDay,
    durationMinutes,
    status,
    notes,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    }
    if (data.containsKey('ends_next_day')) {
      context.handle(
        _endsNextDayMeta,
        endsNextDay.isAcceptableOrUnknown(
          data['ends_next_day']!,
          _endsNextDayMeta,
        ),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      ),
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      ),
      endsNextDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ends_next_day'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
      status: $ActivitiesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityStatus, String, String> $converterstatus =
      const EnumNameConverter<ActivityStatus>(ActivityStatus.values);
}

class Activity extends DataClass implements Insertable<Activity> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final String dateKey;
  final int? startMinute;
  final int? endMinute;

  /// True when the end time belongs to the following calendar day.
  final bool endsNextDay;

  /// Explicit duration in minutes, used when no start/end times are given.
  final int? durationMinutes;
  final ActivityStatus status;
  final String? notes;

  /// Comma-separated, normalized tags. Added in schema version 2.
  final String? tags;
  const Activity({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    required this.dateKey,
    this.startMinute,
    this.endMinute,
    required this.endsNextDay,
    this.durationMinutes,
    required this.status,
    this.notes,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['date_key'] = Variable<String>(dateKey);
    if (!nullToAbsent || startMinute != null) {
      map['start_minute'] = Variable<int>(startMinute);
    }
    if (!nullToAbsent || endMinute != null) {
      map['end_minute'] = Variable<int>(endMinute);
    }
    map['ends_next_day'] = Variable<bool>(endsNextDay);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    {
      map['status'] = Variable<String>(
        $ActivitiesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      dateKey: Value(dateKey),
      startMinute: startMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinute),
      endMinute: endMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinute),
      endsNextDay: Value(endsNextDay),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      startMinute: serializer.fromJson<int?>(json['startMinute']),
      endMinute: serializer.fromJson<int?>(json['endMinute']),
      endsNextDay: serializer.fromJson<bool>(json['endsNextDay']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      status: $ActivitiesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<String?>(categoryId),
      'dateKey': serializer.toJson<String>(dateKey),
      'startMinute': serializer.toJson<int?>(startMinute),
      'endMinute': serializer.toJson<int?>(endMinute),
      'endsNextDay': serializer.toJson<bool>(endsNextDay),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'status': serializer.toJson<String>(
        $ActivitiesTable.$converterstatus.toJson(status),
      ),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  Activity copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    String? dateKey,
    Value<int?> startMinute = const Value.absent(),
    Value<int?> endMinute = const Value.absent(),
    bool? endsNextDay,
    Value<int?> durationMinutes = const Value.absent(),
    ActivityStatus? status,
    Value<String?> notes = const Value.absent(),
    Value<String?> tags = const Value.absent(),
  }) => Activity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    dateKey: dateKey ?? this.dateKey,
    startMinute: startMinute.present ? startMinute.value : this.startMinute,
    endMinute: endMinute.present ? endMinute.value : this.endMinute,
    endsNextDay: endsNextDay ?? this.endsNextDay,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    tags: tags.present ? tags.value : this.tags,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      endsNextDay: data.endsNextDay.present
          ? data.endsNextDay.value
          : this.endsNextDay,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateKey: $dateKey, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('endsNextDay: $endsNextDay, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    title,
    description,
    categoryId,
    dateKey,
    startMinute,
    endMinute,
    endsNextDay,
    durationMinutes,
    status,
    notes,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.dateKey == this.dateKey &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.endsNextDay == this.endsNextDay &&
          other.durationMinutes == this.durationMinutes &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.tags == this.tags);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> categoryId;
  final Value<String> dateKey;
  final Value<int?> startMinute;
  final Value<int?> endMinute;
  final Value<bool> endsNextDay;
  final Value<int?> durationMinutes;
  final Value<ActivityStatus> status;
  final Value<String?> notes;
  final Value<String?> tags;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.endsNextDay = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    required String dateKey,
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.endsNextDay = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    required ActivityStatus status,
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       title = Value(title),
       dateKey = Value(dateKey),
       status = Value(status);
  static Insertable<Activity> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? dateKey,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<bool>? endsNextDay,
    Expression<int>? durationMinutes,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (dateKey != null) 'date_key': dateKey,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (endsNextDay != null) 'ends_next_day': endsNextDay,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? categoryId,
    Value<String>? dateKey,
    Value<int?>? startMinute,
    Value<int?>? endMinute,
    Value<bool>? endsNextDay,
    Value<int?>? durationMinutes,
    Value<ActivityStatus>? status,
    Value<String?>? notes,
    Value<String?>? tags,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      dateKey: dateKey ?? this.dateKey,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      endsNextDay: endsNextDay ?? this.endsNextDay,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (endsNextDay.present) {
      map['ends_next_day'] = Variable<bool>(endsNextDay.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ActivitiesTable.$converterstatus.toSql(status.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateKey: $dateKey, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('endsNextDay: $endsNextDay, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitTrackingType, String>
  trackingType = GeneratedColumn<String>(
    'tracking_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<HabitTrackingType>($HabitsTable.$convertertrackingType);
  static const VerificationMeta _targetUnitMeta = const VerificationMeta(
    'targetUnit',
  );
  @override
  late final GeneratedColumn<String> targetUnit = GeneratedColumn<String>(
    'target_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    true,
    check: () => ComparableExpr(reminderMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    description,
    categoryId,
    icon,
    color,
    trackingType,
    targetUnit,
    startDate,
    endDate,
    archived,
    sortOrder,
    reminderMinute,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('target_unit')) {
      context.handle(
        _targetUnitMeta,
        targetUnit.isAcceptableOrUnknown(data['target_unit']!, _targetUnitMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      trackingType: $HabitsTable.$convertertrackingType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tracking_type'],
        )!,
      ),
      targetUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_unit'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitTrackingType, String, String>
  $convertertrackingType = const EnumNameConverter<HabitTrackingType>(
    HabitTrackingType.values,
  );
}

class Habit extends DataClass implements Insertable<Habit> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? icon;
  final String? color;
  final HabitTrackingType trackingType;
  final String? targetUnit;
  final String startDate;
  final String? endDate;
  final bool archived;
  final int sortOrder;

  /// Local minute-of-day for an optional reminder.
  final int? reminderMinute;
  const Habit({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.icon,
    this.color,
    required this.trackingType,
    this.targetUnit,
    required this.startDate,
    this.endDate,
    required this.archived,
    required this.sortOrder,
    this.reminderMinute,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    {
      map['tracking_type'] = Variable<String>(
        $HabitsTable.$convertertrackingType.toSql(trackingType),
      );
    }
    if (!nullToAbsent || targetUnit != null) {
      map['target_unit'] = Variable<String>(targetUnit);
    }
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || reminderMinute != null) {
      map['reminder_minute'] = Variable<int>(reminderMinute);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      trackingType: Value(trackingType),
      targetUnit: targetUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(targetUnit),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      reminderMinute: reminderMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinute),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      trackingType: $HabitsTable.$convertertrackingType.fromJson(
        serializer.fromJson<String>(json['trackingType']),
      ),
      targetUnit: serializer.fromJson<String?>(json['targetUnit']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      reminderMinute: serializer.fromJson<int?>(json['reminderMinute']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'categoryId': serializer.toJson<String?>(categoryId),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'trackingType': serializer.toJson<String>(
        $HabitsTable.$convertertrackingType.toJson(trackingType),
      ),
      'targetUnit': serializer.toJson<String?>(targetUnit),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'reminderMinute': serializer.toJson<int?>(reminderMinute),
    };
  }

  Habit copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    HabitTrackingType? trackingType,
    Value<String?> targetUnit = const Value.absent(),
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    bool? archived,
    int? sortOrder,
    Value<int?> reminderMinute = const Value.absent(),
  }) => Habit(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    trackingType: trackingType ?? this.trackingType,
    targetUnit: targetUnit.present ? targetUnit.value : this.targetUnit,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    reminderMinute: reminderMinute.present
        ? reminderMinute.value
        : this.reminderMinute,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      trackingType: data.trackingType.present
          ? data.trackingType.value
          : this.trackingType,
      targetUnit: data.targetUnit.present
          ? data.targetUnit.value
          : this.targetUnit,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('trackingType: $trackingType, ')
          ..write('targetUnit: $targetUnit, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('reminderMinute: $reminderMinute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    description,
    categoryId,
    icon,
    color,
    trackingType,
    targetUnit,
    startDate,
    endDate,
    archived,
    sortOrder,
    reminderMinute,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.trackingType == this.trackingType &&
          other.targetUnit == this.targetUnit &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.reminderMinute == this.reminderMinute);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> categoryId;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<HabitTrackingType> trackingType;
  final Value<String?> targetUnit;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<int?> reminderMinute;
  final Value<int> rowid;
  const HabitsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.targetUnit = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required HabitTrackingType trackingType,
    this.targetUnit = const Value.absent(),
    required String startDate,
    this.endDate = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       trackingType = Value(trackingType),
       startDate = Value(startDate);
  static Insertable<Habit> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? trackingType,
    Expression<String>? targetUnit,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<int>? reminderMinute,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (trackingType != null) 'tracking_type': trackingType,
      if (targetUnit != null) 'target_unit': targetUnit,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? categoryId,
    Value<String?>? icon,
    Value<String?>? color,
    Value<HabitTrackingType>? trackingType,
    Value<String?>? targetUnit,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<int?>? reminderMinute,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      trackingType: trackingType ?? this.trackingType,
      targetUnit: targetUnit ?? this.targetUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (trackingType.present) {
      map['tracking_type'] = Variable<String>(
        $HabitsTable.$convertertrackingType.toSql(trackingType.value),
      );
    }
    if (targetUnit.present) {
      map['target_unit'] = Variable<String>(targetUnit.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('trackingType: $trackingType, ')
          ..write('targetUnit: $targetUnit, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitSchedulesTable extends HabitSchedules
    with TableInfo<$HabitSchedulesTable, HabitSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<String> effectiveFrom = GeneratedColumn<String>(
    'effective_from',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecurrenceType, String>
  recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<RecurrenceType>($HabitSchedulesTable.$converterrecurrence);
  static const VerificationMeta _weekdaysMaskMeta = const VerificationMeta(
    'weekdaysMask',
  );
  @override
  late final GeneratedColumn<int> weekdaysMask = GeneratedColumn<int>(
    'weekdays_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    habitId,
    effectiveFrom,
    recurrence,
    weekdaysMask,
    intervalDays,
    targetValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('weekdays_mask')) {
      context.handle(
        _weekdaysMaskMeta,
        weekdaysMask.isAcceptableOrUnknown(
          data['weekdays_mask']!,
          _weekdaysMaskMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, effectiveFrom},
  ];
  @override
  HabitSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitSchedule(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from'],
      )!,
      recurrence: $HabitSchedulesTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      weekdaysMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays_mask'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      ),
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      ),
    );
  }

  @override
  $HabitSchedulesTable createAlias(String alias) {
    return $HabitSchedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecurrenceType, String, String>
  $converterrecurrence = const EnumNameConverter<RecurrenceType>(
    RecurrenceType.values,
  );
}

class HabitSchedule extends DataClass implements Insertable<HabitSchedule> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String habitId;
  final String effectiveFrom;
  final RecurrenceType recurrence;

  /// Bit mask of ISO weekdays: bit 0 = Monday ... bit 6 = Sunday.
  final int weekdaysMask;
  final int? intervalDays;
  final double? targetValue;
  const HabitSchedule({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.habitId,
    required this.effectiveFrom,
    required this.recurrence,
    required this.weekdaysMask,
    this.intervalDays,
    this.targetValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['effective_from'] = Variable<String>(effectiveFrom);
    {
      map['recurrence'] = Variable<String>(
        $HabitSchedulesTable.$converterrecurrence.toSql(recurrence),
      );
    }
    map['weekdays_mask'] = Variable<int>(weekdaysMask);
    if (!nullToAbsent || intervalDays != null) {
      map['interval_days'] = Variable<int>(intervalDays);
    }
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<double>(targetValue);
    }
    return map;
  }

  HabitSchedulesCompanion toCompanion(bool nullToAbsent) {
    return HabitSchedulesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      habitId: Value(habitId),
      effectiveFrom: Value(effectiveFrom),
      recurrence: Value(recurrence),
      weekdaysMask: Value(weekdaysMask),
      intervalDays: intervalDays == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalDays),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
    );
  }

  factory HabitSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitSchedule(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      effectiveFrom: serializer.fromJson<String>(json['effectiveFrom']),
      recurrence: $HabitSchedulesTable.$converterrecurrence.fromJson(
        serializer.fromJson<String>(json['recurrence']),
      ),
      weekdaysMask: serializer.fromJson<int>(json['weekdaysMask']),
      intervalDays: serializer.fromJson<int?>(json['intervalDays']),
      targetValue: serializer.fromJson<double?>(json['targetValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'effectiveFrom': serializer.toJson<String>(effectiveFrom),
      'recurrence': serializer.toJson<String>(
        $HabitSchedulesTable.$converterrecurrence.toJson(recurrence),
      ),
      'weekdaysMask': serializer.toJson<int>(weekdaysMask),
      'intervalDays': serializer.toJson<int?>(intervalDays),
      'targetValue': serializer.toJson<double?>(targetValue),
    };
  }

  HabitSchedule copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? habitId,
    String? effectiveFrom,
    RecurrenceType? recurrence,
    int? weekdaysMask,
    Value<int?> intervalDays = const Value.absent(),
    Value<double?> targetValue = const Value.absent(),
  }) => HabitSchedule(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    recurrence: recurrence ?? this.recurrence,
    weekdaysMask: weekdaysMask ?? this.weekdaysMask,
    intervalDays: intervalDays.present ? intervalDays.value : this.intervalDays,
    targetValue: targetValue.present ? targetValue.value : this.targetValue,
  );
  HabitSchedule copyWithCompanion(HabitSchedulesCompanion data) {
    return HabitSchedule(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      weekdaysMask: data.weekdaysMask.present
          ? data.weekdaysMask.value
          : this.weekdaysMask,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitSchedule(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('recurrence: $recurrence, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('targetValue: $targetValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    habitId,
    effectiveFrom,
    recurrence,
    weekdaysMask,
    intervalDays,
    targetValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitSchedule &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.recurrence == this.recurrence &&
          other.weekdaysMask == this.weekdaysMask &&
          other.intervalDays == this.intervalDays &&
          other.targetValue == this.targetValue);
}

class HabitSchedulesCompanion extends UpdateCompanion<HabitSchedule> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> habitId;
  final Value<String> effectiveFrom;
  final Value<RecurrenceType> recurrence;
  final Value<int> weekdaysMask;
  final Value<int?> intervalDays;
  final Value<double?> targetValue;
  final Value<int> rowid;
  const HabitSchedulesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.weekdaysMask = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitSchedulesCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String habitId,
    required String effectiveFrom,
    required RecurrenceType recurrence,
    this.weekdaysMask = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       habitId = Value(habitId),
       effectiveFrom = Value(effectiveFrom),
       recurrence = Value(recurrence);
  static Insertable<HabitSchedule> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<String>? effectiveFrom,
    Expression<String>? recurrence,
    Expression<int>? weekdaysMask,
    Expression<int>? intervalDays,
    Expression<double>? targetValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (recurrence != null) 'recurrence': recurrence,
      if (weekdaysMask != null) 'weekdays_mask': weekdaysMask,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (targetValue != null) 'target_value': targetValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitSchedulesCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? habitId,
    Value<String>? effectiveFrom,
    Value<RecurrenceType>? recurrence,
    Value<int>? weekdaysMask,
    Value<int?>? intervalDays,
    Value<double?>? targetValue,
    Value<int>? rowid,
  }) {
    return HabitSchedulesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      recurrence: recurrence ?? this.recurrence,
      weekdaysMask: weekdaysMask ?? this.weekdaysMask,
      intervalDays: intervalDays ?? this.intervalDays,
      targetValue: targetValue ?? this.targetValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<String>(effectiveFrom.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $HabitSchedulesTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (weekdaysMask.present) {
      map['weekdays_mask'] = Variable<int>(weekdaysMask.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitSchedulesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('recurrence: $recurrence, ')
          ..write('weekdaysMask: $weekdaysMask, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('targetValue: $targetValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitRecordsTable extends HabitRecords
    with TableInfo<$HabitRecordsTable, HabitRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HabitStatus>($HabitRecordsTable.$converterstatus);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSnapshotMeta = const VerificationMeta(
    'targetSnapshot',
  );
  @override
  late final GeneratedColumn<double> targetSnapshot = GeneratedColumn<double>(
    'target_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    habitId,
    dateKey,
    status,
    value,
    targetSnapshot,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('target_snapshot')) {
      context.handle(
        _targetSnapshotMeta,
        targetSnapshot.isAcceptableOrUnknown(
          data['target_snapshot']!,
          _targetSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, dateKey},
  ];
  @override
  HabitRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRecord(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      status: $HabitRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      ),
      targetSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_snapshot'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $HabitRecordsTable createAlias(String alias) {
    return $HabitRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitStatus, String, String> $converterstatus =
      const EnumNameConverter<HabitStatus>(HabitStatus.values);
}

class HabitRecord extends DataClass implements Insertable<HabitRecord> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String habitId;
  final String dateKey;
  final HabitStatus status;
  final double? value;

  /// The target that applied when this record was written.
  final double? targetSnapshot;
  final String? note;
  const HabitRecord({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.habitId,
    required this.dateKey,
    required this.status,
    this.value,
    this.targetSnapshot,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['date_key'] = Variable<String>(dateKey);
    {
      map['status'] = Variable<String>(
        $HabitRecordsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    if (!nullToAbsent || targetSnapshot != null) {
      map['target_snapshot'] = Variable<double>(targetSnapshot);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  HabitRecordsCompanion toCompanion(bool nullToAbsent) {
    return HabitRecordsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      habitId: Value(habitId),
      dateKey: Value(dateKey),
      status: Value(status),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      targetSnapshot: targetSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSnapshot),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory HabitRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRecord(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      status: $HabitRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      value: serializer.fromJson<double?>(json['value']),
      targetSnapshot: serializer.fromJson<double?>(json['targetSnapshot']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'dateKey': serializer.toJson<String>(dateKey),
      'status': serializer.toJson<String>(
        $HabitRecordsTable.$converterstatus.toJson(status),
      ),
      'value': serializer.toJson<double?>(value),
      'targetSnapshot': serializer.toJson<double?>(targetSnapshot),
      'note': serializer.toJson<String?>(note),
    };
  }

  HabitRecord copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? habitId,
    String? dateKey,
    HabitStatus? status,
    Value<double?> value = const Value.absent(),
    Value<double?> targetSnapshot = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => HabitRecord(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    dateKey: dateKey ?? this.dateKey,
    status: status ?? this.status,
    value: value.present ? value.value : this.value,
    targetSnapshot: targetSnapshot.present
        ? targetSnapshot.value
        : this.targetSnapshot,
    note: note.present ? note.value : this.note,
  );
  HabitRecord copyWithCompanion(HabitRecordsCompanion data) {
    return HabitRecord(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      status: data.status.present ? data.status.value : this.status,
      value: data.value.present ? data.value.value : this.value,
      targetSnapshot: data.targetSnapshot.present
          ? data.targetSnapshot.value
          : this.targetSnapshot,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRecord(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('dateKey: $dateKey, ')
          ..write('status: $status, ')
          ..write('value: $value, ')
          ..write('targetSnapshot: $targetSnapshot, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    habitId,
    dateKey,
    status,
    value,
    targetSnapshot,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRecord &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.dateKey == this.dateKey &&
          other.status == this.status &&
          other.value == this.value &&
          other.targetSnapshot == this.targetSnapshot &&
          other.note == this.note);
}

class HabitRecordsCompanion extends UpdateCompanion<HabitRecord> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> habitId;
  final Value<String> dateKey;
  final Value<HabitStatus> status;
  final Value<double?> value;
  final Value<double?> targetSnapshot;
  final Value<String?> note;
  final Value<int> rowid;
  const HabitRecordsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.status = const Value.absent(),
    this.value = const Value.absent(),
    this.targetSnapshot = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitRecordsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String habitId,
    required String dateKey,
    required HabitStatus status,
    this.value = const Value.absent(),
    this.targetSnapshot = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       habitId = Value(habitId),
       dateKey = Value(dateKey),
       status = Value(status);
  static Insertable<HabitRecord> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<String>? dateKey,
    Expression<String>? status,
    Expression<double>? value,
    Expression<double>? targetSnapshot,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (dateKey != null) 'date_key': dateKey,
      if (status != null) 'status': status,
      if (value != null) 'value': value,
      if (targetSnapshot != null) 'target_snapshot': targetSnapshot,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitRecordsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? habitId,
    Value<String>? dateKey,
    Value<HabitStatus>? status,
    Value<double?>? value,
    Value<double?>? targetSnapshot,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return HabitRecordsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      dateKey: dateKey ?? this.dateKey,
      status: status ?? this.status,
      value: value ?? this.value,
      targetSnapshot: targetSnapshot ?? this.targetSnapshot,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $HabitRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (targetSnapshot.present) {
      map['target_snapshot'] = Variable<double>(targetSnapshot.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitRecordsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('dateKey: $dateKey, ')
          ..write('status: $status, ')
          ..write('value: $value, ')
          ..write('targetSnapshot: $targetSnapshot, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayerRecordsTable extends PrayerRecords
    with TableInfo<$PrayerRecordsTable, PrayerRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Prayer, String> prayer =
      GeneratedColumn<String>(
        'prayer',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Prayer>($PrayerRecordsTable.$converterprayer);
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrayerStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrayerStatus>($PrayerRecordsTable.$converterstatus);
  static const VerificationMeta _performedMinuteMeta = const VerificationMeta(
    'performedMinute',
  );
  @override
  late final GeneratedColumn<int> performedMinute = GeneratedColumn<int>(
    'performed_minute',
    aliasedName,
    true,
    check: () => ComparableExpr(performedMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jamaahMeta = const VerificationMeta('jamaah');
  @override
  late final GeneratedColumn<bool> jamaah = GeneratedColumn<bool>(
    'jamaah',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("jamaah" IN (0, 1))',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    prayer,
    dateKey,
    status,
    performedMinute,
    jamaah,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('performed_minute')) {
      context.handle(
        _performedMinuteMeta,
        performedMinute.isAcceptableOrUnknown(
          data['performed_minute']!,
          _performedMinuteMeta,
        ),
      );
    }
    if (data.containsKey('jamaah')) {
      context.handle(
        _jamaahMeta,
        jamaah.isAcceptableOrUnknown(data['jamaah']!, _jamaahMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {prayer, dateKey},
  ];
  @override
  PrayerRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerRecord(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      prayer: $PrayerRecordsTable.$converterprayer.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}prayer'],
        )!,
      ),
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      status: $PrayerRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      performedMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}performed_minute'],
      ),
      jamaah: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}jamaah'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PrayerRecordsTable createAlias(String alias) {
    return $PrayerRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Prayer, String, String> $converterprayer =
      const EnumNameConverter<Prayer>(Prayer.values);
  static JsonTypeConverter2<PrayerStatus, String, String> $converterstatus =
      const EnumNameConverter<PrayerStatus>(PrayerStatus.values);
}

class PrayerRecord extends DataClass implements Insertable<PrayerRecord> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final Prayer prayer;

  /// The local date the prayer belongs to (not derived from a UTC timestamp).
  final String dateKey;
  final PrayerStatus status;

  /// Optional local wall-clock time the prayer was performed.
  final int? performedMinute;

  /// Null means "not recorded".
  final bool? jamaah;
  final String? note;
  const PrayerRecord({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.prayer,
    required this.dateKey,
    required this.status,
    this.performedMinute,
    this.jamaah,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    {
      map['prayer'] = Variable<String>(
        $PrayerRecordsTable.$converterprayer.toSql(prayer),
      );
    }
    map['date_key'] = Variable<String>(dateKey);
    {
      map['status'] = Variable<String>(
        $PrayerRecordsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || performedMinute != null) {
      map['performed_minute'] = Variable<int>(performedMinute);
    }
    if (!nullToAbsent || jamaah != null) {
      map['jamaah'] = Variable<bool>(jamaah);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PrayerRecordsCompanion toCompanion(bool nullToAbsent) {
    return PrayerRecordsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      prayer: Value(prayer),
      dateKey: Value(dateKey),
      status: Value(status),
      performedMinute: performedMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(performedMinute),
      jamaah: jamaah == null && nullToAbsent
          ? const Value.absent()
          : Value(jamaah),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PrayerRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerRecord(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      prayer: $PrayerRecordsTable.$converterprayer.fromJson(
        serializer.fromJson<String>(json['prayer']),
      ),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      status: $PrayerRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      performedMinute: serializer.fromJson<int?>(json['performedMinute']),
      jamaah: serializer.fromJson<bool?>(json['jamaah']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'prayer': serializer.toJson<String>(
        $PrayerRecordsTable.$converterprayer.toJson(prayer),
      ),
      'dateKey': serializer.toJson<String>(dateKey),
      'status': serializer.toJson<String>(
        $PrayerRecordsTable.$converterstatus.toJson(status),
      ),
      'performedMinute': serializer.toJson<int?>(performedMinute),
      'jamaah': serializer.toJson<bool?>(jamaah),
      'note': serializer.toJson<String?>(note),
    };
  }

  PrayerRecord copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    Prayer? prayer,
    String? dateKey,
    PrayerStatus? status,
    Value<int?> performedMinute = const Value.absent(),
    Value<bool?> jamaah = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => PrayerRecord(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    prayer: prayer ?? this.prayer,
    dateKey: dateKey ?? this.dateKey,
    status: status ?? this.status,
    performedMinute: performedMinute.present
        ? performedMinute.value
        : this.performedMinute,
    jamaah: jamaah.present ? jamaah.value : this.jamaah,
    note: note.present ? note.value : this.note,
  );
  PrayerRecord copyWithCompanion(PrayerRecordsCompanion data) {
    return PrayerRecord(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      status: data.status.present ? data.status.value : this.status,
      performedMinute: data.performedMinute.present
          ? data.performedMinute.value
          : this.performedMinute,
      jamaah: data.jamaah.present ? data.jamaah.value : this.jamaah,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerRecord(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('prayer: $prayer, ')
          ..write('dateKey: $dateKey, ')
          ..write('status: $status, ')
          ..write('performedMinute: $performedMinute, ')
          ..write('jamaah: $jamaah, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    prayer,
    dateKey,
    status,
    performedMinute,
    jamaah,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerRecord &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.prayer == this.prayer &&
          other.dateKey == this.dateKey &&
          other.status == this.status &&
          other.performedMinute == this.performedMinute &&
          other.jamaah == this.jamaah &&
          other.note == this.note);
}

class PrayerRecordsCompanion extends UpdateCompanion<PrayerRecord> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<Prayer> prayer;
  final Value<String> dateKey;
  final Value<PrayerStatus> status;
  final Value<int?> performedMinute;
  final Value<bool?> jamaah;
  final Value<String?> note;
  final Value<int> rowid;
  const PrayerRecordsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.prayer = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.status = const Value.absent(),
    this.performedMinute = const Value.absent(),
    this.jamaah = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerRecordsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required Prayer prayer,
    required String dateKey,
    required PrayerStatus status,
    this.performedMinute = const Value.absent(),
    this.jamaah = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       prayer = Value(prayer),
       dateKey = Value(dateKey),
       status = Value(status);
  static Insertable<PrayerRecord> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? prayer,
    Expression<String>? dateKey,
    Expression<String>? status,
    Expression<int>? performedMinute,
    Expression<bool>? jamaah,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (prayer != null) 'prayer': prayer,
      if (dateKey != null) 'date_key': dateKey,
      if (status != null) 'status': status,
      if (performedMinute != null) 'performed_minute': performedMinute,
      if (jamaah != null) 'jamaah': jamaah,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerRecordsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<Prayer>? prayer,
    Value<String>? dateKey,
    Value<PrayerStatus>? status,
    Value<int?>? performedMinute,
    Value<bool?>? jamaah,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PrayerRecordsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      prayer: prayer ?? this.prayer,
      dateKey: dateKey ?? this.dateKey,
      status: status ?? this.status,
      performedMinute: performedMinute ?? this.performedMinute,
      jamaah: jamaah ?? this.jamaah,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<String>(
        $PrayerRecordsTable.$converterprayer.toSql(prayer.value),
      );
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PrayerRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (performedMinute.present) {
      map['performed_minute'] = Variable<int>(performedMinute.value);
    }
    if (jamaah.present) {
      map['jamaah'] = Variable<bool>(jamaah.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerRecordsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('prayer: $prayer, ')
          ..write('dateKey: $dateKey, ')
          ..write('status: $status, ')
          ..write('performedMinute: $performedMinute, ')
          ..write('jamaah: $jamaah, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorshipItemsTable extends WorshipItems
    with TableInfo<$WorshipItemsTable, WorshipItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorshipItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorshipTrackingType, String>
  trackingType =
      GeneratedColumn<String>(
        'tracking_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WorshipTrackingType>(
        $WorshipItemsTable.$convertertrackingType,
      );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _showOnTodayMeta = const VerificationMeta(
    'showOnToday',
  );
  @override
  late final GeneratedColumn<bool> showOnToday = GeneratedColumn<bool>(
    'show_on_today',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_on_today" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    name,
    trackingType,
    unit,
    targetValue,
    showOnToday,
    archived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worship_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorshipItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('show_on_today')) {
      context.handle(
        _showOnTodayMeta,
        showOnToday.isAcceptableOrUnknown(
          data['show_on_today']!,
          _showOnTodayMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorshipItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorshipItem(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      trackingType: $WorshipItemsTable.$convertertrackingType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tracking_type'],
        )!,
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      ),
      showOnToday: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_on_today'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WorshipItemsTable createAlias(String alias) {
    return $WorshipItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WorshipTrackingType, String, String>
  $convertertrackingType = const EnumNameConverter<WorshipTrackingType>(
    WorshipTrackingType.values,
  );
}

class WorshipItem extends DataClass implements Insertable<WorshipItem> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final WorshipTrackingType trackingType;
  final String? unit;
  final double? targetValue;
  final bool showOnToday;
  final bool archived;
  final int sortOrder;
  const WorshipItem({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    required this.trackingType,
    this.unit,
    this.targetValue,
    required this.showOnToday,
    required this.archived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['tracking_type'] = Variable<String>(
        $WorshipItemsTable.$convertertrackingType.toSql(trackingType),
      );
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<double>(targetValue);
    }
    map['show_on_today'] = Variable<bool>(showOnToday);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorshipItemsCompanion toCompanion(bool nullToAbsent) {
    return WorshipItemsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      trackingType: Value(trackingType),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
      showOnToday: Value(showOnToday),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorshipItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorshipItem(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      trackingType: $WorshipItemsTable.$convertertrackingType.fromJson(
        serializer.fromJson<String>(json['trackingType']),
      ),
      unit: serializer.fromJson<String?>(json['unit']),
      targetValue: serializer.fromJson<double?>(json['targetValue']),
      showOnToday: serializer.fromJson<bool>(json['showOnToday']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'trackingType': serializer.toJson<String>(
        $WorshipItemsTable.$convertertrackingType.toJson(trackingType),
      ),
      'unit': serializer.toJson<String?>(unit),
      'targetValue': serializer.toJson<double?>(targetValue),
      'showOnToday': serializer.toJson<bool>(showOnToday),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorshipItem copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? name,
    WorshipTrackingType? trackingType,
    Value<String?> unit = const Value.absent(),
    Value<double?> targetValue = const Value.absent(),
    bool? showOnToday,
    bool? archived,
    int? sortOrder,
  }) => WorshipItem(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    trackingType: trackingType ?? this.trackingType,
    unit: unit.present ? unit.value : this.unit,
    targetValue: targetValue.present ? targetValue.value : this.targetValue,
    showOnToday: showOnToday ?? this.showOnToday,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WorshipItem copyWithCompanion(WorshipItemsCompanion data) {
    return WorshipItem(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      trackingType: data.trackingType.present
          ? data.trackingType.value
          : this.trackingType,
      unit: data.unit.present ? data.unit.value : this.unit,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      showOnToday: data.showOnToday.present
          ? data.showOnToday.value
          : this.showOnToday,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorshipItem(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trackingType: $trackingType, ')
          ..write('unit: $unit, ')
          ..write('targetValue: $targetValue, ')
          ..write('showOnToday: $showOnToday, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    name,
    trackingType,
    unit,
    targetValue,
    showOnToday,
    archived,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorshipItem &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.trackingType == this.trackingType &&
          other.unit == this.unit &&
          other.targetValue == this.targetValue &&
          other.showOnToday == this.showOnToday &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder);
}

class WorshipItemsCompanion extends UpdateCompanion<WorshipItem> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<WorshipTrackingType> trackingType;
  final Value<String?> unit;
  final Value<double?> targetValue;
  final Value<bool> showOnToday;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const WorshipItemsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.trackingType = const Value.absent(),
    this.unit = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.showOnToday = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorshipItemsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    required WorshipTrackingType trackingType,
    this.unit = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.showOnToday = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       trackingType = Value(trackingType);
  static Insertable<WorshipItem> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? trackingType,
    Expression<String>? unit,
    Expression<double>? targetValue,
    Expression<bool>? showOnToday,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (trackingType != null) 'tracking_type': trackingType,
      if (unit != null) 'unit': unit,
      if (targetValue != null) 'target_value': targetValue,
      if (showOnToday != null) 'show_on_today': showOnToday,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorshipItemsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<WorshipTrackingType>? trackingType,
    Value<String?>? unit,
    Value<double?>? targetValue,
    Value<bool>? showOnToday,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return WorshipItemsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      trackingType: trackingType ?? this.trackingType,
      unit: unit ?? this.unit,
      targetValue: targetValue ?? this.targetValue,
      showOnToday: showOnToday ?? this.showOnToday,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (trackingType.present) {
      map['tracking_type'] = Variable<String>(
        $WorshipItemsTable.$convertertrackingType.toSql(trackingType.value),
      );
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (showOnToday.present) {
      map['show_on_today'] = Variable<bool>(showOnToday.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorshipItemsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trackingType: $trackingType, ')
          ..write('unit: $unit, ')
          ..write('targetValue: $targetValue, ')
          ..write('showOnToday: $showOnToday, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorshipRecordsTable extends WorshipRecords
    with TableInfo<$WorshipRecordsTable, WorshipRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorshipRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES worship_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WorshipStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WorshipStatus>($WorshipRecordsTable.$converterstatus);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    itemId,
    dateKey,
    status,
    value,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worship_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorshipRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {itemId, dateKey},
  ];
  @override
  WorshipRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorshipRecord(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      status: $WorshipRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WorshipRecordsTable createAlias(String alias) {
    return $WorshipRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WorshipStatus, String, String> $converterstatus =
      const EnumNameConverter<WorshipStatus>(WorshipStatus.values);
}

class WorshipRecord extends DataClass implements Insertable<WorshipRecord> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String itemId;
  final String dateKey;
  final WorshipStatus status;
  final double? value;
  final String? note;
  const WorshipRecord({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.itemId,
    required this.dateKey,
    required this.status,
    this.value,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['date_key'] = Variable<String>(dateKey);
    {
      map['status'] = Variable<String>(
        $WorshipRecordsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorshipRecordsCompanion toCompanion(bool nullToAbsent) {
    return WorshipRecordsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      itemId: Value(itemId),
      dateKey: Value(dateKey),
      status: Value(status),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WorshipRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorshipRecord(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      status: $WorshipRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      value: serializer.fromJson<double?>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'dateKey': serializer.toJson<String>(dateKey),
      'status': serializer.toJson<String>(
        $WorshipRecordsTable.$converterstatus.toJson(status),
      ),
      'value': serializer.toJson<double?>(value),
      'note': serializer.toJson<String?>(note),
    };
  }

  WorshipRecord copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? itemId,
    String? dateKey,
    WorshipStatus? status,
    Value<double?> value = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => WorshipRecord(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    dateKey: dateKey ?? this.dateKey,
    status: status ?? this.status,
    value: value.present ? value.value : this.value,
    note: note.present ? note.value : this.note,
  );
  WorshipRecord copyWithCompanion(WorshipRecordsCompanion data) {
    return WorshipRecord(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      status: data.status.present ? data.status.value : this.status,
      value: data.value.present ? data.value.value : this.value,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorshipRecord(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('dateKey: $dateKey, ')
          ..write('status: $status, ')
          ..write('value: $value, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    itemId,
    dateKey,
    status,
    value,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorshipRecord &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.dateKey == this.dateKey &&
          other.status == this.status &&
          other.value == this.value &&
          other.note == this.note);
}

class WorshipRecordsCompanion extends UpdateCompanion<WorshipRecord> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> dateKey;
  final Value<WorshipStatus> status;
  final Value<double?> value;
  final Value<String?> note;
  final Value<int> rowid;
  const WorshipRecordsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.status = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorshipRecordsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String itemId,
    required String dateKey,
    required WorshipStatus status,
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       itemId = Value(itemId),
       dateKey = Value(dateKey),
       status = Value(status);
  static Insertable<WorshipRecord> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? dateKey,
    Expression<String>? status,
    Expression<double>? value,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (dateKey != null) 'date_key': dateKey,
      if (status != null) 'status': status,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorshipRecordsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? dateKey,
    Value<WorshipStatus>? status,
    Value<double?>? value,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WorshipRecordsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      dateKey: dateKey ?? this.dateKey,
      status: status ?? this.status,
      value: value ?? this.value,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $WorshipRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorshipRecordsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('dateKey: $dateKey, ')
          ..write('status: $status, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionsTable extends Reflections
    with TableInfo<$ReflectionsTable, Reflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    dateKey,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reflection(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $ReflectionsTable createAlias(String alias) {
    return $ReflectionsTable(attachedDatabase, alias);
  }
}

class Reflection extends DataClass implements Insertable<Reflection> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String dateKey;
  final String body;
  const Reflection({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.dateKey,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['date_key'] = Variable<String>(dateKey);
    map['body'] = Variable<String>(body);
    return map;
  }

  ReflectionsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      dateKey: Value(dateKey),
      body: Value(body),
    );
  }

  factory Reflection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reflection(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'dateKey': serializer.toJson<String>(dateKey),
      'body': serializer.toJson<String>(body),
    };
  }

  Reflection copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? dateKey,
    String? body,
  }) => Reflection(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    dateKey: dateKey ?? this.dateKey,
    body: body ?? this.body,
  );
  Reflection copyWithCompanion(ReflectionsCompanion data) {
    return Reflection(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reflection(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, dateKey, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reflection &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.dateKey == this.dateKey &&
          other.body == this.body);
}

class ReflectionsCompanion extends UpdateCompanion<Reflection> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> dateKey;
  final Value<String> body;
  final Value<int> rowid;
  const ReflectionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionsCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String dateKey,
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       dateKey = Value(dateKey);
  static Insertable<Reflection> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? dateKey,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (dateKey != null) 'date_key': dateKey,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionsCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? dateKey,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return ReflectionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionAnswersTable extends ReflectionAnswers
    with TableInfo<$ReflectionAnswersTable, ReflectionAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reflectionIdMeta = const VerificationMeta(
    'reflectionId',
  );
  @override
  late final GeneratedColumn<String> reflectionId = GeneratedColumn<String>(
    'reflection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reflections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    id,
    reflectionId,
    prompt,
    answer,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflection_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReflectionAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reflection_id')) {
      context.handle(
        _reflectionIdMeta,
        reflectionId.isAcceptableOrUnknown(
          data['reflection_id']!,
          _reflectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reflectionIdMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {reflectionId, prompt},
  ];
  @override
  ReflectionAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionAnswer(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reflectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_id'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ReflectionAnswersTable createAlias(String alias) {
    return $ReflectionAnswersTable(attachedDatabase, alias);
  }
}

class ReflectionAnswer extends DataClass
    implements Insertable<ReflectionAnswer> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String reflectionId;
  final String prompt;
  final String answer;
  final int sortOrder;
  const ReflectionAnswer({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.reflectionId,
    required this.prompt,
    required this.answer,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['reflection_id'] = Variable<String>(reflectionId);
    map['prompt'] = Variable<String>(prompt);
    map['answer'] = Variable<String>(answer);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ReflectionAnswersCompanion toCompanion(bool nullToAbsent) {
    return ReflectionAnswersCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      reflectionId: Value(reflectionId),
      prompt: Value(prompt),
      answer: Value(answer),
      sortOrder: Value(sortOrder),
    );
  }

  factory ReflectionAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionAnswer(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      reflectionId: serializer.fromJson<String>(json['reflectionId']),
      prompt: serializer.fromJson<String>(json['prompt']),
      answer: serializer.fromJson<String>(json['answer']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'reflectionId': serializer.toJson<String>(reflectionId),
      'prompt': serializer.toJson<String>(prompt),
      'answer': serializer.toJson<String>(answer),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ReflectionAnswer copyWith({
    int? createdAt,
    int? updatedAt,
    String? id,
    String? reflectionId,
    String? prompt,
    String? answer,
    int? sortOrder,
  }) => ReflectionAnswer(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    reflectionId: reflectionId ?? this.reflectionId,
    prompt: prompt ?? this.prompt,
    answer: answer ?? this.answer,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ReflectionAnswer copyWithCompanion(ReflectionAnswersCompanion data) {
    return ReflectionAnswer(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      reflectionId: data.reflectionId.present
          ? data.reflectionId.value
          : this.reflectionId,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      answer: data.answer.present ? data.answer.value : this.answer,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionAnswer(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('reflectionId: $reflectionId, ')
          ..write('prompt: $prompt, ')
          ..write('answer: $answer, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    id,
    reflectionId,
    prompt,
    answer,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionAnswer &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.reflectionId == this.reflectionId &&
          other.prompt == this.prompt &&
          other.answer == this.answer &&
          other.sortOrder == this.sortOrder);
}

class ReflectionAnswersCompanion extends UpdateCompanion<ReflectionAnswer> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> reflectionId;
  final Value<String> prompt;
  final Value<String> answer;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ReflectionAnswersCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.reflectionId = const Value.absent(),
    this.prompt = const Value.absent(),
    this.answer = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionAnswersCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String reflectionId,
    required String prompt,
    required String answer,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       id = Value(id),
       reflectionId = Value(reflectionId),
       prompt = Value(prompt),
       answer = Value(answer);
  static Insertable<ReflectionAnswer> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? reflectionId,
    Expression<String>? prompt,
    Expression<String>? answer,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (reflectionId != null) 'reflection_id': reflectionId,
      if (prompt != null) 'prompt': prompt,
      if (answer != null) 'answer': answer,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionAnswersCompanion copyWith({
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? id,
    Value<String>? reflectionId,
    Value<String>? prompt,
    Value<String>? answer,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ReflectionAnswersCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      reflectionId: reflectionId ?? this.reflectionId,
      prompt: prompt ?? this.prompt,
      answer: answer ?? this.answer,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reflectionId.present) {
      map['reflection_id'] = Variable<String>(reflectionId.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionAnswersCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('reflectionId: $reflectionId, ')
          ..write('prompt: $prompt, ')
          ..write('answer: $answer, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitSchedulesTable habitSchedules = $HabitSchedulesTable(this);
  late final $HabitRecordsTable habitRecords = $HabitRecordsTable(this);
  late final $PrayerRecordsTable prayerRecords = $PrayerRecordsTable(this);
  late final $WorshipItemsTable worshipItems = $WorshipItemsTable(this);
  late final $WorshipRecordsTable worshipRecords = $WorshipRecordsTable(this);
  late final $ReflectionsTable reflections = $ReflectionsTable(this);
  late final $ReflectionAnswersTable reflectionAnswers =
      $ReflectionAnswersTable(this);
  late final Index activitiesDateKey = Index(
    'activities_date_key',
    'CREATE INDEX activities_date_key ON activities (date_key)',
  );
  late final Index activitiesCategory = Index(
    'activities_category',
    'CREATE INDEX activities_category ON activities (category_id)',
  );
  late final Index habitRecordsDateKey = Index(
    'habit_records_date_key',
    'CREATE INDEX habit_records_date_key ON habit_records (date_key)',
  );
  late final Index prayerRecordsDateKey = Index(
    'prayer_records_date_key',
    'CREATE INDEX prayer_records_date_key ON prayer_records (date_key)',
  );
  late final Index worshipRecordsDateKey = Index(
    'worship_records_date_key',
    'CREATE INDEX worship_records_date_key ON worship_records (date_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    categories,
    activities,
    habits,
    habitSchedules,
    habitRecords,
    prayerRecords,
    worshipItems,
    worshipRecords,
    reflections,
    reflectionAnswers,
    activitiesDateKey,
    activitiesCategory,
    habitRecordsDateKey,
    prayerRecordsDateKey,
    worshipRecordsDateKey,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_schedules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'worship_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('worship_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reflections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reflection_answers', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          SettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      SettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> icon,
  Value<String?> color,
  Value<int> sortOrder,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> icon,
  Value<String?> color,
  Value<int> sortOrder,
  Value<bool> archived,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'categories__id__activities__category_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitsTable, List<Habit>> _habitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.habits,
    aliasName: 'categories__id__habits__category_id',
  );

  $$HabitsTableProcessedTableManager get habitsRefs {
    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitsRefs(
    Expression<bool> Function($$HabitsTableFilterComposer f) f,
  ) {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitsRefs<T extends Object>(
    Expression<T> Function($$HabitsTableAnnotationComposer a) f,
  ) {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool activitiesRefs, bool habitsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                icon: icon,
                color: color,
                sortOrder: sortOrder,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, Category>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({activitiesRefs = false, habitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activitiesRefs) db.activities,
                    if (habitsRefs) db.habits,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activitiesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Activity
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._activitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Habit
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._habitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).habitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool activitiesRefs, bool habitsRefs})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String title,
  Value<String?> description,
  Value<String?> categoryId,
  required String dateKey,
  Value<int?> startMinute,
  Value<int?> endMinute,
  Value<bool> endsNextDay,
  Value<int?> durationMinutes,
  required ActivityStatus status,
  Value<String?> notes,
  Value<String?> tags,
  Value<int> rowid,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<String?> categoryId,
  Value<String> dateKey,
  Value<int?> startMinute,
  Value<int?> endMinute,
  Value<bool> endsNextDay,
  Value<int?> durationMinutes,
  Value<ActivityStatus> status,
  Value<String?> notes,
  Value<String?> tags,
  Value<int> rowid,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('activities__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get endsNextDay => $composableBuilder(
    column: $table.endsNextDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityStatus, ActivityStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get endsNextDay => $composableBuilder(
    column: $table.endsNextDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<bool> get endsNextDay => $composableBuilder(
    column: $table.endsNextDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ActivityStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool categoryId})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<int?> startMinute = const Value.absent(),
                Value<int?> endMinute = const Value.absent(),
                Value<bool> endsNextDay = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                Value<ActivityStatus> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                title: title,
                description: description,
                categoryId: categoryId,
                dateKey: dateKey,
                startMinute: startMinute,
                endMinute: endMinute,
                endsNextDay: endsNextDay,
                durationMinutes: durationMinutes,
                status: status,
                notes: notes,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required String dateKey,
                Value<int?> startMinute = const Value.absent(),
                Value<int?> endMinute = const Value.absent(),
                Value<bool> endsNextDay = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
                required ActivityStatus status,
                Value<String?> notes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                title: title,
                description: description,
                categoryId: categoryId,
                dateKey: dateKey,
                startMinute: startMinute,
                endMinute: endMinute,
                endsNextDay: endsNextDay,
                durationMinutes: durationMinutes,
                status: status,
                notes: notes,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, Activity>(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$ActivitiesTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$ActivitiesTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> categoryId,
  Value<String?> icon,
  Value<String?> color,
  required HabitTrackingType trackingType,
  Value<String?> targetUnit,
  required String startDate,
  Value<String?> endDate,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<int?> reminderMinute,
  Value<int> rowid,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> categoryId,
  Value<String?> icon,
  Value<String?> color,
  Value<HabitTrackingType> trackingType,
  Value<String?> targetUnit,
  Value<String> startDate,
  Value<String?> endDate,
  Value<bool> archived,
  Value<int> sortOrder,
  Value<int?> reminderMinute,
  Value<int> rowid,
});

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('habits__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HabitSchedulesTable, List<HabitSchedule>>
  _habitSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitSchedules,
    aliasName: 'habits__id__habit_schedules__habit_id',
  );

  $$HabitSchedulesTableProcessedTableManager get habitSchedulesRefs {
    final manager = $$HabitSchedulesTableTableManager(
      $_db,
      $_db.habitSchedules,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitSchedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HabitRecordsTable, List<HabitRecord>>
  _habitRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitRecords,
    aliasName: 'habits__id__habit_records__habit_id',
  );

  $$HabitRecordsTableProcessedTableManager get habitRecordsRefs {
    final manager = $$HabitRecordsTableTableManager(
      $_db,
      $_db.habitRecords,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitTrackingType, HabitTrackingType, String>
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get targetUnit => $composableBuilder(
    column: $table.targetUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> habitSchedulesRefs(
    Expression<bool> Function($$HabitSchedulesTableFilterComposer f) f,
  ) {
    final $$HabitSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitSchedules,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.habitSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> habitRecordsRefs(
    Expression<bool> Function($$HabitRecordsTableFilterComposer f) f,
  ) {
    final $$HabitRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitRecords,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitRecordsTableFilterComposer(
            $db: $db,
            $table: $db.habitRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUnit => $composableBuilder(
    column: $table.targetUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitTrackingType, String>
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetUnit => $composableBuilder(
    column: $table.targetUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> habitSchedulesRefs<T extends Object>(
    Expression<T> Function($$HabitSchedulesTableAnnotationComposer a) f,
  ) {
    final $$HabitSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitSchedules,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.habitSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> habitRecordsRefs<T extends Object>(
    Expression<T> Function($$HabitRecordsTableAnnotationComposer a) f,
  ) {
    final $$HabitRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitRecords,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({
            bool categoryId,
            bool habitSchedulesRefs,
            bool habitRecordsRefs,
          })
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<HabitTrackingType> trackingType = const Value.absent(),
                Value<String?> targetUnit = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                categoryId: categoryId,
                icon: icon,
                color: color,
                trackingType: trackingType,
                targetUnit: targetUnit,
                startDate: startDate,
                endDate: endDate,
                archived: archived,
                sortOrder: sortOrder,
                reminderMinute: reminderMinute,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                required HabitTrackingType trackingType,
                Value<String?> targetUnit = const Value.absent(),
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> reminderMinute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                categoryId: categoryId,
                icon: icon,
                color: color,
                trackingType: trackingType,
                targetUnit: targetUnit,
                startDate: startDate,
                endDate: endDate,
                archived: archived,
                sortOrder: sortOrder,
                reminderMinute: reminderMinute,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, Habit>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                habitSchedulesRefs = false,
                habitRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (habitSchedulesRefs) db.habitSchedules,
                    if (habitRecordsRefs) db.habitRecords,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$HabitsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$HabitsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (habitSchedulesRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (habitRecordsRefs)
                        await $_getPrefetchedData<
                          Habit,
                          $HabitsTable,
                          HabitRecord
                        >(
                          currentTable: table,
                          referencedTable: $$HabitsTableReferences
                              ._habitRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HabitsTableReferences(
                                db,
                                table,
                                p0,
                              ).habitRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.habitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({
        bool categoryId,
        bool habitSchedulesRefs,
        bool habitRecordsRefs,
      })
    >;
typedef $$HabitSchedulesTableCreateCompanionBuilder =
    HabitSchedulesCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String habitId,
      required String effectiveFrom,
      required RecurrenceType recurrence,
      Value<int> weekdaysMask,
      Value<int?> intervalDays,
      Value<double?> targetValue,
      Value<int> rowid,
    });
typedef $$HabitSchedulesTableUpdateCompanionBuilder =
    HabitSchedulesCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> habitId,
      Value<String> effectiveFrom,
      Value<RecurrenceType> recurrence,
      Value<int> weekdaysMask,
      Value<int?> intervalDays,
      Value<double?> targetValue,
      Value<int> rowid,
    });

final class $$HabitSchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $HabitSchedulesTable, HabitSchedule> {
  $$HabitSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_schedules__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $HabitSchedulesTable> {
  $$HabitSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecurrenceType, RecurrenceType, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitSchedulesTable> {
  $$HabitSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitSchedulesTable> {
  $$HabitSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RecurrenceType, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<int> get weekdaysMask => $composableBuilder(
    column: $table.weekdaysMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitSchedulesTable,
          HabitSchedule,
          $$HabitSchedulesTableFilterComposer,
          $$HabitSchedulesTableOrderingComposer,
          $$HabitSchedulesTableAnnotationComposer,
          $$HabitSchedulesTableCreateCompanionBuilder,
          $$HabitSchedulesTableUpdateCompanionBuilder,
          (HabitSchedule, $$HabitSchedulesTableReferences),
          HabitSchedule,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitSchedulesTableTableManager(
    _$AppDatabase db,
    $HabitSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> effectiveFrom = const Value.absent(),
                Value<RecurrenceType> recurrence = const Value.absent(),
                Value<int> weekdaysMask = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<double?> targetValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitSchedulesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                habitId: habitId,
                effectiveFrom: effectiveFrom,
                recurrence: recurrence,
                weekdaysMask: weekdaysMask,
                intervalDays: intervalDays,
                targetValue: targetValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String habitId,
                required String effectiveFrom,
                required RecurrenceType recurrence,
                Value<int> weekdaysMask = const Value.absent(),
                Value<int?> intervalDays = const Value.absent(),
                Value<double?> targetValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitSchedulesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                habitId: habitId,
                effectiveFrom: effectiveFrom,
                recurrence: recurrence,
                weekdaysMask: weekdaysMask,
                intervalDays: intervalDays,
                targetValue: targetValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitSchedulesTable, HabitSchedule>(table),
                  $$HabitSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$HabitSchedulesTableReferences
                            ._habitIdTable(db),
                        referencedColumn: $$HabitSchedulesTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitSchedulesTable,
      HabitSchedule,
      $$HabitSchedulesTableFilterComposer,
      $$HabitSchedulesTableOrderingComposer,
      $$HabitSchedulesTableAnnotationComposer,
      $$HabitSchedulesTableCreateCompanionBuilder,
      $$HabitSchedulesTableUpdateCompanionBuilder,
      (HabitSchedule, $$HabitSchedulesTableReferences),
      HabitSchedule,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$HabitRecordsTableCreateCompanionBuilder =
    HabitRecordsCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String habitId,
      required String dateKey,
      required HabitStatus status,
      Value<double?> value,
      Value<double?> targetSnapshot,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$HabitRecordsTableUpdateCompanionBuilder =
    HabitRecordsCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> habitId,
      Value<String> dateKey,
      Value<HabitStatus> status,
      Value<double?> value,
      Value<double?> targetSnapshot,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$HabitRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitRecordsTable, HabitRecord> {
  $$HabitRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_records__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<String>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitRecordsTable> {
  $$HabitRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitStatus, HabitStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitRecordsTable> {
  $$HabitRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitRecordsTable> {
  $$HabitRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<double> get targetSnapshot => $composableBuilder(
    column: $table.targetSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitRecordsTable,
          HabitRecord,
          $$HabitRecordsTableFilterComposer,
          $$HabitRecordsTableOrderingComposer,
          $$HabitRecordsTableAnnotationComposer,
          $$HabitRecordsTableCreateCompanionBuilder,
          $$HabitRecordsTableUpdateCompanionBuilder,
          (HabitRecord, $$HabitRecordsTableReferences),
          HabitRecord,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitRecordsTableTableManager(_$AppDatabase db, $HabitRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<HabitStatus> status = const Value.absent(),
                Value<double?> value = const Value.absent(),
                Value<double?> targetSnapshot = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitRecordsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                habitId: habitId,
                dateKey: dateKey,
                status: status,
                value: value,
                targetSnapshot: targetSnapshot,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String habitId,
                required String dateKey,
                required HabitStatus status,
                Value<double?> value = const Value.absent(),
                Value<double?> targetSnapshot = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitRecordsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                habitId: habitId,
                dateKey: dateKey,
                status: status,
                value: value,
                targetSnapshot: targetSnapshot,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitRecordsTable, HabitRecord>(table),
                  $$HabitRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$HabitRecordsTableReferences
                            ._habitIdTable(db),
                        referencedColumn: $$HabitRecordsTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitRecordsTable,
      HabitRecord,
      $$HabitRecordsTableFilterComposer,
      $$HabitRecordsTableOrderingComposer,
      $$HabitRecordsTableAnnotationComposer,
      $$HabitRecordsTableCreateCompanionBuilder,
      $$HabitRecordsTableUpdateCompanionBuilder,
      (HabitRecord, $$HabitRecordsTableReferences),
      HabitRecord,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$PrayerRecordsTableCreateCompanionBuilder =
    PrayerRecordsCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required Prayer prayer,
      required String dateKey,
      required PrayerStatus status,
      Value<int?> performedMinute,
      Value<bool?> jamaah,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PrayerRecordsTableUpdateCompanionBuilder =
    PrayerRecordsCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<Prayer> prayer,
      Value<String> dateKey,
      Value<PrayerStatus> status,
      Value<int?> performedMinute,
      Value<bool?> jamaah,
      Value<String?> note,
      Value<int> rowid,
    });

class $$PrayerRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerRecordsTable> {
  $$PrayerRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Prayer, Prayer, String> get prayer =>
      $composableBuilder(
        column: $table.prayer,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrayerStatus, PrayerStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get performedMinute => $composableBuilder(
    column: $table.performedMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get jamaah => $composableBuilder(
    column: $table.jamaah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerRecordsTable> {
  $$PrayerRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get performedMinute => $composableBuilder(
    column: $table.performedMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get jamaah => $composableBuilder(
    column: $table.jamaah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerRecordsTable> {
  $$PrayerRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Prayer, String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrayerStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get performedMinute => $composableBuilder(
    column: $table.performedMinute,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get jamaah =>
      $composableBuilder(column: $table.jamaah, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PrayerRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerRecordsTable,
          PrayerRecord,
          $$PrayerRecordsTableFilterComposer,
          $$PrayerRecordsTableOrderingComposer,
          $$PrayerRecordsTableAnnotationComposer,
          $$PrayerRecordsTableCreateCompanionBuilder,
          $$PrayerRecordsTableUpdateCompanionBuilder,
          (
            PrayerRecord,
            BaseReferences<_$AppDatabase, $PrayerRecordsTable, PrayerRecord>,
          ),
          PrayerRecord,
          PrefetchHooks Function()
        > {
  $$PrayerRecordsTableTableManager(_$AppDatabase db, $PrayerRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<Prayer> prayer = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<PrayerStatus> status = const Value.absent(),
                Value<int?> performedMinute = const Value.absent(),
                Value<bool?> jamaah = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerRecordsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                prayer: prayer,
                dateKey: dateKey,
                status: status,
                performedMinute: performedMinute,
                jamaah: jamaah,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required Prayer prayer,
                required String dateKey,
                required PrayerStatus status,
                Value<int?> performedMinute = const Value.absent(),
                Value<bool?> jamaah = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerRecordsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                prayer: prayer,
                dateKey: dateKey,
                status: status,
                performedMinute: performedMinute,
                jamaah: jamaah,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrayerRecordsTable, PrayerRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PrayerRecordsTable,
                    PrayerRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerRecordsTable,
      PrayerRecord,
      $$PrayerRecordsTableFilterComposer,
      $$PrayerRecordsTableOrderingComposer,
      $$PrayerRecordsTableAnnotationComposer,
      $$PrayerRecordsTableCreateCompanionBuilder,
      $$PrayerRecordsTableUpdateCompanionBuilder,
      (
        PrayerRecord,
        BaseReferences<_$AppDatabase, $PrayerRecordsTable, PrayerRecord>,
      ),
      PrayerRecord,
      PrefetchHooks Function()
    >;
typedef $$WorshipItemsTableCreateCompanionBuilder =
    WorshipItemsCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String name,
      required WorshipTrackingType trackingType,
      Value<String?> unit,
      Value<double?> targetValue,
      Value<bool> showOnToday,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$WorshipItemsTableUpdateCompanionBuilder =
    WorshipItemsCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> name,
      Value<WorshipTrackingType> trackingType,
      Value<String?> unit,
      Value<double?> targetValue,
      Value<bool> showOnToday,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$WorshipItemsTableReferences
    extends BaseReferences<_$AppDatabase, $WorshipItemsTable, WorshipItem> {
  $$WorshipItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorshipRecordsTable, List<WorshipRecord>>
  _worshipRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.worshipRecords,
    aliasName: 'worship_items__id__worship_records__item_id',
  );

  $$WorshipRecordsTableProcessedTableManager get worshipRecordsRefs {
    final manager = $$WorshipRecordsTableTableManager(
      $_db,
      $_db.worshipRecords,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_worshipRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorshipItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WorshipItemsTable> {
  $$WorshipItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    WorshipTrackingType,
    WorshipTrackingType,
    String
  >
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showOnToday => $composableBuilder(
    column: $table.showOnToday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> worshipRecordsRefs(
    Expression<bool> Function($$WorshipRecordsTableFilterComposer f) f,
  ) {
    final $$WorshipRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.worshipRecords,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorshipRecordsTableFilterComposer(
            $db: $db,
            $table: $db.worshipRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorshipItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorshipItemsTable> {
  $$WorshipItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showOnToday => $composableBuilder(
    column: $table.showOnToday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorshipItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorshipItemsTable> {
  $$WorshipItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorshipTrackingType, String>
  get trackingType => $composableBuilder(
    column: $table.trackingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showOnToday => $composableBuilder(
    column: $table.showOnToday,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> worshipRecordsRefs<T extends Object>(
    Expression<T> Function($$WorshipRecordsTableAnnotationComposer a) f,
  ) {
    final $$WorshipRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.worshipRecords,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorshipRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.worshipRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorshipItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorshipItemsTable,
          WorshipItem,
          $$WorshipItemsTableFilterComposer,
          $$WorshipItemsTableOrderingComposer,
          $$WorshipItemsTableAnnotationComposer,
          $$WorshipItemsTableCreateCompanionBuilder,
          $$WorshipItemsTableUpdateCompanionBuilder,
          (WorshipItem, $$WorshipItemsTableReferences),
          WorshipItem,
          PrefetchHooks Function({bool worshipRecordsRefs})
        > {
  $$WorshipItemsTableTableManager(_$AppDatabase db, $WorshipItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorshipItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorshipItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorshipItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<WorshipTrackingType> trackingType = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> targetValue = const Value.absent(),
                Value<bool> showOnToday = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorshipItemsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                trackingType: trackingType,
                unit: unit,
                targetValue: targetValue,
                showOnToday: showOnToday,
                archived: archived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String name,
                required WorshipTrackingType trackingType,
                Value<String?> unit = const Value.absent(),
                Value<double?> targetValue = const Value.absent(),
                Value<bool> showOnToday = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorshipItemsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                trackingType: trackingType,
                unit: unit,
                targetValue: targetValue,
                showOnToday: showOnToday,
                archived: archived,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorshipItemsTable, WorshipItem>(table),
                  $$WorshipItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({worshipRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (worshipRecordsRefs) db.worshipRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (worshipRecordsRefs)
                    await $_getPrefetchedData<
                      WorshipItem,
                      $WorshipItemsTable,
                      WorshipRecord
                    >(
                      currentTable: table,
                      referencedTable: $$WorshipItemsTableReferences
                          ._worshipRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorshipItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).worshipRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorshipItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorshipItemsTable,
      WorshipItem,
      $$WorshipItemsTableFilterComposer,
      $$WorshipItemsTableOrderingComposer,
      $$WorshipItemsTableAnnotationComposer,
      $$WorshipItemsTableCreateCompanionBuilder,
      $$WorshipItemsTableUpdateCompanionBuilder,
      (WorshipItem, $$WorshipItemsTableReferences),
      WorshipItem,
      PrefetchHooks Function({bool worshipRecordsRefs})
    >;
typedef $$WorshipRecordsTableCreateCompanionBuilder =
    WorshipRecordsCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String itemId,
      required String dateKey,
      required WorshipStatus status,
      Value<double?> value,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WorshipRecordsTableUpdateCompanionBuilder =
    WorshipRecordsCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> itemId,
      Value<String> dateKey,
      Value<WorshipStatus> status,
      Value<double?> value,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$WorshipRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $WorshipRecordsTable, WorshipRecord> {
  $$WorshipRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorshipItemsTable _itemIdTable(_$AppDatabase db) => db.worshipItems
      .createAlias('worship_records__item_id__worship_items__id');

  $$WorshipItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$WorshipItemsTableTableManager(
      $_db,
      $_db.worshipItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorshipRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WorshipRecordsTable> {
  $$WorshipRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WorshipStatus, WorshipStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$WorshipItemsTableFilterComposer get itemId {
    final $$WorshipItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.worshipItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorshipItemsTableFilterComposer(
            $db: $db,
            $table: $db.worshipItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorshipRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorshipRecordsTable> {
  $$WorshipRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorshipItemsTableOrderingComposer get itemId {
    final $$WorshipItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.worshipItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorshipItemsTableOrderingComposer(
            $db: $db,
            $table: $db.worshipItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorshipRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorshipRecordsTable> {
  $$WorshipRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorshipStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$WorshipItemsTableAnnotationComposer get itemId {
    final $$WorshipItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.worshipItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorshipItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.worshipItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorshipRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorshipRecordsTable,
          WorshipRecord,
          $$WorshipRecordsTableFilterComposer,
          $$WorshipRecordsTableOrderingComposer,
          $$WorshipRecordsTableAnnotationComposer,
          $$WorshipRecordsTableCreateCompanionBuilder,
          $$WorshipRecordsTableUpdateCompanionBuilder,
          (WorshipRecord, $$WorshipRecordsTableReferences),
          WorshipRecord,
          PrefetchHooks Function({bool itemId})
        > {
  $$WorshipRecordsTableTableManager(
    _$AppDatabase db,
    $WorshipRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorshipRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorshipRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorshipRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<WorshipStatus> status = const Value.absent(),
                Value<double?> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorshipRecordsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                itemId: itemId,
                dateKey: dateKey,
                status: status,
                value: value,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String itemId,
                required String dateKey,
                required WorshipStatus status,
                Value<double?> value = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorshipRecordsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                itemId: itemId,
                dateKey: dateKey,
                status: status,
                value: value,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorshipRecordsTable, WorshipRecord>(table),
                  $$WorshipRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$WorshipRecordsTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$WorshipRecordsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorshipRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorshipRecordsTable,
      WorshipRecord,
      $$WorshipRecordsTableFilterComposer,
      $$WorshipRecordsTableOrderingComposer,
      $$WorshipRecordsTableAnnotationComposer,
      $$WorshipRecordsTableCreateCompanionBuilder,
      $$WorshipRecordsTableUpdateCompanionBuilder,
      (WorshipRecord, $$WorshipRecordsTableReferences),
      WorshipRecord,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$ReflectionsTableCreateCompanionBuilder =
    ReflectionsCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String dateKey,
      Value<String> body,
      Value<int> rowid,
    });
typedef $$ReflectionsTableUpdateCompanionBuilder =
    ReflectionsCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> dateKey,
      Value<String> body,
      Value<int> rowid,
    });

final class $$ReflectionsTableReferences
    extends BaseReferences<_$AppDatabase, $ReflectionsTable, Reflection> {
  $$ReflectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReflectionAnswersTable, List<ReflectionAnswer>>
  _reflectionAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reflectionAnswers,
        aliasName: 'reflections__id__reflection_answers__reflection_id',
      );

  $$ReflectionAnswersTableProcessedTableManager get reflectionAnswersRefs {
    final manager = $$ReflectionAnswersTableTableManager(
      $_db,
      $_db.reflectionAnswers,
    ).filter((f) => f.reflectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reflectionAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReflectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reflectionAnswersRefs(
    Expression<bool> Function($$ReflectionAnswersTableFilterComposer f) f,
  ) {
    final $$ReflectionAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reflectionAnswers,
      getReferencedColumn: (t) => t.reflectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReflectionAnswersTableFilterComposer(
            $db: $db,
            $table: $db.reflectionAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReflectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReflectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionsTable> {
  $$ReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  Expression<T> reflectionAnswersRefs<T extends Object>(
    Expression<T> Function($$ReflectionAnswersTableAnnotationComposer a) f,
  ) {
    final $$ReflectionAnswersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.reflectionAnswers,
          getReferencedColumn: (t) => t.reflectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReflectionAnswersTableAnnotationComposer(
                $db: $db,
                $table: $db.reflectionAnswers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReflectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReflectionsTable,
          Reflection,
          $$ReflectionsTableFilterComposer,
          $$ReflectionsTableOrderingComposer,
          $$ReflectionsTableAnnotationComposer,
          $$ReflectionsTableCreateCompanionBuilder,
          $$ReflectionsTableUpdateCompanionBuilder,
          (Reflection, $$ReflectionsTableReferences),
          Reflection,
          PrefetchHooks Function({bool reflectionAnswersRefs})
        > {
  $$ReflectionsTableTableManager(_$AppDatabase db, $ReflectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                dateKey: dateKey,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String dateKey,
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                dateKey: dateKey,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReflectionsTable, Reflection>(table),
                  $$ReflectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reflectionAnswersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (reflectionAnswersRefs) db.reflectionAnswers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reflectionAnswersRefs)
                    await $_getPrefetchedData<
                      Reflection,
                      $ReflectionsTable,
                      ReflectionAnswer
                    >(
                      currentTable: table,
                      referencedTable: $$ReflectionsTableReferences
                          ._reflectionAnswersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReflectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).reflectionAnswersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.reflectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReflectionsTable,
      Reflection,
      $$ReflectionsTableFilterComposer,
      $$ReflectionsTableOrderingComposer,
      $$ReflectionsTableAnnotationComposer,
      $$ReflectionsTableCreateCompanionBuilder,
      $$ReflectionsTableUpdateCompanionBuilder,
      (Reflection, $$ReflectionsTableReferences),
      Reflection,
      PrefetchHooks Function({bool reflectionAnswersRefs})
    >;
typedef $$ReflectionAnswersTableCreateCompanionBuilder =
    ReflectionAnswersCompanion Function({
      required int createdAt,
      required int updatedAt,
      required String id,
      required String reflectionId,
      required String prompt,
      required String answer,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ReflectionAnswersTableUpdateCompanionBuilder =
    ReflectionAnswersCompanion Function({
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> id,
      Value<String> reflectionId,
      Value<String> prompt,
      Value<String> answer,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$ReflectionAnswersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReflectionAnswersTable,
          ReflectionAnswer
        > {
  $$ReflectionAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReflectionsTable _reflectionIdTable(_$AppDatabase db) => db
      .reflections
      .createAlias('reflection_answers__reflection_id__reflections__id');

  $$ReflectionsTableProcessedTableManager get reflectionId {
    final $_column = $_itemColumn<String>('reflection_id')!;

    final manager = $$ReflectionsTableTableManager(
      $_db,
      $_db.reflections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reflectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReflectionAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionAnswersTable> {
  $$ReflectionAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ReflectionsTableFilterComposer get reflectionId {
    final $$ReflectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reflectionId,
      referencedTable: $db.reflections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReflectionsTableFilterComposer(
            $db: $db,
            $table: $db.reflections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReflectionAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionAnswersTable> {
  $$ReflectionAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReflectionsTableOrderingComposer get reflectionId {
    final $$ReflectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reflectionId,
      referencedTable: $db.reflections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReflectionsTableOrderingComposer(
            $db: $db,
            $table: $db.reflections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReflectionAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionAnswersTable> {
  $$ReflectionAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ReflectionsTableAnnotationComposer get reflectionId {
    final $$ReflectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reflectionId,
      referencedTable: $db.reflections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReflectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.reflections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReflectionAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReflectionAnswersTable,
          ReflectionAnswer,
          $$ReflectionAnswersTableFilterComposer,
          $$ReflectionAnswersTableOrderingComposer,
          $$ReflectionAnswersTableAnnotationComposer,
          $$ReflectionAnswersTableCreateCompanionBuilder,
          $$ReflectionAnswersTableUpdateCompanionBuilder,
          (ReflectionAnswer, $$ReflectionAnswersTableReferences),
          ReflectionAnswer,
          PrefetchHooks Function({bool reflectionId})
        > {
  $$ReflectionAnswersTableTableManager(
    _$AppDatabase db,
    $ReflectionAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionAnswersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> reflectionId = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionAnswersCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                reflectionId: reflectionId,
                prompt: prompt,
                answer: answer,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int createdAt,
                required int updatedAt,
                required String id,
                required String reflectionId,
                required String prompt,
                required String answer,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionAnswersCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                reflectionId: reflectionId,
                prompt: prompt,
                answer: answer,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReflectionAnswersTable, ReflectionAnswer>(table),
                  $$ReflectionAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reflectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reflectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.reflectionId,
                        referencedTable: $$ReflectionAnswersTableReferences
                            ._reflectionIdTable(db),
                        referencedColumn: $$ReflectionAnswersTableReferences
                            ._reflectionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReflectionAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReflectionAnswersTable,
      ReflectionAnswer,
      $$ReflectionAnswersTableFilterComposer,
      $$ReflectionAnswersTableOrderingComposer,
      $$ReflectionAnswersTableAnnotationComposer,
      $$ReflectionAnswersTableCreateCompanionBuilder,
      $$ReflectionAnswersTableUpdateCompanionBuilder,
      (ReflectionAnswer, $$ReflectionAnswersTableReferences),
      ReflectionAnswer,
      PrefetchHooks Function({bool reflectionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitSchedulesTableTableManager get habitSchedules =>
      $$HabitSchedulesTableTableManager(_db, _db.habitSchedules);
  $$HabitRecordsTableTableManager get habitRecords =>
      $$HabitRecordsTableTableManager(_db, _db.habitRecords);
  $$PrayerRecordsTableTableManager get prayerRecords =>
      $$PrayerRecordsTableTableManager(_db, _db.prayerRecords);
  $$WorshipItemsTableTableManager get worshipItems =>
      $$WorshipItemsTableTableManager(_db, _db.worshipItems);
  $$WorshipRecordsTableTableManager get worshipRecords =>
      $$WorshipRecordsTableTableManager(_db, _db.worshipRecords);
  $$ReflectionsTableTableManager get reflections =>
      $$ReflectionsTableTableManager(_db, _db.reflections);
  $$ReflectionAnswersTableTableManager get reflectionAnswers =>
      $$ReflectionAnswersTableTableManager(_db, _db.reflectionAnswers);
}
