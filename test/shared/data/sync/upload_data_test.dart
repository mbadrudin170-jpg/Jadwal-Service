// path: test/shared/data/sync/upload_data_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
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
import 'package:wifi/shared/operasi/firebase_operasi/active_customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/apk_version_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/category_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/feedback_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/order_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/settings_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/sub_category_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/wallet_op_firebase.dart';
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

import 'upload_data_test.mocks.dart';

@GenerateMocks([
  // Firebase Operations
  WalletOpFirebase,
  CategoryOpFirebase,
  PackageOpFirebase,
  CustomerOpFirebase,
  ActiveCustomerOpFirebase,
  TransactionOpFirebase,
  FeedbackOpFirebase,
  OrderOpFirebase,
  SubCategoryOpFirebase,
  ApkVersionOpFirebase,
  SettingsOpFirebase,
  // SQLite Operations
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
  SyncManager,
])
void main() {
  late UploadDataService uploadDataService;
  // Mocks for Firebase
  late MockWalletOpFirebase mockWalletOpFirebase;
  late MockCategoryOpFirebase mockCategoryOpFirebase;
  late MockPackageOpFirebase mockPackageOpFirebase;
  late MockCustomerOpFirebase mockCustomerOpFirebase;
  late MockActiveCustomerOpFirebase mockActiveCustomerOpFirebase;
  late MockTransactionOpFirebase mockTransactionOpFirebase;
  late MockFeedbackOpFirebase mockFeedbackOpFirebase;
  late MockOrderOpFirebase mockOrderOpFirebase;
  late MockSubCategoryOpFirebase mockSubCategoryOpFirebase;
  late MockApkVersionOpFirebase mockApkVersionOpFirebase;
  late MockSettingsOpFirebase mockSettingsOpFirebase;
  // Mocks for SQLite
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
  // Other mocks
  late MockSyncManager mockSyncManager;

  setUp(() {
    mockWalletOpFirebase = MockWalletOpFirebase();
    mockCategoryOpFirebase = MockCategoryOpFirebase();
    mockPackageOpFirebase = MockPackageOpFirebase();
    mockCustomerOpFirebase = MockCustomerOpFirebase();
    mockActiveCustomerOpFirebase = MockActiveCustomerOpFirebase();
    mockTransactionOpFirebase = MockTransactionOpFirebase();
    mockFeedbackOpFirebase = MockFeedbackOpFirebase();
    mockOrderOpFirebase = MockOrderOpFirebase();
    mockSubCategoryOpFirebase = MockSubCategoryOpFirebase();
    mockApkVersionOpFirebase = MockApkVersionOpFirebase();
    mockSettingsOpFirebase = MockSettingsOpFirebase();

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

    mockSyncManager = MockSyncManager();

    uploadDataService = UploadDataService.forTest(
      walletOpFirebase: mockWalletOpFirebase,
      categoryOpFirebase: mockCategoryOpFirebase,
      packageOpFirebase: mockPackageOpFirebase,
      customerOpFirebase: mockCustomerOpFirebase,
      activeCustomerOpFirebase: mockActiveCustomerOpFirebase,
      transactionOpFirebase: mockTransactionOpFirebase,
      feedbackOpFirebase: mockFeedbackOpFirebase,
      orderOpFirebase: mockOrderOpFirebase,
      subCategoryOpFirebase: mockSubCategoryOpFirebase,
      apkVersionOpFirebase: mockApkVersionOpFirebase,
      settingsOpFirebase: mockSettingsOpFirebase,
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
      syncManager: mockSyncManager,
    );
  });

  group('UploadDataService', () {
    final lastSync = DateTime(2023);

    setUp(() {
      when(mockSyncManager.getLastUpload()).thenAnswer((_) async => lastSync);
    });

    test('uploadAllData orchestrates all individual upload methods', () async {
      // Setup SQLite mocks to return empty lists to avoid upload logic
      when(mockWalletOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockCategoryOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockPackageOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockCustomerOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockActiveCustomerOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockTransactionOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockFeedbackOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockOrderOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockSubCategoryOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockApkVersionOperation.getUnsynced(any)).thenAnswer((_) async => []);
      when(mockSettingsOperation.getUnsynced(any)).thenAnswer((_) async => []);

      await uploadDataService.uploadAllData();

      verify(mockSyncManager.getLastUpload()).atLeast(10);
    });

    test('synchronizeCollection uploads data when local unsynced data is found', () async {
      final unsyncedData = [WalletModel(id: 'wallet1', balance: 100)];
      when(mockWalletOperation.getUnsynced(any)).thenAnswer((_) async => unsyncedData);
      when(mockWalletOpFirebase.insertOrUpdateBatch(any)).thenAnswer((_) async {});

      await uploadDataService.synchronizeCollection<WalletModel, WalletOpFirebase>(
        localOperation: mockWalletOperation,
        remoteOperation: mockWalletOpFirebase,
        lastUploadTime: lastSync,
      );

      verify(mockWalletOpFirebase.insertOrUpdateBatch(unsyncedData)).called(1);
    });

    test('synchronizeCollection does not upload when no unsynced data is found', () async {
      when(mockWalletOperation.getUnsynced(any)).thenAnswer((_) async => []);

       await uploadDataService.synchronizeCollection<WalletModel, WalletOpFirebase>(
        localOperation: mockWalletOperation,
        remoteOperation: mockWalletOpFirebase,
        lastUploadTime: lastSync,
      );

      verifyNever(mockWalletOpFirebase.insertOrUpdateBatch(any));
    });
  });
}
