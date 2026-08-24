import 'dart:ui' show Color;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numo/data/accounts_repository.dart';
import 'package:numo/data/database.dart';
import 'package:numo/data/rates_repository.dart';
import 'package:numo/data/repository.dart';
import 'package:numo/models/account.dart';
import 'package:numo/models/transaction.dart';
import 'package:numo/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sampleXml = '''
<ValCurs Date="22.08.2026" name="Foreign Currency Market">
<Valute ID="R01235">
<NumCode>840</NumCode>
<CharCode>USD</CharCode>
<Nominal>1</Nominal>
<Name>Доллар США</Name>
<Value>84,5000</Value>
<VunitRate>84,5</VunitRate>
</Valute>
<Valute ID="R01335">
<NumCode>398</NumCode>
<CharCode>KZT</CharCode>
<Nominal>100</Nominal>
<Name>Казахстанских тенге</Name>
<Value>16,2000</Value>
<VunitRate>0,162</VunitRate>
</Valute>
</ValCurs>
''';

class _FakeRates extends RatesRepository {
  _FakeRates(this.snapshot);

  final RatesSnapshot? snapshot;

  @override
  Future<RatesSnapshot?> load() async => snapshot;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parseCbrXml: курс за единицу с учётом номинала', () {
    final rates = RatesRepository.parseCbrXml(_sampleXml);
    expect(rates['USD'], 84.5);
    expect(rates['KZT'], closeTo(0.162, 0.0001));
  });

  test('netWorth конвертирует валютные счета по курсу ЦБ', () async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const usd = Account(
      id: 'usd',
      title: 'Долларовый',
      iconKey: 'savings',
      color: Color(0xFF4CC9F0),
      currency: 'USD',
    );
    final txRepo = await TransactionsRepository.open(db);
    await txRepo.saveAll([
      Tx(
        id: '1',
        type: TxType.income,
        amount: 1000,
        categoryId: 'salary',
        date: DateTime(2026, 8, 1),
        accountId: 'main',
      ),
      Tx(
        id: '2',
        type: TxType.income,
        amount: 10,
        categoryId: 'salary',
        date: DateTime(2026, 8, 2),
        accountId: 'usd',
      ),
    ]);
    final accountsRepo = await AccountsRepository.open(db);
    await accountsRepo.saveAll([Accounts.main, usd]);

    final container = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(txRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
      ratesRepositoryProvider.overrideWithValue(_FakeRates(RatesSnapshot(
        rates: const {'USD': 84.5},
        fetchedAt: DateTime(2026, 8, 24),
      ))),
    ]);
    addTearDown(container.dispose);

    await container.read(ratesProvider.future);
    final netWorth = container.read(netWorthProvider);
    expect(netWorth.value, closeTo(1000 + 10 * 84.5, 0.01));
    expect(netWorth.approximate, isTrue);
    expect(netWorth.unconverted, isEmpty);
  });

  test('без курсов валютный счёт исключается и помечается', () async {
    SharedPreferences.setMockInitialValues({
      'numo.transactions.migrated-to-drift.v1': true,
    });
    final db = NumoDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    const usd = Account(
      id: 'usd',
      title: 'Долларовый',
      iconKey: 'savings',
      color: Color(0xFF4CC9F0),
      currency: 'USD',
    );
    final txRepo = await TransactionsRepository.open(db);
    await txRepo.saveAll([
      Tx(
        id: '1',
        type: TxType.income,
        amount: 10,
        categoryId: 'salary',
        date: DateTime(2026, 8, 2),
        accountId: 'usd',
      ),
    ]);
    final accountsRepo = await AccountsRepository.open(db);
    await accountsRepo.saveAll([Accounts.main, usd]);

    final container = ProviderContainer(overrides: [
      repositoryProvider.overrideWithValue(txRepo),
      accountsRepositoryProvider.overrideWithValue(accountsRepo),
      ratesRepositoryProvider.overrideWithValue(_FakeRates(null)),
    ]);
    addTearDown(container.dispose);

    await container.read(ratesProvider.future);
    final netWorth = container.read(netWorthProvider);
    expect(netWorth.value, 0);
    expect(netWorth.unconverted, ['USD']);
  });
}
