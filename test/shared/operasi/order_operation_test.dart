// path: test/shared/operasi/order_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
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

  group('Tes Operasi Pesanan', () {
    final tOrder = OrderModel.create(
      id: '1',
      customerId: 'cust1',
      packageId: 'pkg1',
      date: DateTime.now(),
    );
    final tOrderMap = tOrder.toSqlite();
    final tableName = TableNameValue.get(TableName.customerOrder);

    test('1. getAllOrders harus mengembalikan daftar pesanan dari database',
        () async {
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [tOrderMap]);

      final result = await orderOperation.getAllOrders();

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.id, tOrder.id);
      verify(mockDatabase.query(tableName, orderBy: anyNamed('orderBy')))
          .called(1);
    });

    test('2. saveOrder harus memanggil insert pada baseOperation', () async {
      when(mockBaseOperation.sisipkan(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.saveOrder(tOrder);

      verify(mockBaseOperation.sisipkan(tableName, any)).called(1);
    });

    test('3. updateOrderStatus harus memanggil update pada baseOperation',
        () async {
      const newStatus = StatusOrderEnum.selesai;
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tOrderMap]);
      when(mockBaseOperation.update(any, any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.updateOrderStatus(tOrder.id, newStatus);

      final verificationResult = verify(mockBaseOperation.update(
        tableName,
        captureAny, // capture the map
        tOrder.id,
      ));
      verificationResult.called(1);

      final capturedMap =
          verificationResult.captured.first as Map<String, dynamic>;
      expect(capturedMap['status'], newStatus.name);
    });

    test('4. deleteOrder harus memanggil delete pada baseOperation', () async {
      when(mockBaseOperation.delete(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.deleteOrder('1');

      verify(mockBaseOperation.delete(tableName, '1')).called(1);
    });

    test('5. softDelete harus memanggil softDelete pada baseOperation',
        () async {
      when(mockBaseOperation.hapusSementara(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(tableName, '1')).called(1);
    });

    test(
        '6. insertOrUpdateBatch harus memanggil insertOrUpdateBatch pada baseOperation',
        () async {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) => Future.value());

      await orderOperation.insertOrUpdateBatch([tOrder]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });

    test(
        '7. getJumlahByStatus harus menghitung berapa total data berdasarkan status',
        () async {
      const status = StatusOrderEnum.baru;
      when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [
            {'COUNT(*)': 5}
          ]);

      final result = await orderOperation.getJumlahByStatus(status);

      expect(result, 5);
      verify(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM customerOrder WHERE ${ColumnNames.status} = ? AND ${ColumnNames.isDeleted} = 0',
        [status.name],
      )).called(1);
    });

    test(
        '8. getAllActiveOrdersStream harus mengembalikan stream daftar pesanan aktif',
        () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [tOrderMap]);

      final stream = orderOperation.getAllActiveOrdersStream();

      expect(
          stream,
          emits(isA<List<OrderModel>>()
              .having((list) => list.length, 'panjang', 1)
              .having((list) => list.first.id, 'id', tOrder.id)));
      await untilCalled(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        orderBy: anyNamed('orderBy'),
      ));
    });

    test(
        '9. getOrdersByStatus harus mengembalikan daftar pesanan berdasarkan status',
        () async {
      const status = StatusOrderEnum.diproses;
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [tOrderMap]);

      final result = await orderOperation.getOrdersByStatus(status);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      expect(result.first.id, tOrder.id);
      verify(mockDatabase.query(
        tableName,
        where: '${ColumnNames.status} = ? AND ${ColumnNames.isDeleted} = 0',
        whereArgs: [status.name],
        orderBy: anyNamed('orderBy'),
      )).called(1);
    });

    test('10. softDeleteAll harus memanggil softDeleteAll pada baseOperation',
        () async {
      when(mockBaseOperation.hapusSementaraSemua(any))
          .thenAnswer((_) async => 1);

      await orderOperation.softDeleteAll();

      verify(mockBaseOperation.hapusSementaraSemua(tableName)).called(1);
    });

    test('11. getOrdersByIds harus mengembalikan daftar pesanan berdasarkan ID',
        () async {
      final ids = ['1', '2'];
      final questionMarks = List.filled(ids.length, '?').join(',');
      final expectedWhere =
          '${ColumnNames.id} IN ($questionMarks) AND ${ColumnNames.isDeleted} = 0';

      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tOrderMap]);

      final result = await orderOperation.getOrdersByIds(ids);

      expect(result, isA<List<OrderModel>>());
      expect(result.length, 1);
      verify(mockDatabase.query(
        tableName,
        where: expectedWhere,
        whereArgs: ids,
      )).called(1);
    });
  });
}
