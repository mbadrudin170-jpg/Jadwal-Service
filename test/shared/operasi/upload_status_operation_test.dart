// path: test/shared/operasi/upload_status_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/upload_status_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/upload_status_operation.dart';

import 'upload_status_operation_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late UploadStatusOperation uploadStatusOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    uploadStatusOperation = UploadStatusOperation(dbHelper: mockDbHelper);
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  group('UploadStatusOperation Tests', () {
    final tUploadStatus = UploadStatusModel(
      id: UploadStatusModel.idNeedUpload,
      needUpload: true,
      updatedAt: DateTime.now(),
    );
    final tUploadStatusMap = tUploadStatus.toSqlite();
    final tableName = TableNameValue.get(TableName.uploadStatus);

    test('setNeedUpload should insert or replace the upload status', () async {
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      await uploadStatusOperation.setNeedUpload(true);

      verify(mockDatabase.insert(
        tableName,
        any, // We can be more specific here if needed
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('getNeedUpload should return true when data exists', () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tUploadStatusMap]);

      final result = await uploadStatusOperation.getNeedUpload();

      expect(result, isTrue);
      verify(mockDatabase.query(
        tableName,
        where: 'id = ?',
        whereArgs: [UploadStatusModel.idNeedUpload],
      )).called(1);
    });

    test('getNeedUpload should return false when no data exists', () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []); // Return empty list

      final result = await uploadStatusOperation.getNeedUpload();

      expect(result, isFalse);
    });

    test('resetNeedUpload should call setNeedUpload with false', () async {
      // We can\'t easily verify a call to another method in the same class.
      // Instead, we test the underlying database call that resetNeedUpload makes.
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      await uploadStatusOperation.resetNeedUpload();

      final verification = verify(mockDatabase.insert(
        tableName,
        captureAny,
        conflictAlgorithm: ConflictAlgorithm.replace,
      ));
      verification.called(1);

      final captured = verification.captured.single as Map<String, dynamic>;
      // PERBAIKAN: Sesuaikan ekspektasi dengan implementasi model
      // Model menggunakan `ColumnNames.value` sebagai kunci dan String '0' untuk false.
      expect(captured[ColumnNames.value], '0');
    });

    test('getUploadStatusModel should return a model when data exists',
        () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [tUploadStatusMap]);

      final result = await uploadStatusOperation.getUploadStatusModel();

      expect(result, isA<UploadStatusModel>());
      expect(result?.id, tUploadStatus.id);
      expect(result?.needUpload, isTrue);
    });

    test('getUploadStatusModel should return null when no data exists',
        () async {
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      final result = await uploadStatusOperation.getUploadStatusModel();

      expect(result, isNull);
    });
  });
}
