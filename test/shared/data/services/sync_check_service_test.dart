// path: test/shared/data/services/sync_check_service_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/data/services/pengecekan_data_baru_service.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
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
  PengecekanDataBaruService,
])
void main() {
  late MockSyncManager mockSyncManager;
  late MockUploadDataService mockUploadService;
  late MockDownloadDataService mockDownloadService;
  late MockNewDataCheckService mockNewDataCheck;
  late FakeFirebaseFirestore mockFirestore;
  late LayananCekSinkronisasi syncCheckService;

  setUp(() {
    mockSyncManager = MockSyncManager();
    mockUploadService = MockUploadDataService();
    mockDownloadService = MockDownloadDataService();
    mockNewDataCheck = MockNewDataCheckService();
    mockFirestore = FakeFirebaseFirestore();

    syncCheckService = LayananCekSinkronisasi(
      pengelolaSinkronisasi: mockSyncManager,
      layananUnggah: mockUploadService,
      layananUnduh: mockDownloadService,
      pengecekanDataBaru: mockNewDataCheck,
      firestore: mockFirestore,
    );

    // Atur perilaku default untuk mock agar tidak terjadi error null
    when(mockUploadService.uploadSemuaData()).thenAnswer((_) async => {});
    when(mockDownloadService.downloadAllData()).thenAnswer((_) async => {});
    when(mockSyncManager.simpanWaktuTerkahirUnggah(any))
        .thenAnswer((_) async => {});
    when(mockSyncManager.simpanWaktuTerakhirunduh(any))
        .thenAnswer((_) async => {});
    when(mockNewDataCheck.resetNeedUpload()).thenAnswer((_) async => {});
  });

  group('SyncCheckService - runSyncCheck', () {
    test(
        'harus menjalankan upload dan download jika ada data baru di lokal dan server',
        () async {
      // ATUR
      when(mockNewDataCheck.apakahSqliteAdaDataBaru())
          .thenAnswer((_) async => true);
      when(mockNewDataCheck.apakahFirebaseAdaDataBaru(
        namaKoleksi: anyNamed('collectionName'),
        idDokumen: anyNamed('documentId'),
      )).thenAnswer((_) async => true);

      // JALANKAN
      await syncCheckService.jalankanCekSinkronisasi();

      // VERIFIKASI
      // Pastikan proses unggah terpicu
      verify(mockNewDataCheck.apakahSqliteAdaDataBaru()).called(1);
      verify(mockUploadService.uploadSemuaData()).called(1);
      verify(mockSyncManager.simpanWaktuTerkahirUnggah(any)).called(1);
      verify(mockNewDataCheck.resetNeedUpload()).called(1);

      // Pastikan status global diperbarui karena ada unggahan
      final statusDoc = await mockFirestore
          .collection(NamaTabel.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isTrue);
      expect(statusDoc.data(), contains(NamaKolom.diperbaruiPada));

      // Pastikan proses unduh terpicu
      verify(mockNewDataCheck.apakahFirebaseAdaDataBaru(
              namaKoleksi: NamaTabel.get(TableName.statusGlobal),
              idDokumen: globalStatusId))
          .called(1);
      verify(mockDownloadService.downloadAllData()).called(1);
      verify(mockSyncManager.simpanWaktuTerakhirunduh(any)).called(1);
    });

    test('harus menjalankan upload saja jika hanya ada data baru di lokal',
        () async {
      // ATUR
      when(mockNewDataCheck.apakahSqliteAdaDataBaru())
          .thenAnswer((_) async => true);
      when(mockNewDataCheck.apakahFirebaseAdaDataBaru(
        namaKoleksi: anyNamed('collectionName'),
        idDokumen: anyNamed('documentId'),
      )).thenAnswer((_) async => false);

      // JALANKAN
      await syncCheckService.jalankanCekSinkronisasi();

      // VERIFIKASI
      // Pastikan proses unggah terpicu
      verify(mockUploadService.uploadSemuaData()).called(1);
      verify(mockSyncManager.simpanWaktuTerkahirUnggah(any)).called(1);

      // Pastikan proses unduh diperiksa tapi tidak dieksekusi
      verify(mockNewDataCheck.apakahFirebaseAdaDataBaru(
              namaKoleksi: NamaTabel.get(TableName.statusGlobal),
              idDokumen: globalStatusId))
          .called(1);
      verifyNever(mockDownloadService.downloadAllData());
      verifyNever(mockSyncManager.simpanWaktuTerakhirunduh(any));
    });

    test('harus menjalankan download saja jika hanya ada data baru di server',
        () async {
      // ATUR
      when(mockNewDataCheck.apakahSqliteAdaDataBaru())
          .thenAnswer((_) async => false);
      when(mockNewDataCheck.apakahFirebaseAdaDataBaru(
        namaKoleksi: anyNamed('collectionName'),
        idDokumen: anyNamed('documentId'),
      )).thenAnswer((_) async => true);

      // JALANKAN
      await syncCheckService.jalankanCekSinkronisasi();

      // VERIFIKASI
      // Pastikan proses unggah diperiksa tapi tidak dieksekusi
      verify(mockNewDataCheck.apakahSqliteAdaDataBaru()).called(1);
      verifyNever(mockUploadService.uploadSemuaData());
      verifyNever(mockSyncManager.simpanWaktuTerkahirUnggah(any));

      // Pastikan status global tidak diperbarui
      final statusDoc = await mockFirestore
          .collection(NamaTabel.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isFalse);

      // Pastikan proses unduh terpicu
      verify(mockDownloadService.downloadAllData()).called(1);
      verify(mockSyncManager.simpanWaktuTerakhirunduh(any)).called(1);
    });

    test('tidak melakukan apa-apa jika tidak ada data baru sama sekali',
        () async {
      // ATUR
      when(mockNewDataCheck.apakahSqliteAdaDataBaru())
          .thenAnswer((_) async => false);
      when(mockNewDataCheck.apakahFirebaseAdaDataBaru(
        namaKoleksi: anyNamed('collectionName'),
        idDokumen: anyNamed('documentId'),
      )).thenAnswer((_) async => false);

      // JALANKAN
      await syncCheckService.jalankanCekSinkronisasi();

      // VERIFIKASI
      verify(mockNewDataCheck.apakahSqliteAdaDataBaru()).called(1);
      verifyNever(mockUploadService.uploadSemuaData());

      verify(mockNewDataCheck.apakahFirebaseAdaDataBaru(
              namaKoleksi: NamaTabel.get(TableName.statusGlobal),
              idDokumen: globalStatusId))
          .called(1);
      verifyNever(mockDownloadService.downloadAllData());

      final statusDoc = await mockFirestore
          .collection(NamaTabel.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isFalse);
    });

    test('harus log error dan tidak update metadata saat unggah gagal',
        () async {
      // ATUR
      when(mockNewDataCheck.apakahSqliteAdaDataBaru())
          .thenAnswer((_) async => true);
      when(mockUploadService.uploadSemuaData()).thenThrow(Exception('Gagal!'));
      when(mockNewDataCheck.apakahFirebaseAdaDataBaru(
              namaKoleksi: anyNamed('collectionName'),
              idDokumen: anyNamed('documentId')))
          .thenAnswer((_) async => false);

      // JALANKAN
      await syncCheckService.jalankanCekSinkronisasi();

      // VERIFIKASI
      verify(mockUploadService.uploadSemuaData()).called(1);

      // Pastikan metadata tidak diperbarui karena ada error
      verifyNever(mockSyncManager.simpanWaktuTerkahirUnggah(any));
      verifyNever(mockNewDataCheck.resetNeedUpload());
      final statusDoc = await mockFirestore
          .collection(NamaTabel.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .get();
      expect(statusDoc.exists, isFalse);

      // Pengecekan unduh harus tetap berjalan
      verify(mockNewDataCheck.apakahFirebaseAdaDataBaru(
              namaKoleksi: anyNamed('collectionName'),
              idDokumen: anyNamed('documentId')))
          .called(1);
    });

    test('harus log error dan tidak update metadata saat unduh gagal',
        () async {
      // ATUR
      when(mockNewDataCheck.apakahSqliteAdaDataBaru())
          .thenAnswer((_) async => false);
      when(mockNewDataCheck.apakahFirebaseAdaDataBaru(
              namaKoleksi: anyNamed('collectionName'),
              idDokumen: anyNamed('documentId')))
          .thenAnswer((_) async => true);
      when(mockDownloadService.downloadAllData())
          .thenThrow(Exception('Gagal!'));

      // JALANKAN
      await syncCheckService.jalankanCekSinkronisasi();

      // VERIFIKASI
      verify(mockDownloadService.downloadAllData()).called(1);
      verifyNever(mockSyncManager.simpanWaktuTerakhirunduh(any));
    });
  });
}
