import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/self_updater_io.dart';
import 'package:numo/data/update_service.dart';
import 'package:numo/models/account.dart';

void main() {
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
