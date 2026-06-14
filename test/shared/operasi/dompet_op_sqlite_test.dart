// path: test/shared/operasi/dompet_op_sqlite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';

import 'dompet_op_sqlite_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database, Transaction])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late DompetOpSqlite dompetOpSqlite;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    dompetOpSqlite = DompetOpSqlite(
      sqliteDb: mockDbHelper,
      baseOpSqlite: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('Uji Coba DompetOpSqlite', () {
    final tWallet = DompetModel(
      id: '1',
      name: 'Dompet Utama',
      balance: 1000000,
      updatedAt: DateTime.now(),
    );
    final tWalletMap = tWallet.toSqlite();
    final tableName = NamaTabel.get(TableName.wallet);

    test('1. getWallets harus mengembalikan daftar dompet', () async {
      when(mockDatabase.query(any, where: anyNamed('where')))
          .thenAnswer((_) async => [tWalletMap]);

      final result = await dompetOpSqlite.ambilSemua();

      expect(result, isA<List<DompetModel>>());
      expect(result.length, 1);
      expect(result.first.id, tWallet.id);
      verify(mockDatabase.query(tableName,
              where: 'is_deleted = 0 AND archived_at IS NULL'))
          .called(1);
    });

    test('2. tambahDompet harus memanggil insert pada baseOperation', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async => 1);

      await dompetOpSqlite.tambahDompet(tWallet);

      verify(mockBaseOperation.sisipkan(tableName, any)).called(1);
    });

    test('3. updateDompet harus memanggil update pada baseOperation', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async => 1);

      await dompetOpSqlite.updateDompet(tWallet);

      verify(mockBaseOperation.update(tableName, any, tWallet.id)).called(1);
    });

    test('4. softDelete harus memanggil softDelete pada baseOperation',
        () async {
      when(mockBaseOperation.hapusSementara(any, any))
          .thenAnswer((_) async => 1);

      await dompetOpSqlite.softDelete('1');

      verify(mockBaseOperation.hapusSementara(tableName, '1')).called(1);
    });

    test(
        '5. softDeleteAll harus menjalankan operasi kompleks untuk menghapus semua',
        () async {
      when(mockBaseOperation.hapusSementaraSemua(tableName, dariServer: false))
          .thenAnswer((_) async => 1);

      await dompetOpSqlite.softDeleteAll();

      verify(mockBaseOperation.hapusSementaraSemua(tableName,
              dariServer: false))
          .called(1);
    });

    test(
        '6. insertOrUpdateBatch harus memanggil insertOrUpdateBatch pada baseOperation',
        () async {
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async {});

      await dompetOpSqlite.insertOrUpdateBatch([tWallet]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}
