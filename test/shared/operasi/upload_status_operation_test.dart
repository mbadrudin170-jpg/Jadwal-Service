// path: test/shared/operasi/upload_status_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/upload_status_model.dart';
import 'package:wifi/shared/operasi/upload_status_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<UploadStatusModel> baseOperation;
  late UploadStatusOperation uploadStatusOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<UploadStatusModel>(mockDatabase, 'upload_status');
    uploadStatusOperation = UploadStatusOperation(baseOperation);
  });

  group('UploadStatusOperation Tests', () {
    final tUploadStatus = UploadStatusModel(
      id: '1',
      tableName: 'customers',
      lastUpload: DateTime.now(),
    );

    test('getUploadStatus should return a list of upload status', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tUploadStatus.toMap()]);

      final result = await uploadStatusOperation.getUploadStatus();

      expect(result, isA<List<UploadStatusModel>>());
      expect(result.length, 1);
      expect(result.first.id, tUploadStatus.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getUploadStatusById should return a single upload status', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tUploadStatus.toMap());

      final result = await uploadStatusOperation.getUploadStatusById('1');

      expect(result, isA<UploadStatusModel>());
      expect(result?.id, tUploadStatus.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertUploadStatus should insert a new upload status', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await uploadStatusOperation.insertUploadStatus(tUploadStatus);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updateUploadStatus should update an existing upload status', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await uploadStatusOperation.updateUploadStatus(tUploadStatus.id, tUploadStatus);

      expect(result, 1);
      verify(baseOperation.update(tUploadStatus.id, any)).called(1);
    });

    test('deleteUploadStatus should delete an upload status', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await uploadStatusOperation.deleteUploadStatus('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
