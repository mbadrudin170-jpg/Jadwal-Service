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
  DatabaseHelper,
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

    test('getAllApkVersions should return a list of apk versions', () async {
      when(mockDatabase.query(any, orderBy: anyNamed('orderBy')))
          .thenAnswer((_) async => [tApkVersionMap]);

      final result = await apkVersionOperation.getAllApkVersions();

      expect(result, isA<List<ApkVersionModel>>());
      expect(result.length, 1);
      expect(result.first.id, tApkVersion.id);
      verify(mockDatabase.query(any, orderBy: anyNamed('orderBy'))).called(1);
    });

    test('getLatestApkVersion should return the latest apk version', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'),
              orderBy: anyNamed('orderBy'),
              limit: anyNamed('limit')))
          .thenAnswer((_) async => [tApkVersionMap]);

      final result = await apkVersionOperation.getLatestApkVersion();

      expect(result, isA<ApkVersionModel>());
      expect(result?.id, tApkVersion.id);
    });

    test('addApkVersion should insert a new apk version', () async {
      when(mockBaseOperation.insert(any, any)).thenAnswer((_) async {});

      await apkVersionOperation.addApkVersion(tApkVersion);

      verify(mockBaseOperation.insert(any, any)).called(1);
    });

    test('updateApkVersion should update an existing apk version', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await apkVersionOperation.updateApkVersion(tApkVersion);

      verify(mockBaseOperation.update(any, any, any)).called(1);
    });

    test('softDelete should soft delete an apk version', () async {
      when(mockBaseOperation.softDelete(any, any)).thenAnswer((_) async {});

      await apkVersionOperation.softDelete('1');

      verify(mockBaseOperation.softDelete(any, '1')).called(1);
    });
  });
}
