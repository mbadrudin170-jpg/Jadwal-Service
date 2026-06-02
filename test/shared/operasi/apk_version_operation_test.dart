// path: test/shared/operasi/apk_version_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<ApkVersionModel> baseOperation;
  late ApkVersionOperation apkVersionOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<ApkVersionModel>(mockDatabase, 'apk_versions');
    apkVersionOperation = ApkVersionOperation(baseOperation);
  });

  group('ApkVersionOperation Tests', () {
    final tApkVersion = ApkVersionModel(
      id: '1',
      version: '1.0.0',
      buildNumber: 1,
      url: 'http://example.com/app.apk',
      releaseNotes: 'Initial release',
    );

    test('getApkVersions should return a list of apk versions', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tApkVersion.toMap()]);

      final result = await apkVersionOperation.getApkVersions();

      expect(result, isA<List<ApkVersionModel>>());
      expect(result.length, 1);
      expect(result.first.id, tApkVersion.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getApkVersionById should return a single apk version', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tApkVersion.toMap());

      final result = await apkVersionOperation.getApkVersionById('1');

      expect(result, isA<ApkVersionModel>());
      expect(result?.id, tApkVersion.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertApkVersion should insert a new apk version', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await apkVersionOperation.insertApkVersion(tApkVersion);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateApkVersion should update an existing apk version', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await apkVersionOperation.updateApkVersion(tApkVersion.id, tApkVersion);

      expect(result, 1);
      verify(baseOperation.update(tApkVersion.id, any)).called(1);
    });

    test('deleteApkVersion should delete an apk version', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await apkVersionOperation.deleteApkVersion('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
