// path: test/shared/operasi/active_customer_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<ActiveCustomerModel> baseOperation;
  late ActiveCustomerOperation activeCustomerOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation =
        BaseOperation<ActiveCustomerModel>(mockDatabase, 'active_customers');
    activeCustomerOperation = ActiveCustomerOperation(baseOperation);
  });

  group('ActiveCustomerOperation Tests', () {
    final tActiveCustomer = ActiveCustomerModel(
      id: '1',
      customerId: 'cust1',
      packageId: 'pkg1',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );

    test('getActiveCustomers should return a list of active customers',
        () async {
      when(baseOperation.getAll())
          .thenAnswer((_) async => [tActiveCustomer.toMap()]);

      final result = await activeCustomerOperation.getActiveCustomers();

      expect(result, isA<List<ActiveCustomerModel>>());
      expect(result.length, 1);
      expect(result.first.id, tActiveCustomer.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getActiveCustomerById should return a single active customer',
        () async {
      when(baseOperation.getById('1'))
          .thenAnswer((_) async => tActiveCustomer.toMap());

      final result = await activeCustomerOperation.getActiveCustomerById('1');

      expect(result, isA<ActiveCustomerModel>());
      expect(result?.id, tActiveCustomer.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertActiveCustomer should insert a new active customer', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id =
          await activeCustomerOperation.insertActiveCustomer(tActiveCustomer);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateActiveCustomer should update an existing active customer',
        () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await activeCustomerOperation.updateActiveCustomer(
          tActiveCustomer.id, tActiveCustomer);

      expect(result, 1);
      verify(baseOperation.update(tActiveCustomer.id, any)).called(1);
    });

    test('deleteActiveCustomer should delete an active customer', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await activeCustomerOperation.deleteActiveCustomer('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
