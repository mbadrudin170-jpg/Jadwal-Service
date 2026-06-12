// path: test/shared/operasi/transaction_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';

import 'transaction_operation_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOperation, Database, Transaction])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late TransactionOperation transactionOperation;
  late MockTransaction mockTransaction;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    transactionOperation = TransactionOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('TransactionOperation Tests', () {
    final tTransaction = TransactionModel(
      id: '1',
      amount: 50000,
      date: DateTime.now(),
      description: 'Test transaction',
      type: TransactionType.income,
      walletId: 'wallet1',
      categoryId: 'cat1',
      updatedAt: DateTime.now(),
    );
    final tTransactionMap = tTransaction.toSqlite();
    final tableName = TableNameValue.get(TableName.transactions);

    test('getAllTransactions should return a list of transactions', () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [tTransactionMap]);

      final result = await transactionOperation.getAllTransactions();

      expect(result, isA<List<TransactionModel>>());
      expect(result.length, 1);
      expect(result.first.id, tTransaction.id);
      verify(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
      )).called(1);
    });

    test(
        'addTransaction should call runComplexOperation and recalculate balances',
        () async {
      when(mockBaseOperation.runComplexOperation<int>(any))
          .thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<int>
            Function(Transaction);
        // Mock the inner transaction logic
        when(mockTransaction.insert(any, any,
                conflictAlgorithm: anyNamed('conflictAlgorithm')))
            .thenAnswer((_) async => 1);
        when(mockTransaction.rawQuery(any, any)).thenAnswer((_) async => [
              {'total': 1000.0}
            ]);
        when(mockTransaction.update(any, any,
                where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
            .thenAnswer((_) async => 1);

        return await action(mockTransaction);
      });

      await transactionOperation.addTransaction(tTransaction);

      verify(mockBaseOperation.runComplexOperation<int>(any)).called(1);
    });

    test(
        'updateTransaction should call runComplexOperation and recalculate balances',
        () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<void>
            Function(Transaction);

        when(mockTransaction.query(any,
                where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
            .thenAnswer((_) async => [tTransactionMap]);
        when(mockTransaction.update(any, any,
                where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
            .thenAnswer((_) async => 1);
        when(mockTransaction.rawQuery(any, any)).thenAnswer((_) async => [
              {'total': 1000.0}
            ]);

        return await action(mockTransaction);
      });

      await transactionOperation.updateTransaction('1', tTransaction);

      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
    });

    test('softDelete should call runComplexOperation and recalculate balances',
        () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        final action = invocation.positionalArguments[0] as Future<void>
            Function(Transaction);

        when(mockTransaction.query(any,
                where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
            .thenAnswer((_) async => [tTransactionMap]);
        when(mockTransaction.update(any, any,
                where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
            .thenAnswer((_) async => 1);
        when(mockTransaction.rawQuery(any, any)).thenAnswer((_) async => [
              {'total': 1000.0}
            ]);

        return await action(mockTransaction);
      });

      await transactionOperation.softDelete('1');

      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
    });
  });
}
