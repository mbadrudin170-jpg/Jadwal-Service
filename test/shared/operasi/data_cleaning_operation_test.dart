// path: test/shared/operasi/data_cleaning_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/operasi/data_cleaning_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late DataCleaningOperation dataCleaningOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    dataCleaningOperation = DataCleaningOperation(mockDatabase);
  });

  group('DataCleaningOperation Tests', () {
    test('cleanAllData should delete all data from all tables', () async {
      // Stub the transaction method
      when(mockDatabase.transaction(any)).thenAnswer((realInvocation) async {
        final action = realInvocation.positionalArguments.first as Future Function(Transaction);
        final mockTransaction = MockTransaction();
        return await action(mockTransaction);
      });

      // Stub the delete method for each table
      when(mockDatabase.delete(any)).thenAnswer((_) async => 1);

      await dataCleaningOperation.cleanAllData();

      // Verify that delete was called for each table
      verify(mockDatabase.delete('customers')).called(1);
      verify(mockDatabase.delete('packages')).called(1);
      verify(mockDatabase.delete('active_customers')).called(1);
      verify(mockDatabase.delete('transactions')).called(1);
      verify(mockDatabase.delete('wallets')).called(1);
      verify(mockDatabase.delete('categories')).called(1);
      verify(mockDatabase.delete('sub_categories')).called(1);
      verify(mockDatabase.delete('orders')).called(1);
      verify(mockDatabase.delete('apk_versions')).called(1);
      verify(mockDatabase.delete('settings')).called(1);
      verify(mockDatabase.delete('feedback')).called(1);
      verify(mockDatabase.delete('upload_status')).called(1);
    });
  });
}

class MockTransaction extends Mock implements Transaction {}
