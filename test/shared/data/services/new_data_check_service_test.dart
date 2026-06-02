// path: test/shared/data/services/new_data_check_service_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/data/services/new_data_check_service.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/upload_status_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

import 'new_data_check_service_test.mocks.dart';

// Menambahkan semua kelas yang perlu di-mock, termasuk dari Firebase.
// Ini adalah cara yang paling andal untuk memastikan mockito dapat menangani semua metode.
@GenerateMocks([
  UploadStatusOperation,
  SyncManager,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
])
void main() {
  late NewDataCheckService service;
  late MockSyncManager mockSyncManager;
  late MockUploadStatusOperation mockUploadStatusOperation;

  setUp(() {
    // Menggunakan mock yang akan digenerate oleh build_runner
    mockSyncManager = MockSyncManager();
    mockUploadStatusOperation = MockUploadStatusOperation();
  });

  group('Pengecekan Data Baru di Lokal (SQLite)', () {
    test('harus mengembalikan true jika ada data yang belum diunggah di SQLite',
        () async {
      // Membuat instance service di dalam test untuk isolasi
      service = NewDataCheckService(
        firestore: FakeFirebaseFirestore(),
        syncManager: mockSyncManager,
        uploadStatusOperation: mockUploadStatusOperation,
      );
      when(mockUploadStatusOperation.getNeedUpload())
          .thenAnswer((_) async => true);

      final result = await service.hasNewSqliteData();

      expect(result, isTrue);
      verify(mockUploadStatusOperation.getNeedUpload()).called(1);
    });

    test(
        'harus mengembalikan false jika tidak ada data yang belum diunggah di SQLite',
        () async {
      service = NewDataCheckService(
        firestore: FakeFirebaseFirestore(),
        syncManager: mockSyncManager,
        uploadStatusOperation: mockUploadStatusOperation,
      );
      when(mockUploadStatusOperation.getNeedUpload())
          .thenAnswer((_) async => false);

      final result = await service.hasNewSqliteData();

      expect(result, isFalse);
      verify(mockUploadStatusOperation.getNeedUpload()).called(1);
    });
  });

  group('Pengecekan Data Baru di Firebase', () {
    const String testCollection = 'status';
    const String testDocument = 'status_document';
    final lastDownloadTime = DateTime(2023, 1, 1, 12);

    // Tes yang menggunakan implementasi nyata (FakeFirebaseFirestore)
    test('harus mengembalikan true jika ada data baru di Firebase', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      service = NewDataCheckService(
        firestore: fakeFirestore,
        syncManager: mockSyncManager,
        uploadStatusOperation: mockUploadStatusOperation,
      );
      when(mockSyncManager.getLastDownload())
          .thenAnswer((_) async => lastDownloadTime);

      final newDataTime = lastDownloadTime.add(const Duration(hours: 1));
      await fakeFirestore.collection(testCollection).doc(testDocument).set({
        'updated_at': Timestamp.fromDate(newDataTime),
      });

      final result = await service.hasNewFirebaseData(
          collectionName: testCollection, documentId: testDocument);

      expect(result, isTrue);
      verify(mockSyncManager.getLastDownload()).called(1);
    });

    test('harus mengembalikan false jika tidak ada data baru di Firebase',
        () async {
      final fakeFirestore = FakeFirebaseFirestore();
      service = NewDataCheckService(
        firestore: fakeFirestore,
        syncManager: mockSyncManager,
        uploadStatusOperation: mockUploadStatusOperation,
      );
      when(mockSyncManager.getLastDownload())
          .thenAnswer((_) async => lastDownloadTime);

      final oldDataTime = lastDownloadTime.subtract(const Duration(hours: 1));
      await fakeFirestore.collection(testCollection).doc(testDocument).set({
        'updated_at': Timestamp.fromDate(oldDataTime),
      });

      final result = await service.hasNewFirebaseData(
          collectionName: testCollection, documentId: testDocument);

      expect(result, isFalse);
      verify(mockSyncManager.getLastDownload()).called(1);
    });

    // Tes yang gagal sebelumnya, sekarang diperbaiki dengan mock yang digenerate
    test('harus mengembalikan false jika terjadi error saat query', () async {
      when(mockSyncManager.getLastDownload())
          .thenAnswer((_) async => lastDownloadTime);

      // Menggunakan Mocks yang digenerate untuk seluruh rantai panggilan Firestore
      final mockFirestore = MockFirebaseFirestore();
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDocument = MockDocumentReference<Map<String, dynamic>>();

      // Membuat instance service dengan mock Firestore
      final serviceWithMock = NewDataCheckService(
        firestore: mockFirestore,
        syncManager: mockSyncManager,
        uploadStatusOperation: mockUploadStatusOperation,
      );

      // Menyiapkan rantai stubbing dari firestore -> collection -> doc -> get
      when(mockFirestore.collection(testCollection)).thenReturn(mockCollection);
      when(mockCollection.doc(testDocument)).thenReturn(mockDocument);
      when(mockDocument.get(any))
          .thenThrow(FirebaseException(plugin: 'test', message: 'Test Error'));

      final result = await serviceWithMock.hasNewFirebaseData(
          collectionName: testCollection, documentId: testDocument);

      expect(result, isFalse, reason: 'Harusnya false karena ada exception');

      // Verifikasi bahwa semua metode yang diharapkan dipanggil
      verify(mockSyncManager.getLastDownload()).called(1);
      verify(mockFirestore.collection(testCollection)).called(1);
      verify(mockCollection.doc(testDocument)).called(1);
      verify(mockDocument.get(any)).called(1);
    });
  });
}
