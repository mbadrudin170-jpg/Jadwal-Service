library;
// path: lib/shared/operasi/operasi_dasar.dart
//// diubah: Menambahkan konstruktor untuk Dependency Injection agar bisa diuji.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/status_unggah_operasi.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class OperasiDasar {
  final DatabaseHelper _dbHelper;
  final StatusUnggahOperasi _statusUnggahOperasi;

  // diubah: Konstruktor diubah untuk menerima dependensi (DI).
  // Ini memungkinkan penyuntikan mock saat pengujian.
  // Konstruktor default tetap berjalan seperti biasa untuk kode produksi.
  OperasiDasar({
    @visibleForTesting DatabaseHelper? dbHelper,
    @visibleForTesting StatusUnggahOperasi? statusUnggahOperasi,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance,
       _statusUnggahOperasi = statusUnggahOperasi ?? StatusUnggahOperasi();

  // Fungsi generik untuk menjalankan operasi tulis di dalam transaksi.
  Future<T> _jalankanDalamTransaksi<T>(
    Future<T> Function(Transaction) aksi,
  ) async {
    Log.info(
      '[TRANSAKSI DIMULAI] Memulai proses eksekusi dalam wrapper transaksi.',
    );

    try {
      Log.info('[TRANSAKSI] Mengambil instance database dari DatabaseHelper.');
      final db = await _dbHelper.database;
      Log.info(
        '[TRANSAKSI] Instance database berhasil didapatkan. Tipe: ${db.runtimeType}',
      );

      Log.info(
        '[TRANSAKSI] Memanggil db.transaction() untuk memulai blok transaksi.',
      );
      return await db.transaction((txn) async {
        Log.info(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance Transaction: ${txn.runtimeType}',
        );

        try {
          Log.info(
            '[TRANSAKSI AKTIF] Menandai status `perlu_unggah` menjadi TRUE.',
          );
          await _statusUnggahOperasi.setPerluUnggah(true, transaction: txn);
          Log.info(
            '[TRANSAKSI AKTIF] Status `perlu_unggah` berhasil ditandai.',
          );

          Log.info(
            '[TRANSAKSI AKTIF] Mengeksekusi aksi utama (callback) yang diberikan.',
          );
          final result = await aksi(txn);
          Log.info(
            '[TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. Hasil: ${result.runtimeType}',
          );

          Log.info(
            '[TRANSAKSI COMMIT] Transaksi akan di-commit karena semua langkah berhasil.',
          );
          return result;
        } catch (e, stackTrace) {
          Log.error(
            '[TRANSAKSI GAGAL DI DALAM] Terjadi error saat menjalankan aksi di dalam blok transaksi.',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
      });
    } catch (e, stackTrace) {
      Log.error(
        '[TRANSAKSI GAGAL DI LUAR] Gagal saat memulai atau menyelesaikan transaksi.',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Menjalankan blok operasi kustom yang kompleks.
  Future<T> jalankanOperasiKompleks<T>(
    Future<T> Function(Transaction txn) aksiKustom,
  ) async {
    Log.info('Mendelegasikan eksekusi transaksi kompleks');
    return await _jalankanDalamTransaksi(aksiKustom);
  }

  /// Menyisipkan satu baris data ke dalam tabel.
  Future<void> sisipkan(String tabel, Map<String, dynamic> data) async {
    Log.info('Memulai penyisipan data ke tabel: $tabel', data);
    try {
      await _jalankanDalamTransaksi((txn) async {
        final result = await txn.insert(
          tabel,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        Log.info('INSERT berhasil', {'rowId': result, 'tabel': tabel});
        return result;
      });
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $tabel',
        error: e,
        stackTrace: s,
        data: data,
      );
      rethrow;
    }
  }

  /// Memperbarui satu baris data di dalam tabel.
  Future<void> perbarui(
    String tabel,
    Map<String, dynamic> data,
    String id,
  ) async {
    Log.info('Memulai pembaruan data di tabel: $tabel', {
      'id': id,
      'data': data,
    });
    try {
      await _jalankanDalamTransaksi((txn) async {
        final rowsAffected = await txn.update(
          tabel,
          data,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rowsAffected == 0) {
          Log.warning(
            'Update selesai tapi tidak ada baris yang berubah (ID tidak ditemukan)',
            {'id': id, 'tabel': tabel},
          );
        } else {
          Log.info('UPDATE berhasil', {'rowsAffected': rowsAffected, 'id': id});
        }
        return rowsAffected;
      });
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui data di tabel: $tabel',
        error: e,
        stackTrace: s,
        data: {'id': id, 'payload': data},
      );
      rethrow;
    }
  }

  /// Menghapus (atau mengarsipkan) satu baris data.
  Future<void> hapus(String tabel, String id) async {
    Log.info('Memulai penghapusan data', {'tabel': tabel, 'id': id});
    try {
      await _jalankanDalamTransaksi((txn) async {
        final rowsDeleted = await txn.delete(
          tabel,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rowsDeleted == 0) {
          Log.warning('Delete selesai tapi tidak ada data yang terhapus', {
            'id': id,
            'tabel': tabel,
          });
        } else {
          Log.info('DELETE berhasil', {'rowsDeleted': rowsDeleted, 'id': id});
        }
        return rowsDeleted;
      });
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $tabel',
        error: e,
        stackTrace: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Metode batch untuk menyisipkan atau memperbarui banyak data sekaligus.
  Future<void> sisipkanAtauPerbaruiBatch(
    String tabel,
    List<Map<String, dynamic>> daftarData,
  ) async {
    if (daftarData.isEmpty) {
      Log.warning('Daftar data batch kosong, operasi dibatalkan', {
        'tabel': tabel,
      });
      return;
    }
    Log.info('Memulai batch operation', {
      'tabel': tabel,
      'totalItem': daftarData.length,
    });
    try {
      await _jalankanDalamTransaksi((txn) async {
        final batch = txn.batch();
        int validCount = 0;
        for (int i = 0; i < daftarData.length; i++) {
          final data = daftarData[i];
          if (data.isNotEmpty) {
            batch.insert(
              tabel,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            validCount++;
            if (i % 10 == 0 && i > 0) {
              Log.info(
                'Batch progress: $i/${daftarData.length} item diproses...',
              );
            }
          }
        }
        Log.info('Melakukan commit batch...', {'validCount': validCount});
        await batch.commit(noResult: true);
        Log.info('Batch operation sukses');
      });
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch operation di tabel: $tabel',
        error: e,
        stackTrace: s,
        data: {'totalItem': daftarData.length},
      );
      rethrow;
    }
  }
}
