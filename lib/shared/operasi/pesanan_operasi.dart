// path: lib/shared/operasi/pesanan_operasi.dart// diubah: Menghapus fungsi yang tidak valid (totalPendapatanHariIni, hitungPesananHariIni)
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/pesanan_model.dart';

class PesananOperasi {
  final dbHelper = DatabaseHelper.instance;

  // Simpan pesanan baru
  Future<void> simpanPesanan(PesananModel pesanan) async {
    final db = await dbHelper.database;
    await db.insert(
      'pesanan',
      pesanan.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil semua pesanan (terbaru di atas)
  Future<List<PesananModel>> ambilSemuaPesanan() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      orderBy: 'tanggal DESC',
    );
    return maps.map((map) => PesananModel.fromSqlite(map)).toList();
  }

  // Ambil pesanan berdasarkan status
  Future<List<PesananModel>> ambilPesananByStatus(String status) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'tanggal DESC',
    );
    return maps.map((map) => PesananModel.fromSqlite(map)).toList();
  }

  // Update status pesanan
  Future<void> updateStatusPesanan(String id, String status) async {
    final db = await dbHelper.database;
    await db.update(
      'pesanan',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hapus pesanan
  Future<void> hapusPesanan(String id) async {
    final db = await dbHelper.database;
    await db.delete('pesanan', where: 'id = ?', whereArgs: [id]);
  }

  // Menyisipkan atau memperbarui data secara batch
  Future<void> sisipkanAtauPerbaruiBatch(List<PesananModel> items) async {
    final db = await dbHelper.database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'pesanan',
        item.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PesananModel>> getPesananByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await dbHelper.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return List.generate(maps.length, (i) {
      return PesananModel.fromSqlite(maps[i]);
    });
  }
}
