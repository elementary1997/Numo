import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'data/categories_repository.dart';
import 'data/repository.dart';
import 'state/providers.dart';
import 'screens/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  final repository = await TransactionsRepository.open();
  final categoriesRepository = await CategoriesRepository.open();
  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
        categoriesRepositoryProvider.overrideWithValue(categoriesRepository),
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
