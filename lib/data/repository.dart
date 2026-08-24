import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/transaction.dart';

/// Хранилище операций. Сейчас — JSON в shared_preferences (работает на всех
/// шести платформах); интерфейс позволяет позже заменить на SQLite/drift,
/// не трогая UI и состояние.
class TransactionsRepository {
  TransactionsRepository._(this._prefs);

  static const _key = 'numo.transactions.v1';
  static const _seededKey = 'numo.seeded.v1';

  final SharedPreferences _prefs;

  static Future<TransactionsRepository> open() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = TransactionsRepository._(prefs);
    if (!(prefs.getBool(_seededKey) ?? false)) {
      await repo.saveAll(_demoData());
      await prefs.setBool(_seededKey, true);
    }
    return repo;
  }

  List<Tx> loadAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final list = (jsonDecode(raw) as List)
        .map((e) => Tx.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveAll(List<Tx> transactions) async {
    final raw = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await _prefs.setString(_key, raw);
  }

  /// Демо-данные первого запуска: пример живого месяца, чтобы дашборд
  /// и аналитика сразу были наглядными. Удаляются как обычные операции.
  static List<Tx> _demoData() {
    final rng = Random(7);
    final now = DateTime.now();
    final txs = <Tx>[];
    var id = 0;
    String nextId() => 'demo-${id++}';

    void spend(int daysAgo, TxCategory cat, double amount, [String note = '']) {
      txs.add(Tx(
        id: nextId(),
        type: TxType.expense,
        amount: amount,
        categoryId: cat.id,
        date: DateTime(now.year, now.month, now.day - daysAgo,
            9 + rng.nextInt(12), rng.nextInt(60)),
        note: note,
      ));
    }

    void earn(int daysAgo, TxCategory cat, double amount, [String note = '']) {
      txs.add(Tx(
        id: nextId(),
        type: TxType.income,
        amount: amount,
        categoryId: cat.id,
        date: DateTime(now.year, now.month, now.day - daysAgo, 10),
        note: note,
      ));
    }

    earn(21, Categories.salary, 145000, 'Аванс');
    earn(6, Categories.salary, 145000, 'Зарплата');
    earn(12, Categories.freelance, 30000, 'Проект на стороне');

    for (var d = 0; d < 28; d++) {
      if (d % 2 == 0) {
        spend(d, Categories.groceries, 700 + rng.nextInt(1800).toDouble());
      }
      if (d % 3 == 0) {
        spend(d, Categories.transport, 120 + rng.nextInt(400).toDouble());
      }
      if (d % 5 == 1) {
        spend(d, Categories.cafe, 900 + rng.nextInt(2200).toDouble());
      }
    }
    spend(2, Categories.entertainment, 1800, 'Кино');
    spend(4, Categories.shopping, 6400, 'Кроссовки');
    spend(9, Categories.health, 3200, 'Аптека');
    spend(15, Categories.home, 8900, 'Коммуналка');
    spend(18, Categories.entertainment, 2500, 'Концерт');
    spend(24, Categories.shopping, 4300, 'Подарок');

    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }
}
