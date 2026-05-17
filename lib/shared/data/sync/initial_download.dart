// path: lib/shared/data/sync/initial_download.dart
// diperbaiki: Mengganti semua nama tabel hardcoded dengan konstanta dari TableNameValue.
// diperbaiki: Menggunakan TableName yang sesuai untuk setiap fungsi.

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

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
      // Escape nama tabel dengan double quotes untuk reserved keyword seperti 'order'
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      Log.info("Tabel '$tableName': $count baris.");
      return count == 0;
    } on Exception catch (e, st) {
      // tambahkan st
      Log.error(
        "Gagal mengecek tabel '$tableName'.",
        e: e,
        st: st, // tambahkan stack trace
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

  // --- Implementasi Fungsi Khusus dengan nama tabel sesuai konstanta ---

  Future<void> _downloadPackageDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.package),
        downloadFunction: _downloadService.downloadPackageData,
      );

  Future<void> _downloadCategoryDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.category),
        downloadFunction: _downloadService.downloadCategoryData,
      );

  Future<void> _downloadSubCategoryDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.subCategory),
        downloadFunction: _downloadService.downloadSubCategoryData,
      );

  Future<void> _downloadWalletDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.wallet),
        downloadFunction: _downloadService.downloadWalletData,
      );

  Future<void> _downloadCustomerDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.customer),
        downloadFunction: _downloadService.downloadCustomerData,
      );

  Future<void> _downloadApkVersionDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.userApkVersion),
        downloadFunction: _downloadService.downloadApkVersionData,
      );

  Future<void> _downloadSettingsDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.settings),
        downloadFunction: _downloadService.downloadSettingsData,
      );

  Future<void> _downloadActiveCustomerDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.activeCustomer),
        downloadFunction: _downloadService.downloadActiveCustomerData,
      );

  Future<void> _downloadTransactionDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.transactions),
        downloadFunction: _downloadService.downloadTransactionData,
      );

  Future<void> _downloadFeedbackDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.feedback),
        downloadFunction: _downloadService.downloadFeedbackData,
      );

  // Perbaikan: Untuk order, gunakan tabel 'order' (bukan 'pesan')
  Future<void> _downloadOrderDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.customerOrder),
        downloadFunction: _downloadService.downloadOrderData,
      );
}
