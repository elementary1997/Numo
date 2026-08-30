import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:numo/data/self_updater_io.dart';
import 'package:numo/data/update_service.dart';
import 'package:numo/models/account.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SelfUpdater.macAppPathFor', () {
    test('транслоцированный путь заменяется на /Applications', () {
      expect(
        SelfUpdater.macAppPathFor(
            '/private/var/folders/ab/xyz/T/AppTranslocation/1234-5678/d/Numo.app'),
        '/Applications/Numo.app',
      );
    });

    test('обычный путь остаётся как есть', () {
      expect(SelfUpdater.macAppPathFor('/Applications/Numo.app'),
          '/Applications/Numo.app');
      expect(SelfUpdater.macAppPathFor('/Users/p/Apps/Numo.app'),
          '/Users/p/Apps/Numo.app');
    });
  });

  group('SelfUpdater.windowsUpdateScript', () {
    test('ждёт процесс и копирует файлы средствами PowerShell', () {
      final ps = SelfUpdater.windowsUpdateScript(
        pid: 4242,
        source: r'C:\Users\Павел\AppData\Local\Temp\numo-update-1\extracted',
        target: r'C:\Users\Павел\Numo',
      );

      expect(ps, contains('Wait-Process -Id 4242'));
      // robocopy: устойчивее Copy-Item на деревьях и повторяет попытки.
      expect(ps, contains('robocopy.exe'));
      // Код 8 и выше у robocopy — это ошибка копирования.
      expect(ps, contains(r'if ($robo.ExitCode -ge 8)'));
      expect(ps, contains('numo-update.log'));
      // Приложение поднимается даже при неудачной подмене.
      expect(ps, contains('finally'));
      expect(ps, contains('Start-Process'));
      // Кириллица в пути должна дожить до скрипта как есть.
      expect(ps, contains('Павел'));
      // Старый .bat падал на этих командах при кириллице в %TEMP%.
      expect(ps, isNot(contains('tasklist')));
      expect(ps, isNot(contains('timeout /T')));
    });

    test('одинарная кавычка в пути экранируется', () {
      final ps = SelfUpdater.windowsUpdateScript(
        pid: 1,
        source: r"C:\Users\O'Brien\tmp",
        target: r"C:\Users\O'Brien\Numo",
      );
      expect(ps, contains("O''Brien"));
    });
  });

  group('platformAssetName', () {
    test('выбирает архив своей платформы', () {
      expect(platformAssetName(platformOverride: 'windows'),
          'numo-windows-x64.zip');
      expect(platformAssetName(platformOverride: 'macos'), 'numo-macos.zip');
      expect(platformAssetName(platformOverride: 'linux'),
          'numo-linux-x64.tar.gz');
      expect(platformAssetName(platformOverride: 'web'), isNull);
    });
  });

  group('UpdateService.isNewerVersion', () {
    test('сравнивает semver по компонентам', () {
      expect(UpdateService.isNewerVersion('1.0.1', '1.0.0'), isTrue);
      expect(UpdateService.isNewerVersion('1.1.0', '1.0.9'), isTrue);
      expect(UpdateService.isNewerVersion('2.0.0', '1.9.9'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(UpdateService.isNewerVersion('0.9.0', '1.0.0'), isFalse);
    });

    test('игнорирует build-суффикс', () {
      expect(UpdateService.isNewerVersion('1.0.1', '1.0.0+7'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0', '1.0.0+7'), isFalse);
    });
  });

  group('UpdateService.check', () {
    // Архивы всех платформ, чтобы тест работал на любом хосте CI.
    const releaseJson = '{"tag_name": "v9.9.9",'
        '"html_url": "https://github.com/elementary1997/Numo/releases/tag/v9.9.9",'
        '"assets": ['
        '{"name": "numo-macos.zip", "browser_download_url": "https://dl/numo-macos.zip"},'
        '{"name": "numo-linux-x64.tar.gz", "browser_download_url": "https://dl/numo-linux-x64.tar.gz"},'
        '{"name": "numo-windows-x64.zip", "browser_download_url": "https://dl/numo-windows-x64.zip"}'
        ']}';

    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'Numo',
        packageName: 'numo',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    });

    UpdateService serviceCounting(void Function() onHit) =>
        UpdateService(client: MockClient((_) async {
          onHit();
          return http.Response(releaseJson, 200);
        }));

    test('находит новый релиз вместе со ссылкой на архив платформы',
        () async {
      SharedPreferences.setMockInitialValues({});
      final info = await serviceCounting(() {}).check();
      expect(info!.version, '9.9.9');
      expect(info.assetUrl, startsWith('https://dl/numo-'));
    });

    test('в пределах TTL сеть не трогается, архив сохраняется в кэше',
        () async {
      SharedPreferences.setMockInitialValues({});
      var hits = 0;
      final service = serviceCounting(() => hits++);
      await service.check();
      final cached = await service.check();
      expect(hits, 1);
      expect(cached!.version, '9.9.9');
      expect(cached.assetUrl, startsWith('https://dl/numo-'));
    });

    test('просроченный кэш перечитывается из сети', () async {
      SharedPreferences.setMockInitialValues({
        'numo.updates.lastCheck': DateTime.now()
            .subtract(UpdateService.cacheTtl + const Duration(minutes: 1))
            .toIso8601String(),
        'numo.updates.latestVersion': '1.0.0',
        'numo.updates.latestUrl': 'https://old',
      });
      var hits = 0;
      final info = await serviceCounting(() => hits++).check();
      expect(hits, 1);
      expect(info!.version, '9.9.9');
    });
  });

  group('Account.projectedAtClose', () {
    final deposit = Account(
      id: 'dep',
      title: 'Вклад',
      iconKey: 'savings',
      color: const Color(0xFF3DDC97),
      kind: AccountKind.deposit,
      rate: 20,
      openedAt: DateTime(2026, 1, 1),
      closesAt: DateTime(2027, 1, 1),
    );

    test('простые проценты за срок вклада', () {
      // 100 000 под 20% годовых на 365 дней ≈ 120 000.
      expect(deposit.projectedAtClose(100000), closeTo(120000, 100));
    });

    test('обычный счёт и вклад без ставки прогноза не дают', () {
      const regular = Account(
        id: 'a',
        title: 'Карта',
        iconKey: 'card',
        color: Color(0xFF7C5CFF),
      );
      expect(regular.projectedAtClose(1000), isNull);
      expect(
          deposit.copyWith(kind: AccountKind.card).projectedAtClose(1000),
          isNull);
    });

    test('JSON round-trip сохраняет поля вклада', () {
      final restored = Account.fromJson(deposit.toJson());
      expect(restored.kind, AccountKind.deposit);
      expect(restored.rate, 20);
      expect(restored.openedAt, DateTime(2026, 1, 1));
      expect(restored.closesAt, DateTime(2027, 1, 1));
    });
  });
}
