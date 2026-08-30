import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/onboarding.dart' show onboardedKey;
import '../state/providers.dart';
import 'accounts_repository.dart';
import 'budgets_repository.dart';
import 'categories_repository.dart';
import 'database.dart';
import 'goals_repository.dart';
import 'imports_repository.dart';
import 'members_repository.dart';
import 'recurring_repository.dart';
import 'repository.dart';
import 'rules_repository.dart';
import 'seed_localization.dart';
import 'security_repository.dart';
import 'shared_sync.dart';
import 'sync_service.dart';

/// Что случилось при подготовке приложения к запуску.
class StartupFailure {
  const StartupFailure({required this.step, required this.error});

  /// Последний начатый шаг — по нему видно, где всё встало.
  final String step;
  final Object error;
}

/// Готовит хранилища и настройки. Раньше это происходило в `main()` до
/// `runApp`, и любая заминка оставляла пользователя с висящим процессом
/// без окна: показывать было нечего. Теперь окно появляется сразу, а
/// подготовка идёт под присмотром — с логом шагов и общим сроком.
class Startup {
  /// Дальше ждать бессмысленно: столько не занимает даже миграция
  /// большой базы, значит что-то держит нас навсегда.
  static const timeout = Duration(seconds: 45);

  final _steps = <String>[];
  String _current = 'start';

  /// Пройденные шаги — попадают в лог и на экран ошибки.
  List<String> get steps => List.unmodifiable(_steps);
  String get currentStep => _current;

  Future<T> _step<T>(String name, Future<T> Function() action) async {
    _current = name;
    final result = await action();
    _steps.add(name);
    return result;
  }

  /// Готовит приложение и возвращает overrides для ProviderScope.
  Future<List<Override>> run() async {
    final database = await _step('database', () async => NumoDatabase());
    final seedLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ru'
            ? 'ru'
            : 'en';

    // Демо-данные — только в dev-сборках.
    final repository = await _step(
        'transactions',
        () => TransactionsRepository.open(database,
            seedLocale: seedLocale, seedDemo: !kReleaseMode));
    final categories = await _step('categories',
        () => CategoriesRepository.open(database, seedLocale: seedLocale));
    final budgets =
        await _step('budgets', () => BudgetsRepository.open(database));
    final recurring =
        await _step('recurring', () => RecurringRepository.open(database));
    final accounts = await _step('accounts',
        () => AccountsRepository.open(database, seedLocale: seedLocale));
    final rules = await _step('rules', () => RulesRepository.open(database));
    final goals = await _step('goals', () => GoalsRepository.open(database));
    final imports =
        await _step('imports', () => ImportsRepository.open(database));
    final security =
        await _step('security', () => SecurityRepository.open());
    final members = await _step(
        'members',
        () => MembersRepository.open(database,
            meName: seedLocale == 'ru' ? 'Я' : 'Me'));
    final sync = await _step('sync', () => SyncService.open());
    final sharedSync =
        await _step('shared-sync', () => SharedSyncService.open());

    final prefs =
        await _step('preferences', () => SharedPreferences.getInstance());
    final localeOverride = prefs.getString('numo.locale');

    // Наступившие регулярные операции превращаются в реальные.
    await _step('recurring-materialize',
        () => recurring.materialize(repository));
    // Названия встроенных категорий и счёта следуют языку.
    await _step(
        'relocalize',
        () => relocalizeSeedData(
              categories: categories,
              accounts: accounts,
              languageCode: localeOverride ?? seedLocale,
            ));

    _current = 'ready';
    return [
      repositoryProvider.overrideWithValue(repository),
      categoriesRepositoryProvider.overrideWithValue(categories),
      budgetsRepositoryProvider.overrideWithValue(budgets),
      recurringRepositoryProvider.overrideWithValue(recurring),
      accountsRepositoryProvider.overrideWithValue(accounts),
      rulesRepositoryProvider.overrideWithValue(rules),
      goalsRepositoryProvider.overrideWithValue(goals),
      importsRepositoryProvider.overrideWithValue(imports),
      securityRepositoryProvider.overrideWithValue(security),
      membersRepositoryProvider.overrideWithValue(members),
      syncServiceProvider.overrideWithValue(sync),
      sharedSyncProvider.overrideWithValue(sharedSync),
      onboardedProvider
          .overrideWith((ref) => prefs.getBool(onboardedKey) ?? false),
      localeOverrideProvider.overrideWith((ref) => localeOverride),
      themeOverrideProvider
          .overrideWith((ref) => prefs.getString('numo.theme')),
      accentColorProvider.overrideWith((ref) => prefs.getInt('numo.accent')),
      uiScaleProvider
          .overrideWith((ref) => prefs.getDouble('numo.uiScale') ?? 1.0),
      dismissedUpdateProvider.overrideWith(
          (ref) => prefs.getString('numo.updates.dismissedVersion')),
      notificationsEnabledProvider.overrideWith(
          (ref) => prefs.getBool('numo.notifications.enabled') ?? false),
    ];
  }

  /// Пишет ход запуска рядом с логом обновления — если приложение
  /// однажды не откроется, будет видно, на каком шаге это случилось.
  void writeLog({Object? error}) {
    if (kIsWeb) return;
    try {
      final dir = Platform.isWindows
          ? (Platform.environment['TEMP'] ?? r'C:\Windows\Temp')
          : '/tmp';
      File('$dir/numo-startup.log').writeAsStringSync([
        DateTime.now().toIso8601String(),
        'steps: ${_steps.join(' → ')}',
        'stopped at: $_current',
        if (error != null) 'error: $error',
      ].join('\n'));
    } catch (_) {
      // Лог — вспомогательный: не смог записать, и ладно.
    }
  }
}
