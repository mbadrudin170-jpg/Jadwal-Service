// path: test/shared/operasi/transaction_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<TransactionModel> baseOperation;
  late TransactionOperation transactionOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<TransactionModel>(mockDatabase, 'transactions');
    transactionOperation = TransactionOperation(baseOperation);
  });

  group('TransactionOperation Tests', () {
    final tTransaction = TransactionModel(
      id: '1',
      amount: 50000,
      date: DateTime.now(),
      description: 'Test transaction',
    );

    test('getTransactions should return a list of transactions', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tTransaction.toMap()]);

      final result = await transactionOperation.getTransactions();

      expect(result, isA<List<TransactionModel>>());
      expect(result.length, 1);
      expect(result.first.id, tTransaction.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getTransactionById should return a single transaction', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tTransaction.toMap());

      final result = await transactionOperation.getTransactionById('1');

      expect(result, isA<TransactionModel>());
      expect(result?.id, tTransaction.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertTransaction should insert a new transaction', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await transactionOperation.insertTransaction(tTransaction);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateTransaction should update an existing transaction', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await transactionOperation.updateTransaction(tTransaction.id, tTransaction);

      expect(result, 1);
      verify(baseOperation.update(tTransaction.id, any)).called(1);
    });

    test('deleteTransaction should delete a transaction', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await transactionOperation.deleteTransaction('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
