import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  final repository = await TransactionsRepository.open(database);
  final categoriesRepository = await CategoriesRepository.open(database);
  final budgetsRepository = await BudgetsRepository.open(database);
  final recurringRepository = await RecurringRepository.open(database);
  final accountsRepository = await AccountsRepository.open(database);
  final rulesRepository = await RulesRepository.open(database);
  final securityRepository = await SecurityRepository.open();
  final syncService = await SyncService.open();
  final onboarded = (await SharedPreferences.getInstance())
          .getBool(onboardedKey) ??
      false;
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
    return MaterialApp(
      title: 'Numo',
      debugShowCheckedModeBanner: false,
      theme: NumoTheme.light(),
      darkTheme: NumoTheme.dark(),
      themeMode: ThemeMode.system,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: locked
          ? const LockScreen()
          : !onboarded
              ? const OnboardingScreen()
              : const SyncRoot(child: HomeShell()),
    );
  }
}
