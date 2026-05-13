// path: lib/data/operasi/sub_kategori_operasi.dart
// diubah: Refaktorisasi untuk menggunakan OperasiDasar dan menambahkan parameter `dariServer`.
// dihapus: Impor sqflite yang tidak digunakan.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/debug/log.dart';

class SubKategoriOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  // diubah: Menggunakan OperasiDasar dan menambahkan `dariServer`
  Future<void> createSubKategori(SubKategoriModel subKategori,
      {bool dariServer = false}) async {
    Log.info('Membuat sub-kategori baru: ${subKategori.nama}');
    final data = subKategori.copyWith(diperbarui: DateTime.now()).toSqlite();
    await _operasiDasar.sisipkan('sub_kategori', data, dariServer: dariServer);
  }

  Future<List<SubKategoriModel>> getSubKategoriByKategoriId(
    String idKategori,
  ) async {
    Log.info('Mengambil sub-kategori untuk kategori ID: $idKategori');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id_kategori = ? AND isDeleted = ?',
      whereArgs: [idKategori, 0],
    );
    return List.generate(maps.length, (i) {
      return SubKategoriModel.fromSqlite(maps[i]);
    });
  }

  Future<SubKategoriModel?> getSubKategoriById(String id) async {
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

  // diubah: Menggunakan OperasiDasar dan menambahkan `dariServer`
  Future<void> updateSubKategori(SubKategoriModel subKategori,
      {bool dariServer = false}) async {
    Log.info('Memperbarui sub-kategori: ${subKategori.nama}');
    final data = subKategori.copyWith(diperbarui: DateTime.now()).toSqlite();
    await _operasiDasar.perbarui('sub_kategori', data, subKategori.id,
        dariServer: dariServer);
  }

  // diubah: Menggunakan OperasiDasar dan menambahkan `dariServer`
  Future<void> deleteSubKategori(String id,
      {bool softDelete = true, bool dariServer = false}) async {
    Log.info('Menghapus sub-kategori ID: $id (softDelete: $softDelete)');
    if (softDelete) {
      final dataToUpdate = {
        'isDeleted': 1,
        'diperbarui': DateTime.now().toIso8601String()
      };
      await _operasiDasar.perbarui('sub_kategori', dataToUpdate, id,
          dariServer: dariServer);
    } else {
      await _operasiDasar.hapus('sub_kategori', id, dariServer: dariServer);
    }
  }

  // diubah: Menggunakan OperasiDasar dan menambahkan `dariServer`
  Future<void> sisipkanAtauPerbaruiBatch(List<SubKategoriModel> items,
      {bool dariServer = false}) async {
    Log.info('Memulai batch insert/update untuk ${items.length} sub-kategori.');
    if (items.isEmpty) return;
    final data = items
        .map((item) => item.copyWith(diperbarui: DateTime.now()).toSqlite())
        .toList();
    await _operasiDasar.sisipkanAtauPerbaruiBatch('sub_kategori', data,
        dariServer: dariServer);
    Log.info('Batch sub-kategori selesai.');
  }

  Future<List<SubKategoriModel>> getSubKategoriByIds(List<String> ids) async {
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
    return List.generate(maps.length, (i) {
      return SubKategoriModel.fromSqlite(maps[i]);
    });
  }
}
