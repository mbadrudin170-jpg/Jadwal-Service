// path: lib/shared/operasi/operasi_dasar.dart
// diubah: Menambahkan parameter `dariServer` untuk memutus siklus sinkronisasi.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/status_unggah_operasi.dart';

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class OperasiDasar {
  final DatabaseHelper _dbHelper;
  final StatusUnggahOperasi _statusUnggahOperasi;

  /// Konstruktor untuk `OperasiDasar`.
  ///
  /// Memungkinkan injeksi dependensi untuk `DatabaseHelper` dan `StatusUnggahOperasi`
  /// untuk memfasilitasi pengujian.
  OperasiDasar({
    @visibleForTesting final DatabaseHelper? dbHelper,
    @visibleForTesting final StatusUnggahOperasi? statusUnggahOperasi,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _statusUnggahOperasi = statusUnggahOperasi ?? StatusUnggahOperasi();

  /// Menjalankan `aksi` di dalam sebuah transaksi database.
  ///
  /// Jika [dariServer] bernilai `false`, maka akan menandai status `perlu_unggah`
  /// menjadi `true` untuk sinkronisasi data ke server.
  Future<T> _jalankanDalamTransaksi<T>(
    final Future<T> Function(Transaction) aksi, {
    final bool dariServer = false,
  }) async {
    Log.info(
      '[TRANSAKSI DIMULAI] Memulai proses eksekusi dalam wrapper transaksi.',
    );

    try {
      final db = await _dbHelper.database;
      return await db.transaction((final txn) async {
        Log.info(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance: ${txn.runtimeType}',
        );

        try {
          if (!dariServer) {
            Log.info(
              '[TRANSAKSI AKTIF] Menandai status `perlu_unggah` menjadi TRUE (operasi lokal).',
            );
            await _statusUnggahOperasi.setPerluUnggah(true, transaction: txn);
            Log.info(
              '[TRANSAKSI AKTIF] Status `perlu_unggah` berhasil ditandai.',
            );
          } else {
            Log.info(
              '[TRANSAKSI AKTIF] Melewati penandaan `perlu_unggah` (operasi dari server).',
            );
          }

          final result = await aksi(txn);
          Log.info(
            '[TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. Hasil: ${result.runtimeType}',
          );

          Log.info(
            '[TRANSAKSI COMMIT] Transaksi akan di-commit.',
          );
          return result;
        } catch (e, st) {
          Log.error(
            '[TRANSAKSI GAGAL DI DALAM] Error di dalam blok transaksi.',
            e: e,
            st: st,
          );
          rethrow;
        }
      });
    } catch (e, st) {
      Log.error(
        '[TRANSAKSI GAGAL DI LUAR] Gagal memulai atau menyelesaikan transaksi.',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menjalankan operasi database yang kompleks di dalam sebuah transaksi.
  Future<T> jalankanOperasiKompleks<T>(
    final Future<T> Function(Transaction txn) aksiKustom, {
    final bool dariServer = false,
  }) async {
    Log.info('Mendelegasikan eksekusi transaksi kompleks');
    return await _jalankanDalamTransaksi(aksiKustom, dariServer: dariServer);
  }

  /// Menyisipkan data baru ke dalam [tabel].
  Future<void> sisipkan(
    final String tabel,
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai penyisipan data ke tabel: $tabel');
    try {
      await _jalankanDalamTransaksi(
        (final txn) async {
          final result = await txn.insert(
            tabel,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          Log.info('INSERT berhasil', {'rowId': result, 'tabel': tabel});
          return result;
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $tabel',
        e: e,
        st: s,
        data: data,
      );
      rethrow;
    }
  }

// TODO: rencana selanjutnya adalah bermasalah
  /// Memperbarui data di [tabel] berdasarkan [id].
  Future<void> perbarui(
    final String tabel,
    final Map<String, dynamic> data,
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai pembaruan data di tabel: $tabel', {
      'id': id,
      'data': data,
    });
    try {
      await _jalankanDalamTransaksi(
        (final txn) async {
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
            Log.info(
              'UPDATE berhasil',
              {'rowsAffected': rowsAffected, 'id': id},
            );
          }
          return rowsAffected;
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui data di tabel: $tabel',
        e: e,
        st: s,
        data: {'id': id, 'payload': data},
      );
      rethrow;
    }
  }

  /// Menghapus data dari [tabel] berdasarkan [id].
  Future<void> hapus(final String tabel, final String id,
      {final bool dariServer = false}) async {
    Log.info('Memulai penghapusan data', {'tabel': tabel, 'id': id});
    try {
      await _jalankanDalamTransaksi(
        (final txn) async {
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
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $tabel',
        e: e,
        st: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan data dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final String tabel,
    final List<Map<String, dynamic>> daftarData, {
    final bool dariServer = false,
  }) async {
    if (daftarData.isEmpty) {
      Log.warning('Daftar data batch kosong, operasi dibatalkan', {
        'tabel': tabel,
      });
      return;
    }
    Log.info('Memulai batch operation', {
      'tabel': tabel,
      'totalItem': daftarData.length,
      'dariServer': dariServer,
    });
    try {
      await _jalankanDalamTransaksi(
        (final txn) async {
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
            }
          }
          Log.info('Melakukan commit batch...', {'validCount': validCount});
          await batch.commit(noResult: true);
          Log.info('Batch operation sukses');
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch operation di tabel: $tabel',
        e: e,
        st: s,
        data: {'totalItem': daftarData.length},
      );
      rethrow;
    }
  }
}
