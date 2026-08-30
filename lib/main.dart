import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'core/ui_scale.dart';
import 'data/accounts_repository.dart';
import 'data/budgets_repository.dart';
import 'data/categories_repository.dart';
import 'data/database.dart';
import 'data/goals_repository.dart';
import 'data/members_repository.dart';
import 'data/imports_repository.dart';
import 'data/recurring_repository.dart';
import 'data/repository.dart';
import 'data/rules_repository.dart';
import 'data/seed_localization.dart';
import 'data/security_repository.dart';
import 'data/shared_sync.dart';
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
  // Демо-данные — только в dev-сборках; релизы начинаются с чистого
  // состояния.
  final repository = await TransactionsRepository.open(database,
      seedLocale: seedLocale, seedDemo: !kReleaseMode);
  final categoriesRepository =
      await CategoriesRepository.open(database, seedLocale: seedLocale);
  final budgetsRepository = await BudgetsRepository.open(database);
  final recurringRepository = await RecurringRepository.open(database);
  final accountsRepository =
      await AccountsRepository.open(database, seedLocale: seedLocale);
  final rulesRepository = await RulesRepository.open(database);
  final goalsRepository = await GoalsRepository.open(database);
  final importsRepository = await ImportsRepository.open(database);
  final securityRepository = await SecurityRepository.open();
  final membersRepository = await MembersRepository.open(database,
      meName: seedLocale == 'ru' ? 'Я' : 'Me');
  final syncService = await SyncService.open();
  final sharedSync = await SharedSyncService.open();
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool(onboardedKey) ?? false;
  final localeOverride = prefs.getString('numo.locale');
  final themeOverride = prefs.getString('numo.theme');
  final accentColor = prefs.getInt('numo.accent');
  final uiScale = prefs.getDouble('numo.uiScale') ?? 1.0;
  // Наступившие регулярные операции превращаются в реальные при запуске.
  await recurringRepository.materialize(repository);
  // Названия встроенных категорий/счёта следуют текущему языку.
  await relocalizeSeedData(
    categories: categoriesRepository,
    accounts: accountsRepository,
    languageCode: localeOverride ?? seedLocale,
  );
  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        categoriesRepositoryProvider.overrideWithValue(categoriesRepository),
        budgetsRepositoryProvider.overrideWithValue(budgetsRepository),
        recurringRepositoryProvider.overrideWithValue(recurringRepository),
        accountsRepositoryProvider.overrideWithValue(accountsRepository),
        rulesRepositoryProvider.overrideWithValue(rulesRepository),
        goalsRepositoryProvider.overrideWithValue(goalsRepository),
        importsRepositoryProvider.overrideWithValue(importsRepository),
        securityRepositoryProvider.overrideWithValue(securityRepository),
        membersRepositoryProvider.overrideWithValue(membersRepository),
        syncServiceProvider.overrideWithValue(syncService),
        sharedSyncProvider.overrideWithValue(sharedSync),
        onboardedProvider.overrideWith((ref) => onboarded),
        localeOverrideProvider.overrideWith((ref) => localeOverride),
        themeOverrideProvider.overrideWith((ref) => themeOverride),
        accentColorProvider.overrideWith((ref) => accentColor),
        uiScaleProvider.overrideWith((ref) => uiScale),
      ],
      child: const NumoApp(),
    ),
  );
}

/// На desktop горизонтальные списки должны таскаться и мышью.
class _NumoScrollBehavior extends MaterialScrollBehavior {
  const _NumoScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class NumoApp extends ConsumerWidget {
  const NumoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = ref.watch(lockedProvider);
    final onboarded = ref.watch(onboardedProvider);
    final localeOverride = ref.watch(localeOverrideProvider);
    final themeOverride = ref.watch(themeOverrideProvider);
    final accentValue = ref.watch(accentColorProvider);
    final accent =
        accentValue == null ? NumoColors.violet : Color(accentValue);
    final uiScale = ref.watch(uiScaleProvider);
    return MaterialApp(
      title: 'Numo',
      scrollBehavior: const _NumoScrollBehavior(),
      // Масштаб интерфейса: см. UiScaler (lib/core/ui_scale.dart).
      builder: (context, child) =>
          UiScaler(scale: uiScale, child: child ?? const SizedBox()),
      debugShowCheckedModeBanner: false,
      theme: NumoTheme.light(accent),
      darkTheme: NumoTheme.dark(accent),
      themeMode: switch (themeOverride) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
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
