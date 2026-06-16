
// path: test/shared/data/services/pengecekan_data_baru_service_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/data/services/pengecekan_data_baru_service.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/status_upload_op_sqlite.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockSyncManager extends Mock implements SyncManager {}

class MockStatusUploadOpSqlite extends Mock implements StatusUploadOpSqlite {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late PengecekanDataBaruService pengecekanDataBaruService;
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late MockStatusUploadOpSqlite mockStatusUploadOpSqlite;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockStatusUploadOpSqlite = MockStatusUploadOpSqlite();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    pengecekanDataBaruService = PengecekanDataBaruService(
      firestore: mockFirestore,
      syncManager: mockSyncManager,
      uploadStatusOperation: mockStatusUploadOpSqlite,
    );

    // General stubbing for Firestore
    when(() => mockFirestore.collection(any())).thenReturn(mockCollectionReference);
    when(() => mockCollectionReference.doc(any()))
        .thenReturn(mockDocumentReference);
    when(() => mockDocumentReference.get(any())).thenAnswer((_) async => mockDocumentSnapshot);
  });

  group('apakahSqliteAdaDataBaru', () {
    test('01. harus mengembalikan true jika butuh upload', () async {
      when(() => mockStatusUploadOpSqlite.ambilButuhUpload())
          .thenAnswer((_) async => true);

      final result = await pengecekanDataBaruService.apakahSqliteAdaDataBaru();

      expect(result, isTrue);
      verify(() => mockStatusUploadOpSqlite.ambilButuhUpload()).called(1);
    });

    test('02. harus mengembalikan false jika tidak butuh upload', () async {
      when(() => mockStatusUploadOpSqlite.ambilButuhUpload())
          .thenAnswer((_) async => false);

      final result = await pengecekanDataBaruService.apakahSqliteAdaDataBaru();

      expect(result, isFalse);
    });

    test('03. harus mengembalikan false jika terjadi exception', () async {
      when(() => mockStatusUploadOpSqlite.ambilButuhUpload())
          .thenThrow(Exception('DB Error'));

      final result = await pengecekanDataBaruService.apakahSqliteAdaDataBaru();

      expect(result, isFalse);
    });
  });

  group('resetButuhUpload', () {
    test('01. harus memanggil resetStatusUpload', () async {
      when(() => mockStatusUploadOpSqlite.resetStatusUpload())
          .thenAnswer((_) async {});

      await pengecekanDataBaruService.resetButuhUpload();

      verify(() => mockStatusUploadOpSqlite.resetStatusUpload()).called(1);
    });

    test('02. harus menangani exception tanpa melempar error', () async {
      when(() => mockStatusUploadOpSqlite.resetStatusUpload())
          .thenThrow(Exception('DB Error'));

      expect(() => pengecekanDataBaruService.resetButuhUpload(), returnsNormally);
    });
  });

  group('apakahFirebaseAdaDataBaru', () {
    final waktuLokal = DateTime(2023, 1, 1, 10, 0, 0);
    final waktuServerBaru = Timestamp.fromDate(waktuLokal.add(const Duration(minutes: 5)));
    final waktuServerLama = Timestamp.fromDate(waktuLokal.subtract(const Duration(minutes: 5)));

    setUp(() {
      when(() => mockSyncManager.ambilWaktuTerakhirDownload())
          .thenAnswer((_) async => waktuLokal);
    });

    test('01. harus mengembalikan true jika data server lebih baru', () async {
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.data()).thenReturn({NamaKolom.diperbaruiPada: waktuServerBaru});

      final result = await pengecekanDataBaruService.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status',
        idDokumen: 'global',
      );

      expect(result, isTrue);
    });

    test('02. harus mengembalikan false jika data server lebih lama', () async {
       when(() => mockDocumentSnapshot.exists).thenReturn(true);
       when(() => mockDocumentSnapshot.data()).thenReturn({NamaKolom.diperbaruiPada: waktuServerLama});

      final result = await pengecekanDataBaruService.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status',
        idDokumen: 'global',
      );

       expect(result, isFalse);
    });

    test('03. harus mengembalikan false jika dokumen tidak ada', () async {
      when(() => mockDocumentSnapshot.exists).thenReturn(false);

      final result = await pengecekanDataBaruService.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status',
        idDokumen: 'global',
      );

      expect(result, isFalse);
    });

    test('04. harus mengembalikan false jika field diperbaruiPada tidak ada', () async {
      when(() => mockDocumentSnapshot.exists).thenReturn(true);
      when(() => mockDocumentSnapshot.data()).thenReturn({'fieldLain': 'nilai'});

      final result = await pengecekanDataBaruService.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status',
        idDokumen: 'global',
      );

      expect(result, isFalse);
    });

    test('05. harus mengembalikan false jika field diperbaruiPada null atau tidak valid', () async {
       when(() => mockDocumentSnapshot.exists).thenReturn(true);
       when(() => mockDocumentSnapshot.data()).thenReturn({NamaKolom.diperbaruiPada: null});

      final result = await pengecekanDataBaruService.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status',
        idDokumen: 'global',
      );

       expect(result, isFalse);
    });

    test('06. harus mengembalikan false jika firestore.get() melempar exception', () async {
      when(() => mockDocumentReference.get(any())).thenThrow(Exception('Network Error'));

      final result = await pengecekanDataBaruService.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status',
        idDokumen: 'global',
      );

      expect(result, isFalse);
    });
  });
}
