// path: test/shared/data/services/layanan_cek_sinkronisasi_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduh_data.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unggah_data.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';
import 'package:wifi/shared/data/services/layanan_pengecekan_data_baru.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

import 'layanan_cek_sinkronisasi_test.mocks.dart';

@GenerateMocks([
  PengelolaSinkronisasi,
  LayananUnggahData,
  LayananUnduhData,
  LayananPengecekanDataBaru,
  FirebaseFirestore,
  KoneksiInternetService,
])
void main() {
  late MockPengelolaSinkronisasi mockPengelolaSinkronisasi;
  late MockLayananUnggahData mockLayananUnggah;
  late MockLayananUnduhData mockLayananUnduh;
  late MockLayananPengecekanDataBaru mockPengecekanDataBaru;
  late MockFirebaseFirestore mockFirestore;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late ProviderContainer container;

  setUp(() {
    mockPengelolaSinkronisasi = MockPengelolaSinkronisasi();
    mockLayananUnggah = MockLayananUnggahData();
    mockLayananUnduh = MockLayananUnduhData();
    mockPengecekanDataBaru = MockLayananPengecekanDataBaru();
    mockFirestore = MockFirebaseFirestore();
    mockKoneksiInternetService = MockKoneksiInternetService();

    container = ProviderContainer(
      overrides: [
        pengelolaSinkronisasiProvider.overrideWithValue(
          mockPengelolaSinkronisasi,
        ),
        layananUnggahDataProvider.overrideWithValue(mockLayananUnggah),
        layananUnduhDataProvider.overrideWithValue(mockLayananUnduh),
        pengecekanDataBaruServiceProvider.overrideWithValue(
          mockPengecekanDataBaru,
        ),
        firestoreProvider.overrideWithValue(mockFirestore),
        koneksiInternetServiceProvider.overrideWithValue(
          mockKoneksiInternetService,
        ),
      ],
    );

    when(
      mockKoneksiInternetService.cekInternet(),
    ).thenAnswer((_) async => true);
  });

  tearDown(() {
    container.dispose();
  });

  void aturPengecekanData({
    required bool adaDataLokal,
    required bool adaDataServer,
  }) {
    when(
      mockPengecekanDataBaru.apakahSqliteAdaDataBaru(),
    ).thenAnswer((_) async => adaDataLokal);
    when(
      mockPengecekanDataBaru.apakahFirebaseAdaDataBaru(
        namaKoleksi: anyNamed('namaKoleksi'),
        idDokumen: anyNamed('idDokumen'),
      ),
    ).thenAnswer((_) async => adaDataServer);
  }

  void aturAksiSinkronisasiBerhasil() {
    when(
      mockLayananUnggah.unggahSemuaData(),
    ).thenAnswer((_) async => Future.value());
    when(
      mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(any),
    ).thenAnswer((_) async => Future.value());
    when(
      mockPengecekanDataBaru.resetButuhUpload(),
    ).thenAnswer((_) async => Future.value());
    when(
      mockLayananUnduh.unduhSemuaData(),
    ).thenAnswer((_) async => Future.value());
    when(
      mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(any),
    ).thenAnswer((_) async => Future.value());
  }

  group('LayananCekSinkronisasi', () {
    test(
      '01. harus unggah & unduh jika ada data baru di lokal dan server',
      () async {
        aturPengecekanData(adaDataLokal: true, adaDataServer: true);
        aturAksiSinkronisasiBerhasil();

        final layanan = container.read(layananCekSinkronisasiProvider);
        await layanan.jalankanCekSinkronisasi();

        verify(mockLayananUnggah.unggahSemuaData()).called(1);
        verify(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(any),
        ).called(1);
        verify(mockPengecekanDataBaru.resetButuhUpload()).called(1);
        verify(mockLayananUnduh.unduhSemuaData()).called(1);
        verify(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(any),
        ).called(1);
      },
    );

    test('02. harus unggah saja jika hanya ada data baru di lokal', () async {
      aturPengecekanData(adaDataLokal: true, adaDataServer: false);
      aturAksiSinkronisasiBerhasil();

      final layanan = container.read(layananCekSinkronisasiProvider);
      await layanan.jalankanCekSinkronisasi();

      verify(mockLayananUnggah.unggahSemuaData()).called(1);
      verify(
        mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(any),
      ).called(1);
      verify(mockPengecekanDataBaru.resetButuhUpload()).called(1);

      verifyNever(mockLayananUnduh.unduhSemuaData());
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(any));
    });

    test('03. harus unduh saja jika hanya ada data baru di server', () async {
      aturPengecekanData(adaDataLokal: false, adaDataServer: true);
      aturAksiSinkronisasiBerhasil();

      final layanan = container.read(layananCekSinkronisasiProvider);
      await layanan.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(any));
      verifyNever(mockPengecekanDataBaru.resetButuhUpload());

      verify(mockLayananUnduh.unduhSemuaData()).called(1);
      verify(mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(any))
          .called(1);
    });

    test('04. tidak melakukan apa-apa jika tidak ada data baru', () async {
      aturPengecekanData(adaDataLokal: false, adaDataServer: false);

      final layanan = container.read(layananCekSinkronisasiProvider);
      await layanan.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verifyNever(mockLayananUnduh.unduhSemuaData());
    });

    test(
      '05. harus menangani error saat unggah dan tidak melanjutkan',
      () async {
        aturPengecekanData(adaDataLokal: true, adaDataServer: true);
        final exception = Exception('Gagal unggah');
        when(mockLayananUnggah.unggahSemuaData()).thenThrow(exception);

        final layanan = container.read(layananCekSinkronisasiProvider);
        await layanan.jalankanCekSinkronisasi();

        verify(mockLayananUnggah.unggahSemuaData()).called(1);
        verifyNever(
            mockPengelolaSinkronisasi.simpanWaktuTerakhirUnggahPreferensi(any));
        verifyNever(mockPengecekanDataBaru.resetButuhUpload());
        verifyNever(mockLayananUnduh.unduhSemuaData());
        verifyNever(
            mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(any));
      },
    );

    test('06. harus menangani error saat unduh', () async {
      aturPengecekanData(adaDataLokal: false, adaDataServer: true);
      final exception = Exception('Gagal unduh');
      when(mockLayananUnduh.unduhSemuaData()).thenThrow(exception);

      final layanan = container.read(layananCekSinkronisasiProvider);
      await layanan.jalankanCekSinkronisasi();

      verifyNever(mockLayananUnggah.unggahSemuaData());
      verify(mockLayananUnduh.unduhSemuaData()).called(1);
      verifyNever(
          mockPengelolaSinkronisasi.simpanWaktuTerakhirUnduhPreferensi(any));
    });
  });
}
