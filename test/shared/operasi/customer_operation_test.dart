// path: test/shared/operasi/customer_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';

import 'customer_operation_test.mocks.dart';

@GenerateMocks([
  DatabaseHelper,
  Database,
  BaseOperation,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockBaseOperation mockBaseOperation;
  late CustomerOperation customerOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockBaseOperation = MockBaseOperation();
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    customerOperation = CustomerOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
  });

  group('CustomerOperation', () {
    final tCustomer = CustomerModel(
      id: '1',
      name: 'Test Customer',
      phone: '1234567890',
      address: 'Test Address',
      password: 'password',
    );
    final tCustomerMap = tCustomer.toSqlite();

    test('add should insert a new customer', () async {
      when(mockBaseOperation.insert(any, any)).thenAnswer((_) async => 1);

      await customerOperation.add(tCustomer);

      verify(mockBaseOperation.insert(any, any)).called(1);
    });

    test('getAll should return a list of customers', () async {
      when(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tCustomerMap]);

      final result = await customerOperation.getAll();

      expect(result, isA<List<CustomerModel>>());
      expect(result.first.id, tCustomer.id);
    });

    test('getById should return a customer', () async {
      when(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tCustomerMap]);

      final result = await customerOperation.getById('1');

      expect(result, isA<CustomerModel>());
      expect(result?.id, tCustomer.id);
    });

    test('updateCustomer should update an existing customer', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await customerOperation.updateCustomer(tCustomer);

      verify(mockBaseOperation.update(any, any, any)).called(1);
    });

    test('softDelete should soft delete a customer', () async {
      when(mockBaseOperation.softDelete(any, any)).thenAnswer((_) async {});

      await customerOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(any, '1')).called(1);
    });
  });
}
