// path: test/shared/data/sync/unduh_data_test.dart
// ignore_for_file: avoid_implementing_value_types, subtype_of_sealed_class,
// ignore_for_file: unnecessary_lambdas, prefer_function_declarations_over_variables

@TestOn('vm')
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/shared/data/sync/unduh_data.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';
import 'package:wifi/shared/operasi/kategori_operasi.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_aktif_operasi.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';
import 'package:wifi/shared/operasi/pesanan_operasi.dart';
import 'package:wifi/shared/operasi/sub_kategori_operasi.dart';
import 'package:wifi/shared/operasi/transaksi_operasi.dart';
import 'package:wifi/shared/operasi/versi_apk_user_operasi.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

// --- Mocks ---
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockSyncManager extends Mock implements SyncManager {}

class MockCollectionReference<T> extends Mock
    implements CollectionReference<T> {}

class MockQuery<T> extends Mock implements Query<T> {}

class MockQuerySnapshot<T> extends Mock implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T> extends Mock
    implements QueryDocumentSnapshot<T> {}

class MockDocumentReference<T> extends Mock implements DocumentReference<T> {}

class MockDocumentSnapshot<T> extends Mock implements DocumentSnapshot<T> {}

// Mocks for Operasi classes
class MockDompetOperasi extends Mock implements DompetOperasi {}

class MockKategoriOperasi extends Mock implements KategoriOperasi {}

class MockPaketOperasi extends Mock implements PaketOperasi {}

class MockPelangganOperasi extends Mock implements PelangganOperasi {}

class MockPelangganAktifOperasi extends Mock implements PelangganAktifOperasi {}

class MockTransaksiOperasi extends Mock implements TransaksiOperasi {}

class MockKritikSaranOperasi extends Mock implements KritikSaranOperasi {}

class MockPesananOperasi extends Mock implements PesananOperasi {}

class MockSubKategoriOperasi extends Mock implements SubKategoriOperasi {}

class MockVersiApkUserOperasi extends Mock implements VersiApkUserOperasi {}

class MockPengaturanOperasi extends Mock implements PengaturanOperasi {}

// --- Helper Functions for Testing ---
String _testFromFirebase(final String id, final Map<String, dynamic> data) =>
    id;

void main() {
  late LayananUnduhData service;
  late MockFirebaseFirestore mockFirestore;
  late MockSyncManager mockSyncManager;
  late MockPaketOperasi mockPaketOperasi;
  late MockPengaturanOperasi mockPengaturanOperasi;

  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockSyncManager = MockSyncManager();
    mockPaketOperasi = MockPaketOperasi();
    mockPengaturanOperasi = MockPengaturanOperasi();

    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    service = LayananUnduhData.test(
      firestore: mockFirestore,
      syncManager: mockSyncManager,
      dompetOperasi: MockDompetOperasi(),
      kategoriOperasi: MockKategoriOperasi(),
      paketOperasi: mockPaketOperasi,
      pelangganOperasi: MockPelangganOperasi(),
      pelangganAktifOperasi: MockPelangganAktifOperasi(),
      transaksiOperasi: MockTransaksiOperasi(),
      kritikSaranOperasi: MockKritikSaranOperasi(),
      pesanOperasi: MockPesananOperasi(),
      subKategoriOperasi: MockSubKategoriOperasi(),
      versiApkUserOperasi: MockVersiApkUserOperasi(),
      pengaturanOperasi: mockPengaturanOperasi,
    );

    registerFallbackValue(const GetOptions());

    when(() => mockFirestore.collection(any())).thenReturn(mockCollection);
    when(
      () => mockCollection.where(
        'diperbarui',
        isGreaterThan: any(named: 'isGreaterThan'),
      ),
    ).thenReturn(mockQuery);
    when(() => mockQuery.get(any())).thenAnswer((final _) async => mockSnapshot);
  });

  group('LayananUnduhData', () {
    final tWaktu = DateTime(2024, 7, 31);
    setUp(() {
      when(() => mockSyncManager.getTerakhirUnduh())
          .thenAnswer((final _) async => tWaktu);
    });

    group('unduhSemuaData', () {
      test(
          'harus memanggil semua 11 fungsi unduh dan selesai tanpa error jika semua berhasil',
          () async {
        when(() => mockSnapshot.docs).thenReturn([]);
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockFirestore.collection('pengaturan'))
            .thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
        when(() => mockDocRef.get(any())).thenAnswer((final _) async => mockDoc);
        when(() => mockDoc.exists).thenReturn(false);

        await expectLater(service.unduhSemuaData(), completes);
      });

      test('harus melempar exception jika salah satu fungsi unduh gagal',
          () {
        final exception = Exception('Firestore gagal');
        when(() => mockFirestore.collection('paket')).thenThrow(exception);
        when(() => mockSnapshot.docs).thenReturn([]);
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockFirestore.collection('pengaturan'))
            .thenReturn(mockCollection);
        when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
        when(() => mockDocRef.get(any())).thenAnswer((final _) async => mockDoc);
        when(() => mockDoc.exists).thenReturn(false);

        expect(() => service.unduhSemuaData(), throwsA(isA<Exception>()));
      });
    });

    group('unduhDataPaket', () {
      test('harus memanggil sinkronisasiKoleksi dengan parameter yang benar',
          () async {
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(() => mockSnapshot.docs).thenReturn([mockDoc]);
        when(() => mockDoc.id).thenReturn('paket-1');
        when(mockDoc.data)
            .thenReturn({'id': 'paket-1', 'nama': 'Test', 'harga': 1000});

        when(() => mockPaketOperasi.sisipkanAtauPerbaruiBatch(any(),
            dariServer: any(named: 'dariServer'))).thenAnswer((final _) async {});

        await service.unduhDataPaket();

        verify(() => mockSyncManager.getTerakhirUnduh()).called(1);

        verify(
          () => mockCollection.where('diperbarui', isGreaterThan: tWaktu),
        ).called(1);

        final captured = verify(
          () => mockPaketOperasi.sisipkanAtauPerbaruiBatch(
            captureAny(),
            dariServer: true,
          ),
        ).captured;

        expect(captured.length, 1);
        final List<PaketModel> capturedList =
            captured.first as List<PaketModel>;
        expect(capturedList.length, 1);
        expect(capturedList.first.id, 'paket-1');
        expect(capturedList.first.nama, 'Test');
      });
    });

    group('sinkronisasiKoleksi', () {
      test('Harus memanggil operasiBatch jika ada data baru di Firestore',
          () async {
        const tDataId = 'id_test_123';
        final tDataMap = {'nama': 'Paket Kilat', 'diperbarui': Timestamp.now()};
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockSnapshot.docs).thenReturn([mockDoc]);
        when(() => mockDoc.id).thenReturn(tDataId);
        when(mockDoc.data).thenReturn(tDataMap);

        var batchDipanggil = false;
        final opBatch = (final List<String> list) {
          batchDipanggil = true;
          expect(list.first, tDataId);
          return Future<void>.value();
        };

        await service.sinkronisasiKoleksi<String>(
          namaKoleksi: 'paket',
          waktuUnduhTerakhir: tWaktu,
          fromFirebase: _testFromFirebase,
          operasiBatch: opBatch,
        );

        expect(batchDipanggil, isTrue);
      });

      test(
          'Harus melewati operasiBatch jika tidak ada data baru (snapshot kosong)',
          () async {
        when(() => mockSnapshot.docs).thenReturn([]);
        var batchDipanggil = false;
        final opBatch = (final List<String> list) {
          batchDipanggil = true;
          return Future<void>.value();
        };

        await service.sinkronisasiKoleksi<String>(
          namaKoleksi: 'paket',
          waktuUnduhTerakhir: DateTime.now(),
          fromFirebase: _testFromFirebase,
          operasiBatch: opBatch,
        );

        expect(batchDipanggil, isFalse);
      });

      test('Harus menangani error konversi dan melanjutkan proses', () async {
        final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        final mockDoc3 = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(() => mockDoc1.id).thenReturn('id-1');
        when(mockDoc1.data)
            .thenReturn({'id': 'id-1', 'nama': 'Valid', 'harga': 1});

        when(() => mockDoc2.id).thenReturn('id-2');
        when(mockDoc2.data)
            .thenReturn({'id': 'id-2', 'nama': null, 'harga': 2});

        when(() => mockDoc3.id).thenReturn('id-3');
        when(mockDoc3.data)
            .thenReturn({'id': 'id-3', 'nama': 'Valid 2', 'harga': 3});

        when(() => mockSnapshot.docs)
            .thenReturn([mockDoc1, mockDoc2, mockDoc3]);

        final List<PaketModel> hasilBatch = [];
        final opBatch = (final List<PaketModel> list) {
          hasilBatch.addAll(list);
          return Future<void>.value();
        };

        PaketModel fromFirebasePalsu(final String id, final Map<String, dynamic> data) {
          if (id == 'id-2') {
            throw ArgumentError('Data korup yang disengaja untuk pengujian');
          }
          return PaketModel.fromFirebase(id, data);
        }

        await service.sinkronisasiKoleksi<PaketModel>(
          namaKoleksi: 'paket',
          waktuUnduhTerakhir: tWaktu,
          fromFirebase: fromFirebasePalsu,
          operasiBatch: opBatch,
        );

        expect(hasilBatch.length, 2);
        expect(hasilBatch.map((final e) => e.id), containsAll(['id-1', 'id-3']));
        expect(hasilBatch.map((final e) => e.id), isNot(contains('id-2')));
      });
    });
  });
}
