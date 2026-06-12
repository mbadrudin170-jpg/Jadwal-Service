// path: test/shared/operasi/active_customer_operation_test.dart
// KOREKSI: Menambahkan tipe generik <void> untuk menghilangkan peringatan strict_raw_type.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';

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
  late MockTransaction mockTransaction;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockCustomerOperation = MockCustomerOperation();
    mockNotifikasiServis = MockNotifikasiServis();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();

    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);

    activeCustomerOperation = ActiveCustomerOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
      customerOperation: mockCustomerOperation,
      notifikasiServis: mockNotifikasiServis,
    );
  });

  group('ActiveCustomerOperation Tests', () {
    final tActiveCustomer1 = ActiveCustomerModel(
      id: '1',
      idPelanggan: 'cust1',
      packageId: 'pkg1',
      startDate: DateTime.now().subtract(const Duration(days: 27)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      status: PaymentStatus.paid,
    );

    final tActiveCustomer2 = ActiveCustomerModel(
      id: '2',
      idPelanggan: 'cust2',
      packageId: 'pkg2',
      startDate: DateTime.now().subtract(const Duration(days: 29)),
      endDate: DateTime.now().add(const Duration(days: 1)),
      status: PaymentStatus.paid,
    );

    final tCustomer1 = CustomerModel(
      id: 'cust1',
      name: 'Budi',
      phone: '08123',
      address: 'Jalan A',
      password: 'pass',
    );
    final tCustomer2 = CustomerModel(
      id: 'cust2',
      name: 'Citra',
      phone: '08456',
      address: 'Jalan B',
      password: 'pass',
    );

    final tActiveCustomerMap1 = tActiveCustomer1.toSqlite();
    final tActiveCustomerMap2 = tActiveCustomer2.toSqlite();

    test('1. getAllActiveCustomers harus mengembalikan daftar pelanggan aktif',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap1]);

      final result = await activeCustomerOperation.getAllActiveCustomers();

      expect(result, isA<List<ActiveCustomerModel>>());
      expect(result.length, 1);
      expect(result.first.id, tActiveCustomer1.id);
    });

    test('2. getActiveCustomerById harus mengembalikan satu pelanggan aktif',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap1]);

      final result = await activeCustomerOperation.getActiveCustomerById('1');

      expect(result, isA<ActiveCustomerModel>());
      expect(result?.id, tActiveCustomer1.id);
    });

    test(
        '3. createActiveCustomer harus menyisipkan pelanggan dan jadwal notifikasi',
        () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        // KODE DIPERBAIKI: Menambahkan <void>
        final action = invocation.positionalArguments.first as Future<void>
            Function(Transaction);
        await action(mockTransaction);
      });
      when(mockTransaction.insert(any, any,
              conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);
      when(mockCustomerOperation.getById(any))
          .thenAnswer((_) async => tCustomer1);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});
      when(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .thenAnswer((_) async {});

      final result =
          await activeCustomerOperation.createActiveCustomer(tActiveCustomer1);

      expect(result.id, isNotEmpty);
      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
      verify(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .called(greaterThanOrEqualTo(1));
    });

    test(
        '4. updateActiveCustomer harus memperbarui pelanggan dan jadwal notifikasi',
        () async {
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        // KODE DIPERBAIKI: Menambahkan <void>
        final action = invocation.positionalArguments.first as Future<void>
            Function(Transaction);
        await action(mockTransaction);
      });
      when(mockTransaction.update(any, any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => 1);
      when(mockCustomerOperation.getById(any))
          .thenAnswer((_) async => tCustomer1);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});
      when(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .thenAnswer((_) async {});

      final result =
          await activeCustomerOperation.updateActiveCustomer(tActiveCustomer1);

      expect(result.id, tActiveCustomer1.id);
      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(any))
          .called(greaterThanOrEqualTo(1));
      verify(mockNotifikasiServis.jadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal')))
          .called(greaterThanOrEqualTo(1));
    });

    test(
        '5. softDelete harus mengarsipkan pelanggan dan membatalkan notifikasi',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap1]);

      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        // KODE DIPERBAIKI: Menambahkan <void>
        final action = invocation.positionalArguments.first as Future<void>
            Function(Transaction);
        await action(mockTransaction);
      });

      when(mockTransaction.update(any, any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => 1);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});

      await activeCustomerOperation.softDelete('1');

      verify(mockBaseOperation.runComplexOperation<void>(any)).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(any)).called(3);
    });

    test(
        '6. rescheduleAllNotifications harus menjadwalkan ulang notifikasi untuk semua pelanggan aktif',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tActiveCustomerMap1, tActiveCustomerMap2]);

      when(mockCustomerOperation.getById('cust1'))
          .thenAnswer((_) async => tCustomer1);
      when(mockCustomerOperation.getById('cust2'))
          .thenAnswer((_) async => tCustomer2);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});
      when(mockNotifikasiServis.jadwalNotifikasi(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
      )).thenAnswer((_) async {});

      await activeCustomerOperation.rescheduleAllNotifications();

      verify(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .called(1);
      verify(mockCustomerOperation.getById('cust1')).called(1);
      verify(mockCustomerOperation.getById('cust2')).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(any)).called(6);
      verify(mockNotifikasiServis.jadwalNotifikasi(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
      )).called(3);
    });
  });
}
