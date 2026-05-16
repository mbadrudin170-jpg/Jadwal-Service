// path: test/shared/data/sync/unduhan_awal_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/data/sync/download%20data.dart';
import 'package:wifi/shared/data/sync/initial_download.dart';

@GenerateMocks([DatabaseHelper, Database, LayananUnduhData])
import 'unduhan_awal_test.mocks.dart';

void main() {
  late UnduhanAwalService service;
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;
  late MockLayananUnduhData mockLayananUnduh;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    mockLayananUnduh = MockLayananUnduhData();

    // Inisialisasi service dengan mock
    service = UnduhanAwalService(
      dbHelper: mockDbHelper,
      layananUnduh: mockLayananUnduh,
    );

    // Setup default database mock
    when(mockDbHelper.database).thenAnswer((final _) async => mockDb);
  });

  group('UnduhanAwalService Unit Tests', () {
    test('jalankanUnduhanAwal harus memanggil fungsi unduh jika tabel kosong',
        () async {
      // Setup: semua tabel kosong (count = 0)
      when(mockDb.rawQuery(any)).thenAnswer((final _) async => [
            {'count': 0},
          ],);

      // Setup mock agar unduhan tidak bermasalah
      when(mockLayananUnduh.unduhDataPaket()).thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataKategori())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataSubKategori())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataDompet())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPelanggan())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataVersiApkUser())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPengaturan())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPelangganAktif())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataTransaksi())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataKritikSaran())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPesanan())
          .thenAnswer((final _) async => {});

      await service.jalankanUnduhanAwal();

      // Verifikasi bahwa unduhan dipanggil untuk setiap tabel
      verify(mockLayananUnduh.unduhDataPaket()).called(1);
      verify(mockLayananUnduh.unduhDataKategori()).called(1);
      verify(mockLayananUnduh.unduhDataSubKategori()).called(1);
      verify(mockLayananUnduh.unduhDataDompet()).called(1);
      verify(mockLayananUnduh.unduhDataPelanggan()).called(1);
      verify(mockLayananUnduh.unduhDataVersiApkUser()).called(1);
      verify(mockLayananUnduh.unduhDataPengaturan()).called(1);
      verify(mockLayananUnduh.unduhDataPelangganAktif()).called(1);
      verify(mockLayananUnduh.unduhDataTransaksi()).called(1);
      verify(mockLayananUnduh.unduhDataKritikSaran()).called(1);
      verify(mockLayananUnduh.unduhDataPesanan()).called(1);
    });

    test(
        'jalankanUnduhanAwal harus melewati unduh jika tabel sudah berisi data',
        () async {
      // Setup: tabel sudah berisi (count = 5)
      when(mockDb.rawQuery(any)).thenAnswer((final _) async => [
            {'count': 5},
          ],);

      await service.jalankanUnduhanAwal();

      // Verifikasi bahwa tidak ada unduhan yang dipanggil
      verifyNever(mockLayananUnduh.unduhDataPaket());
      verifyNever(mockLayananUnduh.unduhDataKategori());
      verifyNever(mockLayananUnduh.unduhDataSubKategori());
      verifyNever(mockLayananUnduh.unduhDataDompet());
      verifyNever(mockLayananUnduh.unduhDataPelanggan());
      verifyNever(mockLayananUnduh.unduhDataVersiApkUser());
      verifyNever(mockLayananUnduh.unduhDataPengaturan());
      verifyNever(mockLayananUnduh.unduhDataPelangganAktif());
      verifyNever(mockLayananUnduh.unduhDataTransaksi());
      verifyNever(mockLayananUnduh.unduhDataKritikSaran());
      verifyNever(mockLayananUnduh.unduhDataPesanan());
    });

    test(
        'Harus tetap melanjutkan ke tabel berikutnya jika salah satu proses gagal',
        () async {
      // Setup: semua tabel kosong
      when(mockDb.rawQuery(any)).thenAnswer((final _) async => [
            {'count': 0},
          ],);

      // Mock: unduhDataPaket gagal, yang lain berhasil
      when(mockLayananUnduh.unduhDataPaket())
          .thenThrow(Exception('Koneksi Gagal'));
      when(mockLayananUnduh.unduhDataKategori())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataSubKategori())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataDompet())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPelanggan())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataVersiApkUser())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPengaturan())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPelangganAktif())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataTransaksi())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataKritikSaran())
          .thenAnswer((final _) async => {});
      when(mockLayananUnduh.unduhDataPesanan())
          .thenAnswer((final _) async => {});

      await service.jalankanUnduhanAwal();

      // Verifikasi: paket dicoba, lalu kategori tetap dijalankan
      verify(mockLayananUnduh.unduhDataPaket()).called(1);
      verify(mockLayananUnduh.unduhDataKategori()).called(1);
    });
  });
}
