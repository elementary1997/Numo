// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TransactionRowsTable extends TransactionRows
    with TableInfo<$TransactionRowsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteLowerMeta = const VerificationMeta(
    'noteLower',
  );
  @override
  late final GeneratedColumn<String> noteLower = GeneratedColumn<String>(
    'note_lower',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('main'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _splitMeta = const VerificationMeta('split');
  @override
  late final GeneratedColumn<String> split = GeneratedColumn<String>(
    'split',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    categoryId,
    date,
    note,
    noteLower,
    accountId,
    updatedAt,
    deletedAt,
    authorId,
    split,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('note_lower')) {
      context.handle(
        _noteLowerMeta,
        noteLower.isAcceptableOrUnknown(data['note_lower']!, _noteLowerMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    }
    if (data.containsKey('split')) {
      context.handle(
        _splitMeta,
        split.isAcceptableOrUnknown(data['split']!, _splitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      noteLower: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_lower'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      ),
      split: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}split'],
      ),
    );
  }

  @override
  $TransactionRowsTable createAlias(String alias) {
    return $TransactionRowsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;

  /// Заметка в нижнем регистре — по ней ищет лента. Отдельная колонка
  /// нужна потому, что SQLite-функция lower() понижает только ASCII:
  /// «Пятёрочка» она бы оставила как есть, и поиск стал бы
  /// регистрозависимым для кириллицы.
  final String noteLower;
  final String accountId;

  /// Время последнего изменения и «надгробие» удаления — по ним
  /// сливаются данные участников общего счёта (ADR-0014).
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  /// Участник, внёсший операцию.
  final String? authorId;

  /// Доли участников в трате, JSON `{"memberId": вес}`; null — трата
  /// не делится. Лежит в самой операции, чтобы уезжать в общий файл
  /// и сливаться вместе с ней (ADR-0014).
  final String? split;
  const TransactionRow({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.note,
    required this.noteLower,
    required this.accountId,
    this.updatedAt,
    this.deletedAt,
    this.authorId,
    this.split,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<String>(categoryId);
    map['date'] = Variable<DateTime>(date);
    map['note'] = Variable<String>(note);
    map['note_lower'] = Variable<String>(noteLower);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || authorId != null) {
      map['author_id'] = Variable<String>(authorId);
    }
    if (!nullToAbsent || split != null) {
      map['split'] = Variable<String>(split);
    }
    return map;
  }

  TransactionRowsCompanion toCompanion(bool nullToAbsent) {
    return TransactionRowsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      categoryId: Value(categoryId),
      date: Value(date),
      note: Value(note),
      noteLower: Value(noteLower),
      accountId: Value(accountId),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      authorId: authorId == null && nullToAbsent
          ? const Value.absent()
          : Value(authorId),
      split: split == null && nullToAbsent
          ? const Value.absent()
          : Value(split),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String>(json['note']),
      noteLower: serializer.fromJson<String>(json['noteLower']),
      accountId: serializer.fromJson<String>(json['accountId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      authorId: serializer.fromJson<String?>(json['authorId']),
      split: serializer.fromJson<String?>(json['split']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String>(note),
      'noteLower': serializer.toJson<String>(noteLower),
      'accountId': serializer.toJson<String>(accountId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'authorId': serializer.toJson<String?>(authorId),
      'split': serializer.toJson<String?>(split),
    };
  }

  TransactionRow copyWith({
    String? id,
    String? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    String? noteLower,
    String? accountId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> authorId = const Value.absent(),
    Value<String?> split = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    date: date ?? this.date,
    note: note ?? this.note,
    noteLower: noteLower ?? this.noteLower,
    accountId: accountId ?? this.accountId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    authorId: authorId.present ? authorId.value : this.authorId,
    split: split.present ? split.value : this.split,
  );
  TransactionRow copyWithCompanion(TransactionRowsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      noteLower: data.noteLower.present ? data.noteLower.value : this.noteLower,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      split: data.split.present ? data.split.value : this.split,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('noteLower: $noteLower, ')
          ..write('accountId: $accountId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('authorId: $authorId, ')
          ..write('split: $split')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    categoryId,
    date,
    note,
    noteLower,
    accountId,
    updatedAt,
    deletedAt,
    authorId,
    split,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.date == this.date &&
          other.note == this.note &&
          other.noteLower == this.noteLower &&
          other.accountId == this.accountId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.authorId == this.authorId &&
          other.split == this.split);
}

class TransactionRowsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> categoryId;
  final Value<DateTime> date;
  final Value<String> note;
  final Value<String> noteLower;
  final Value<String> accountId;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> authorId;
  final Value<String?> split;
  final Value<int> rowid;
  const TransactionRowsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.noteLower = const Value.absent(),
    this.accountId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.authorId = const Value.absent(),
    this.split = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionRowsCompanion.insert({
    required String id,
    required String type,
    required double amount,
    required String categoryId,
    required DateTime date,
    this.note = const Value.absent(),
    this.noteLower = const Value.absent(),
    this.accountId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.authorId = const Value.absent(),
    this.split = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       categoryId = Value(categoryId),
       date = Value(date);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? noteLower,
    Expression<String>? accountId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? authorId,
    Expression<String>? split,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (noteLower != null) 'note_lower': noteLower,
      if (accountId != null) 'account_id': accountId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (authorId != null) 'author_id': authorId,
      if (split != null) 'split': split,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? categoryId,
    Value<DateTime>? date,
    Value<String>? note,
    Value<String>? noteLower,
    Value<String>? accountId,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? authorId,
    Value<String?>? split,
    Value<int>? rowid,
  }) {
    return TransactionRowsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      noteLower: noteLower ?? this.noteLower,
      accountId: accountId ?? this.accountId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      authorId: authorId ?? this.authorId,
      split: split ?? this.split,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (noteLower.present) {
      map['note_lower'] = Variable<String>(noteLower.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (split.present) {
      map['split'] = Variable<String>(split.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRowsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('noteLower: $noteLower, ')
          ..write('accountId: $accountId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('authorId: $authorId, ')
          ..write('split: $split, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryRowsTable extends CategoryRows
    with TableInfo<$CategoryRowsTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRowsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconKey,
    color,
    isIncome,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
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
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $CategoryRowsTable createAlias(String alias) {
    return $CategoryRowsTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String title;
  final String iconKey;
  final int color;
  final bool isIncome;
  final bool archived;
  const CategoryRow({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    required this.isIncome,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['icon_key'] = Variable<String>(iconKey);
    map['color'] = Variable<int>(color);
    map['is_income'] = Variable<bool>(isIncome);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  CategoryRowsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRowsCompanion(
      id: Value(id),
      title: Value(title),
      iconKey: Value(iconKey),
      color: Value(color),
      isIncome: Value(isIncome),
      archived: Value(archived),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      color: serializer.fromJson<int>(json['color']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'iconKey': serializer.toJson<String>(iconKey),
      'color': serializer.toJson<int>(color),
      'isIncome': serializer.toJson<bool>(isIncome),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? title,
    String? iconKey,
    int? color,
    bool? isIncome,
    bool? archived,
  }) => CategoryRow(
    id: id ?? this.id,
    title: title ?? this.title,
    iconKey: iconKey ?? this.iconKey,
    color: color ?? this.color,
    isIncome: isIncome ?? this.isIncome,
    archived: archived ?? this.archived,
  );
  CategoryRow copyWithCompanion(CategoryRowsCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      color: data.color.present ? data.color.value : this.color,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('isIncome: $isIncome, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, iconKey, color, isIncome, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconKey == this.iconKey &&
          other.color == this.color &&
          other.isIncome == this.isIncome &&
          other.archived == this.archived);
}

class CategoryRowsCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> iconKey;
  final Value<int> color;
  final Value<bool> isIncome;
  final Value<bool> archived;
  final Value<int> rowid;
  const CategoryRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.color = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRowsCompanion.insert({
    required String id,
    required String title,
    required String iconKey,
    required int color,
    this.isIncome = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       iconKey = Value(iconKey),
       color = Value(color);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? iconKey,
    Expression<int>? color,
    Expression<bool>? isIncome,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconKey != null) 'icon_key': iconKey,
      if (color != null) 'color': color,
      if (isIncome != null) 'is_income': isIncome,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? iconKey,
    Value<int>? color,
    Value<bool>? isIncome,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return CategoryRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      isIncome: isIncome ?? this.isIncome,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
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
    return (StringBuffer('CategoryRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('isIncome: $isIncome, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetRowsTable extends BudgetRows
    with TableInfo<$BudgetRowsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyLimitMeta = const VerificationMeta(
    'monthlyLimit',
  );
  @override
  late final GeneratedColumn<double> monthlyLimit = GeneratedColumn<double>(
    'monthly_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [categoryId, monthlyLimit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('monthly_limit')) {
      context.handle(
        _monthlyLimitMeta,
        monthlyLimit.isAcceptableOrUnknown(
          data['monthly_limit']!,
          _monthlyLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyLimitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      monthlyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_limit'],
      )!,
    );
  }

  @override
  $BudgetRowsTable createAlias(String alias) {
    return $BudgetRowsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final String categoryId;
  final double monthlyLimit;
  const BudgetRow({required this.categoryId, required this.monthlyLimit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['monthly_limit'] = Variable<double>(monthlyLimit);
    return map;
  }

  BudgetRowsCompanion toCompanion(bool nullToAbsent) {
    return BudgetRowsCompanion(
      categoryId: Value(categoryId),
      monthlyLimit: Value(monthlyLimit),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      monthlyLimit: serializer.fromJson<double>(json['monthlyLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'monthlyLimit': serializer.toJson<double>(monthlyLimit),
    };
  }

  BudgetRow copyWith({String? categoryId, double? monthlyLimit}) => BudgetRow(
    categoryId: categoryId ?? this.categoryId,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
  );
  BudgetRow copyWithCompanion(BudgetRowsCompanion data) {
    return BudgetRow(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      monthlyLimit: data.monthlyLimit.present
          ? data.monthlyLimit.value
          : this.monthlyLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('categoryId: $categoryId, ')
          ..write('monthlyLimit: $monthlyLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, monthlyLimit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.categoryId == this.categoryId &&
          other.monthlyLimit == this.monthlyLimit);
}

class BudgetRowsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> categoryId;
  final Value<double> monthlyLimit;
  final Value<int> rowid;
  const BudgetRowsCompanion({
    this.categoryId = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetRowsCompanion.insert({
    required String categoryId,
    required double monthlyLimit,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       monthlyLimit = Value(monthlyLimit);
  static Insertable<BudgetRow> custom({
    Expression<String>? categoryId,
    Expression<double>? monthlyLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (monthlyLimit != null) 'monthly_limit': monthlyLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetRowsCompanion copyWith({
    Value<String>? categoryId,
    Value<double>? monthlyLimit,
    Value<int>? rowid,
  }) {
    return BudgetRowsCompanion(
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (monthlyLimit.present) {
      map['monthly_limit'] = Variable<double>(monthlyLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRowsCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringRowsTable extends RecurringRows
    with TableInfo<$RecurringRowsTable, RecurringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedThroughMeta = const VerificationMeta(
    'appliedThrough',
  );
  @override
  late final GeneratedColumn<DateTime> appliedThrough =
      GeneratedColumn<DateTime>(
        'applied_through',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    categoryId,
    note,
    dayOfMonth,
    startDate,
    appliedThrough,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('applied_through')) {
      context.handle(
        _appliedThroughMeta,
        appliedThrough.isAcceptableOrUnknown(
          data['applied_through']!,
          _appliedThroughMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      appliedThrough: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_through'],
      ),
    );
  }

  @override
  $RecurringRowsTable createAlias(String alias) {
    return $RecurringRowsTable(attachedDatabase, alias);
  }
}

class RecurringRow extends DataClass implements Insertable<RecurringRow> {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final String note;
  final int dayOfMonth;
  final DateTime startDate;

  /// По какую дату включительно правило уже материализовано —
  /// операции создаются только после неё, поэтому удалённые
  /// пользователем сгенерированные операции не возрождаются.
  final DateTime? appliedThrough;
  const RecurringRow({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.dayOfMonth,
    required this.startDate,
    this.appliedThrough,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<String>(categoryId);
    map['note'] = Variable<String>(note);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || appliedThrough != null) {
      map['applied_through'] = Variable<DateTime>(appliedThrough);
    }
    return map;
  }

  RecurringRowsCompanion toCompanion(bool nullToAbsent) {
    return RecurringRowsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      categoryId: Value(categoryId),
      note: Value(note),
      dayOfMonth: Value(dayOfMonth),
      startDate: Value(startDate),
      appliedThrough: appliedThrough == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedThrough),
    );
  }

  factory RecurringRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      appliedThrough: serializer.fromJson<DateTime?>(json['appliedThrough']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String>(note),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'startDate': serializer.toJson<DateTime>(startDate),
      'appliedThrough': serializer.toJson<DateTime?>(appliedThrough),
    };
  }

  RecurringRow copyWith({
    String? id,
    String? type,
    double? amount,
    String? categoryId,
    String? note,
    int? dayOfMonth,
    DateTime? startDate,
    Value<DateTime?> appliedThrough = const Value.absent(),
  }) => RecurringRow(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    note: note ?? this.note,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    startDate: startDate ?? this.startDate,
    appliedThrough: appliedThrough.present
        ? appliedThrough.value
        : this.appliedThrough,
  );
  RecurringRow copyWithCompanion(RecurringRowsCompanion data) {
    return RecurringRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      appliedThrough: data.appliedThrough.present
          ? data.appliedThrough.value
          : this.appliedThrough,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startDate: $startDate, ')
          ..write('appliedThrough: $appliedThrough')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    categoryId,
    note,
    dayOfMonth,
    startDate,
    appliedThrough,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.dayOfMonth == this.dayOfMonth &&
          other.startDate == this.startDate &&
          other.appliedThrough == this.appliedThrough);
}

class RecurringRowsCompanion extends UpdateCompanion<RecurringRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> categoryId;
  final Value<String> note;
  final Value<int> dayOfMonth;
  final Value<DateTime> startDate;
  final Value<DateTime?> appliedThrough;
  final Value<int> rowid;
  const RecurringRowsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.startDate = const Value.absent(),
    this.appliedThrough = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringRowsCompanion.insert({
    required String id,
    required String type,
    required double amount,
    required String categoryId,
    this.note = const Value.absent(),
    required int dayOfMonth,
    required DateTime startDate,
    this.appliedThrough = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       amount = Value(amount),
       categoryId = Value(categoryId),
       dayOfMonth = Value(dayOfMonth),
       startDate = Value(startDate);
  static Insertable<RecurringRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<int>? dayOfMonth,
    Expression<DateTime>? startDate,
    Expression<DateTime>? appliedThrough,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (startDate != null) 'start_date': startDate,
      if (appliedThrough != null) 'applied_through': appliedThrough,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? categoryId,
    Value<String>? note,
    Value<int>? dayOfMonth,
    Value<DateTime>? startDate,
    Value<DateTime?>? appliedThrough,
    Value<int>? rowid,
  }) {
    return RecurringRowsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      appliedThrough: appliedThrough ?? this.appliedThrough,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (appliedThrough.present) {
      map['applied_through'] = Variable<DateTime>(appliedThrough.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringRowsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startDate: $startDate, ')
          ..write('appliedThrough: $appliedThrough, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountRowsTable extends AccountRows
    with TableInfo<$AccountRowsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountRowsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('RUB'),
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('regular'),
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closesAtMeta = const VerificationMeta(
    'closesAt',
  );
  @override
  late final GeneratedColumn<DateTime> closesAt = GeneratedColumn<DateTime>(
    'closes_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sharedMeta = const VerificationMeta('shared');
  @override
  late final GeneratedColumn<bool> shared = GeneratedColumn<bool>(
    'shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconKey,
    color,
    currency,
    archived,
    kind,
    rate,
    openedAt,
    closesAt,
    shared,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('closes_at')) {
      context.handle(
        _closesAtMeta,
        closesAt.isAcceptableOrUnknown(data['closes_at']!, _closesAtMeta),
      );
    }
    if (data.containsKey('shared')) {
      context.handle(
        _sharedMeta,
        shared.isAcceptableOrUnknown(data['shared']!, _sharedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      ),
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      closesAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closes_at'],
      ),
      shared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shared'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $AccountRowsTable createAlias(String alias) {
    return $AccountRowsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String title;
  final String iconKey;
  final int color;
  final String currency;
  final bool archived;
  final String kind;
  final double? rate;
  final DateTime? openedAt;
  final DateTime? closesAt;

  /// Общий счёт: уезжает в папку обмена и сливается с данными
  /// других участников (ADR-0014).
  final bool shared;
  final DateTime? updatedAt;
  const AccountRow({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    required this.currency,
    required this.archived,
    required this.kind,
    this.rate,
    this.openedAt,
    this.closesAt,
    required this.shared,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['icon_key'] = Variable<String>(iconKey);
    map['color'] = Variable<int>(color);
    map['currency'] = Variable<String>(currency);
    map['archived'] = Variable<bool>(archived);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || rate != null) {
      map['rate'] = Variable<double>(rate);
    }
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    if (!nullToAbsent || closesAt != null) {
      map['closes_at'] = Variable<DateTime>(closesAt);
    }
    map['shared'] = Variable<bool>(shared);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  AccountRowsCompanion toCompanion(bool nullToAbsent) {
    return AccountRowsCompanion(
      id: Value(id),
      title: Value(title),
      iconKey: Value(iconKey),
      color: Value(color),
      currency: Value(currency),
      archived: Value(archived),
      kind: Value(kind),
      rate: rate == null && nullToAbsent ? const Value.absent() : Value(rate),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      closesAt: closesAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closesAt),
      shared: Value(shared),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      color: serializer.fromJson<int>(json['color']),
      currency: serializer.fromJson<String>(json['currency']),
      archived: serializer.fromJson<bool>(json['archived']),
      kind: serializer.fromJson<String>(json['kind']),
      rate: serializer.fromJson<double?>(json['rate']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      closesAt: serializer.fromJson<DateTime?>(json['closesAt']),
      shared: serializer.fromJson<bool>(json['shared']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'iconKey': serializer.toJson<String>(iconKey),
      'color': serializer.toJson<int>(color),
      'currency': serializer.toJson<String>(currency),
      'archived': serializer.toJson<bool>(archived),
      'kind': serializer.toJson<String>(kind),
      'rate': serializer.toJson<double?>(rate),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'closesAt': serializer.toJson<DateTime?>(closesAt),
      'shared': serializer.toJson<bool>(shared),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? title,
    String? iconKey,
    int? color,
    String? currency,
    bool? archived,
    String? kind,
    Value<double?> rate = const Value.absent(),
    Value<DateTime?> openedAt = const Value.absent(),
    Value<DateTime?> closesAt = const Value.absent(),
    bool? shared,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => AccountRow(
    id: id ?? this.id,
    title: title ?? this.title,
    iconKey: iconKey ?? this.iconKey,
    color: color ?? this.color,
    currency: currency ?? this.currency,
    archived: archived ?? this.archived,
    kind: kind ?? this.kind,
    rate: rate.present ? rate.value : this.rate,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    closesAt: closesAt.present ? closesAt.value : this.closesAt,
    shared: shared ?? this.shared,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  AccountRow copyWithCompanion(AccountRowsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      color: data.color.present ? data.color.value : this.color,
      currency: data.currency.present ? data.currency.value : this.currency,
      archived: data.archived.present ? data.archived.value : this.archived,
      kind: data.kind.present ? data.kind.value : this.kind,
      rate: data.rate.present ? data.rate.value : this.rate,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closesAt: data.closesAt.present ? data.closesAt.value : this.closesAt,
      shared: data.shared.present ? data.shared.value : this.shared,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('currency: $currency, ')
          ..write('archived: $archived, ')
          ..write('kind: $kind, ')
          ..write('rate: $rate, ')
          ..write('openedAt: $openedAt, ')
          ..write('closesAt: $closesAt, ')
          ..write('shared: $shared, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    iconKey,
    color,
    currency,
    archived,
    kind,
    rate,
    openedAt,
    closesAt,
    shared,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconKey == this.iconKey &&
          other.color == this.color &&
          other.currency == this.currency &&
          other.archived == this.archived &&
          other.kind == this.kind &&
          other.rate == this.rate &&
          other.openedAt == this.openedAt &&
          other.closesAt == this.closesAt &&
          other.shared == this.shared &&
          other.updatedAt == this.updatedAt);
}

class AccountRowsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> iconKey;
  final Value<int> color;
  final Value<String> currency;
  final Value<bool> archived;
  final Value<String> kind;
  final Value<double?> rate;
  final Value<DateTime?> openedAt;
  final Value<DateTime?> closesAt;
  final Value<bool> shared;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const AccountRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.color = const Value.absent(),
    this.currency = const Value.absent(),
    this.archived = const Value.absent(),
    this.kind = const Value.absent(),
    this.rate = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closesAt = const Value.absent(),
    this.shared = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountRowsCompanion.insert({
    required String id,
    required String title,
    required String iconKey,
    required int color,
    this.currency = const Value.absent(),
    this.archived = const Value.absent(),
    this.kind = const Value.absent(),
    this.rate = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closesAt = const Value.absent(),
    this.shared = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       iconKey = Value(iconKey),
       color = Value(color);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? iconKey,
    Expression<int>? color,
    Expression<String>? currency,
    Expression<bool>? archived,
    Expression<String>? kind,
    Expression<double>? rate,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closesAt,
    Expression<bool>? shared,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconKey != null) 'icon_key': iconKey,
      if (color != null) 'color': color,
      if (currency != null) 'currency': currency,
      if (archived != null) 'archived': archived,
      if (kind != null) 'kind': kind,
      if (rate != null) 'rate': rate,
      if (openedAt != null) 'opened_at': openedAt,
      if (closesAt != null) 'closes_at': closesAt,
      if (shared != null) 'shared': shared,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? iconKey,
    Value<int>? color,
    Value<String>? currency,
    Value<bool>? archived,
    Value<String>? kind,
    Value<double?>? rate,
    Value<DateTime?>? openedAt,
    Value<DateTime?>? closesAt,
    Value<bool>? shared,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      currency: currency ?? this.currency,
      archived: archived ?? this.archived,
      kind: kind ?? this.kind,
      rate: rate ?? this.rate,
      openedAt: openedAt ?? this.openedAt,
      closesAt: closesAt ?? this.closesAt,
      shared: shared ?? this.shared,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closesAt.present) {
      map['closes_at'] = Variable<DateTime>(closesAt.value);
    }
    if (shared.present) {
      map['shared'] = Variable<bool>(shared.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('currency: $currency, ')
          ..write('archived: $archived, ')
          ..write('kind: $kind, ')
          ..write('rate: $rate, ')
          ..write('openedAt: $openedAt, ')
          ..write('closesAt: $closesAt, ')
          ..write('shared: $shared, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryRuleRowsTable extends CategoryRuleRows
    with TableInfo<$CategoryRuleRowsTable, CategoryRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRuleRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pattern, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rule_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $CategoryRuleRowsTable createAlias(String alias) {
    return $CategoryRuleRowsTable(attachedDatabase, alias);
  }
}

class CategoryRuleRow extends DataClass implements Insertable<CategoryRuleRow> {
  final String id;
  final String pattern;
  final String categoryId;
  const CategoryRuleRow({
    required this.id,
    required this.pattern,
    required this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pattern'] = Variable<String>(pattern);
    map['category_id'] = Variable<String>(categoryId);
    return map;
  }

  CategoryRuleRowsCompanion toCompanion(bool nullToAbsent) {
    return CategoryRuleRowsCompanion(
      id: Value(id),
      pattern: Value(pattern),
      categoryId: Value(categoryId),
    );
  }

  factory CategoryRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRuleRow(
      id: serializer.fromJson<String>(json['id']),
      pattern: serializer.fromJson<String>(json['pattern']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pattern': serializer.toJson<String>(pattern),
      'categoryId': serializer.toJson<String>(categoryId),
    };
  }

  CategoryRuleRow copyWith({String? id, String? pattern, String? categoryId}) =>
      CategoryRuleRow(
        id: id ?? this.id,
        pattern: pattern ?? this.pattern,
        categoryId: categoryId ?? this.categoryId,
      );
  CategoryRuleRow copyWithCompanion(CategoryRuleRowsCompanion data) {
    return CategoryRuleRow(
      id: data.id.present ? data.id.value : this.id,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRuleRow(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pattern, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRuleRow &&
          other.id == this.id &&
          other.pattern == this.pattern &&
          other.categoryId == this.categoryId);
}

class CategoryRuleRowsCompanion extends UpdateCompanion<CategoryRuleRow> {
  final Value<String> id;
  final Value<String> pattern;
  final Value<String> categoryId;
  final Value<int> rowid;
  const CategoryRuleRowsCompanion({
    this.id = const Value.absent(),
    this.pattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryRuleRowsCompanion.insert({
    required String id,
    required String pattern,
    required String categoryId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pattern = Value(pattern),
       categoryId = Value(categoryId);
  static Insertable<CategoryRuleRow> custom({
    Expression<String>? id,
    Expression<String>? pattern,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pattern != null) 'pattern': pattern,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryRuleRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? pattern,
    Value<String>? categoryId,
    Value<int>? rowid,
  }) {
    return CategoryRuleRowsCompanion(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRuleRowsCompanion(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalRowsTable extends GoalRows with TableInfo<$GoalRowsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalRowsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAmountMeta = const VerificationMeta(
    'savedAmount',
  );
  @override
  late final GeneratedColumn<double> savedAmount = GeneratedColumn<double>(
    'saved_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    iconKey,
    color,
    targetAmount,
    savedAmount,
    deadline,
    accountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('saved_amount')) {
      context.handle(
        _savedAmountMeta,
        savedAmount.isAcceptableOrUnknown(
          data['saved_amount']!,
          _savedAmountMeta,
        ),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      savedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saved_amount'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
    );
  }

  @override
  $GoalRowsTable createAlias(String alias) {
    return $GoalRowsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final String title;
  final String iconKey;
  final int color;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  /// Счёт, на котором лежат деньги цели; пополнения делают перевод
  /// на него с выбранного счёта-источника.
  final String? accountId;
  const GoalRow({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.color,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
    this.accountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['icon_key'] = Variable<String>(iconKey);
    map['color'] = Variable<int>(color);
    map['target_amount'] = Variable<double>(targetAmount);
    map['saved_amount'] = Variable<double>(savedAmount);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    return map;
  }

  GoalRowsCompanion toCompanion(bool nullToAbsent) {
    return GoalRowsCompanion(
      id: Value(id),
      title: Value(title),
      iconKey: Value(iconKey),
      color: Value(color),
      targetAmount: Value(targetAmount),
      savedAmount: Value(savedAmount),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      color: serializer.fromJson<int>(json['color']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      savedAmount: serializer.fromJson<double>(json['savedAmount']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      accountId: serializer.fromJson<String?>(json['accountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'iconKey': serializer.toJson<String>(iconKey),
      'color': serializer.toJson<int>(color),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'savedAmount': serializer.toJson<double>(savedAmount),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'accountId': serializer.toJson<String?>(accountId),
    };
  }

  GoalRow copyWith({
    String? id,
    String? title,
    String? iconKey,
    int? color,
    double? targetAmount,
    double? savedAmount,
    Value<DateTime?> deadline = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
  }) => GoalRow(
    id: id ?? this.id,
    title: title ?? this.title,
    iconKey: iconKey ?? this.iconKey,
    color: color ?? this.color,
    targetAmount: targetAmount ?? this.targetAmount,
    savedAmount: savedAmount ?? this.savedAmount,
    deadline: deadline.present ? deadline.value : this.deadline,
    accountId: accountId.present ? accountId.value : this.accountId,
  );
  GoalRow copyWithCompanion(GoalRowsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      color: data.color.present ? data.color.value : this.color,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      savedAmount: data.savedAmount.present
          ? data.savedAmount.value
          : this.savedAmount,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('deadline: $deadline, ')
          ..write('accountId: $accountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    iconKey,
    color,
    targetAmount,
    savedAmount,
    deadline,
    accountId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.iconKey == this.iconKey &&
          other.color == this.color &&
          other.targetAmount == this.targetAmount &&
          other.savedAmount == this.savedAmount &&
          other.deadline == this.deadline &&
          other.accountId == this.accountId);
}

class GoalRowsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> iconKey;
  final Value<int> color;
  final Value<double> targetAmount;
  final Value<double> savedAmount;
  final Value<DateTime?> deadline;
  final Value<String?> accountId;
  final Value<int> rowid;
  const GoalRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.color = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.savedAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.accountId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalRowsCompanion.insert({
    required String id,
    required String title,
    required String iconKey,
    required int color,
    required double targetAmount,
    this.savedAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.accountId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       iconKey = Value(iconKey),
       color = Value(color),
       targetAmount = Value(targetAmount);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? iconKey,
    Expression<int>? color,
    Expression<double>? targetAmount,
    Expression<double>? savedAmount,
    Expression<DateTime>? deadline,
    Expression<String>? accountId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (iconKey != null) 'icon_key': iconKey,
      if (color != null) 'color': color,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (savedAmount != null) 'saved_amount': savedAmount,
      if (deadline != null) 'deadline': deadline,
      if (accountId != null) 'account_id': accountId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? iconKey,
    Value<int>? color,
    Value<double>? targetAmount,
    Value<double>? savedAmount,
    Value<DateTime?>? deadline,
    Value<String?>? accountId,
    Value<int>? rowid,
  }) {
    return GoalRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      accountId: accountId ?? this.accountId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (savedAmount.present) {
      map['saved_amount'] = Variable<double>(savedAmount.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('iconKey: $iconKey, ')
          ..write('color: $color, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('savedAmount: $savedAmount, ')
          ..write('deadline: $deadline, ')
          ..write('accountId: $accountId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportRowsTable extends ImportRows
    with TableInfo<$ImportRowsTable, ImportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opsCountMeta = const VerificationMeta(
    'opsCount',
  );
  @override
  late final GeneratedColumn<int> opsCount = GeneratedColumn<int>(
    'ops_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fileName, importedAt, opsCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('ops_count')) {
      context.handle(
        _opsCountMeta,
        opsCount.isAcceptableOrUnknown(data['ops_count']!, _opsCountMeta),
      );
    } else if (isInserting) {
      context.missing(_opsCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      opsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ops_count'],
      )!,
    );
  }

  @override
  $ImportRowsTable createAlias(String alias) {
    return $ImportRowsTable(attachedDatabase, alias);
  }
}

class ImportRow extends DataClass implements Insertable<ImportRow> {
  final String id;
  final String fileName;
  final DateTime importedAt;
  final int opsCount;
  const ImportRow({
    required this.id,
    required this.fileName,
    required this.importedAt,
    required this.opsCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['file_name'] = Variable<String>(fileName);
    map['imported_at'] = Variable<DateTime>(importedAt);
    map['ops_count'] = Variable<int>(opsCount);
    return map;
  }

  ImportRowsCompanion toCompanion(bool nullToAbsent) {
    return ImportRowsCompanion(
      id: Value(id),
      fileName: Value(fileName),
      importedAt: Value(importedAt),
      opsCount: Value(opsCount),
    );
  }

  factory ImportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportRow(
      id: serializer.fromJson<String>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      opsCount: serializer.fromJson<int>(json['opsCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fileName': serializer.toJson<String>(fileName),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'opsCount': serializer.toJson<int>(opsCount),
    };
  }

  ImportRow copyWith({
    String? id,
    String? fileName,
    DateTime? importedAt,
    int? opsCount,
  }) => ImportRow(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    importedAt: importedAt ?? this.importedAt,
    opsCount: opsCount ?? this.opsCount,
  );
  ImportRow copyWithCompanion(ImportRowsCompanion data) {
    return ImportRow(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      opsCount: data.opsCount.present ? data.opsCount.value : this.opsCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportRow(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('importedAt: $importedAt, ')
          ..write('opsCount: $opsCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fileName, importedAt, opsCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportRow &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.importedAt == this.importedAt &&
          other.opsCount == this.opsCount);
}

class ImportRowsCompanion extends UpdateCompanion<ImportRow> {
  final Value<String> id;
  final Value<String> fileName;
  final Value<DateTime> importedAt;
  final Value<int> opsCount;
  final Value<int> rowid;
  const ImportRowsCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.opsCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportRowsCompanion.insert({
    required String id,
    required String fileName,
    required DateTime importedAt,
    required int opsCount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fileName = Value(fileName),
       importedAt = Value(importedAt),
       opsCount = Value(opsCount);
  static Insertable<ImportRow> custom({
    Expression<String>? id,
    Expression<String>? fileName,
    Expression<DateTime>? importedAt,
    Expression<int>? opsCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (importedAt != null) 'imported_at': importedAt,
      if (opsCount != null) 'ops_count': opsCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? fileName,
    Value<DateTime>? importedAt,
    Value<int>? opsCount,
    Value<int>? rowid,
  }) {
    return ImportRowsCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      importedAt: importedAt ?? this.importedAt,
      opsCount: opsCount ?? this.opsCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (opsCount.present) {
      map['ops_count'] = Variable<int>(opsCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportRowsCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('importedAt: $importedAt, ')
          ..write('opsCount: $opsCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemberRowsTable extends MemberRows
    with TableInfo<$MemberRowsTable, MemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberRowsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isMeMeta = const VerificationMeta('isMe');
  @override
  late final GeneratedColumn<bool> isMe = GeneratedColumn<bool>(
    'is_me',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_me" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, isMe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemberRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_me')) {
      context.handle(
        _isMeMeta,
        isMe.isAcceptableOrUnknown(data['is_me']!, _isMeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isMe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_me'],
      )!,
    );
  }

  @override
  $MemberRowsTable createAlias(String alias) {
    return $MemberRowsTable(attachedDatabase, alias);
  }
}

class MemberRow extends DataClass implements Insertable<MemberRow> {
  final String id;
  final String name;
  final int color;
  final bool isMe;
  const MemberRow({
    required this.id,
    required this.name,
    required this.color,
    required this.isMe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['is_me'] = Variable<bool>(isMe);
    return map;
  }

  MemberRowsCompanion toCompanion(bool nullToAbsent) {
    return MemberRowsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      isMe: Value(isMe),
    );
  }

  factory MemberRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      isMe: serializer.fromJson<bool>(json['isMe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'isMe': serializer.toJson<bool>(isMe),
    };
  }

  MemberRow copyWith({String? id, String? name, int? color, bool? isMe}) =>
      MemberRow(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        isMe: isMe ?? this.isMe,
      );
  MemberRow copyWithCompanion(MemberRowsCompanion data) {
    return MemberRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      isMe: data.isMe.present ? data.isMe.value : this.isMe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemberRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isMe: $isMe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, isMe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.isMe == this.isMe);
}

class MemberRowsCompanion extends UpdateCompanion<MemberRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<bool> isMe;
  final Value<int> rowid;
  const MemberRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.isMe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberRowsCompanion.insert({
    required String id,
    required String name,
    required int color,
    this.isMe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color);
  static Insertable<MemberRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<bool>? isMe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (isMe != null) 'is_me': isMe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<bool>? isMe,
    Value<int>? rowid,
  }) {
    return MemberRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isMe: isMe ?? this.isMe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isMe.present) {
      map['is_me'] = Variable<bool>(isMe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('isMe: $isMe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$NumoDatabase extends GeneratedDatabase {
  _$NumoDatabase(QueryExecutor e) : super(e);
  $NumoDatabaseManager get managers => $NumoDatabaseManager(this);
  late final $TransactionRowsTable transactionRows = $TransactionRowsTable(
    this,
  );
  late final $CategoryRowsTable categoryRows = $CategoryRowsTable(this);
  late final $BudgetRowsTable budgetRows = $BudgetRowsTable(this);
  late final $RecurringRowsTable recurringRows = $RecurringRowsTable(this);
  late final $AccountRowsTable accountRows = $AccountRowsTable(this);
  late final $CategoryRuleRowsTable categoryRuleRows = $CategoryRuleRowsTable(
    this,
  );
  late final $GoalRowsTable goalRows = $GoalRowsTable(this);
  late final $ImportRowsTable importRows = $ImportRowsTable(this);
  late final $MemberRowsTable memberRows = $MemberRowsTable(this);
  late final Index txDate = Index(
    'tx_date',
    'CREATE INDEX tx_date ON transaction_rows (date)',
  );
  late final Index txAccount = Index(
    'tx_account',
    'CREATE INDEX tx_account ON transaction_rows (account_id)',
  );
  late final Index txDeleted = Index(
    'tx_deleted',
    'CREATE INDEX tx_deleted ON transaction_rows (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactionRows,
    categoryRows,
    budgetRows,
    recurringRows,
    accountRows,
    categoryRuleRows,
    goalRows,
    importRows,
    memberRows,
    txDate,
    txAccount,
    txDeleted,
  ];
}

typedef $$TransactionRowsTableCreateCompanionBuilder =
    TransactionRowsCompanion Function({
      required String id,
      required String type,
      required double amount,
      required String categoryId,
      required DateTime date,
      Value<String> note,
      Value<String> noteLower,
      Value<String> accountId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> authorId,
      Value<String?> split,
      Value<int> rowid,
    });
typedef $$TransactionRowsTableUpdateCompanionBuilder =
    TransactionRowsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<double> amount,
      Value<String> categoryId,
      Value<DateTime> date,
      Value<String> note,
      Value<String> noteLower,
      Value<String> accountId,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> authorId,
      Value<String?> split,
      Value<int> rowid,
    });

class $$TransactionRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $TransactionRowsTable> {
  $$TransactionRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteLower => $composableBuilder(
    column: $table.noteLower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get split => $composableBuilder(
    column: $table.split,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $TransactionRowsTable> {
  $$TransactionRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteLower => $composableBuilder(
    column: $table.noteLower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get split => $composableBuilder(
    column: $table.split,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $TransactionRowsTable> {
  $$TransactionRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get noteLower =>
      $composableBuilder(column: $table.noteLower, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get split =>
      $composableBuilder(column: $table.split, builder: (column) => column);
}

class $$TransactionRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $TransactionRowsTable,
          TransactionRow,
          $$TransactionRowsTableFilterComposer,
          $$TransactionRowsTableOrderingComposer,
          $$TransactionRowsTableAnnotationComposer,
          $$TransactionRowsTableCreateCompanionBuilder,
          $$TransactionRowsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<
              _$NumoDatabase,
              $TransactionRowsTable,
              TransactionRow
            >,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionRowsTableTableManager(
    _$NumoDatabase db,
    $TransactionRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> noteLower = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> authorId = const Value.absent(),
                Value<String?> split = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionRowsCompanion(
                id: id,
                type: type,
                amount: amount,
                categoryId: categoryId,
                date: date,
                note: note,
                noteLower: noteLower,
                accountId: accountId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                authorId: authorId,
                split: split,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required double amount,
                required String categoryId,
                required DateTime date,
                Value<String> note = const Value.absent(),
                Value<String> noteLower = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> authorId = const Value.absent(),
                Value<String?> split = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionRowsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                categoryId: categoryId,
                date: date,
                note: note,
                noteLower: noteLower,
                accountId: accountId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                authorId: authorId,
                split: split,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $TransactionRowsTable,
      TransactionRow,
      $$TransactionRowsTableFilterComposer,
      $$TransactionRowsTableOrderingComposer,
      $$TransactionRowsTableAnnotationComposer,
      $$TransactionRowsTableCreateCompanionBuilder,
      $$TransactionRowsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$NumoDatabase, $TransactionRowsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryRowsTableCreateCompanionBuilder =
    CategoryRowsCompanion Function({
      required String id,
      required String title,
      required String iconKey,
      required int color,
      Value<bool> isIncome,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$CategoryRowsTableUpdateCompanionBuilder =
    CategoryRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> iconKey,
      Value<int> color,
      Value<bool> isIncome,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$CategoryRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $CategoryRowsTable> {
  $$CategoryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$CategoryRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $CategoryRowsTable,
          CategoryRow,
          $$CategoryRowsTableFilterComposer,
          $$CategoryRowsTableOrderingComposer,
          $$CategoryRowsTableAnnotationComposer,
          $$CategoryRowsTableCreateCompanionBuilder,
          $$CategoryRowsTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$NumoDatabase, $CategoryRowsTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoryRowsTableTableManager(_$NumoDatabase db, $CategoryRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRowsCompanion(
                id: id,
                title: title,
                iconKey: iconKey,
                color: color,
                isIncome: isIncome,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String iconKey,
                required int color,
                Value<bool> isIncome = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRowsCompanion.insert(
                id: id,
                title: title,
                iconKey: iconKey,
                color: color,
                isIncome: isIncome,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $CategoryRowsTable,
      CategoryRow,
      $$CategoryRowsTableFilterComposer,
      $$CategoryRowsTableOrderingComposer,
      $$CategoryRowsTableAnnotationComposer,
      $$CategoryRowsTableCreateCompanionBuilder,
      $$CategoryRowsTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$NumoDatabase, $CategoryRowsTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetRowsTableCreateCompanionBuilder =
    BudgetRowsCompanion Function({
      required String categoryId,
      required double monthlyLimit,
      Value<int> rowid,
    });
typedef $$BudgetRowsTableUpdateCompanionBuilder =
    BudgetRowsCompanion Function({
      Value<String> categoryId,
      Value<double> monthlyLimit,
      Value<int> rowid,
    });

class $$BudgetRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $BudgetRowsTable> {
  $$BudgetRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $BudgetRowsTable> {
  $$BudgetRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $BudgetRowsTable> {
  $$BudgetRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => column,
  );
}

class $$BudgetRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $BudgetRowsTable,
          BudgetRow,
          $$BudgetRowsTableFilterComposer,
          $$BudgetRowsTableOrderingComposer,
          $$BudgetRowsTableAnnotationComposer,
          $$BudgetRowsTableCreateCompanionBuilder,
          $$BudgetRowsTableUpdateCompanionBuilder,
          (
            BudgetRow,
            BaseReferences<_$NumoDatabase, $BudgetRowsTable, BudgetRow>,
          ),
          BudgetRow,
          PrefetchHooks Function()
        > {
  $$BudgetRowsTableTableManager(_$NumoDatabase db, $BudgetRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<double> monthlyLimit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetRowsCompanion(
                categoryId: categoryId,
                monthlyLimit: monthlyLimit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required double monthlyLimit,
                Value<int> rowid = const Value.absent(),
              }) => BudgetRowsCompanion.insert(
                categoryId: categoryId,
                monthlyLimit: monthlyLimit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $BudgetRowsTable,
      BudgetRow,
      $$BudgetRowsTableFilterComposer,
      $$BudgetRowsTableOrderingComposer,
      $$BudgetRowsTableAnnotationComposer,
      $$BudgetRowsTableCreateCompanionBuilder,
      $$BudgetRowsTableUpdateCompanionBuilder,
      (BudgetRow, BaseReferences<_$NumoDatabase, $BudgetRowsTable, BudgetRow>),
      BudgetRow,
      PrefetchHooks Function()
    >;
typedef $$RecurringRowsTableCreateCompanionBuilder =
    RecurringRowsCompanion Function({
      required String id,
      required String type,
      required double amount,
      required String categoryId,
      Value<String> note,
      required int dayOfMonth,
      required DateTime startDate,
      Value<DateTime?> appliedThrough,
      Value<int> rowid,
    });
typedef $$RecurringRowsTableUpdateCompanionBuilder =
    RecurringRowsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<double> amount,
      Value<String> categoryId,
      Value<String> note,
      Value<int> dayOfMonth,
      Value<DateTime> startDate,
      Value<DateTime?> appliedThrough,
      Value<int> rowid,
    });

class $$RecurringRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $RecurringRowsTable> {
  $$RecurringRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedThrough => $composableBuilder(
    column: $table.appliedThrough,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $RecurringRowsTable> {
  $$RecurringRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedThrough => $composableBuilder(
    column: $table.appliedThrough,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $RecurringRowsTable> {
  $$RecurringRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedThrough => $composableBuilder(
    column: $table.appliedThrough,
    builder: (column) => column,
  );
}

class $$RecurringRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $RecurringRowsTable,
          RecurringRow,
          $$RecurringRowsTableFilterComposer,
          $$RecurringRowsTableOrderingComposer,
          $$RecurringRowsTableAnnotationComposer,
          $$RecurringRowsTableCreateCompanionBuilder,
          $$RecurringRowsTableUpdateCompanionBuilder,
          (
            RecurringRow,
            BaseReferences<_$NumoDatabase, $RecurringRowsTable, RecurringRow>,
          ),
          RecurringRow,
          PrefetchHooks Function()
        > {
  $$RecurringRowsTableTableManager(_$NumoDatabase db, $RecurringRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> appliedThrough = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRowsCompanion(
                id: id,
                type: type,
                amount: amount,
                categoryId: categoryId,
                note: note,
                dayOfMonth: dayOfMonth,
                startDate: startDate,
                appliedThrough: appliedThrough,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required double amount,
                required String categoryId,
                Value<String> note = const Value.absent(),
                required int dayOfMonth,
                required DateTime startDate,
                Value<DateTime?> appliedThrough = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringRowsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                categoryId: categoryId,
                note: note,
                dayOfMonth: dayOfMonth,
                startDate: startDate,
                appliedThrough: appliedThrough,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $RecurringRowsTable,
      RecurringRow,
      $$RecurringRowsTableFilterComposer,
      $$RecurringRowsTableOrderingComposer,
      $$RecurringRowsTableAnnotationComposer,
      $$RecurringRowsTableCreateCompanionBuilder,
      $$RecurringRowsTableUpdateCompanionBuilder,
      (
        RecurringRow,
        BaseReferences<_$NumoDatabase, $RecurringRowsTable, RecurringRow>,
      ),
      RecurringRow,
      PrefetchHooks Function()
    >;
typedef $$AccountRowsTableCreateCompanionBuilder =
    AccountRowsCompanion Function({
      required String id,
      required String title,
      required String iconKey,
      required int color,
      Value<String> currency,
      Value<bool> archived,
      Value<String> kind,
      Value<double?> rate,
      Value<DateTime?> openedAt,
      Value<DateTime?> closesAt,
      Value<bool> shared,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$AccountRowsTableUpdateCompanionBuilder =
    AccountRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> iconKey,
      Value<int> color,
      Value<String> currency,
      Value<bool> archived,
      Value<String> kind,
      Value<double?> rate,
      Value<DateTime?> openedAt,
      Value<DateTime?> closesAt,
      Value<bool> shared,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$AccountRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $AccountRowsTable> {
  $$AccountRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closesAt => $composableBuilder(
    column: $table.closesAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shared => $composableBuilder(
    column: $table.shared,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $AccountRowsTable> {
  $$AccountRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closesAt => $composableBuilder(
    column: $table.closesAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shared => $composableBuilder(
    column: $table.shared,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $AccountRowsTable> {
  $$AccountRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closesAt =>
      $composableBuilder(column: $table.closesAt, builder: (column) => column);

  GeneratedColumn<bool> get shared =>
      $composableBuilder(column: $table.shared, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $AccountRowsTable,
          AccountRow,
          $$AccountRowsTableFilterComposer,
          $$AccountRowsTableOrderingComposer,
          $$AccountRowsTableAnnotationComposer,
          $$AccountRowsTableCreateCompanionBuilder,
          $$AccountRowsTableUpdateCompanionBuilder,
          (
            AccountRow,
            BaseReferences<_$NumoDatabase, $AccountRowsTable, AccountRow>,
          ),
          AccountRow,
          PrefetchHooks Function()
        > {
  $$AccountRowsTableTableManager(_$NumoDatabase db, $AccountRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double?> rate = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime?> closesAt = const Value.absent(),
                Value<bool> shared = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountRowsCompanion(
                id: id,
                title: title,
                iconKey: iconKey,
                color: color,
                currency: currency,
                archived: archived,
                kind: kind,
                rate: rate,
                openedAt: openedAt,
                closesAt: closesAt,
                shared: shared,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String iconKey,
                required int color,
                Value<String> currency = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<double?> rate = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime?> closesAt = const Value.absent(),
                Value<bool> shared = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountRowsCompanion.insert(
                id: id,
                title: title,
                iconKey: iconKey,
                color: color,
                currency: currency,
                archived: archived,
                kind: kind,
                rate: rate,
                openedAt: openedAt,
                closesAt: closesAt,
                shared: shared,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $AccountRowsTable,
      AccountRow,
      $$AccountRowsTableFilterComposer,
      $$AccountRowsTableOrderingComposer,
      $$AccountRowsTableAnnotationComposer,
      $$AccountRowsTableCreateCompanionBuilder,
      $$AccountRowsTableUpdateCompanionBuilder,
      (
        AccountRow,
        BaseReferences<_$NumoDatabase, $AccountRowsTable, AccountRow>,
      ),
      AccountRow,
      PrefetchHooks Function()
    >;
typedef $$CategoryRuleRowsTableCreateCompanionBuilder =
    CategoryRuleRowsCompanion Function({
      required String id,
      required String pattern,
      required String categoryId,
      Value<int> rowid,
    });
typedef $$CategoryRuleRowsTableUpdateCompanionBuilder =
    CategoryRuleRowsCompanion Function({
      Value<String> id,
      Value<String> pattern,
      Value<String> categoryId,
      Value<int> rowid,
    });

class $$CategoryRuleRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $CategoryRuleRowsTable> {
  $$CategoryRuleRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryRuleRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $CategoryRuleRowsTable> {
  $$CategoryRuleRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryRuleRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $CategoryRuleRowsTable> {
  $$CategoryRuleRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );
}

class $$CategoryRuleRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $CategoryRuleRowsTable,
          CategoryRuleRow,
          $$CategoryRuleRowsTableFilterComposer,
          $$CategoryRuleRowsTableOrderingComposer,
          $$CategoryRuleRowsTableAnnotationComposer,
          $$CategoryRuleRowsTableCreateCompanionBuilder,
          $$CategoryRuleRowsTableUpdateCompanionBuilder,
          (
            CategoryRuleRow,
            BaseReferences<
              _$NumoDatabase,
              $CategoryRuleRowsTable,
              CategoryRuleRow
            >,
          ),
          CategoryRuleRow,
          PrefetchHooks Function()
        > {
  $$CategoryRuleRowsTableTableManager(
    _$NumoDatabase db,
    $CategoryRuleRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRuleRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRuleRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRuleRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryRuleRowsCompanion(
                id: id,
                pattern: pattern,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pattern,
                required String categoryId,
                Value<int> rowid = const Value.absent(),
              }) => CategoryRuleRowsCompanion.insert(
                id: id,
                pattern: pattern,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoryRuleRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $CategoryRuleRowsTable,
      CategoryRuleRow,
      $$CategoryRuleRowsTableFilterComposer,
      $$CategoryRuleRowsTableOrderingComposer,
      $$CategoryRuleRowsTableAnnotationComposer,
      $$CategoryRuleRowsTableCreateCompanionBuilder,
      $$CategoryRuleRowsTableUpdateCompanionBuilder,
      (
        CategoryRuleRow,
        BaseReferences<_$NumoDatabase, $CategoryRuleRowsTable, CategoryRuleRow>,
      ),
      CategoryRuleRow,
      PrefetchHooks Function()
    >;
typedef $$GoalRowsTableCreateCompanionBuilder =
    GoalRowsCompanion Function({
      required String id,
      required String title,
      required String iconKey,
      required int color,
      required double targetAmount,
      Value<double> savedAmount,
      Value<DateTime?> deadline,
      Value<String?> accountId,
      Value<int> rowid,
    });
typedef $$GoalRowsTableUpdateCompanionBuilder =
    GoalRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> iconKey,
      Value<int> color,
      Value<double> targetAmount,
      Value<double> savedAmount,
      Value<DateTime?> deadline,
      Value<String?> accountId,
      Value<int> rowid,
    });

class $$GoalRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $GoalRowsTable> {
  $$GoalRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $GoalRowsTable> {
  $$GoalRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $GoalRowsTable> {
  $$GoalRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get savedAmount => $composableBuilder(
    column: $table.savedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);
}

class $$GoalRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $GoalRowsTable,
          GoalRow,
          $$GoalRowsTableFilterComposer,
          $$GoalRowsTableOrderingComposer,
          $$GoalRowsTableAnnotationComposer,
          $$GoalRowsTableCreateCompanionBuilder,
          $$GoalRowsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$NumoDatabase, $GoalRowsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalRowsTableTableManager(_$NumoDatabase db, $GoalRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<double> savedAmount = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalRowsCompanion(
                id: id,
                title: title,
                iconKey: iconKey,
                color: color,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                deadline: deadline,
                accountId: accountId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String iconKey,
                required int color,
                required double targetAmount,
                Value<double> savedAmount = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalRowsCompanion.insert(
                id: id,
                title: title,
                iconKey: iconKey,
                color: color,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                deadline: deadline,
                accountId: accountId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $GoalRowsTable,
      GoalRow,
      $$GoalRowsTableFilterComposer,
      $$GoalRowsTableOrderingComposer,
      $$GoalRowsTableAnnotationComposer,
      $$GoalRowsTableCreateCompanionBuilder,
      $$GoalRowsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$NumoDatabase, $GoalRowsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;
typedef $$ImportRowsTableCreateCompanionBuilder =
    ImportRowsCompanion Function({
      required String id,
      required String fileName,
      required DateTime importedAt,
      required int opsCount,
      Value<int> rowid,
    });
typedef $$ImportRowsTableUpdateCompanionBuilder =
    ImportRowsCompanion Function({
      Value<String> id,
      Value<String> fileName,
      Value<DateTime> importedAt,
      Value<int> opsCount,
      Value<int> rowid,
    });

class $$ImportRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $ImportRowsTable> {
  $$ImportRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get opsCount => $composableBuilder(
    column: $table.opsCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $ImportRowsTable> {
  $$ImportRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get opsCount => $composableBuilder(
    column: $table.opsCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $ImportRowsTable> {
  $$ImportRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get opsCount =>
      $composableBuilder(column: $table.opsCount, builder: (column) => column);
}

class $$ImportRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $ImportRowsTable,
          ImportRow,
          $$ImportRowsTableFilterComposer,
          $$ImportRowsTableOrderingComposer,
          $$ImportRowsTableAnnotationComposer,
          $$ImportRowsTableCreateCompanionBuilder,
          $$ImportRowsTableUpdateCompanionBuilder,
          (
            ImportRow,
            BaseReferences<_$NumoDatabase, $ImportRowsTable, ImportRow>,
          ),
          ImportRow,
          PrefetchHooks Function()
        > {
  $$ImportRowsTableTableManager(_$NumoDatabase db, $ImportRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> opsCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportRowsCompanion(
                id: id,
                fileName: fileName,
                importedAt: importedAt,
                opsCount: opsCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fileName,
                required DateTime importedAt,
                required int opsCount,
                Value<int> rowid = const Value.absent(),
              }) => ImportRowsCompanion.insert(
                id: id,
                fileName: fileName,
                importedAt: importedAt,
                opsCount: opsCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $ImportRowsTable,
      ImportRow,
      $$ImportRowsTableFilterComposer,
      $$ImportRowsTableOrderingComposer,
      $$ImportRowsTableAnnotationComposer,
      $$ImportRowsTableCreateCompanionBuilder,
      $$ImportRowsTableUpdateCompanionBuilder,
      (ImportRow, BaseReferences<_$NumoDatabase, $ImportRowsTable, ImportRow>),
      ImportRow,
      PrefetchHooks Function()
    >;
typedef $$MemberRowsTableCreateCompanionBuilder =
    MemberRowsCompanion Function({
      required String id,
      required String name,
      required int color,
      Value<bool> isMe,
      Value<int> rowid,
    });
typedef $$MemberRowsTableUpdateCompanionBuilder =
    MemberRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> color,
      Value<bool> isMe,
      Value<int> rowid,
    });

class $$MemberRowsTableFilterComposer
    extends Composer<_$NumoDatabase, $MemberRowsTable> {
  $$MemberRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemberRowsTableOrderingComposer
    extends Composer<_$NumoDatabase, $MemberRowsTable> {
  $$MemberRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMe => $composableBuilder(
    column: $table.isMe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemberRowsTableAnnotationComposer
    extends Composer<_$NumoDatabase, $MemberRowsTable> {
  $$MemberRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isMe =>
      $composableBuilder(column: $table.isMe, builder: (column) => column);
}

class $$MemberRowsTableTableManager
    extends
        RootTableManager<
          _$NumoDatabase,
          $MemberRowsTable,
          MemberRow,
          $$MemberRowsTableFilterComposer,
          $$MemberRowsTableOrderingComposer,
          $$MemberRowsTableAnnotationComposer,
          $$MemberRowsTableCreateCompanionBuilder,
          $$MemberRowsTableUpdateCompanionBuilder,
          (
            MemberRow,
            BaseReferences<_$NumoDatabase, $MemberRowsTable, MemberRow>,
          ),
          MemberRow,
          PrefetchHooks Function()
        > {
  $$MemberRowsTableTableManager(_$NumoDatabase db, $MemberRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemberRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemberRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemberRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isMe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberRowsCompanion(
                id: id,
                name: name,
                color: color,
                isMe: isMe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int color,
                Value<bool> isMe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemberRowsCompanion.insert(
                id: id,
                name: name,
                color: color,
                isMe: isMe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemberRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$NumoDatabase,
      $MemberRowsTable,
      MemberRow,
      $$MemberRowsTableFilterComposer,
      $$MemberRowsTableOrderingComposer,
      $$MemberRowsTableAnnotationComposer,
      $$MemberRowsTableCreateCompanionBuilder,
      $$MemberRowsTableUpdateCompanionBuilder,
      (MemberRow, BaseReferences<_$NumoDatabase, $MemberRowsTable, MemberRow>),
      MemberRow,
      PrefetchHooks Function()
    >;

class $NumoDatabaseManager {
  final _$NumoDatabase _db;
  $NumoDatabaseManager(this._db);
  $$TransactionRowsTableTableManager get transactionRows =>
      $$TransactionRowsTableTableManager(_db, _db.transactionRows);
  $$CategoryRowsTableTableManager get categoryRows =>
      $$CategoryRowsTableTableManager(_db, _db.categoryRows);
  $$BudgetRowsTableTableManager get budgetRows =>
      $$BudgetRowsTableTableManager(_db, _db.budgetRows);
  $$RecurringRowsTableTableManager get recurringRows =>
      $$RecurringRowsTableTableManager(_db, _db.recurringRows);
  $$AccountRowsTableTableManager get accountRows =>
      $$AccountRowsTableTableManager(_db, _db.accountRows);
  $$CategoryRuleRowsTableTableManager get categoryRuleRows =>
      $$CategoryRuleRowsTableTableManager(_db, _db.categoryRuleRows);
  $$GoalRowsTableTableManager get goalRows =>
      $$GoalRowsTableTableManager(_db, _db.goalRows);
  $$ImportRowsTableTableManager get importRows =>
      $$ImportRowsTableTableManager(_db, _db.importRows);
  $$MemberRowsTableTableManager get memberRows =>
      $$MemberRowsTableTableManager(_db, _db.memberRows);
}
