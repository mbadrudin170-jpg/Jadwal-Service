// path: test/shared/data/sync/download_data_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/model/order_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
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

// Mocking FirebaseFirestore isn't straightforward, so we'll trust the Firestore mock behavior.
// For real integration, this would be a fake implementation.
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

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

    // This is a simplified mock setup. A real firestore mock is complex.
    // We will assume the mock query snapshot behaves as expected.
    // In a real scenario, package like `fake_cloud_firestore` is better.
    final mockQuerySnapshot = _MockQuerySnapshot([
      _MockQueryDocumentSnapshot(
          'doc1', {'updatedAt': Timestamp.fromDate(DateTime(2024))})
    ]);

    setUp(() {
      when(mockSyncManager.getLastDownload()).thenAnswer((_) async => lastSync);
      // A generic mock for any collection call
      when(mockFirestore.collection(any))
          .thenReturn(_MockCollectionReference());
      when(_MockCollectionReference().where(any, isGreaterThan: any).get(any))
          .thenAnswer((_) async => mockQuerySnapshot);
      when(mockSettingsOperation.saveOrUpdateSettings(any, fromServer: any))
          .thenAnswer((_) async => 1);
    });

    test('downloadAllData orchestrates all individual download methods',
        () async {
      // For this test, we just want to ensure all download methods are called.
      // We can do this by mocking the individual download methods if they were public,
      // but since they are, let's verify the inner calls.

      await downloadDataService.downloadAllData();

      // Verify that for each collection, it tries to get new data.
      // This is a simplified verification.
      verify(mockSyncManager.getLastDownload())
          .atLeast(10); // Called by each download method
      verify(mockFirestore.collection(any)).atLeast(10);
    });

    test('synchronizeCollection saves data when new documents are found',
        () async {
      await downloadDataService.synchronizeCollection<CategoryModel>(
        collectionName: 'categories',
        lastDownloadTime: lastSync,
        fromFirebase: (id, data) => CategoryModel(id: id),
        batchOperation: (data) =>
            mockCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
      );

      verify(mockCategoryOperation.insertOrUpdateBatch(any, fromServer: true))
          .called(1);
    });

    test('synchronizeCollection does nothing when no new documents are found',
        () async {
      when(_MockCollectionReference().where(any, isGreaterThan: any).get(any))
          .thenAnswer(
              (_) async => _MockQuerySnapshot([])); // Return empty snapshot

      await downloadDataService.synchronizeCollection<CategoryModel>(
        collectionName: 'categories',
        lastDownloadTime: lastSync,
        fromFirebase: (id, data) => CategoryModel(id: id),
        batchOperation: (data) =>
            mockCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
      );

      verifyNever(
          mockCategoryOperation.insertOrUpdateBatch(any, fromServer: any));
    });

    test('downloadSettingsData updates settings if server time is newer',
        () async {
      final serverTime = DateTime(2025);
      final settingsDoc = _MockDocumentSnapshot('settingsId', {
        'updatedAt': Timestamp.fromDate(serverTime),
        'some_setting': 'new_value'
      });
      final docRef = _MockDocumentReference();
      when(mockFirestore.collection('settings').doc(any)).thenReturn(docRef);
      when(docRef.get(any)).thenAnswer((_) async => settingsDoc);

      await downloadDataService.downloadSettingsData();

      verify(mockSettingsOperation.saveOrUpdateSettings(any, fromServer: true))
          .called(1);
    });

    test('downloadSettingsData does not update if local time is newer or same',
        () async {
      final serverTime = DateTime(2022); // Older than lastSync
      final settingsDoc = _MockDocumentSnapshot('settingsId', {
        'updatedAt': Timestamp.fromDate(serverTime),
        'some_setting': 'old_value'
      });
      final docRef = _MockDocumentReference();
      when(mockFirestore.collection('settings').doc(any)).thenReturn(docRef);
      when(docRef.get(any)).thenAnswer((_) async => settingsDoc);

      await downloadDataService.downloadSettingsData();

      verifyNever(
          mockSettingsOperation.saveOrUpdateSettings(any, fromServer: any));
    });
  });
}

// Minimal mocking classes for Firestore components to avoid `fake_cloud_firestore`
class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs;
  _MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

class _MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;
  _MockQueryDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;
}

class _MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  @override
  Future<Query<Map<String, dynamic>>> where(Object field,
      {Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      Iterable<Object?>? arrayContainsAny,
      Iterable<Object?>? whereIn,
      Iterable<Object?>? whereNotIn,
      bool? isNull}) async {
    return this as Query<Map<String, dynamic>>; // Simplified for this test
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return _MockQuerySnapshot([]);
  }
}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;
  _MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;
}
