// path: lib/shared/data/sync/initial_download.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

class InitialDownloadService {
  final DatabaseHelper _dbHelper;
  final DownloadDataService _downloadService;

  InitialDownloadService({
    required DatabaseHelper dbHelper,
    required DownloadDataService downloadService,
  })  : _dbHelper = dbHelper,
        _downloadService = downloadService {
    Log.info(
        'InitialDownloadService diinisialisasi dengan dependency injection.');
  }

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
        'Proses unduhan awal selesai dalam ${stopwatch.elapsed.inSeconds} detik.');
  }

  Future<bool> _isTableEmpty(String tableName) async {
    try {
      final db = await _dbHelper.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final count = Sqflite.firstIntValue(result) ?? 0;
      Log.info("Tabel '$tableName': $count baris.");
      return count == 0;
    } on Exception catch (e, st) {
      Log.error("Gagal mengecek tabel '$tableName'.", e: e, st: st);
      return false;
    }
  }

  Future<void> _downloadIfEmpty({
    required String tableName,
    required Future<void> Function() downloadFunction,
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
      Log.error("ERROR saat mengunduh '$tableName'", e: e, st: s);
    }
  }

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

  Future<void> _downloadOrderDataIfEmpty() => _downloadIfEmpty(
        tableName: TableNameValue.get(TableName.customerOrder),
        downloadFunction: _downloadService.downloadOrderData,
      );
}

// ✅ HANYA SATU PROVIDER - gunakan Provider biasa
final initialDownloadServiceProvider = Provider<InitialDownloadService>((ref) {
  return InitialDownloadService(
    dbHelper: ref.read(databaseHelperProvider),
    downloadService: ref.read(downloadDataServiceProvider),
  );
});
