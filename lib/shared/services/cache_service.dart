// path: lib/shared/services/cache_service.dart
// Fitur: Mengelola operasi caching menggunakan Hive.
// Tujuan: Menyediakan antarmuka terpusat untuk menyimpan, mengambil, dan menghapus data dari cache lokal.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/transaksi_model.dart';

/// Service untuk mengelola semua operasi cache dengan Hive.
///
/// Kelas ini menyediakan metode untuk berinteraksi dengan Hive box
/// dan mengabstraksi detail implementasi dari bagian lain aplikasi.
class CacheService {
  // Nama untuk box Hive yang akan menyimpan transaksi.
  static const _transaksiBoxName = 'transaksiBox';

  /// Menyimpan daftar [TransaksiModel] ke dalam Hive box.
  ///
  /// Metode ini akan membersihkan box terlebih dahulu, lalu menyimpan
  /// semua data transaksi yang baru.
  Future<void> saveTransaksi(final List<TransaksiModel> transaksiList) async {
    try {
      final box = await Hive.openBox<TransaksiModel>(_transaksiBoxName);
      await box.clear();
      await box.addAll(transaksiList);
      Log.info('CacheService: ${transaksiList.length} transaksi berhasil disimpan ke cache.');
    } on Exception catch (e, st) {
      Log.error('CacheService: Gagal menyimpan transaksi ke cache.', e: e, st: st);
    }
  }

  /// Mengambil daftar [TransaksiModel] dari Hive box.
  ///
  /// Jika box kosong atau terjadi error, metode ini akan mengembalikan list kosong.
  Future<List<TransaksiModel>> getTransaksi() async {
    try {
      final box = await Hive.openBox<TransaksiModel>(_transaksiBoxName);
      final transaksiList = box.values.toList();
      Log.info('CacheService: ${transaksiList.length} transaksi berhasil diambil dari cache.');
      return transaksiList;
    } on Exception catch (e, st) {
      Log.error('CacheService: Gagal mengambil transaksi dari cache.', e: e, st: st);
      return [];
    }
  }

  /// Membersihkan semua data dari box transaksi.
  Future<void> clearTransaksi() async {
    try {
      final box = await Hive.openBox<TransaksiModel>(_transaksiBoxName);
      await box.clear();
      Log.info('CacheService: Cache transaksi berhasil dibersihkan.');
    } on Exception catch (e, st) {
      Log.error('CacheService: Gagal membersihkan cache transaksi.', e: e, st: st);
    }
  }
  
  /// Memeriksa apakah cache transaksi kosong.
  Future<bool> isTransaksiCacheEmpty() async {
    try {
      final box = await Hive.openBox<TransaksiModel>(_transaksiBoxName);
      final isEmpty = box.isEmpty;
      Log.info('CacheService: Cache transaksi kosong? $isEmpty');
      return isEmpty;
    } on Exception catch (e, st) {
      Log.error('CacheService: Gagal memeriksa status cache.', e: e, st: st);
      // Asumsikan kosong jika ada error untuk memicu fetch data baru.
      return true;
    }
  }
}
