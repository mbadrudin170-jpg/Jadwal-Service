// path: lib/shared/operasi/pesanan_operasi.dart
// diubah: Memastikan semua operasi tulis memperbarui timestamp `diperbarui` dengan UTC.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';
import 'package:wifi/shared/debug/log.dart';

class PesananOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  // diubah: Menambahkan pengaturan `diperbarui` dengan UTC sebelum menyimpan
  Future<void> simpanPesanan(PesananModel pesanan, {bool dariServer = false}) async {
    Log.info('Menyimpan pesanan baru ID: ${pesanan.id}');
    final pesananUntukDisimpan = pesanan.copyWith(
      diperbarui: DateTime.now().toUtc(),
    );
    await _operasiDasar.sisipkan('pesanan', pesananUntukDisimpan.toSqlite(), dariServer: dariServer);
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

  // diubah: Logika diubah untuk mengambil data, memperbarui, lalu menyimpan kembali.
  // Ini memastikan `diperbarui` selalu diatur dengan benar saat status berubah.
  Future<void> updateStatusPesanan(String id, String status, {bool dariServer = false}) async {
    Log.info('Memperbarui status pesanan ID: $id menjadi $status');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final pesananLama = PesananModel.fromSqlite(maps.first);
      final pesananBaru = pesananLama.copyWith(
        status: status,
        diperbarui: DateTime.now().toUtc(),
      );
      await _operasiDasar.perbarui('pesanan', pesananBaru.toSqlite(), id, dariServer: dariServer);
      Log.info('Status pesanan ID: $id berhasil diperbarui beserta timestamp-nya.');
    } else {
      Log.warning('Gagal memperbarui status: Pesanan dengan ID: $id tidak ditemukan.');
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> hapusPesanan(String id, {bool dariServer = false}) async {
    Log.info('Menghapus pesanan ID: $id');
    await _operasiDasar.hapus('pesanan', id, dariServer: dariServer);
  }

  // diubah: Menambahkan pengaturan `diperbarui` dengan UTC untuk setiap item batch
  Future<void> sisipkanAtauPerbaruiBatch(List<PesananModel> items, {bool dariServer = false}) async {
    Log.info('Memulai batch insert/update untuk ${items.length} pesanan.');
    if (items.isEmpty) return;
    final data = items.map((item) => item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite()).toList();
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
