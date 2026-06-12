// path: lib/shared/operasi/base_operation.dart
// diubah: Menambahkan parameter `fromServer` untuk memutus siklus sinkronisasi.
// diubah: Mengganti StatusUnggahOperasi menjadi UploadStatusOperation.
// diubah: Mengganti nama class dari OperasiDasar menjadi BaseOperation.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/upload_status_operation.dart';

final baseOperationProvider = Provider<BaseOperation>((ref) {
  Log.info('Membuat instance BaseOperation...');

  final dbHelper = ref.read(databaseHelperProvider);

  final uploadStatusOperasi = ref.read(uploadStatusOperationProvider);

  return BaseOperation(
    dbHelper: dbHelper,
    uploadStatusOperasi: uploadStatusOperasi,
  );
});

/// Kelas ini adalah PUSAT KONTROL untuk semua operasi tulis (write) ke database.
class BaseOperation {
  final DatabaseHelper _dbHelper;
  final UploadStatusOperation _uploadStatusOperasi;
  final now = DateTime.now().toUtc();

  /// Konstruktor untuk `BaseOperation`.
  ///
  /// Memungkinkan injeksi dependensi untuk `DatabaseHelper` dan `UploadStatusOperation`
  /// untuk memfasilitasi pengujian.
  BaseOperation({
    required final DatabaseHelper dbHelper,
    required final UploadStatusOperation uploadStatusOperasi,
  })  : _dbHelper = dbHelper,
        _uploadStatusOperasi = uploadStatusOperasi {
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
      final db = await _dbHelper.database;
      return await db.transaction((final txn) async {
        Log.info(
          '[TRANSAKSI AKTIF] Blok transaksi telah dimulai. Instance: ${txn.runtimeType}',
        );

        try {
          if (!dariServer) {
            Log.info(
              '[TRANSAKSI AKTIF] Menandai status `needUpload` menjadi TRUE (operasi lokal).',
            );
            await _uploadStatusOperasi.setNeedUpload(true, transaction: txn);
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
  Future<T> runComplexOperation<T>(
    final Future<T> Function(Transaction txn) customAction, {
    final bool fromServer = false,
  }) async {
    Log.info('Mendelegasikan eksekusi transaksi kompleks');
    return await _runInTransaction(customAction, dariServer: fromServer);
  }

  /// Menyisipkan data baru ke dalam [table].
  Future<void> sisipkan(
    final String table,
    final Map<String, dynamic> data, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai penyisipan data ke tabel: $table');
    try {
      await _runInTransaction(
        (final txn) async {
          final result = await txn.insert(
            table,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          Log.info('INSERT berhasil', {'rowId': result, 'tabel': table});
          return result;
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menyisipkan data ke tabel: $table',
        e: e,
        st: s,
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
      await _runInTransaction(
        (final txn) async {
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
        'Gagal memperbarui data di tabel: $table',
        e: e,
        st: s,
        data: {'id': id, 'payload': data},
      );
      rethrow;
    }
  }

  /// Menghapus data dari [table] berdasarkan [id].
  Future<void> delete(
    final String table,
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai penghapusan data', {'tabel': table, 'id': id});
    try {
      await _runInTransaction(
        (final txn) async {
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
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal menghapus data di tabel: $table',
        e: e,
        st: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada satu baris di [table] berdasarkan [id].
  Future<void> hapusSementara(
    final String table,
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete', {'tabel': table, 'id': id});
    try {
      await _runInTransaction(
        (final txn) async {
          final rowsAffected = await txn.update(
            table,
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.archivedAt: now.millisecondsSinceEpoch,
              ColumnNames.updatedAt: now.millisecondsSinceEpoch,
            },
            where: '${ColumnNames.id} = ?',
            whereArgs: [id],
          );

          if (rowsAffected == 0) {
            Log.warning(
              'Soft delete selesai tapi tidak ada baris yang berubah (ID tidak ditemukan)',
              {'id': id, 'tabel': table},
            );
          } else {
            Log.info(
              'Soft delete berhasil',
              {'rowsAffected': rowsAffected, 'id': id},
            );
          }
          return rowsAffected;
        },
        dariServer: dariServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal melakukan soft delete di tabel: $table',
        e: e,
        st: s,
        data: {'id': id},
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua baris di [table] yang belum di-soft-delete.
  Future<int> hapusSementaraSemua(
    final String table, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai soft delete semua data di tabel: $table');
    try {
      final count = await _runInTransaction<int>(
        (final txn) async {
          final rowsAffected = await txn.update(
            table,
            {
              ColumnNames.isDeleted: 1,
              ColumnNames.archivedAt: now.millisecondsSinceEpoch,
              ColumnNames.updatedAt: now.millisecondsSinceEpoch,
            },
            where: '${ColumnNames.isDeleted} = 0',
          );

          Log.info(
            'Soft delete semua data berhasil',
            {'rowsAffected': rowsAffected, 'tabel': table},
          );
          return rowsAffected;
        },
        dariServer: dariServer,
      );
      return count;
    } catch (e, s) {
      Log.error(
        'Gagal melakukan soft delete semua data di tabel: $table',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan data dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final String table,
    final List<Map<String, dynamic>> dataList, {
    final bool fromServer = false,
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
      'fromServer': fromServer,
    });
    try {
      await _runInTransaction(
        (final txn) async {
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
        },
        dariServer: fromServer,
      );
    } catch (e, s) {
      Log.error(
        'Gagal melakukan batch operation di tabel: $table',
        e: e,
        st: s,
        data: {'totalItem': dataList.length},
      );
      rethrow;
    }
  }
}
