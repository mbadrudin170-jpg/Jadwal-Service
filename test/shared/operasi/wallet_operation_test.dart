// path: test/shared/operasi/wallet_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';

import 'wallet_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, BaseOperation, Database, Transaction])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late DompetOpSqlite walletOperation;
  late MockTransaction mockTransaction;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    walletOperation = DompetOpSqlite(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('WalletOperation Tests', () {
    final tWallet = WalletModel(
      id: '1',
      name: 'Main Wallet',
      balance: 1000000,
      updatedAt: DateTime.now(),
    );
    final tWalletMap = tWallet.toSqlite();
    final tableName = TableNameValue.get(TableName.wallet);

    test('1. getWallets harus mengembalikan daftar dompet', () async {
      // Atur stub untuk mengembalikan data palsu ketika query dijalankan
      when(mockDatabase.query(any, where: anyNamed('where')))
          .thenAnswer((_) async => [tWalletMap]);

      // Panggil metode yang akan diuji
      final result = await walletOperation.getWallets();

      // Verifikasi hasil
      expect(result, isA<List<WalletModel>>());
      expect(result.length, 1);
      expect(result.first.id, tWallet.id);
      // PERBAIKAN: Sesuaikan klausa where agar cocok dengan implementasi asli
      verify(mockDatabase.query(tableName,
              where: 'is_deleted = 0 AND archived_at IS NULL'))
          .called(1);
    });

    test('2. createWallet harus memanggil insert pada baseOperation', () async {
      // Gunakan thenAnswer untuk Future<void>
      when(mockBaseOperation.insert(any, any)).thenAnswer((_) async {});

      await walletOperation.tambahDompet(tWallet);

      verify(mockBaseOperation.insert(tableName, any)).called(1);
    });

    test('3. updateWallet harus memanggil update pada baseOperation', () async {
      // Gunakan thenAnswer untuk Future<void>
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await walletOperation.updateDompet(tWallet);

      verify(mockBaseOperation.update(tableName, any, tWallet.id)).called(1);
    });

    test('4. softDelete harus memanggil softDelete pada baseOperation',
        () async {
      // Gunakan thenAnswer untuk Future<void>
      when(mockBaseOperation.softDelete(any, any)).thenAnswer((_) async {});

      await walletOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(tableName, '1')).called(1);
    });

    test(
        '5. softDeleteAll harus menjalankan operasi kompleks untuk menghapus semua',
        () async {
      // Pindahkan stub untuk mockTransaction ke luar dari thenAnswer
      when(mockTransaction.delete(any)).thenAnswer((_) async => 1);

      // Atur stub untuk runComplexOperation
      when(mockBaseOperation.runComplexOperation<void>(any))
          .thenAnswer((invocation) async {
        // Ambil fungsi 'action' yang dilewatkan sebagai argumen
        final action = invocation.positionalArguments[0] as Future<void>
            Function(Transaction);
        // Jalankan 'action' dengan mockTransaction
        await action(mockTransaction);
      });

      // Panggil metode yang diuji
      await walletOperation.softDeleteAll();

      // Verifikasi bahwa runComplexOperation dipanggil
      verify(mockBaseOperation.softDeleteAll(tableName)).called(1);
    });

    test(
        '6. insertOrUpdateBatch harus memanggil insertOrUpdateBatch pada baseOperation',
        () async {
      // Gunakan thenAnswer untuk Future<void>
      when(mockBaseOperation.insertOrUpdateBatch(any, any))
          .thenAnswer((_) async {});

      await walletOperation.insertOrUpdateBatch([tWallet]);

      verify(mockBaseOperation.insertOrUpdateBatch(tableName, any)).called(1);
    });
  });
}
