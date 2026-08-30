import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numo/data/startup.dart';
import 'package:numo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Медленная подготовка: пока она идёт, пользователь должен видеть
/// окно, а не пустоту.
class _SlowStartup extends Startup {
  @override
  Future<List<Override>> run() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    throw StateError('slow');
  }

  @override
  void writeLog({Object? error}) {}
}

/// Подготовка, падающая на конкретном шаге.
class _FailingStartup extends Startup {
  int attempts = 0;

  @override
  String get currentStep => 'transactions';

  @override
  Future<List<Override>> run() async {
    attempts++;
    throw StateError('database is locked');
  }

  @override
  void writeLog({Object? error}) {}
}

/// Запуск приложения: окно появляется сразу, а подготовка хранилищ
/// идёт уже под ним. Раньше она шла до runApp, и любая заминка
/// оставляла пользователя с висящим процессом без единого окна.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('ru');
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('пока данные готовятся, видно окно с индикатором',
      (tester) async {
    await tester.pumpWidget(NumoBootstrap(startup: _SlowStartup()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Даём подготовке завершиться, чтобы тест не оставлял таймеров.
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('неудачная подготовка объясняет себя, а не молчит',
      (tester) async {
    final startup = _FailingStartup();
    await tester.pumpWidget(NumoBootstrap(startup: startup));
    await tester.pumpAndSettle();

    expect(find.text('Numo не смог открыть данные'), findsOneWidget);
    // Видно, на каком шаге встало и что именно случилось.
    expect(find.textContaining('Шаг: transactions'), findsOneWidget);
    expect(find.textContaining('database is locked'), findsOneWidget);
    // И можно попробовать снова, не перезапуская приложение.
    expect(find.text('Повторить'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(startup.attempts, 2);
  });
}
