import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numo/data/security_repository.dart';
import 'package:numo/l10n/app_localizations.dart';
import 'package:numo/screens/lock.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Экран блокировки — единственная преграда между посторонним и всеми
/// финансами пользователя, поэтому проверяется отдельно.
Future<Widget> buildLockScreen(SecurityRepository security) async =>
    ProviderScope(
      overrides: [
        securityRepositoryProvider.overrideWithValue(security),
        localeOverrideProvider.overrideWith((ref) => 'ru'),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LockScreen(),
      ),
    );

/// Нажимает цифры PIN по одной.
Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.widgetWithText(InkWell, digit).first);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('ru');
  });

  late SecurityRepository security;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    security = await SecurityRepository.open();
    await security.setPin('1234');
  });

  testWidgets('верный PIN снимает блокировку', (tester) async {
    await tester.pumpWidget(await buildLockScreen(security));
    await tester.pumpAndSettle();

    final scope = ProviderScope.containerOf(
        tester.element(find.byType(LockScreen)));
    expect(scope.read(lockedProvider), isTrue);

    await enterPin(tester, '1234');
    expect(scope.read(lockedProvider), isFalse);
  });

  testWidgets('неверный PIN не пускает и сообщает об ошибке',
      (tester) async {
    await tester.pumpWidget(await buildLockScreen(security));
    await tester.pumpAndSettle();

    final scope = ProviderScope.containerOf(
        tester.element(find.byType(LockScreen)));

    await enterPin(tester, '9999');
    expect(scope.read(lockedProvider), isTrue);
    expect(find.text('Неверный PIN, попробуйте ещё раз'), findsOneWidget);

    // После ошибки ввод сбрасывается — следующий верный код работает.
    await enterPin(tester, '1234');
    expect(scope.read(lockedProvider), isFalse);
  });

  testWidgets('незаконченный ввод не разблокирует', (tester) async {
    await tester.pumpWidget(await buildLockScreen(security));
    await tester.pumpAndSettle();

    final scope = ProviderScope.containerOf(
        tester.element(find.byType(LockScreen)));

    await enterPin(tester, '12');
    expect(scope.read(lockedProvider), isTrue);
  });

  test('PIN хранится хэшем с солью, а не в открытом виде', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = await SecurityRepository.open();
    await repo.setPin('4321');

    expect(repo.verify('4321'), isTrue);
    expect(repo.verify('1234'), isFalse);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getKeys()
        .map((k) => prefs.get(k)?.toString() ?? '')
        .join('|');
    expect(stored.contains('4321'), isFalse,
        reason: 'PIN не должен лежать в prefs открытым текстом');
  });
}
