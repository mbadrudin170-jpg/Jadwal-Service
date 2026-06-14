// path: test/shared/operasi/customer_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart';

import 'customer_operation_test.mocks.dart';

@GenerateMocks([
  SqliteDatabase,
  Database,
  BaseOpSqlite,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockBaseOperation mockBaseOperation;
  late PelangganOpSqlite customerOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockBaseOperation = MockBaseOperation();
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    customerOperation = PelangganOpSqlite(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
  });

  group('Pengujian CustomerOperation', () {
    final tCustomer = PelangganModel(
      id: '1',
      name: 'Test Customer',
      phone: '1234567890',
      address: 'Test Address',
      password: 'password',
    );
    final tCustomerMap = tCustomer.toSqlite();

    test('1. add harus menyisipkan customer baru', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async => 1);

      await customerOperation.add(tCustomer);

      verify(mockBaseOperation.sisipkan(any, any)).called(1);
    });

    test('2. getAll harus mengembalikan daftar customer', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tCustomerMap]);

      final result = await customerOperation.ambilSemua();

      expect(result, isA<List<PelangganModel>>());
      expect(result.first.id, tCustomer.id);
    });

    test('3. getById harus mengembalikan seorang customer', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tCustomerMap]);

      final result = await customerOperation.getById('1');

      expect(result, isA<PelangganModel>());
      expect(result?.id, tCustomer.id);
    });

    test('4. updateCustomer harus memperbarui customer yang ada', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await customerOperation.updateCustomer(tCustomer);

      verify(mockBaseOperation.update(any, any, any)).called(1);
    });

    test('5. softDelete harus melakukan soft delete pada customer', () async {
      when(mockBaseOperation.hapusSementara(any, any)).thenAnswer((_) async {});

      await customerOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(any, '1')).called(1);
    });
  });
}
