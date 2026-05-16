// path: test/shared/data/services/pengecekan_data_baru_test.dart
// ignore_for_file: avoid_implementing_value_types, subtype_of_sealed_class

@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/data/services/pengecekan_data_baru.dart';
import 'package:wifi/shared/operasi/upload_status_operasi.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// --- Mock ---
// Mock untuk FirebaseFirestore diperlukan sebagai dependensi service.
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

// Mock CollectionReference: sealed class dari Firestore, hanya untuk testing.
class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

// Mock DocumentReference: sealed class dari Firestore, hanya untuk testing.
class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

// Mock DocumentSnapshot: sealed class dari Firestore, hanya untuk testing.
class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

class MockSyncManager extends Mock implements SyncManager {}

class MockStatusUnggahOperasi extends Mock implements StatusUnggahOperasi {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late MockStatusUnggahOperasi mockStatusUnggah;
  late PengecekanDataBaruService service;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockStatusUnggah = MockStatusUnggahOperasi();
    service = PengecekanDataBaruService(
      firestore: mockFirestore,
      syncManager: mockSyncManager,
      statusUnggahOperasi: mockStatusUnggah,
    );
    registerFallbackValue(const GetOptions());
  });

  // ============ apakahSqliteAdaDataBaru ============
  group('apakahSqliteAdaDataBaru', () {
    test('mengembalikan true jika status perlu_unggah true', () async {
      when(() => mockStatusUnggah.getPerluUnggah())
          .thenAnswer((final _) async => true);

      final result = await service.apakahSqliteAdaDataBaru();
      expect(result, isTrue);
    });

    test('mengembalikan false jika status perlu_unggah false', () async {
      when(() => mockStatusUnggah.getPerluUnggah())
          .thenAnswer((final _) async => false);

      final result = await service.apakahSqliteAdaDataBaru();
      expect(result, isFalse);
    });

    test('mengembalikan false jika terjadi exception', () async {
      when(() => mockStatusUnggah.getPerluUnggah())
          .thenThrow(Exception('DB error'));

      final result = await service.apakahSqliteAdaDataBaru();
      expect(result, isFalse);
    });
  });

  // ============ apakahFirebaseAdaDataBaru ============
  group('apakahFirebaseAdaDataBaru', () {
    const namaKoleksi = 'status';
    const idDokumen = 'global';

    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockDocumentReference<Map<String, dynamic>> mockDocRef;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

    setUp(() {
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

      when(() => mockFirestore.collection(namaKoleksi))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc(idDokumen)).thenReturn(mockDocRef);
      when(() => mockDocRef.get(any()))
          .thenAnswer((final _) async => mockDocSnapshot);
    });

    test('mengembalikan true jika waktu server lebih baru dari lokal',
        () async {
      final waktuLokal = DateTime(2024, 1, 1, 12);
      final waktuServer = DateTime(2024, 1, 2, 12); // lebih baru

      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => waktuLokal);

      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn({
        'diperbarui': Timestamp.fromDate(waktuServer),
      });

      final result = await service.apakahFirebaseAdaDataBaru(
        namaKoleksi: namaKoleksi,
        idDokumen: idDokumen,
      );
      expect(result, isTrue);
    });

    test('mengembalikan false jika waktu server tidak lebih baru', () async {
      final waktuLokal = DateTime(2024, 1, 2, 12);
      final waktuServer = DateTime(2024, 1, 1, 12); // lebih lama

      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => waktuLokal);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn({
        'diperbarui': Timestamp.fromDate(waktuServer),
      });

      final result = await service.apakahFirebaseAdaDataBaru(
        namaKoleksi: namaKoleksi,
        idDokumen: idDokumen,
      );
      expect(result, isFalse);
    });

    test('mengembalikan false jika field diperbarui tidak ada', () async {
      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => DateTime(2024));
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn(<String, dynamic>{
        // tidak ada 'diperbarui'
        'nama': 'test',
      });

      final result = await service.apakahFirebaseAdaDataBaru(
        namaKoleksi: namaKoleksi,
        idDokumen: idDokumen,
      );
      expect(result, isFalse);
    });

    test('mengembalikan false jika dokumen tidak ada', () async {
      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => DateTime(2024));
      when(() => mockDocSnapshot.exists).thenReturn(false);

      final result = await service.apakahFirebaseAdaDataBaru(
        namaKoleksi: namaKoleksi,
        idDokumen: idDokumen,
      );
      expect(result, isFalse);
    });

    test('mengembalikan false jika data snapshot null', () async {
      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => DateTime(2024));
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn(null);

      final result = await service.apakahFirebaseAdaDataBaru(
        namaKoleksi: namaKoleksi,
        idDokumen: idDokumen,
      );
      expect(result, isFalse);
    });

    test('mengembalikan false jika terjadi exception', () async {
      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => DateTime(2024));
      when(() => mockDocRef.get(any()))
          .thenThrow(FirebaseException(plugin: 'firestore', message: 'Error'));

      final result = await service.apakahFirebaseAdaDataBaru(
        namaKoleksi: namaKoleksi,
        idDokumen: idDokumen,
      );
      expect(result, isFalse);
    });
  });
}
