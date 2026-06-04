// path: test/shared/data/sync/upload_data_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

import 'upload_data_test.mocks.dart';

@GenerateMocks([
  DatabaseHelper,
  FirebaseFirestore,
  SyncManager,
  Database,
  WriteBatch,
  CollectionReference,
  DocumentReference,
])
void main() {
  late UploadDataService uploadDataService;
  late MockDatabaseHelper mockDbHelper;
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late MockDatabase mockDb;
  late MockWriteBatch mockBatch;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockDb = MockDatabase();
    mockBatch = MockWriteBatch();

    when(mockDbHelper.database).thenAnswer((_) async => mockDb);
    when(mockFirestore.batch()).thenReturn(mockBatch);

    uploadDataService = UploadDataService(
      dbHelper: mockDbHelper,
      firestore: mockFirestore,
      syncManager: mockSyncManager,
    );
  });

  group('UploadDataService', () {
    final lastSync = DateTime(2023);

    setUp(() {
      when(mockSyncManager.getLastUpload()).thenAnswer((_) async => lastSync);
    });

    test('uploadAllData orchestrates all individual upload methods', () async {
      when(mockDb.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      await uploadDataService.uploadAllData();

      verify(mockSyncManager.getLastUpload()).called(greaterThanOrEqualTo(10));
    });

    test('uploadGenericData uploads data when local unsynced data is found',
        () async {
      final unsyncedMap = {
        'id': 'wallet1',
        'balance': 100.0,
        'name': 'Test Wallet',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      when(mockDb.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [unsyncedMap]);

      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();

      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDoc);
      when(mockBatch.commit()).thenAnswer((_) async => []);

      await uploadDataService.uploadGenericData<WalletModel>(
        'wallets',
        'wallets',
        WalletModel.fromSqlite,
        (m) => m.toFirebase(),
        lastSync,
      );

      verify(mockBatch.set(any, any, any)).called(1);
      verify(mockBatch.commit()).called(1);
    });

    test('uploadGenericData does not upload when no unsynced data is found',
        () async {
      when(mockDb.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => []);

      await uploadDataService.uploadGenericData<WalletModel>(
        'wallets',
        'wallets',
        WalletModel.fromSqlite,
        (m) => m.toFirebase(),
        lastSync,
      );

      verifyNever(mockBatch.set(any, any, any));
      verifyNever(mockBatch.commit());
    });
  });
}
