import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numo/data/security_repository.dart';
import 'package:numo/l10n/app_localizations.dart';
import 'package:numo/screens/settings_sheets.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Диалог PIN: единственный путь, которым пользователь включает,
/// меняет и снимает защиту приложения.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('ru');
  });

  late SecurityRepository security;

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        securityRepositoryProvider.overrideWithValue(security),
        localeOverrideProvider.overrideWith((ref) => 'ru'),
      ],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showSecurityDialog(context, ref),
                child: const Text('открыть'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();
  }

  /// Вводит PIN в открытый диалог и жмёт «Далее».
  Future<void> typePin(WidgetTester tester, String pin) async {
    await tester.enterText(find.byType(TextField), pin);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    security = await SecurityRepository.open();
  });

  testWidgets('PIN устанавливается после подтверждения', (tester) async {
    await openDialog(tester);
    expect(find.text('Новый PIN (4–6 цифр)'), findsOneWidget);

    await typePin(tester, '1234');
    expect(find.text('Повторите PIN'), findsOneWidget);
    await typePin(tester, '1234');

    expect(security.hasPin, isTrue);
    expect(security.verify('1234'), isTrue);
    expect(find.text('PIN установлен'), findsOneWidget);
  });

  testWidgets('несовпавший повтор не сохраняет PIN', (tester) async {
    await openDialog(tester);
    await typePin(tester, '1234');
    await typePin(tester, '9999');

    expect(security.hasPin, isFalse);
    expect(find.text('PIN не совпал — не сохранён'), findsOneWidget);
  });

  testWidgets('короткий PIN не принимается', (tester) async {
    await openDialog(tester);
    await tester.enterText(find.byType(TextField), '12');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    // Диалог не закрылся, PIN не установлен.
    expect(find.text('Новый PIN (4–6 цифр)'), findsOneWidget);
    expect(security.hasPin, isFalse);
  });

  testWidgets('снять PIN можно только зная текущий', (tester) async {
    await security.setPin('1234');

    await openDialog(tester);
    await tester.tap(find.text('Отключить PIN'));
    await tester.pumpAndSettle();

    await typePin(tester, '9999');
    expect(security.hasPin, isTrue, reason: 'чужой PIN не снимает защиту');
    expect(find.text('Неверный PIN'), findsOneWidget);

    await openDialog(tester);
    await tester.tap(find.text('Отключить PIN'));
    await tester.pumpAndSettle();
    await typePin(tester, '1234');
    expect(security.hasPin, isFalse);
  });
}
