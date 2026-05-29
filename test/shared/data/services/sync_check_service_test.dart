// path: test/shared/data/services/sync_check_service_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/data/services/new_data_check_service.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

import 'sync_check_service_test.mocks.dart';

@GenerateMocks([
  SyncManager,
  UploadDataService,
  DownloadDataService,
  NewDataCheckService,
])
void main() {
  late MockSyncManager mockSyncManager;
  late MockUploadDataService mockUploadService;
  late MockDownloadDataService mockDownloadService;
  late MockNewDataCheckService mockNewDataCheck;
  late FakeFirebaseFirestore mockFirestore;
  late SyncCheckService syncCheckService;

  setUp(() {
    mockSyncManager = MockSyncManager();
    mockUploadService = MockUploadDataService();
    mockDownloadService = MockDownloadDataService();
    mockNewDataCheck = MockNewDataCheckService();
    mockFirestore = FakeFirebaseFirestore();

    syncCheckService = SyncCheckService(
      syncManager: mockSyncManager,
      uploadService: mockUploadService,
      downloadService: mockDownloadService,
      newDataCheck: mockNewDataCheck,
      firestore: mockFirestore,
    );

    // Atur perilaku default untuk mock agar tidak terjadi error null
    when(mockUploadService.uploadAllData()).thenAnswer((_) async => {});
    when(mockDownloadService.downloadAllData()).thenAnswer((_) async => {});
    when(mockSyncManager.setLastUpload(any)).thenAnswer((_) async => {});
    when(mockSyncManager.setLastDownload(any)).thenAnswer((_) async => {});
    when(mockNewDataCheck.resetNeedUpload()).thenAnswer((_) async => {});
  });

  group('SyncCheckService - runSyncCheck', () {
    test(
        'harus menjalankan upload dan download jika ada data baru di lokal dan server',
        () async {
      // ATUR
      when(mockNewDataCheck.hasNewSqliteData()).thenAnswer((_) async => true);
      when(mockNewDataCheck.hasNewFirebaseData(
        collectionName: anyNamed('collectionName'),
        documentId: anyNamed('documentId'),
      )).thenAnswer((_) async => true);

      // JALANKAN
      await syncCheckService.runSyncCheck();

      // VERIFIKASI
      // Pastikan proses unggah terpicu
      verify(mockNewDataCheck.hasNewSqliteData()).called(1);
      verify(mockUploadService.uploadAllData()).called(1);
      verify(mockSyncManager.setLastUpload(any)).called(1);
      verify(mockNewDataCheck.resetNeedUpload()).called(1);

      // Pastikan status global diperbarui karena ada unggahan
      final statusDoc = await mockFirestore
          .collection(TableNameValue.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isTrue);
      expect(statusDoc.data(), contains(ColumnNames.updatedAt));

      // Pastikan proses unduh terpicu
      verify(mockNewDataCheck.hasNewFirebaseData(
              collectionName: TableNameValue.get(TableName.statusGlobal),
              documentId: globalStatusId))
          .called(1);
      verify(mockDownloadService.downloadAllData()).called(1);
      verify(mockSyncManager.setLastDownload(any)).called(1);
    });

    test('harus menjalankan upload saja jika hanya ada data baru di lokal',
        () async {
      // ATUR
      when(mockNewDataCheck.hasNewSqliteData()).thenAnswer((_) async => true);
      when(mockNewDataCheck.hasNewFirebaseData(
        collectionName: anyNamed('collectionName'),
        documentId: anyNamed('documentId'),
      )).thenAnswer((_) async => false);

      // JALANKAN
      await syncCheckService.runSyncCheck();

      // VERIFIKASI
      // Pastikan proses unggah terpicu
      verify(mockUploadService.uploadAllData()).called(1);
      verify(mockSyncManager.setLastUpload(any)).called(1);

      // Pastikan proses unduh diperiksa tapi tidak dieksekusi
      verify(mockNewDataCheck.hasNewFirebaseData(
              collectionName: TableNameValue.get(TableName.statusGlobal),
              documentId: globalStatusId))
          .called(1);
      verifyNever(mockDownloadService.downloadAllData());
      verifyNever(mockSyncManager.setLastDownload(any));
    });

    test('harus menjalankan download saja jika hanya ada data baru di server',
        () async {
      // ATUR
      when(mockNewDataCheck.hasNewSqliteData()).thenAnswer((_) async => false);
      when(mockNewDataCheck.hasNewFirebaseData(
        collectionName: anyNamed('collectionName'),
        documentId: anyNamed('documentId'),
      )).thenAnswer((_) async => true);

      // JALANKAN
      await syncCheckService.runSyncCheck();

      // VERIFIKASI
      // Pastikan proses unggah diperiksa tapi tidak dieksekusi
      verify(mockNewDataCheck.hasNewSqliteData()).called(1);
      verifyNever(mockUploadService.uploadAllData());
      verifyNever(mockSyncManager.setLastUpload(any));

      // Pastikan status global tidak diperbarui
      final statusDoc = await mockFirestore
          .collection(TableNameValue.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isFalse);

      // Pastikan proses unduh terpicu
      verify(mockDownloadService.downloadAllData()).called(1);
      verify(mockSyncManager.setLastDownload(any)).called(1);
    });

    test('tidak melakukan apa-apa jika tidak ada data baru sama sekali',
        () async {
      // ATUR
      when(mockNewDataCheck.hasNewSqliteData()).thenAnswer((_) async => false);
      when(mockNewDataCheck.hasNewFirebaseData(
        collectionName: anyNamed('collectionName'),
        documentId: anyNamed('documentId'),
      )).thenAnswer((_) async => false);

      // JALANKAN
      await syncCheckService.runSyncCheck();

      // VERIFIKASI
      verify(mockNewDataCheck.hasNewSqliteData()).called(1);
      verifyNever(mockUploadService.uploadAllData());

      verify(mockNewDataCheck.hasNewFirebaseData(
              collectionName: TableNameValue.get(TableName.statusGlobal),
              documentId: globalStatusId))
          .called(1);
      verifyNever(mockDownloadService.downloadAllData());

      final statusDoc = await mockFirestore
          .collection(TableNameValue.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isFalse);
    });

    test('harus log error dan tidak update metadata saat unggah gagal',
        () async {
      // ATUR
      when(mockNewDataCheck.hasNewSqliteData()).thenAnswer((_) async => true);
      when(mockUploadService.uploadAllData()).thenThrow(Exception('Gagal!'));
      when(mockNewDataCheck.hasNewFirebaseData(
              collectionName: anyNamed('collectionName'),
              documentId: anyNamed('documentId')))
          .thenAnswer((_) async => false);

      // JALANKAN
      await syncCheckService.runSyncCheck();

      // VERIFIKASI
      verify(mockUploadService.uploadAllData()).called(1);

      // Pastikan metadata tidak diperbarui karena ada error
      verifyNever(mockSyncManager.setLastUpload(any));
      verifyNever(mockNewDataCheck.resetNeedUpload());
      final statusDoc = await mockFirestore
          .collection(TableNameValue.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isFalse);

      // Pengecekan unduh harus tetap berjalan
      verify(mockNewDataCheck.hasNewFirebaseData(
              collectionName: anyNamed('collectionName'),
              documentId: anyNamed('documentId')))
          .called(1);
    });

    test('harus log error dan tidak update metadata saat unduh gagal',
        () async {
      // ATUR
      when(mockNewDataCheck.hasNewSqliteData()).thenAnswer((_) async => false);
      when(mockNewDataCheck.hasNewFirebaseData(
              collectionName: anyNamed('collectionName'),
              documentId: anyNamed('documentId')))
          .thenAnswer((_) async => true);
      when(mockDownloadService.downloadAllData())
          .thenThrow(Exception('Gagal!'));

      // JALANKAN
      await syncCheckService.runSyncCheck();

      // VERIFIKASI
      verify(mockDownloadService.downloadAllData()).called(1);
      verifyNever(mockSyncManager.setLastDownload(any));
    });
  });
}
