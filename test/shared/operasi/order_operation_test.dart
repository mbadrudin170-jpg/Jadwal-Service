// path: test/shared/operasi/order_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_operation.dart';

import 'order_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, BaseOperation, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late OrderOperation orderOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    orderOperation = OrderOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('OrderOperation Tests', () {
    final tOrder = OrderModel(
      id: '1',
      customerId: 'cust1',
      packageId: 'pkg1',
      date: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final tOrderMap = tOrder.toSqlite();
    final tableName = TableNameValue.get(TableName.customerOrder);

    test('getAllOrders should return a list of orders from database', () async {
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [tOrderMap]);

      final result = await orderOperation.getAllOrders();

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.id, tOrder.id);
      verify(mockDatabase.query(tableName, orderBy: anyNamed('orderBy')))
          .called(1);
    });

    test('saveOrder should call insert on baseOperation', () async {
      when(mockBaseOperation.insert(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.saveOrder(tOrder);

      verify(mockBaseOperation.insert(tableName, any)).called(1);
    });

    test('updateOrderStatus should call update on baseOperation', () async {
      // Arrange
      const newStatus = StatusOrderEnum.selesai;
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tOrderMap]);
      when(mockBaseOperation.update(any, any, any))
          .thenAnswer((_) => Future.value());

      // Act
      await orderOperation.updateOrderStatus(tOrder.id, newStatus);

      // Assert
      final verificationResult = verify(mockBaseOperation.update(
        tableName,
        captureAny, // capture the map
        tOrder.id,
      ));
      verificationResult.called(1);

      // Check that the status in the captured map is updated
      final capturedMap =
          verificationResult.captured.first as Map<String, dynamic>;
      expect(capturedMap['status'], newStatus.name);
    });

    test('deleteOrder should call delete on baseOperation', () async {
      when(mockBaseOperation.delete(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.deleteOrder('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('softDelete should call softDelete on baseOperation', () async {
      when(mockBaseOperation.softDelete(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(tableName, '1')).called(1);
    });

    test('insertOrUpdateBatch should call insertOrUpdateBatch on baseOperation',
        () async {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.insertOrUpdateBatch([tOrder]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
    test('getJumlahByStatus harus menghitung berapa total data berdasarkan status', )
  });
}
