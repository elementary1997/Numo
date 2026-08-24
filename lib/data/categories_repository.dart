import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';

/// Хранилище категорий. При первом запуске сидируется встроенным
/// набором [Categories.defaults]; дальше единственный источник
/// правды — этот репозиторий.
class CategoriesRepository {
  CategoriesRepository._(this._prefs);

  static const _key = 'numo.categories.v1';

  final SharedPreferences _prefs;

  static Future<CategoriesRepository> open() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = CategoriesRepository._(prefs);
    if (!prefs.containsKey(_key)) {
      await repo.saveAll(Categories.defaults);
    }
    return repo;
  }

  List<TxCategory> loadAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return Categories.defaults;
    return (jsonDecode(raw) as List)
        .map((e) => TxCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<TxCategory> categories) async {
    final raw = jsonEncode(categories.map((c) => c.toJson()).toList());
    await _prefs.setString(_key, raw);
  }
}
