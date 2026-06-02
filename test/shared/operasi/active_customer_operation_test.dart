// path: test/shared/operasi/active_customer_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

import 'active_customer_operation_test.mocks.dart';

@GenerateMocks([
  DatabaseHelper,
  BaseOperation,
  CustomerOperation,
  NotifikasiServis,
  Database,
  Transaction,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockCustomerOperation mockCustomerOperation;
  late MockNotifikasiServis mockNotifikasiServis;
  late MockDatabase mockDatabase;
  late ActiveCustomerOperation activeCustomerOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockCustomerOperation = MockCustomerOperation();
    mockNotifikasiServis = MockNotifikasiServis();
    mockDatabase = MockDatabase();

    // Stubbing the database getter
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);

    activeCustomerOperation = ActiveCustomerOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
      customerOperation: mockCustomerOperation,
      notifikasiServis: mockNotifikasiServis,
    );
  });

  group('ActiveCustomerOperation', () {
    final tActiveCustomer = ActiveCustomerModel(
      id: '1',
      customerId: 'cust1',
      packageId: 'pkg1',
      startDate: DateTime(2024),
      endDate: DateTime(2024).add(const Duration(days: 30)),
      status: PaymentStatus.paid,
    );
    final tActiveCustomerMap = tActiveCustomer.toSqlite();
    final tCustomer = CustomerModel(
        name: 'test', phone: '123', address: '-', password: '123');

    test('getAllActiveCustomers should return a list of active customers',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap]);

      final result = await activeCustomerOperation.getAllActiveCustomers();

      expect(result, isA<List<ActiveCustomerModel>>());
      expect(result.length, 1);
      expect(result.first.id, tActiveCustomer.id);
      verify(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .called(1);
    });

    test('getActiveCustomerById should return a single active customer',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap]);

      final result = await activeCustomerOperation.getActiveCustomerById('1');

      expect(result, isA<ActiveCustomerModel>());
      expect(result?.id, tActiveCustomer.id);
      verify(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .called(1);
    });

    test('createActiveCustomer should insert a new active customer', () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((_) async {});
      when(mockCustomerOperation.getById(any)).thenAnswer((_) async => null);
      when(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .thenAnswer((_) async {});

      final result =
          await activeCustomerOperation.createActiveCustomer(tActiveCustomer);

      expect(result.id, isNotEmpty);
      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
    });

    test('updateActiveCustomer should update an existing active customer',
        () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((_) async {});
      when(mockCustomerOperation.getById(any))
          .thenAnswer((_) async => tCustomer);
      when(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .thenAnswer((_) async {});

      final result =
          await activeCustomerOperation.updateActiveCustomer(tActiveCustomer);

      expect(result.id, tActiveCustomer.id);
      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
    });

    test('softDelete should archive an active customer', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap]);
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((_) async {});
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});

      await activeCustomerOperation.softDelete('1');

      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
    });
  });
}
