// path: test/shared/data/sync/unduh_data_test.dart
// ignore_for_file: avoid_implementing_value_types, subtype_of_sealed_class

@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/data/sync/unduh_data.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// --- Mocks ---
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockSyncManager extends Mock implements SyncManager {}

class MockCollectionReference<T> extends Mock implements CollectionReference<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

// --- Helper Functions for Testing ---
// Mapper function for tear-off, to satisfy 'unnecessary_lambdas' lint.
String _testFromFirebase(final String id, final Map<String, dynamic> data) => id;

void main() {
  late LayananUnduhData service;
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    service = LayananUnduhData(
      firestore: mockFirestore,
      syncManager: mockSyncManager,
    );
    // registerFallbackValue for GetOptions is needed for `any()` matcher.
    registerFallbackValue(const GetOptions());
  });

  group('LayananUnduhData - sinkronisasiKoleksi', () {
    test('Harus memanggil operasiBatch jika ada data baru di Firestore',
        () async {
      final tWaktuLokal = DateTime(2024);
      const tDataId = 'id_test_123';
      final tDataMap = {'nama': 'Paket Kilat', 'diperbarui': Timestamp.now()};
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

      // Stubbing alur query Firestore
      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(
        () => mockCollection.where(
          'diperbarui',
          isGreaterThan: any(named: 'isGreaterThan'),
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get(any()))
          .thenAnswer((final _) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([mockDoc]);
      when(() => mockDoc.id).thenReturn(tDataId);
      when(mockDoc.data).thenReturn(tDataMap);

      var batchDipanggil = false;

      // Jalankan sinkronisasi
      await service.sinkronisasiKoleksi<String>(
        namaKoleksi: 'paket',
        waktuUnduhTerakhir: tWaktuLokal,
        fromFirebase: _testFromFirebase, // Menggunakan tear-off
        operasiBatch: (final list) async {
          batchDipanggil = true;
          expect(list.first, tDataId);
        },
      );

      expect(batchDipanggil, isTrue);
    });

    test(
        'Harus melewati operasiBatch jika tidak ada data baru (snapshot kosong)',
        () async {
      // Stubbing
      when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
      when(
        () => mockCollection.where(
          any(),
          isGreaterThan: any(named: 'isGreaterThan'),
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get(any()))
          .thenAnswer((final _) async => mockSnapshot);
      when(() => mockSnapshot.docs).thenReturn([]); // Snapshot kosong

      var batchDipanggil = false;

      // Eksekusi
      await service.sinkronisasiKoleksi<String>(
        namaKoleksi: 'paket',
        waktuUnduhTerakhir: DateTime.now(),
        fromFirebase: _testFromFirebase, // Menggunakan tear-off
        operasiBatch: (final list) async {
          batchDipanggil = true;
        },
      );

      // Verifikasi
      expect(batchDipanggil, isFalse);
    });
  });
}
