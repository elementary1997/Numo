import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/backup.dart';
import 'package:numo/data/security_repository.dart';
import 'package:numo/data/sync_service.dart';
import 'package:numo/models/category.dart';
import 'package:numo/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecurityRepository', () {
    test('PIN устанавливается, проверяется и снимается', () async {
      SharedPreferences.setMockInitialValues({});
      final security = await SecurityRepository.open();
      expect(security.hasPin, isFalse);

      await security.setPin('4821');
      expect(security.hasPin, isTrue);
      expect(security.verify('4821'), isTrue);
      expect(security.verify('0000'), isFalse);

      await security.clear();
      expect(security.hasPin, isFalse);
      expect(security.verify('4821'), isFalse);
    });

    test('PIN не хранится открытым текстом', () async {
      SharedPreferences.setMockInitialValues({});
      final security = await SecurityRepository.open();
      await security.setPin('4821');
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys()) {
        expect('${prefs.get(key)}', isNot(contains('4821')));
      }
    });
  });

  group('SyncService', () {
    late Directory tmp;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tmp = await Directory.systemTemp.createTemp('numo-sync-test');
    });

    tearDown(() => tmp.delete(recursive: true));

    BackupData data(int txCount) => BackupData(
          transactions: [
            for (var i = 0; i < txCount; i++)
              Tx(
                id: 'tx-$i',
                type: TxType.expense,
                amount: 100,
                categoryId: 'other',
                date: DateTime(2026, 8, 1 + i),
              ),
          ],
          categories: Categories.defaults,
        );

    test('запись и отсутствие «новее» для собственного файла', () async {
      final sync = await SyncService.open();
      await sync.setDirectory(tmp.path);
      await sync.writeNow(data(2));

      expect(
          File('${tmp.path}/${SyncService.fileName}').existsSync(), isTrue);
      // Свой собственный файл не предлагается к принятию.
      expect(await sync.checkForNewer(), isNull);
    });

    test('файл с другого устройства (новее) предлагается к принятию',
        () async {
      final sync = await SyncService.open();
      await sync.setDirectory(tmp.path);
      await sync.writeNow(data(1));

      // «Другое устройство» записало файл позже.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      final foreign = Backup.encode(data(5));
      File('${tmp.path}/${SyncService.fileName}')
          .writeAsStringSync(foreign);

      final newer = await sync.checkForNewer();
      expect(newer, isNotNull);
      expect(newer!.$1.transactions, hasLength(5));

      await sync.markAccepted(newer.$2);
      expect(await sync.checkForNewer(), isNull);
    });

    test('без папки синхронизация молчит', () async {
      final sync = await SyncService.open();
      expect(await sync.checkForNewer(), isNull);
      // scheduleWrite без папки — no-op, не бросает.
      sync.scheduleWrite(() => data(1));
    });
  });
}
