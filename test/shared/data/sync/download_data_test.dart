// path: test/shared/data/sync/download_data_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/kategori_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

import 'download_data_test.mocks.dart';

@GenerateMocks([
  SyncManager,
  DompetOpSqlite,
  KategoriOpSqlite,
  PaketOpSqlite,
  PelangganOpSqlite,
  PelangganAktifOpSqlite,
  TransaksiOpsqlite,
  FeedbackOperation,
  OrderOpsqlite,
  SubKategoriOpSqlite,
  ApkVersionOperation,
  SettingsOpSqlite,
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late DownloadDataService downloadDataService;
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockCategoryOperation mockCategoryOperation;
  late MockPackageOperation mockPackageOperation;
  late MockCustomerOperation mockCustomerOperation;
  late MockActiveCustomerOperation mockActiveCustomerOperation;
  late MockTransactionOperation mockTransactionOperation;
  late MockFeedbackOperation mockFeedbackOperation;
  late MockOrderOperation mockOrderOperation;
  late MockSubCategoryOperation mockSubCategoryOperation;
  late MockApkVersionOperation mockApkVersionOperation;
  late MockSettingsOperation mockSettingsOperation;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDoc;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSettingsDoc;
  late MockQuery<Map<String, dynamic>> mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockCategoryOperation = MockCategoryOperation();
    mockPackageOperation = MockPackageOperation();
    mockCustomerOperation = MockCustomerOperation();
    mockActiveCustomerOperation = MockActiveCustomerOperation();
    mockTransactionOperation = MockTransactionOperation();
    mockFeedbackOperation = MockFeedbackOperation();
    mockOrderOperation = MockOrderOperation();
    mockSubCategoryOperation = MockSubCategoryOperation();
    mockApkVersionOperation = MockApkVersionOperation();
    mockSettingsOperation = MockSettingsOperation();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockSettingsDoc = MockDocumentSnapshot<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();

    downloadDataService = DownloadDataService.test(
      firestore: mockFirestore,
      syncManager: mockSyncManager,
      walletOperation: mockDompetOpSqlite,
      categoryOperation: mockCategoryOperation,
      packageOperation: mockPackageOperation,
      customerOperation: mockCustomerOperation,
      activeCustomerOperation: mockActiveCustomerOperation,
      transactionOperation: mockTransactionOperation,
      feedbackOperation: mockFeedbackOperation,
      orderOperation: mockOrderOperation,
      subCategoryOperation: mockSubCategoryOperation,
      apkVersionOperation: mockApkVersionOperation,
      settingsOperation: mockSettingsOperation,
    );
  });

  group('Pengujian DownloadDataService', () {
    final lastSync = DateTime(2023);

    setUp(() {
      when(mockSyncManager.ambilTanggalTerakhirDownload())
          .thenAnswer((_) async => lastSync);

      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.get(any)).thenAnswer((_) async => mockSettingsDoc);
      when(
        mockCollection.where(any, isGreaterThan: anyNamed('isGreaterThan')),
      ).thenReturn(mockQuery);
      when(mockQuery.get(any)).thenAnswer((final _) async => mockQuerySnapshot);

      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockDoc.id).thenReturn('doc1');
      when(
        mockDoc.data(),
      ).thenReturn(
          {NamaKolom.diperbaruiPada: Timestamp.fromDate(DateTime(2024))});

      when(mockSettingsDoc.exists).thenReturn(false);
    });

    test(
      '1. downloadAllData harus mengoordinasikan semua metode unduh individu',
      () async {
        await downloadDataService.downloadAllData();

        verify(
          mockSyncManager.ambilTanggalTerakhirDownload(),
        ).called(greaterThanOrEqualTo(10));
        verify(mockFirestore.collection(any)).called(greaterThanOrEqualTo(10));
      },
    );

    test(
      '2. synchronizeCollection harus menyimpan data ketika dokumen baru ditemukan',
      () async {
        when(mockQuerySnapshot.docs).thenReturn([mockDoc]);

        await downloadDataService.synchronizeCollection<KategoriModel>(
          collectionName: 'categories',
          lastDownloadTime: lastSync,
          fromFirebase: (final id, final data) => KategoriModel(
            id: id,
            nama: 'Test Category',
            tipe: TipeKategori.income,
          ),
          batchOperation: (final data) =>
              mockCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
        );

        verify(
          mockCategoryOperation.insertOrUpdateBatch(any, fromServer: true),
        ).called(1);
      },
    );

    test(
      '3. synchronizeCollection tidak melakukan apa pun jika tidak ada dokumen baru',
      () async {
        when(mockQuerySnapshot.docs).thenReturn([]);

        await downloadDataService.synchronizeCollection<KategoriModel>(
          collectionName: 'categories',
          lastDownloadTime: lastSync,
          fromFirebase: (final id, final data) => KategoriModel(
            id: id,
            nama: 'Test Category',
            tipe: TipeKategori.income,
          ),
          batchOperation: (final data) =>
              mockCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
        );

        verifyNever(
          mockCategoryOperation.insertOrUpdateBatch(
            any,
            fromServer: anyNamed('fromServer'),
          ),
        );
      },
    );

    test(
      '4. downloadSettingsData harus memperbarui pengaturan jika waktu server lebih baru',
      () async {
        final serverTime = DateTime(2025);
        when(mockDocRef.get(any))
            .thenAnswer((final _) async => mockSettingsDoc);
        when(mockSettingsDoc.exists).thenReturn(true);
        when(mockSettingsDoc.id).thenReturn('settingsId');
        when(mockSettingsDoc.data()).thenReturn({
          NamaKolom.diperbaruiPada: Timestamp.fromDate(serverTime),
          'autoSyncInterval': 2,
          'autoDeleteArchiveDays': 30,
          'maintenanceMode': false,
          'maintenanceInfo': '',
        });

        await downloadDataService.downloadSettingsData();

        verify(
          mockSettingsOperation.saveOrUpdateSettings(any, fromServer: true),
        ).called(1);
      },
    );

    test(
      '5. downloadSettingsData tidak boleh memperbarui jika waktu lokal lebih baru atau sama',
      () async {
        final serverTime = DateTime(2022); // Older than lastSync
        when(mockDocRef.get(any))
            .thenAnswer((final _) async => mockSettingsDoc);
        when(mockSettingsDoc.exists).thenReturn(true);
        when(mockSettingsDoc.data()).thenReturn({
          NamaKolom.diperbaruiPada: Timestamp.fromDate(serverTime),
          'autoSyncInterval': 2,
          'autoDeleteArchiveDays': 30,
          'maintenanceMode': false,
          'maintenanceInfo': '',
        });

        await downloadDataService.downloadSettingsData();

        verifyNever(
          mockSettingsOperation.saveOrUpdateSettings(
            any,
            fromServer: anyNamed('fromServer'),
          ),
        );
      },
    );
  });
}
