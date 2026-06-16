// path: test/shared/operasi/feedback_operation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';

import 'feedback_operation_test.mocks.dart';

// 1. Definisikan kelas yang akan di-mock
@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database, Transaction])
void main() {
  // 2. Deklarasikan variabel untuk mock dan kelas yang diuji
  late MockDatabaseHelper mockDbHelper;
  late MockBaseOperation mockBaseOperation;
  late MockDatabase mockDatabase;
  late MockTransaction mockTransaction;
  late FeedbackOpSqlite feedbackOperation;
  final tableName = NamaTabel.get(TableName.feedback);

  // 3. Siapkan instance sebelum setiap test
  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockBaseOperation = MockBaseOperation();
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    feedbackOperation = FeedbackOpSqlite(
      sqliteDb: mockDbHelper,
      baseOpSqlite: mockBaseOperation,
    );

    // Atur respons default untuk mock
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    when(mockBaseOperation.runComplexOperation<int>(any,
            fromServer: anyNamed('fromServer')))
        .thenAnswer((invocation) async {
      final callback = invocation.positionalArguments.first as Future<int>
          Function(Transaction);
      return await callback(mockTransaction);
    });
  });

  // Data dummy untuk digunakan di seluruh test
  final feedback1 = FeedbackModel(
    id: 'id1',
    userId: 'user1',
    pesan: 'Feedback pertama',
    tanggal: DateTime(2023),
  );

  final feedback2 = FeedbackModel(
    id: 'id2',
    userId: 'user2',
    pesan: 'Feedback kedua',
    tanggal: DateTime(2023, 1, 2),
    dihapus: true,
  );

  final feedbackMap1 = feedback1.toSqlite();
  final feedbackMap2 = feedback2.toSqlite();

  group('Pengujian FeedbackOperation', () {
    test('1. add harus memanggil baseOperation.insert dengan data yang benar',
        () async {
      // Arrange
      // Tidak perlu `when` karena `insert` mengembalikan Future<void>

      // Act
      await feedbackOperation.add(feedback1);

      // Assert
      // Verifikasi bahwa `insert` dipanggil dengan argumen yang benar
      verify(mockBaseOperation.sisipkan(
        tableName,
        any, // `any` karena `updatedAt` di-generate di dalam method `add`
      )).called(1);
    });

    test('2. getAll harus mengembalikan daftar FeedbackModel', () async {
      // Arrange
      when(mockDatabase.query(tableName, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [feedbackMap1, feedbackMap2]);

      // Act
      final result = await feedbackOperation.getAll();

      // Assert
      expect(result, isA<List<FeedbackModel>>());
      expect(result.length, 2);
      expect(result.first.id, feedback1.id);
    });

    test(
        '3. getAllActiveFeedback harus mengembalikan hanya feedback yang tidak dihapus',
        () async {
      // Arrange
      when(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        orderBy: anyNamed('orderBy'),
      )).thenAnswer((_) async => [feedbackMap1]);

      // Act
      final result = await feedbackOperation.getAllActiveFeedback();

      // Assert
      expect(result.length, 1);
      expect(result.first.isDeleted, false);
      verify(mockDatabase.query(
        tableName,
        where: '${NamaKolom.dihapus} = 0',
        orderBy: '${NamaKolom.tanggal} DESC',
      )).called(1);
    });

    test(
        '4. getById harus mengembalikan FeedbackModel yang benar saat ditemukan',
        () async {
      // Arrange
      when(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [feedbackMap1]);

      // Act
      final result = await feedbackOperation.getById('id1');

      // Assert
      expect(result.id, 'id1');
      expect(result.content, feedback1.content);
    });

    test('5. getById harus melempar Exception saat tidak ditemukan', () {
      // Arrange
      when(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // Act & Assert
      expect(
        () async => await feedbackOperation.getById('unknown'),
        throwsA(isA<Exception>()),
      );
    });

    test(
        '6. getChanges harus mengembalikan feedback yang diperbarui setelah lastSync',
        () async {
      // Arrange
      final lastSync = DateTime(2023, 1, 1, 12);
      final updatedFeedback =
          feedback1.copyWith(updatedAt: lastSync.add(const Duration(hours: 1)));

      when(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [updatedFeedback.toSqlite()]);

      // Act
      final result = await feedbackOperation.getChanges(lastSync);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, updatedFeedback.id);
      verify(mockDatabase.query(
        tableName,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [lastSync.millisecondsSinceEpoch],
      )).called(1);
    });

    test(
        '7. insertOrUpdateBatch harus memanggil baseOperation.insertOrUpdateBatch dengan benar',
        () async {
      // Arrange
      final feedbackList = [feedback1, feedback2];
      // `when` tidak diperlukan jika return type-nya void

      // Act
      await feedbackOperation.sisipkanAtauPerbaruiBatch(feedbackList);

      // Assert
      verify(mockBaseOperation.insertOrUpdateBatch(
        tableName,
        any, // `any` karena `updatedAt` di-generate di dalam method
      )).called(1);
    });

    test(
        '8. insertOrUpdateBatch dengan list kosong tidak boleh memanggil baseOperation',
        () async {
      // Act
      await feedbackOperation.sisipkanAtauPerbaruiBatch([]);

      // Assert
      verifyNever(mockBaseOperation.insertOrUpdateBatch(any, any));
    });

    test('9. delete harus memanggil baseOperation.delete', () async {
      // Act
      await feedbackOperation.delete('id1');

      // Assert
      verify(mockBaseOperation.delete(tableName, 'id1')).called(1);
    });

    test('10. softDelete harus memanggil baseOperation.softDelete', () async {
      // Act
      await feedbackOperation.softDelete('id1');

      // Assert
      verify(mockBaseOperation.hapusSementara(tableName, 'id1')).called(1);
    });

    test(
        '11. softDeleteAll harus memanggil baseOperation.softDeleteAll dan mengembalikan jumlahnya',
        () async {
      // Arrange
      when(mockBaseOperation.hapusSementaraSemua(tableName))
          .thenAnswer((_) async => 5);

      // Act
      final count = await feedbackOperation.softDeleteAll();

      // Assert
      expect(count, 5);
      verify(mockBaseOperation.hapusSementaraSemua(tableName)).called(1);
    });

    test('12. deleteAll harus mengeksekusi delete dalam sebuah transaksi',
        () async {
      // Arrange
      when(mockTransaction.delete(tableName)).thenAnswer((_) async => 10);

      // Act
      await feedbackOperation.deleteAll();

      // Assert
      verify(mockBaseOperation.runComplexOperation<int>(any)).called(1);
      verify(mockTransaction.delete(tableName)).called(1);
    });

    test(
        '13. deleteByUserId harus mengeksekusi delete dengan klausa where dalam sebuah transaksi',
        () async {
      // Arrange
      const userId = 'user_to_delete';
      when(mockTransaction.delete(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => 3);

      // Act
      await feedbackOperation.deleteByUserId(userId);

      // Assert
      verify(mockBaseOperation.runComplexOperation<int>(any)).called(1);
      verify(mockTransaction.delete(
        tableName,
        where: '${NamaKolom.userId} = ?',
        whereArgs: [userId],
      )).called(1);
    });

    test('14. getByIds harus mengembalikan daftar FeedbackModel yang benar',
        () async {
      // Arrange
      when(mockDatabase.query(
        tableName,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [feedbackMap1, feedbackMap2]);

      // Act
      final result = await feedbackOperation.getByIds(['id1', 'id2']);

      // Assert
      expect(result.length, 2);
      verify(mockDatabase.query(
        tableName,
        where: 'id IN (?,?)',
        whereArgs: ['id1', 'id2'],
      )).called(1);
    });

    test('15. getByIds dengan list kosong harus mengembalikan list kosong',
        () async {
      // Act
      final result = await feedbackOperation.getByIds([]);

      // Assert
      expect(result, isEmpty);
      verifyNever(mockDatabase.query(any));
    });
  });
}
