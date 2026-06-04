// path: test/shared/data/sync/initial_download_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';

import 'initial_download_test.mocks.dart';

@GenerateMocks([DownloadDataService, DatabaseHelper, Database])
void main() {
  late InitialDownloadService initialDownloadService;
  late MockDownloadDataService mockDownloadDataService;
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;

  setUp(() {
    mockDownloadDataService = MockDownloadDataService();
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();

    // Mock DatabaseHelper agar mengembalikan mock database
    when(mockDbHelper.database).thenAnswer((_) async => mockDb);

    initialDownloadService = InitialDownloadService(
      downloadService: mockDownloadDataService,
      dbHelper: mockDbHelper,
    );
  });

  group('InitialDownloadService', () {
    test('runInitialDownload melakukan unduh jika tabel-tabel kosong',
        () async {
      // Mock query count mengembalikan 0 (tabel kosong)
      when(mockDb.rawQuery(any)).thenAnswer((_) async => [
            {'count': 0}
          ]);

      // Mock semua fungsi download agar berhasil
      when(mockDownloadDataService.downloadPackageData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadCategoryData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadSubCategoryData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadWalletData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadCustomerData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadApkVersionData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadSettingsData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadActiveCustomerData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadTransactionData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadFeedbackData())
          .thenAnswer((_) async {});
      when(mockDownloadDataService.downloadOrderData())
          .thenAnswer((_) async {});

      await initialDownloadService.runInitialDownload();

      // Verifikasi bahwa orchestration memanggil fungsi download
      verify(mockDownloadDataService.downloadPackageData()).called(1);
      verify(mockDownloadDataService.downloadCategoryData()).called(1);
      verify(mockDownloadDataService.downloadWalletData()).called(1);
    });

    test('runInitialDownload melewati unduh jika tabel sudah memiliki data',
        () async {
      // Mock query count mengembalikan nilai > 0 (tabel tidak kosong)
      when(mockDb.rawQuery(any)).thenAnswer((_) async => [
            {'count': 10}
          ]);

      await initialDownloadService.runInitialDownload();

      // Verifikasi bahwa fungsi download tidak pernah dipanggil
      verifyNever(mockDownloadDataService.downloadPackageData());
      verifyNever(mockDownloadDataService.downloadCategoryData());
      verifyNever(mockDownloadDataService.downloadWalletData());
    });
  });
}
