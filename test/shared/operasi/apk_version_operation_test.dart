// path: test/shared/operasi/apk_version_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/upload_status_operation.dart';

import 'apk_version_operation_test.mocks.dart';

@GenerateMocks([
  SqliteDatabase,
  Database,
  BaseOperation,
  UploadStatusOperation,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockBaseOperation mockBaseOperation;
  late ApkVersionOperation apkVersionOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockBaseOperation = MockBaseOperation();
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    apkVersionOperation = ApkVersionOperation(
      dbHelper: mockDbHelper,
      baseOperation: mockBaseOperation,
    );
  });

  group('ApkVersionOperation', () {
    final tApkVersion = ApkVersionModel(
      id: '1',
      latestVersion: '1.0.0',
      releaseNotes: 'Test release notes',
    );
    final tApkVersionMap = tApkVersion.toSqlite();

    test('1. getAllApkVersions harus mengembalikan daftar versi apk', () async {
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [tApkVersionMap]);

      final result = await apkVersionOperation.getAllApkVersions();

      expect(result, isA<List<ApkVersionModel>>());
      expect(result.length, 1);
      expect(result.first.id, tApkVersion.id);
      verify(mockDatabase.query(any, orderBy: anyNamed('orderBy'))).called(1);
    });

    test('2. getLatestApkVersion harus mengembalikan versi apk terbaru',
        () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'),
              orderBy: anyNamed('orderBy'),
              limit: anyNamed('limit')))
          .thenAnswer((_) async => [tApkVersionMap]);

      final result = await apkVersionOperation.getLatestApkVersion();

      expect(result, isA<ApkVersionModel>());
      expect(result?.id, tApkVersion.id);
    });

    test('3. addApkVersion harus menyisipkan versi apk baru', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async {});

      await apkVersionOperation.addApkVersion(tApkVersion);

      verify(mockBaseOperation.sisipkan(any, any)).called(1);
    });

    test('4. updateApkVersion harus memperbarui versi apk yang ada', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await apkVersionOperation.updateApkVersion(tApkVersion);

      verify(mockBaseOperation.update(any, any, any)).called(1);
    });

    test('5. softDelete harus melakukan soft delete pada versi apk', () async {
      when(mockBaseOperation.hapusSementara(any, any)).thenAnswer((_) async {});

      await apkVersionOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(any, '1')).called(1);
    });
  });
}
