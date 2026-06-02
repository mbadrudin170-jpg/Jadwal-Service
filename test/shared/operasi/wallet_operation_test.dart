// path: test/shared/operasi/wallet_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<WalletModel> baseOperation;
  late WalletOperation walletOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<WalletModel>(mockDatabase, 'wallets');
    walletOperation = WalletOperation(baseOperation);
  });

  group('WalletOperation Tests', () {
    final tWallet = WalletModel(
      id: '1',
      name: 'Main Wallet',
      balance: 1000000,
    );

    test('getWallets should return a list of wallets', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tWallet.toMap()]);

      final result = await walletOperation.getWallets();

      expect(result, isA<List<WalletModel>>());
      expect(result.length, 1);
      expect(result.first.id, tWallet.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getWalletById should return a single wallet', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tWallet.toMap());

      final result = await walletOperation.getWalletById('1');

      expect(result, isA<WalletModel>());
      expect(result?.id, tWallet.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertWallet should insert a new wallet', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await walletOperation.insertWallet(tWallet);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateWallet should update an existing wallet', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await walletOperation.updateWallet(tWallet.id, tWallet);

      expect(result, 1);
      verify(baseOperation.update(tWallet.id, any)).called(1);
    });

    test('deleteWallet should delete a wallet', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await walletOperation.deleteWallet('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
