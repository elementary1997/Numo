import '../models/account.dart';
import '../models/category.dart';
import 'accounts_repository.dart';
import 'categories_repository.dart';

/// Переводит названия встроенных категорий и счёта по умолчанию на
/// [languageCode], не трогая переименованные пользователем. Вызывается
/// при запуске и при смене языка — чинит случай «засидировалось на
/// одном языке, интерфейс переключили на другой».
Future<void> relocalizeSeedData({
  required CategoriesRepository categories,
  required AccountsRepository accounts,
  required String languageCode,
}) async {
  var changed = false;
  final updatedCategories = [
    for (final c in categories.loadAll())
      if (Categories.isUntouchedDefault(c.id, c.title) &&
          Categories.defaultTitle(c.id, languageCode) != null &&
          Categories.defaultTitle(c.id, languageCode) != c.title)
        () {
          changed = true;
          return c.copyWith(
              title: Categories.defaultTitle(c.id, languageCode));
        }()
      else
        c,
  ];
  if (changed) await categories.saveAll(updatedCategories);

  var accountsChanged = false;
  final mainTitles = {Accounts.main.title, Accounts.mainEn.title};
  final updatedAccounts = [
    for (final a in accounts.loadAll())
      if (a.id == Accounts.main.id && mainTitles.contains(a.title))
        () {
          final target = Accounts.mainFor(languageCode).title;
          if (target != a.title) accountsChanged = true;
          return a.copyWith(title: target);
        }()
      else
        a,
  ];
  if (accountsChanged) await accounts.saveAll(updatedAccounts);
}
