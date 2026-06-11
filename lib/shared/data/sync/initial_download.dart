// path: lib/shared/data/sync/initial_download.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

class LayananUnduhAwal {
  final DatabaseHelper _dbHelper;
  final DownloadDataService _layananUnduh;

  LayananUnduhAwal({
    required DatabaseHelper dbHelper,
    required DownloadDataService layananUnduh,
  })  : _dbHelper = dbHelper,
        _layananUnduh = layananUnduh {
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
      final db = await _dbHelper.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $namaTabel');
      final jumlah = Sqflite.firstIntValue(result) ?? 0;
      Log.info("Tabel '$namaTabel': $jumlah baris.");
      return jumlah == 0;
    } on Exception catch (e, st) {
      Log.error("Gagal mengecek tabel '$namaTabel'.", e: e, st: st);
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
      Log.error("ERROR saat mengunduh '$namaTabel'", e: e, st: s);
    }
  }

  Future<void> _unduhDataPaketJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.package),
        fungsiUnduh: _layananUnduh.downloadPackageData,
      );

  Future<void> _unduhDataKategoriJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.category),
        fungsiUnduh: _layananUnduh.downloadCategoryData,
      );

  Future<void> _unduhDataSubKategoriJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.subCategory),
        fungsiUnduh: _layananUnduh.downloadSubCategoryData,
      );

  Future<void> _unduhDataDompetJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.wallet),
        fungsiUnduh: _layananUnduh.downloadWalletData,
      );

  Future<void> _unduhDataPelangganJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.customer),
        fungsiUnduh: _layananUnduh.downloadCustomerData,
      );

  Future<void> _unduhDataVersiApkJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.userApkVersion),
        fungsiUnduh: _layananUnduh.downloadApkVersionData,
      );

  Future<void> _unduhDataPengaturanJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.settings),
        fungsiUnduh: _layananUnduh.downloadSettingsData,
      );

  Future<void> _unduhDataPelangganAktifJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.activeCustomer),
        fungsiUnduh: _layananUnduh.downloadActiveCustomerData,
      );

  Future<void> _unduhDataTransaksiJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.transactions),
        fungsiUnduh: _layananUnduh.downloadTransactionData,
      );

  Future<void> _unduhDataUmpanBalikJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.feedback),
        fungsiUnduh: _layananUnduh.downloadFeedbackData,
      );

  Future<void> _unduhDataPesananJikaKosong() => _unduhJikaKosong(
        namaTabel: TableNameValue.get(TableName.customerOrder),
        fungsiUnduh: _layananUnduh.downloadOrderData,
      );
}

// ✅ HANYA SATU PROVIDER - gunakan Provider biasa
final initialDownloadServiceProvider = Provider<LayananUnduhAwal>((ref) {
  return LayananUnduhAwal(
    dbHelper: ref.read(databaseHelperProvider),
    layananUnduh: ref.read(downloadDataServiceProvider),
  );
});
