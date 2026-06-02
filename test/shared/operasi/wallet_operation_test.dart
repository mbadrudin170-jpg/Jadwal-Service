// path: test/shared/operasi/wallet_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';

import 'wallet_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, BaseOperation, Database, Transaction])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late WalletOperation walletOperation;
  late MockTransaction mockTransaction;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    walletOperation = WalletOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('WalletOperation Tests', () {
    final tWallet = WalletModel(
      id: '1',
      name: 'Main Wallet',
      balance: 1000000,
      updatedAt: DateTime.now(),
    );
    final tWalletMap = tWallet.toSqlite();
    final tableName = TableNameValue.get(TableName.wallet);

    test('getWallets should return a list of wallets', () async {
      when(mockDatabase.query(any, where: anyNamed('where')))
          .thenAnswer((_) async => [tWalletMap]);

      final result = await walletOperation.getWallets();

      expect(result, isA<List<WalletModel>>());
      expect(result.length, 1);
      expect(result.first.id, tWallet.id);
      verify(mockDatabase.query(tableName, where: anyNamed('where'))).called(1);
    });

    test('createWallet should call insert on baseOperation', () {
      when(mockBaseOperation.insert(any, any))
          .thenAnswer((_) async => Future.value());

      walletOperation.createWallet(tWallet);

      verify(mockBaseOperation.insert(tableName, any)).called(1);
    });

    test('updateWallet should call update on baseOperation', () {
      when(mockBaseOperation.update(any, any, any))
          .thenAnswer((_) async => Future.value());

      walletOperation.updateWallet(tWallet);

      verify(mockBaseOperation.update(tableName, any, tWallet.id)).called(1);
    });

    test('softDelete should call softDelete on baseOperation', () {
      when(mockBaseOperation.softDelete(any, any))
          .thenAnswer((_) async => Future.value());

      walletOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(tableName, '1')).called(1);
    });

    test('deleteAllWallets should run a complex operation to delete all',
        () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0]
            as Future<void> Function(Transaction);
        when(mockTransaction.delete(any)).thenAnswer((_) async => 1);
        await action(mockTransaction);
      });

      await walletOperation.deleteAllWallets();

      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
    });

    test(
        'insertOrUpdateBatch should call insertOrUpdateBatch on baseOperation', () {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async => Future.value());

      walletOperation.insertOrUpdateBatch([tWallet]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}
