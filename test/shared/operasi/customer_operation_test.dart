// path: test/shared/operasi/customer_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<CustomerModel> baseOperation;
  late CustomerOperation customerOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<CustomerModel>(mockDatabase, 'customers');
    customerOperation = CustomerOperation(baseOperation);
  });

  group('CustomerOperation Tests', () {
    final tCustomer = CustomerModel(
      id: '1',
      name: 'John Doe',
      phoneNumber: '08123456789',
      address: '123 Main St',
    );

    test('getCustomers should return a list of customers', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tCustomer.toMap()]);

      final result = await customerOperation.getCustomers();

      expect(result, isA<List<CustomerModel>>());
      expect(result.length, 1);
      expect(result.first.id, tCustomer.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getCustomerById should return a single customer', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tCustomer.toMap());

      final result = await customerOperation.getCustomerById('1');

      expect(result, isA<CustomerModel>());
      expect(result?.id, tCustomer.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertCustomer should insert a new customer', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await customerOperation.insertCustomer(tCustomer);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateCustomer should update an existing customer', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await customerOperation.updateCustomer(tCustomer.id, tCustomer);

      expect(result, 1);
      verify(baseOperation.update(tCustomer.id, any)).called(1);
    });

    test('deleteCustomer should delete a customer', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await customerOperation.deleteCustomer('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
