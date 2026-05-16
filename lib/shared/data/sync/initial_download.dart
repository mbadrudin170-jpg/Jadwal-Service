// path: lib/shared/data/sync/initial_download.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/debug/log.dart';

/// [InitialDownloadService] bertanggung jawab untuk mengisi database lokal dengan
/// data dari server jika tabel-tabel tertentu masih kosong.
class InitialDownloadService {
  final DatabaseHelper _dbHelper;
  final DownloadDataService _downloadService;

  /// Konstruktor utama.
  /// Menerima [dbHelper] dan [downloadService] opsional, berguna untuk pengujian.
  InitialDownloadService({
    final DatabaseHelper? dbHelper,
    final DownloadDataService? downloadService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _downloadService = downloadService ?? DownloadDataService();

  /// Menjalankan pengecekan dan pengunduhan data awal untuk seluruh tabel.
  Future<void> runInitialDownload() async {
    Log.info('Memulai sinkronisasi awal: Mengecek tabel lokal yang kosong...');

    final stopwatch = Stopwatch()..start();

    await _downloadPackageDataIfEmpty();
    await _downloadCategoryDataIfEmpty();
    await _downloadSubCategoryDataIfEmpty();
    await _downloadWalletDataIfEmpty();
    await _downloadCustomerDataIfEmpty();
    await _downloadApkVersionDataIfEmpty();
    await _downloadSettingsDataIfEmpty();
    await _downloadActiveCustomerDataIfEmpty();
    await _downloadTransactionDataIfEmpty();
    await _downloadFeedbackDataIfEmpty();
    await _downloadOrderDataIfEmpty();

    stopwatch.stop();
    Log.info(
      'Proses unduhan awal selesai dalam ${stopwatch.elapsed.inSeconds} detik.',
    );
  }

  /// Memeriksa apakah sebuah tabel kosong.
  Future<bool> _isTableEmpty(final String tableName) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;

      Log.info("Tabel '$tableName': $count baris.");
      return count == 0;
    } on Exception catch (e) {
      Log.error(
        "Gagal mengecek tabel '$tableName'.",
        e: e,
      );
      return false;
    }
  }

  /// Template fungsi pembungkus untuk proses unduh per tabel agar kode lebih bersih.
  Future<void> _downloadIfEmpty({
    required final String tableName,
    required final Future<void> Function() downloadFunction,
  }) async {
    try {
      if (await _isTableEmpty(tableName)) {
        Log.info("Memulai unduh data untuk '$tableName'...");
        await downloadFunction();
        Log.info("Data '$tableName' berhasil disimpan ke lokal.");
      } else {
        Log.info("Skip '$tableName' (Sudah ada data).");
      }
    } on Exception catch (e, s) {
      Log.error(
        "ERROR saat mengunduh '$tableName'",
        e: e,
        st: s,
      );
    }
  }

  // --- Implementasi Fungsi Khusus ---

  Future<void> _downloadPackageDataIfEmpty() => _downloadIfEmpty(
        tableName: 'paket',
        downloadFunction: _downloadService.downloadPackageData,
      );

  Future<void> _downloadCategoryDataIfEmpty() => _downloadIfEmpty(
        tableName: 'kategori',
        downloadFunction: _downloadService.downloadCategoryData,
      );

  Future<void> _downloadSubCategoryDataIfEmpty() => _downloadIfEmpty(
        tableName: 'sub_kategori',
        downloadFunction: _downloadService.downloadSubCategoryData,
      );

  Future<void> _downloadWalletDataIfEmpty() => _downloadIfEmpty(
        tableName: 'dompet',
        downloadFunction: _downloadService.downloadWalletData,
      );

  Future<void> _downloadCustomerDataIfEmpty() => _downloadIfEmpty(
        tableName: 'pelanggan',
        downloadFunction: _downloadService.downloadCustomerData,
      );

  Future<void> _downloadApkVersionDataIfEmpty() => _downloadIfEmpty(
        tableName: 'versi_apk_user',
        downloadFunction: _downloadService.downloadApkVersionData,
      );

  Future<void> _downloadSettingsDataIfEmpty() => _downloadIfEmpty(
        tableName: 'pengaturan',
        downloadFunction: _downloadService.downloadSettingsData,
      );

  Future<void> _downloadActiveCustomerDataIfEmpty() => _downloadIfEmpty(
        tableName: 'pelanggan_aktif',
        downloadFunction: _downloadService.downloadActiveCustomerData,
      );

  Future<void> _downloadTransactionDataIfEmpty() => _downloadIfEmpty(
        tableName: 'transaksi',
        downloadFunction: _downloadService.downloadTransactionData,
      );

  Future<void> _downloadFeedbackDataIfEmpty() => _downloadIfEmpty(
        tableName: 'kritik_saran',
        downloadFunction: _downloadService.downloadFeedbackData,
      );

  Future<void> _downloadOrderDataIfEmpty() => _downloadIfEmpty(
        tableName: 'pesan',
        downloadFunction: _downloadService.downloadOrderData,
      );
}
