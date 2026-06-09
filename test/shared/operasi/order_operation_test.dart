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
  final tableName = TableNameValue.get(TableName.customerOrder);

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

  // Contoh data pesanan untuk pengujian
  final tOrder = OrderModel.create(
    id: '1',
    customerId: 'cust1',
    packageId: 'pkg1',
    date: DateTime.now(),
    status: StatusOrderEnum.baru,
  );
  final tOrderMap = tOrder.toSqlite();

  group('Tes Operasi Pesanan (OrderOperation)', () {
    test('1. getAllOrders harus mengembalikan daftar pesanan', () async {
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [tOrderMap]);

      final result = await orderOperation.getAllOrders();

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.id, tOrder.id);
      verify(mockDatabase.query(tableName, orderBy: anyNamed('orderBy')))
          .called(1);
    });

    test('2. saveOrder harus memanggil metode insert', () async {
      when(mockBaseOperation.insert(any, any)).thenAnswer((_) async => 1);

      await orderOperation.saveOrder(tOrder);

      verify(mockBaseOperation.insert(tableName, any)).called(1);
    });

    test('3. updateOrderStatus harus memanggil metode update', () async {
      const newStatus = StatusOrderEnum.selesai;
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tOrderMap]);
      when(mockBaseOperation.update(any, any, any))
          .thenAnswer((_) async => 1);

      await orderOperation.updateOrderStatus(tOrder.id, newStatus);

      final verificationResult = verify(mockBaseOperation.update(
        tableName,
        captureAny,
        tOrder.id,
      ));
      verificationResult.called(1);

      final capturedMap =
          verificationResult.captured.first as Map<String, dynamic>;
      expect(capturedMap['status'], newStatus.name);
    });

    test('4. deleteOrder harus memanggil metode delete', () async {
      when(mockBaseOperation.delete(any, any)).thenAnswer((_) async => 1);

      await orderOperation.deleteOrder('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('5. softDelete harus memanggil metode softDelete', () async {
      when(mockBaseOperation.softDelete(any, any)).thenAnswer((_) async => 1);

      await orderOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(tableName, '1')).called(1);
    });

    test('6. insertOrUpdateBatch harus memanggil metode insertOrUpdateBatch',
        () async {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async => {});

      await orderOperation.insertOrUpdateBatch([tOrder]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });

    test('7. getJumlahByStatus harus mengembalikan jumlah data yang benar',
        () async {
      const status = StatusOrderEnum.baru;
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [
            {'COUNT(*)': 5}
          ]);

      final result = await orderOperation.getJumlahByStatus(status);

      expect(result, 5);
      verify(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM $tableName WHERE status = ? AND isDeleted = 0',
        [status.name],
      )).called(1);
    });

    test('8. getAllActiveOrdersStream harus mengembalikan stream data non-hapus',
        () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [tOrderMap]);

      final stream = orderOperation.getAllActiveOrdersStream();

      await expectLater(
        stream,
        emits(
          isA<List<OrderModel>>()
              .having((list) => list.length, 'panjang', 1)
              .having((list) => list.first.id, 'id', tOrder.id),
        ),
      );
      verify(mockDatabase.query(
        tableName,
        where: 'isDeleted = 0',
        orderBy: anyNamed('orderBy'),
      )).called(1);
    });

    test('9. getOrdersByStatus harus mengembalikan pesanan sesuai status',
        () async {
      const status = StatusOrderEnum.diproses;
      final orderDiproses = tOrder.copyWith(status: status).toSqlite();
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [orderDiproses]);

      final result = await orderOperation.getOrdersByStatus(status);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.status, status);
      verify(mockDatabase.query(
        tableName,
        where: 'status = ? AND isDeleted = 0',
        whereArgs: [status.name],
        orderBy: anyNamed('orderBy'),
      )).called(1);
    });

    test('10. softDeleteAll harus memanggil metode softDeleteAll dari base',
        () async {
      when(mockBaseOperation.softDeleteAll(any)).thenAnswer((_) async => 1);

      await orderOperation.softDeleteAll();

      verify(mockBaseOperation.softDeleteAll(tableName)).called(1);
    });

    test('11. getOrdersByIds harus mengembalikan pesanan sesuai daftar ID',
        () async {
      final ids = ['1', '2'];
      final anotherOrder =
          OrderModel.create(id: '2', customerId: 'cust2', packageId: 'pkg2', date: DateTime.now());
      final queryResult = [tOrderMap, anotherOrder.toSqlite()];

      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => queryResult);

      final result = await orderOperation.getOrdersByIds(ids);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll(ids));
      verify(mockDatabase.query(
        tableName,
        where: 'id IN (?, ?) AND isDeleted = 0',
        whereArgs: ids,
      )).called(1);
    });
  });
}
