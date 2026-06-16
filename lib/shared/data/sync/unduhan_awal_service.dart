// path: lib/shared/data/sync/unduhan_awal_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/data/sync/layanan_unduh_data.dart';
import 'package:wifi/shared/debug/log.dart';

class UnduhanAwalService {
  final SqliteDatabase _sqliteDb;
  final LayananUnduhData _downloadDataService;

  UnduhanAwalService({
    required SqliteDatabase sqliteDb,
    required LayananUnduhData downloadDataService,
  })  : _sqliteDb = sqliteDb,
        _downloadDataService = downloadDataService {
    Log.info(
        'InitialDownloadService diinisialisasi dengan dependency injection.');
  }

  Future<void> jalankanUnduhanAwal() async {
    Log.info('Memulai sinkronisasi awal: Mengecek tabel lokal yang kosong...');
    final pengukurWaktu = Stopwatch()..start();

    await _unduhDataPaketJikaKosong();
    await _unduhDataKategoriJikaKosong();
    await _unduhDataSubKategoriJikaKosong();
    await _unduhDataDompetJikaKosong();
    await _unduhDataPelangganJikaKosong();
    await _unduhDataVersiApkJikaKosong();
    await _unduhDataPengaturanJikaKosong();
    await _unduhDataPelangganAktifJikaKosong();
    await _unduhDataTransaksiJikaKosong();
    await _unduhDataUmpanBalikJikaKosong();
    await _unduhDataPesananJikaKosong();

    pengukurWaktu.stop();
    Log.info(
        'Proses unduhan awal selesai dalam ${pengukurWaktu.elapsed.inSeconds} detik.');
  }

  Future<bool> _apakahTabelKosong(String namaTabel) async {
    try {
      final db = await _sqliteDb.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $namaTabel');
      final jumlah = Sqflite.firstIntValue(result) ?? 0;
      Log.info("Tabel '$namaTabel': $jumlah baris.");
      return jumlah == 0;
    } on Exception catch (e, st) {
      Log.error("Gagal mengecek tabel '$namaTabel'.", e: e, s: st);
      return false;
    }
  }

  Future<void> _unduhJikaKosong({
    required String namaTabel,
    required Future<void> Function() fungsiUnduh,
  }) async {
    try {
      if (await _apakahTabelKosong(namaTabel)) {
        Log.info("Memulai unduh data untuk '$namaTabel'...");
        await fungsiUnduh();
        Log.info("Data '$namaTabel' berhasil disimpan ke lokal.");
      } else {
        Log.info("Lewati '$namaTabel' (Sudah ada data).");
      }
    } on Exception catch (e, s) {
      Log.error("ERROR saat mengunduh '$namaTabel'", e: e, s: s);
    }
  }

  Future<void> _unduhDataPaketJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.paket,
        fungsiUnduh: _downloadDataService.downloadPackageData,
      );

  Future<void> _unduhDataKategoriJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.kategori,
        fungsiUnduh: _downloadDataService.downloadCategoryData,
      );

  Future<void> _unduhDataSubKategoriJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.subKategori,
        fungsiUnduh: _downloadDataService.downloadSubCategoryData,
      );

  Future<void> _unduhDataDompetJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.dompet,
        fungsiUnduh: _downloadDataService.downloadWalletData,
      );

  Future<void> _unduhDataPelangganJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.pelanggan,
        fungsiUnduh: _downloadDataService.downloadCustomerData,
      );

  Future<void> _unduhDataVersiApkJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.versiApkUser,
        fungsiUnduh: _downloadDataService.downloadApkVersionData,
      );

  Future<void> _unduhDataPengaturanJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.settings,
        fungsiUnduh: _downloadDataService.downloadSettingsData,
      );

  Future<void> _unduhDataPelangganAktifJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.pelangganAktif,
        fungsiUnduh: _downloadDataService.downloadActiveCustomerData,
      );

  Future<void> _unduhDataTransaksiJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.transaksi,
        fungsiUnduh: _downloadDataService.downloadTransactionData,
      );

  Future<void> _unduhDataUmpanBalikJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.feedback,
        fungsiUnduh: _downloadDataService.downloadFeedbackData,
      );

  Future<void> _unduhDataPesananJikaKosong() => _unduhJikaKosong(
        namaTabel: NamaTabel.pesananPelanggan,
        fungsiUnduh: _downloadDataService.downloadOrderData,
      );
}

// ✅ HANYA SATU PROVIDER - gunakan Provider biasa
final unduhanAwalServiceProvider = Provider<UnduhanAwalService>((ref) {
  return UnduhanAwalService(
    sqliteDb: ref.read(sqliteDatabaseProvider),
    downloadDataService: ref.read(downloadDataServiceProvider),
  );
});
