import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'data/accounts_repository.dart';
import 'data/budgets_repository.dart';
import 'data/categories_repository.dart';
import 'data/database.dart';
import 'data/recurring_repository.dart';
import 'data/repository.dart';
import 'data/rules_repository.dart';
import 'data/security_repository.dart';
import 'data/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/lock.dart';
import 'screens/onboarding.dart';
import 'screens/sync_root.dart';
import 'state/providers.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final database = NumoDatabase();
  // Язык сидирования данных первого запуска — по языку системы.
  final seedLocale =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ru'
          ? 'ru'
          : 'en';
  final repository =
      await TransactionsRepository.open(database, seedLocale: seedLocale);
  final categoriesRepository =
      await CategoriesRepository.open(database, seedLocale: seedLocale);
  final budgetsRepository = await BudgetsRepository.open(database);
  final recurringRepository = await RecurringRepository.open(database);
  final accountsRepository =
      await AccountsRepository.open(database, seedLocale: seedLocale);
  final rulesRepository = await RulesRepository.open(database);
  final securityRepository = await SecurityRepository.open();
  final syncService = await SyncService.open();
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool(onboardedKey) ?? false;
  final localeOverride = prefs.getString('numo.locale');
  // Наступившие регулярные операции превращаются в реальные при запуске.
  await recurringRepository.materialize(repository);
  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        categoriesRepositoryProvider.overrideWithValue(categoriesRepository),
        budgetsRepositoryProvider.overrideWithValue(budgetsRepository),
        recurringRepositoryProvider.overrideWithValue(recurringRepository),
        accountsRepositoryProvider.overrideWithValue(accountsRepository),
        rulesRepositoryProvider.overrideWithValue(rulesRepository),
        securityRepositoryProvider.overrideWithValue(securityRepository),
        syncServiceProvider.overrideWithValue(syncService),
        onboardedProvider.overrideWith((ref) => onboarded),
        localeOverrideProvider.overrideWith((ref) => localeOverride),
      ],
      child: const NumoApp(),
    ),
  );
}

class NumoApp extends ConsumerWidget {
  const NumoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(lockedProvider);
    final onboarded = ref.watch(onboardedProvider);
    final localeOverride = ref.watch(localeOverrideProvider);
    return MaterialApp(
      title: 'Numo',
      debugShowCheckedModeBanner: false,
      theme: NumoTheme.light(),
      darkTheme: NumoTheme.dark(),
      themeMode: ThemeMode.system,
      locale: localeOverride == null ? null : Locale(localeOverride),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: locked
          ? const LockScreen()
          : !onboarded
              ? const OnboardingScreen()
              : const SyncRoot(child: HomeShell()),
    );
  }
}
