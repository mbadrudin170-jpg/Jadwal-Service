// path: test/shared/operasi/order_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/order_model.dart';
import 'package:wifi/shared/operasi/order_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<OrderModel> baseOperation;
  late OrderOperation orderOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<OrderModel>(mockDatabase, 'orders');
    orderOperation = OrderOperation(baseOperation);
  });

  group('OrderOperation Tests', () {
    final tOrder = OrderModel(
      id: '1',
      customerId: 'cust1',
      packageId: 'pkg1',
      orderDate: DateTime.now(),
      totalAmount: 100000,
    );

    test('getOrders should return a list of orders', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tOrder.toMap()]);

      final result = await orderOperation.getOrders();

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.id, tOrder.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getOrderById should return a single order', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tOrder.toMap());

      final result = await orderOperation.getOrderById('1');

      expect(result, isA<OrderModel>());
      expect(result?.id, tOrder.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertOrder should insert a new order', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await orderOperation.insertOrder(tOrder);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateOrder should update an existing order', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await orderOperation.updateOrder(tOrder.id, tOrder);

      expect(result, 1);
      verify(baseOperation.update(tOrder.id, any)).called(1);
    });

    test('deleteOrder should delete an order', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await orderOperation.deleteOrder('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
