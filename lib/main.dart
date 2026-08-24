import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'data/budgets_repository.dart';
import 'data/categories_repository.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'state/providers.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final database = NumoDatabase();
  final repository = await TransactionsRepository.open(database);
  final categoriesRepository = await CategoriesRepository.open(database);
  final budgetsRepository = await BudgetsRepository.open(database);
  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        categoriesRepositoryProvider.overrideWithValue(categoriesRepository),
        budgetsRepositoryProvider.overrideWithValue(budgetsRepository),
      ],
      child: const NumoApp(),
    ),
  );
}

class NumoApp extends ConsumerWidget {
  const NumoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      home: const HomeShell(),
    );
  }
}
