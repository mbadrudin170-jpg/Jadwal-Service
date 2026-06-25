// path: lib/shared/operasi/sqlite_operasi/base_op_sqlite.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/status_upload_op_sqlite.dart';

final baseOpSqliteProvider = Provider<BaseOpSqlite>((ref) {
  Log.info('Membuat instance BaseOperation...');
  final sqliteDb = ref.read(sqliteDatabaseProvider);
  final statusUnggahOpSqlite = ref.read(statusUploadOpSlite);
  return BaseOpSqlite(
    sqliteDb: sqliteDb,
    statusUnggahOpSqlite: statusUnggahOpSqlite,
  );
});

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class BaseOpSqlite {
  final SqliteDatabase _sqliteDb;
  final StatusUploadOpSqlite _statusUnggahOpsqlite;
  final now = DateTime.now().toUtc();

  /// Konstruktor untuk `BaseOperation`.
  ///
  /// Memungkinkan injeksi dependensi untuk `DatabaseHelper` dan `UploadStatusOperation`
  /// untuk memfasilitasi pengujian.
  BaseOpSqlite({
    required final SqliteDatabase sqliteDb,
    required final StatusUploadOpSqlite statusUnggahOpSqlite,
  }) : _sqliteDb = sqliteDb,
       _statusUnggahOpsqlite = statusUnggahOpSqlite {
    Log.info('BaseOperation instance dibuat.');
  }

  /// Menjalankan `action` di dalam sebuah transaksi database.
  ///
  /// Jika [dariServer] bernilai `false`, maka akan menandai status `needUpload`
  /// menjadi `true` untuk sinkronisasi data ke server.
  Future<T> _runInTransaction<T>(
    final Future<T> Function(Transaction) action, {
    final bool dariServer = false,
  }) async {
    Log.info(
      '[TRANSAKSI DIMULAI] Memulai proses eksekusi dalam wrapper transaksi.',
    );

    try {
      final db = await _sqliteDb.database;
      return await db.transaction((txn) async {
        Log.info(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance: ${txn.runtimeType}',
        );

        try {
          if (!dariServer) {
            Log.info(
              '[TRANSAKSI AKTIF] Menandai status `needUpload` menjadi TRUE (operasi lokal).',
            );
            await _statusUnggahOpsqlite.tandaiButuhUpload(
              true,
              transaction: txn,
            );
            Log.info(
              '[TRANSAKSI AKTIF] Status `needUpload` berhasil ditandai.',
            );
          } else {
            Log.info(
              '[TRANSAKSI AKTIF] Melewati penandaan `needUpload` (operasi dari server).',
            );
          }
          final result = await action(txn);
          Log.info(
            '[TRANSAKSI AKTIF] Aksi utama berhasil dieksekusi. Hasil: ${result.runtimeType}',
          );

          Log.info('[TRANSAKSI COMMIT] Transaksi akan di-commit.');
          return result;
        } catch (e, st) {
          Log.error(
            '[TRANSAKSI GAGAL DI DALAM] Error di dalam blok transaksi.',
            e: e,
            s: st,
          );
          rethrow;
        }
      });
    } catch (e, st) {
      Log.error(
        '[TRANSAKSI GAGAL DI LUAR] Gagal memulai atau menyelesaikan transaksi.',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menjalankan operasi database yang kompleks di dalam sebuah transaksi.
  Future<T> runComplexOperation<T>(
    final Future<T> Function(Transaction txn) customAction, {
    final bool dariServer = false,
  }) async {
    Log.info('Mendelegasikan eksekusi transaksi kompleks');
    return await _runInTransaction(customAction, dariServer: dariServer);
  }

  /// Menyisipkan data baru ke dalam [table].
  Future<void> sisipkan(
    final String table,
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai penyisipan data ke tabel: $table');
    try {
      await _runInTransaction((txn) async {
        final hasil = await txn.insert(
          table,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        Log.info('INSERT berhasil', {'rowId': hasil, 'tabel': table});
        return hasil;
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $table',
        e: e,
        s: s,
        data: data,
      );
      rethrow;
    }
  }

  /// Memperbarui data di [table] berdasarkan [id].
  Future<void> update(
    final String table,
    final Map<String, dynamic> data,
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai pembaruan data di tabel: $table', {
      'id': id,
      'data': data,
    });
    try {
      await _runInTransaction((txn) async {
        final rowsAffected = await txn.update(
          table,
          data,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rowsAffected == 0) {
          Log.warning(
            'Update selesai tapi tidak ada baris yang berubah (ID tidak ditemukan)',
            {'id': id, 'tabel': table},
          );
        } else {
          Log.info('UPDATE berhasil', {'rowsAffected': rowsAffected, 'id': id});
        }
        return rowsAffected;
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui data di tabel: $table',
        e: e,
        s: s,
        data: {'id': id, 'payload': data},
      );
      rethrow;
    }
  }

  /// Menghapus data dari [table] berdasarkan [id].
  Future<void> delete(
    String table,
    String id, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai penghapusan data', {'tabel': table, 'id': id});
    try {
      await _runInTransaction((txn) async {
        final rowsDeleted = await txn.delete(
          table,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (rowsDeleted == 0) {
          Log.warning('Delete selesai tapi tidak ada data yang terhapus', {
            'id': id,
            'tabel': table,
          });
        } else {
          Log.info('DELETE berhasil', {'rowsDeleted': rowsDeleted, 'id': id});
        }
        return rowsDeleted;
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $table',
        e: e,
        s: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada satu baris di [table] berdasarkan [id].
  Future<void> softDelete(
    final String table,
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete', {'tabel': table, 'id': id});
    try {
      await _runInTransaction((final txn) async {
        final rowsAffected = await txn.update(
          table,
          {
            NamaKolom.dihapus: 1,
            NamaKolom.diarsipkanPada: now.millisecondsSinceEpoch,
            NamaKolom.diperbaruiPada: now.millisecondsSinceEpoch,
          },
          where: '${NamaKolom.id} = ?',
          whereArgs: [id],
        );

        if (rowsAffected == 0) {
          Log.warning(
            'Soft delete selesai tapi tidak ada baris yang berubah (ID tidak ditemukan)',
            {'id': id, 'tabel': table},
          );
        } else {
          Log.info('Soft delete berhasil', {
            'rowsAffected': rowsAffected,
            'id': id,
          });
        }
        return rowsAffected;
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error(
        'Gagal melakukan soft delete di tabel: $table',
        e: e,
        s: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua baris di [table] yang belum di-soft-delete.
  Future<int> softDeleteAll(
    final String table, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete semua data di tabel: $table');
    try {
      final count = await _runInTransaction<int>((final txn) async {
        final rowsAffected = await txn.update(table, {
          NamaKolom.dihapus: 1,
          NamaKolom.diarsipkanPada: now.millisecondsSinceEpoch,
          NamaKolom.diperbaruiPada: now.millisecondsSinceEpoch,
        }, where: '${NamaKolom.dihapus} = 0');

        Log.info('Soft delete semua data berhasil', {
          'rowsAffected': rowsAffected,
          'tabel': table,
        });
        return rowsAffected;
      }, dariServer: dariServer);
      return count;
    } catch (e, s) {
      Log.error(
        'Gagal melakukan soft delete semua data di tabel: $table',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan data dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final String table,
    final List<Map<String, dynamic>> dataList, {
    final bool dariServer = false,
  }) async {
    if (dataList.isEmpty) {
      Log.warning('Daftar data batch kosong, operasi dibatalkan', {
        'tabel': table,
      });
      return;
    }
    Log.info('Memulai batch operation', {
      'tabel': table,
      'totalItem': dataList.length,
      'fromServer': dariServer,
    });
    try {
      await _runInTransaction((final txn) async {
        final batch = txn.batch();
        int validCount = 0;

        for (int i = 0; i < dataList.length; i++) {
          final data = dataList[i];
          if (data.isNotEmpty) {
            batch.insert(
              table,
              data,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            validCount++;
          }
        }
        Log.info('Melakukan commit batch...', {'validCount': validCount});
        await batch.commit(noResult: true);
        Log.info('Batch operation sukses');
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch operation di tabel: $table',
        e: e,
        s: s,
        data: {'totalItem': dataList.length},
      );
      rethrow;
    }
  }
}
