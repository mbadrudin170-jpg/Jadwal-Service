// path: test/shared/data/services/layanan_cek_sinkronisasi_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/data/services/layanan_pengecekan_data_baru.dart';
import 'package:wifi/shared/data/sync/layanan_unduh_data.dart';
import 'package:wifi/shared/data/sync/layanan_unggah_data.dart';
import 'package:wifi/shared/utils/pengelola_sinkronisasi.dart';

import 'layanan_cek_sinkronisasi_test.mocks.dart';

@GenerateMocks([
  PengelolaSinkronisasi,
  LayananUnggahData,
  LayananUnduhData,
  LayananPengecekanDataBaru,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
])
void main() {
  late LayananCekSinkronisasi layananCekSinkronisasi;
  late MockPengelolaSinkronisasi mockPengelolaSinkronisasi;
  late MockLayananUnggahData mockLayananUnggah;
  late MockLayananUnduhData mockLayananUnduh;
  late MockLayananPengecekanDataBaru mockPengecekanDataBaru;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;

  setUp(() {
    mockPengelolaSinkronisasi = MockPengelolaSinkronisasi();
    mockLayananUnggah = MockLayananUnggahData();
    mockLayananUnduh = MockLayananUnduhData();
    mockPengecekanDataBaru = MockLayananPengecekanDataBaru();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();

    layananCekSinkronisasi = LayananCekSinkronisasi(
      pengelolaSinkronisasi: mockPengelolaSinkronisasi,
      layananUnggah: mockLayananUnggah,
      layananUnduh: mockLayananUnduh,
      pengecekanDataBaru: mockPengecekanDataBaru,
      firestore: mockFirestore,
    );

    // Stubbing untuk Firestore
    when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.set(any, any))
        .thenAnswer((_) async => Future.value());
  });

  tearDown(() {
    reset(mockPengelolaSinkronisasi);
    reset(mockLayananUnggah);
    reset(mockLayananUnduh);
    reset(mockPengecekanDataBaru);
    reset(mockFirestore);
    reset(mockCollectionReference);
    reset(mockDocumentReference);
  });

  void aturPengecekanData({
    required bool adaDataLokal,
    required bool adaDataServer,
  }) {
    when(mockPengecekanDataBaru.apakahSqliteAdaDataBaru())
        .thenAnswer((_) async => adaDataLokal);
    when(mockPengecekanDataBaru.apakahFirebaseAdaDataBaru(
      namaKoleksi: anyNamed('namaKoleksi'),
      idDokumen: anyNamed('idDokumen'),
    )).thenAnswer((_) async => adaDataServer);
  }

  void aturAksiSinkronisasiBerhasil() {
    when(mockLayananUnggah.unggahSemuaData())
        .thenAnswer((_) async => Future.value());
    when(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggah(any))
        .thenAnswer((_) async => Future.value());
    when(mockPengecekanDataBaru.resetButuhUpload())
        .thenAnswer((_) async => Future.value());
    when(mockLayananUnduh.unduhSemuaData())
        .thenAnswer((_) async => Future.value());
    when(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduh(any))
        .thenAnswer((_) async => Future.value());
  }

  group('LayananCekSinkronisasi', () {
    test('01. harus unggah & unduh jika ada data baru di lokal dan server',
        () async {
      aturPengecekanData(adaDataLokal: true, adaDataServer: true);
      aturAksiSinkronisasiBerhasil();

      await layananCekSinkronisasi.jalankanCekSinkronisasi();

      verify(mockLayananUnggah.unggahSemuaData()).called(1);
      verify(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggah(any))
          .called(1);
      verify(mockPengecekanDataBaru.resetButuhUpload()).called(1);
      verify(mockDocumentReference.set(
        {NamaKolom.diperbaruiPada: FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      )).called(1);
      verify(mockLayananUnduh.unduhSemuaData()).called(1);
      verify(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduh(any))
          .called(1);
    });

    test('02. harus unggah saja jika hanya ada data baru di lokal', () async {
      aturPengecekanData(adaDataLokal: true, adaDataServer: false);
      aturAksiSinkronisasiBerhasil();

      await layananCekSinkronisasi.jalankanCekSinkronisasi();

      verify(mockLayananUnggah.unggahSemuaData()).called(1);
      verify(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggah(any))
          .called(1);
      verify(mockPengecekanDataBaru.resetButuhUpload()).called(1);
      verify(mockDocumentReference.set(
        {NamaKolom.diperbaruiPada: FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      )).called(1);

      verifyNever(mockLayananUnduh.unduhSemuaData());
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduh(any));
    });

    test('03. harus unduh saja jika hanya ada data baru di server', () async {
      aturPengecekanData(adaDataLokal: false, adaDataServer: true);
      aturAksiSinkronisasiBerhasil();

      await layananCekSinkronisasi.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggah(any));
      verifyNever(mockPengecekanDataBaru.resetButuhUpload());
      verifyNever(mockDocumentReference.set(any, any));

      verify(mockLayananUnduh.unduhSemuaData()).called(1);
      verify(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduh(any))
          .called(1);
    });

    test('04. tidak melakukan apa-apa jika tidak ada data baru', () async {
      aturPengecekanData(adaDataLokal: false, adaDataServer: false);

      await layananCekSinkronisasi.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verifyNever(mockLayananUnduh.unduhSemuaData());
      verifyNever(mockDocumentReference.set(any, any));
    });

    test('05. harus menangani error saat unggah dan tetap melanjutkan unduh',
        () async {
      aturPengecekanData(adaDataLokal: true, adaDataServer: true);
      final exception = Exception('Gagal unggah');
      when(mockPengecekanDataBaru.apakahSqliteAdaDataBaru())
          .thenThrow(exception);
      aturAksiSinkronisasiBerhasil();

      await layananCekSinkronisasi.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggah(any));
      verifyNever(mockDocumentReference.set(any, any));

      verify(mockLayananUnduh.unduhSemuaData()).called(1);
      verify(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduh(any))
          .called(1);
    });

    test('06. harus menangani error saat unduh', () async {
      aturPengecekanData(adaDataLokal: false, adaDataServer: true);
      final exception = Exception('Gagal unduh');
      when(mockPengecekanDataBaru.apakahFirebaseAdaDataBaru(
        namaKoleksi: anyNamed('namaKoleksi'),
        idDokumen: anyNamed('idDokumen'),
      )).thenThrow(exception);

      await layananCekSinkronisasi.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verifyNever(mockLayananUnduh.unduhSemuaData());
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduh(any));
    });

    test('07. harus menangani error saat memperbarui status global', () async {
      aturPengecekanData(adaDataLokal: true, adaDataServer: false);
      aturAksiSinkronisasiBerhasil();
      final exception = Exception('Gagal update Firestore');
      when(mockDocumentReference.set(any, any)).thenThrow(exception);

      expect(layananCekSinkronisasi.jalankanCekSinkronisasi(), completes);

      verify(mockLayananUnggah.unggahSemuaData()).called(1);
    });
  });
}
