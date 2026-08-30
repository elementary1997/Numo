import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/member.dart';
import '../models/transaction.dart';
import 'sync_file_stub.dart' if (dart.library.io) 'sync_file_io.dart'
    as sync_file;

/// Данные, вычитанные из файлов других участников.
class SharedSnapshot {
  const SharedSnapshot({
    required this.members,
    required this.accounts,
    required this.transactions,
    this.categories = const [],
  });

  static const empty = SharedSnapshot(
      members: [], accounts: [], transactions: []);

  final List<Member> members;
  final List<Account> accounts;

  /// Категории, встречающиеся в общих операциях: без них чужая
  /// операция у второго участника попала бы в «Другое».
  final List<TxCategory> categories;

  /// Операции по общим счетам, включая надгробия удалённых.
  final List<Tx> transactions;

  bool get isEmpty =>
      members.isEmpty &&
      accounts.isEmpty &&
      transactions.isEmpty &&
      categories.isEmpty;
}

/// Обмен данными общих счетов через папку в облаке пользователя
/// (ADR-0013). Каждый участник пишет свой файл и никогда не трогает
/// чужие; слияние делают репозитории по отметкам изменения.
class SharedSyncService {
  SharedSyncService._(this._prefs);

  static const filePrefix = 'numo-shared-';
  static const formatVersion = 1;
  static const _dirKey = 'numo.shared.dir';
  static const _lastPullKey = 'numo.shared.lastPull';

  final SharedPreferences _prefs;
  Timer? _debounce;

  static Future<SharedSyncService> open() async =>
      SharedSyncService._(await SharedPreferences.getInstance());

  static bool get supported => sync_file.syncSupported;

  String? get directory => _prefs.getString(_dirKey);

  bool get enabled => supported && directory != null;

  DateTime? get lastPull {
    final raw = _prefs.getString(_lastPullKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setDirectory(String? dir) async {
    if (dir == null) {
      await _prefs.remove(_dirKey);
      await _prefs.remove(_lastPullKey);
    } else {
      await _prefs.setString(_dirKey, dir);
    }
  }

  String fileNameFor(String memberId) => '$filePrefix$memberId.json';

  /// Собирает файл участника: общие счета и операции по ним.
  static String encode({
    required Member me,
    required List<Account> accounts,
    required List<Tx> transactions,
    List<TxCategory> categories = const [],
  }) {
    final shared = accounts.where((a) => a.shared).toList();
    final sharedIds = shared.map((a) => a.id).toSet();
    final sent = [
      for (final tx in transactions)
        if (sharedIds.contains(tx.accountId)) tx,
    ];
    final usedCategories = sent.map((t) => t.categoryId).toSet();
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'numo',
      'kind': 'shared',
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'member': me.toJson(),
      'accounts': shared.map((a) => a.toJson()).toList(),
      'categories': [
        for (final category in categories)
          if (usedCategories.contains(category.id)) category.toJson(),
      ],
      'transactions': [for (final tx in sent) tx.toJson()],
    });
  }

  /// Разбирает файл участника; null — файл не наш или повреждён.
  static SharedSnapshot? decode(String raw) {
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> ||
          json['app'] != 'numo' ||
          json['kind'] != 'shared') {
        return null;
      }
      if ((json['version'] as int? ?? 0) > formatVersion) return null;
      final member = json['member'] as Map<String, dynamic>?;
      return SharedSnapshot(
        members: [if (member != null) Member.fromJson(member)],
        accounts: ((json['accounts'] as List?) ?? const [])
            .map((e) => Account.fromJson(e as Map<String, dynamic>))
            .toList(),
        transactions: ((json['transactions'] as List?) ?? const [])
            .map((e) => Tx.fromJson(e as Map<String, dynamic>))
            .toList(),
        categories: ((json['categories'] as List?) ?? const [])
            .map((e) => TxCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Записывает мой файл в общую папку.
  Future<void> publish({
    required Member me,
    required List<Account> accounts,
    required List<Tx> transactions,
    List<TxCategory> categories = const [],
  }) async {
    final dir = directory;
    if (!supported || dir == null) return;
    try {
      await sync_file.writeSyncFile(
        '$dir/${fileNameFor(me.id)}',
        encode(
          me: me,
          accounts: accounts,
          transactions: transactions,
          categories: categories,
        ),
      );
    } catch (_) {
      // Папка недоступна (облако отмонтировано) — публикация повторится
      // при следующем изменении.
    }
  }

  /// Публикация с дебаунсом: серия правок превращается в одну запись.
  void schedulePublish(
    ({
      Member me,
      List<Account> accounts,
      List<Tx> transactions,
      List<TxCategory> categories
    })?
            Function()
        collect,
  ) {
    if (!enabled) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      final data = collect();
      if (data == null) return;
      await publish(
        me: data.me,
        accounts: data.accounts,
        transactions: data.transactions,
        categories: data.categories,
      );
    });
  }

  /// Читает файлы всех участников, кроме своего.
  Future<SharedSnapshot> pull({required String myMemberId}) async {
    final dir = directory;
    if (!supported || dir == null) return SharedSnapshot.empty;
    final members = <Member>[];
    final accounts = <Account>[];
    final transactions = <Tx>[];
    final categories = <TxCategory>[];
    try {
      final paths = await sync_file.listSyncFiles(dir, filePrefix);
      for (final path in paths) {
        if (path.endsWith(fileNameFor(myMemberId))) continue;
        final raw = await sync_file.readSyncFile(path);
        if (raw == null) continue;
        final snapshot = decode(raw);
        if (snapshot == null) continue;
        members.addAll(snapshot.members);
        accounts.addAll(snapshot.accounts);
        transactions.addAll(snapshot.transactions);
        categories.addAll(snapshot.categories);
      }
      await _prefs.setString(
          _lastPullKey, DateTime.now().toIso8601String());
    } catch (_) {
      return SharedSnapshot.empty;
    }
    return SharedSnapshot(
      members: members,
      accounts: accounts,
      transactions: transactions,
      categories: categories,
    );
  }

  void dispose() => _debounce?.cancel();
}
