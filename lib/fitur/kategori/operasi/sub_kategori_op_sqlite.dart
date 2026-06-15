// path: lib/fitur/kategori/operasi/sub_kategori_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';

/// Kelas untuk operasi terkait data sub-kategori di database lokal.
class SubKategoriOpSqlite {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final SqliteDatabase sqliteDb;

  /// Instance dari [BaseOpSqlite] untuk operasi CRUD dasar.
  final BaseOpSqlite baseOpSqlite;

  final String _tableName = NamaTabel.subKategori;

  SubKategoriOpSqlite({
    required this.sqliteDb,
    required this.baseOpSqlite,
  });

  /// Menyimpan [SubKategoriModel] baru ke dalam database.
  Future<void> createSubCategory(
    final SubKategoriModel subKategori, {
    final bool fromServer = false,
  }) async {
    Log.info('Membuat sub-kategori baru: ${subKategori.nama}');
    try {
      final data = subKategori
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();
      await baseOpSqlite.sisipkan(
        _tableName,
        data,
        dariServer: fromServer,
      );
      Log.info('Berhasil membuat sub-kategori ID: ${subKategori.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal membuat sub-kategori.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua sub-kategori yang terkait dengan [categoryId].
  Future<List<SubKategoriModel>> ambilBerdasarkanIdPelanggan(
    final String categoryId,
  ) async {
    Log.info('Mengambil sub-kategori untuk kategori ID: $categoryId');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: '${NamaKolom.idKategori} = ? AND ${NamaKolom.diHapus} = ?',
        whereArgs: [categoryId, 0],
      );
      Log.info('Berhasil mengambil ${maps.length} sub-kategori aktif.');
      return List.generate(maps.length, (final i) {
        return SubKategoriModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan kategori ID.',
          e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil [SubKategoriModel] berdasarkan [id].
  Future<SubKategoriModel?> getSubCategoryById(final String id) async {
    Log.info('Mengambil sub-kategori dengan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Sub-kategori dengan ID: $id ditemukan.');
        return SubKategoriModel.fromSqlite(maps.first);
      }
      Log.warning('Sub-kategori dengan ID: $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan ID.', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui [SubKategoriModel] yang ada di database.
  Future<void> updateSubCategory(
    final SubKategoriModel subKategori, {
    final bool fromServer = false,
  }) async {
    Log.info('Memperbarui sub-kategori: ${subKategori.nama}');
    try {
      final data = subKategori
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();
      await baseOpSqlite.update(
        _tableName,
        data,
        subKategori.id,
        dariServer: fromServer,
      );
      Log.info('Berhasil memperbarui sub-kategori ID: ${subKategori.id}');
    } on Exception catch (e, s) {
      Log.error('Gagal memperbarui sub-kategori.', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus [SubKategoriModel] dari database secara permanen.
  Future<void> delete(final String id, {final bool fromServer = false}) async {
    Log.warning('PERINGATAN: Menghapus sub-kategori ID: $id secara permanen');
    try {
      await baseOpSqlite.delete(
        _tableName,
        id,
        dariServer: fromServer,
      );
      Log.warning('Berhasil melakukan hard delete sub-kategori ID: $id');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus sub-kategori secara permanen.', e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada sub-kategori berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk sub-kategori ID: $id');
    try {
      await baseOpSqlite.softDelete(
        _tableName,
        id,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete sub-kategori ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete sub-kategori ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua sub-kategori.
  Future<int> softDeleteAll({
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk semua sub-kategori');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _tableName,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua sub-kategori. Total: $count item.');
      return count;
    } on Exception catch (e, st) {
      Log.error('Gagal saat soft delete semua sub-kategori', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [SubKategoriModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<SubKategoriModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Memulai batch insert/update untuk ${items.length} sub-kategori.',
    );
    if (items.isEmpty) {
      Log.warning('List item kosong, membatalkan proses operasi batch.');
      return;
    }
    try {
      final data = items
          .map(
            (final item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await baseOpSqlite.insertOrUpdateBatch(
        _tableName,
        data,
        dariServer: fromServer,
      );
      Log.info('Batch sub-kategori selesai diproses.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan operasi batch sub-kategori.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [SubKategoriModel] berdasarkan daftar [ids].
  Future<List<SubKategoriModel>> getSubCategoryByIds(
    final List<String> ids,
  ) async {
    Log.info('Mengambil sub-kategori untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong.');
      return [];
    }
    try {
      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id IN ($placeholders) AND ${NamaKolom.diHapus} = 0',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} sub-kategori dari list ID.');
      return List.generate(maps.length, (final i) {
        return SubKategoriModel.fromSqlite(maps[i]);
      });
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil sub-kategori berdasarkan list ID.',
          e: e, s: s);
      rethrow;
    }
  }
}
