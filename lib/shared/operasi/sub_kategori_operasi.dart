// path: lib/data/operasi/sub_kategori_operasi.dart
// diubah: Menyesuaikan pemanggilan metode model menjadi fromSqlite dan toSqlite.
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:sqflite/sqflite.dart';

class SubKategoriOperasi {
  final dbHelper = DatabaseHelper.instance;

  Future<void> createSubKategori(SubKategoriModel subKategori) async {
    final db = await dbHelper.database;
    final data = subKategori
        .copyWith(diperbarui: DateTime.now())
        // diubah: dari toMapForSqlite ke toSqlite
        .toSqlite();
    await db.insert(
      'sub_kategori',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SubKategoriModel>> getSubKategoriByKategoriId(
    String idKategori,
  ) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id_kategori = ? AND isDeleted = ?',
      whereArgs: [idKategori, 0],
    );
    return List.generate(maps.length, (i) {
      // diubah: dari fromMap ke fromSqlite
      return SubKategoriModel.fromSqlite(maps[i]);
    });
  }

  Future<SubKategoriModel?> getSubKategoriById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      // diubah: dari fromMap ke fromSqlite
      return SubKategoriModel.fromSqlite(maps.first);
    }
    return null;
  }

  Future<void> updateSubKategori(SubKategoriModel subKategori) async {
    final db = await dbHelper.database;
    final data = subKategori
        .copyWith(diperbarui: DateTime.now())
        // diubah: dari toMapForSqlite ke toSqlite
        .toSqlite();
    await db.update(
      'sub_kategori',
      data,
      where: 'id = ?',
      whereArgs: [subKategori.id],
    );
  }

  Future<void> deleteSubKategori(String id, {bool softDelete = true}) async {
    final db = await dbHelper.database;
    if (softDelete) {
      await db.update(
        'sub_kategori',
        {'isDeleted': 1, 'diperbarui': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      await db.delete('sub_kategori', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<SubKategoriModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      final itemToSave = item.copyWith(diperbarui: DateTime.now());
      batch.insert(
        'sub_kategori',
        // diubah: dari toMapForSqlite ke toSqlite
        itemToSave.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
  Future<List<SubKategoriModel>> getSubKategoriByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'sub_kategori',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      // diubah: dari fromMap ke fromSqlite
      return SubKategoriModel.fromSqlite(maps[i]);
    });
  }
}
