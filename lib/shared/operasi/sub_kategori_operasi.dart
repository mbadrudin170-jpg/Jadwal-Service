// path: lib/data/operasi/sub_kategori_operasi.dart
// diubah: Refaktorisasi untuk menggunakan OperasiDasar dan menambahkan parameter `dariServer`.
// dihapus: Impor sqflite yang tidak digunakan.

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data sub-kategori di database lokal.
class SubKategoriOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  DatabaseHelper dbHelper;

  /// Instance dari OperasiDasar untuk operasi CRUD dasar.
  OperasiDasar operasiDasar;

  /// Konstruktor untuk [SubKategoriOperasi].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [operasiDasar]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  SubKategoriOperasi({final DatabaseHelper? dbHelper, final OperasiDasar? operasiDasar})
      : dbHelper = dbHelper ?? DatabaseHelper.instance,
        operasiDasar = operasiDasar ?? OperasiDasar();

  /// Mengganti instance [DatabaseHelper] untuk tujuan pengujian.
  @visibleForTesting
  void testSetDbHelper(final DatabaseHelper helper) {
    dbHelper = helper;
  }

  /// Mengganti instance [OperasiDasar] untuk tujuan pengujian.
  @visibleForTesting
  void testSetOperasiDasar(final OperasiDasar operasi) {
    operasiDasar = operasi;
  }

  /// Menyimpan [SubKategoriModel] baru ke dalam database.
  Future<void> createSubKategori(
    final SubKategoriModel subKategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Membuat sub-kategori baru: ${subKategori.nama}');
    final data = subKategori.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();
    await operasiDasar.sisipkan('sub_kategori', data, dariServer: dariServer);
  }

  /// Mengambil semua sub-kategori yang terkait dengan [idKategori].
  Future<List<SubKategoriModel>> getSubKategoriByKategoriId(
    final String idKategori,
  ) async {
    Log.info('Mengambil sub-kategori untuk kategori ID: $idKategori');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id_kategori = ? AND isDeleted = ?',
      whereArgs: [idKategori, 0],
    );
    return List.generate(maps.length, (final i) {
      return SubKategoriModel.fromSqlite(maps[i]);
    });
  }

  /// Mengambil [SubKategoriModel] berdasarkan [id].
  Future<SubKategoriModel?> getSubKategoriById(final String id) async {
    Log.info('Mengambil sub-kategori dengan ID: $id');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SubKategoriModel.fromSqlite(maps.first);
    }
    return null;
  }

  /// Memperbarui [SubKategoriModel] yang ada di database.
  Future<void> updateSubKategori(
    final SubKategoriModel subKategori, {
    final bool dariServer = false,
  }) async {
    Log.info('Memperbarui sub-kategori: ${subKategori.nama}');
    final data = subKategori.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();
    await operasiDasar.perbarui(
      'sub_kategori',
      data,
      subKategori.id,
      dariServer: dariServer,
    );
  }

  /// Menghapus [SubKategoriModel] dari database.
  ///
  /// Jika [softDelete] bernilai `true`, maka hanya akan menandai `isDeleted` menjadi `1`.
  /// Jika `false`, maka akan menghapus data secara permanen.
  Future<void> deleteSubKategori(
    final String id, {
    final bool softDelete = true,
    final bool dariServer = false,
  }) async {
    Log.info('Menghapus sub-kategori ID: $id (softDelete: $softDelete)');
    if (softDelete) {
      final dataToUpdate = {
        'isDeleted': 1,
        'diperbarui': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
      await operasiDasar.perbarui(
        'sub_kategori',
        dataToUpdate,
        id,
        dariServer: dariServer,
      );
    } else {
      await operasiDasar.hapus('sub_kategori', id, dariServer: dariServer);
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [SubKategoriModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<SubKategoriModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk ${items.length} sub-kategori.');
    if (items.isEmpty) return;
    final data = items
        .map((final item) => item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite())
        .toList();
    await operasiDasar.sisipkanAtauPerbaruiBatch(
      'sub_kategori',
      data,
      dariServer: dariServer,
    );
    Log.info('Batch sub-kategori selesai.');
  }

  /// Mengambil beberapa [SubKategoriModel] berdasarkan daftar [ids].
  Future<List<SubKategoriModel>> getSubKategoriByIds(final List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    Log.info('Mengambil sub-kategori untuk ${ids.length} ID.');
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (final i) {
      return SubKategoriModel.fromSqlite(maps[i]);
    });
  }
}
