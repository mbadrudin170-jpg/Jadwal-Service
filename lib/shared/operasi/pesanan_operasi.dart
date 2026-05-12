// path: lib/shared/operasi/pesanan_operasi.dart
// diubah: Refaktorisasi untuk menggunakan OperasiDasar dan menambahkan parameter `dariServer`.
// dihapus: Impor sqflite yang tidak digunakan.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/debug/log.dart';

class PesananOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  // diubah: Menambahkan `dariServer`
  Future<void> simpanPesanan(PesananModel pesanan, {bool dariServer = false}) async {
    Log.info('Menyimpan pesanan baru ID: ${pesanan.id}');
    await _operasiDasar.sisipkan('pesanan', pesanan.toSqlite(), dariServer: dariServer);
  }

  Future<List<PesananModel>> ambilSemuaPesanan() async {
    Log.info('Mengambil semua pesanan dari database.');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      orderBy: 'tanggal DESC',
    );
    return maps.map((map) => PesananModel.fromSqlite(map)).toList();
  }

  Future<List<PesananModel>> ambilPesananByStatus(String status) async {
    Log.info('Mengambil pesanan dengan status: $status');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'tanggal DESC',
    );
    return maps.map((map) => PesananModel.fromSqlite(map)).toList();
  }

  // diubah: Menambahkan `dariServer`
  Future<void> updateStatusPesanan(String id, String status, {bool dariServer = false}) async {
    Log.info('Memperbarui status pesanan ID: $id menjadi $status');
    await _operasiDasar.perbarui('pesanan', {'status': status}, id, dariServer: dariServer);
  }

  // diubah: Menambahkan `dariServer`
  Future<void> hapusPesanan(String id, {bool dariServer = false}) async {
    Log.info('Menghapus pesanan ID: $id');
    await _operasiDasar.hapus('pesanan', id, dariServer: dariServer);
  }

  // diubah: Menambahkan `dariServer`
  Future<void> sisipkanAtauPerbaruiBatch(List<PesananModel> items, {bool dariServer = false}) async {
    Log.info('Memulai batch insert/update untuk ${items.length} pesanan.');
    if (items.isEmpty) return;
    final data = items.map((item) => item.toSqlite()).toList();
    await _operasiDasar.sisipkanAtauPerbaruiBatch('pesanan', data, dariServer: dariServer);
    Log.info('Batch pesanan selesai.');
  }

  Future<List<PesananModel>> getPesananByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    Log.info('Mengambil pesanan untuk ${ids.length} ID.');
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
