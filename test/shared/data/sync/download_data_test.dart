// path: test/shared/data/sync/download_data_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/feedback_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/package_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

import 'download_data_test.mocks.dart';

@GenerateMocks([
  SyncManager,
  WalletOperation,
  CategoryOperation,
  PackageOperation,
  CustomerOperation,
  ActiveCustomerOperation,
  TransactionOperation,
  FeedbackOperation,
  OrderOperation,
  SubCategoryOperation,
  ApkVersionOperation,
  SettingsOperation,
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
  late MockWalletOperation mockWalletOperation;
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
  late MockQuery<Map<String, dynamic>> mockQuery;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockWalletOperation = MockWalletOperation();
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
    mockQuery = MockQuery<Map<String, dynamic>>();

    downloadDataService = DownloadDataService.test(
      firestore: mockFirestore,
      syncManager: mockSyncManager,
      walletOperation: mockWalletOperation,
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

  group('DownloadDataService', () {
    final lastSync = DateTime(2023);

    setUp(() {
      when(mockSyncManager.getLastDownload()).thenAnswer((_) async => lastSync);

      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(
        mockCollection.where(any, isGreaterThan: any),
      ).thenReturn(mockQuery);
      when(mockQuery.get(any)).thenAnswer((_) async => mockQuerySnapshot);

      when(mockQuerySnapshot.docs).thenReturn([mockDoc]);
      when(mockDoc.id).thenReturn('doc1');
      when(
        mockDoc.data(),
      ).thenReturn({'updatedAt': Timestamp.fromDate(DateTime(2024))});
    });

    test(
      'downloadAllData orchestrates all individual download methods',
      () async {
        await downloadDataService.downloadAllData();

        verify(
          mockSyncManager.getLastDownload(),
        ).called(greaterThanOrEqualTo(10));
        verify(mockFirestore.collection(any)).called(greaterThanOrEqualTo(10));
      },
    );

    test(
      'synchronizeCollection saves data when new documents are found',
      () async {
        await downloadDataService.synchronizeCollection<CategoryModel>(
          collectionName: 'categories',
          lastDownloadTime: lastSync,
          fromFirebase: (id, data) => CategoryModel(
            id: id,
            name: 'Test Category',
            type: CategoryType.income,
          ),
          batchOperation: (data) =>
              mockCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
        );

        verify(
          mockCategoryOperation.insertOrUpdateBatch(any, fromServer: true),
        ).called(1);
      },
    );

    test(
      'synchronizeCollection does nothing when no new documents are found',
      () async {
        when(mockQuerySnapshot.docs).thenReturn([]);

        await downloadDataService.synchronizeCollection<CategoryModel>(
          collectionName: 'categories',
          lastDownloadTime: lastSync,
          fromFirebase: (id, data) => CategoryModel(
            id: id,
            name: 'Test Category',
            type: CategoryType.income,
          ),
          batchOperation: (data) =>
              mockCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
        );

        verifyNever(
          mockCategoryOperation.insertOrUpdateBatch(any, fromServer: any),
        );
      },
    );

    test(
      'downloadSettingsData updates settings if server time is newer',
      () async {
        final serverTime = DateTime(2025);
        final mockSettingsDoc = MockDocumentSnapshot<Map<String, dynamic>>();
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(
          mockFirestore.collection('settings').doc(any),
        ).thenReturn(mockDocRef);
        when(mockDocRef.get(any)).thenAnswer((_) async => mockSettingsDoc);
        when(mockSettingsDoc.exists).thenReturn(true);
        when(mockSettingsDoc.id).thenReturn('settingsId');
        when(mockSettingsDoc.data()).thenReturn({
          'updatedAt': Timestamp.fromDate(serverTime),
          'some_setting': 'new_value',
        });

        await downloadDataService.downloadSettingsData();

        verify(
          mockSettingsOperation.saveOrUpdateSettings(any, fromServer: true),
        ).called(1);
      },
    );

    test(
      'downloadSettingsData does not update if local time is newer or same',
      () async {
        final serverTime = DateTime(2022); // Older than lastSync
        final mockSettingsDoc = MockDocumentSnapshot<Map<String, dynamic>>();
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        when(
          mockFirestore.collection('settings').doc(any),
        ).thenReturn(mockDocRef);
        when(mockDocRef.get(any)).thenAnswer((_) async => mockSettingsDoc);
        when(mockSettingsDoc.exists).thenReturn(true);
        when(mockSettingsDoc.data()).thenReturn({
          'updatedAt': Timestamp.fromDate(serverTime),
          'some_setting': 'old_value',
        });

        await downloadDataService.downloadSettingsData();

        verifyNever(
          mockSettingsOperation.saveOrUpdateSettings(any, fromServer: any),
        );
      },
    );
  });
}
