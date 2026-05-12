// path: lib/shared/operasi/pelanggan_operasi.dart
// diubah: Menambahkan parameter `dariServer` ke semua operasi tulis.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

class PelangganOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  // diubah: Menambahkan `dariServer`
  Future<void> createPelanggan(PelangganModel pelanggan, {bool dariServer = false}) async {
    Log.info('Memulai pembuatan pelanggan dengan ID: ${pelanggan.id}');
    try {
      final pelangganUntukDisimpan = pelanggan.copyWith(
        diperbarui: DateTime.now(),
      );
      final data = pelangganUntukDisimpan.toSqlite();

      await _operasiDasar.sisipkan('pelanggan', data, dariServer: dariServer);

      Log.info(
        'Pelanggan (ID: ${pelangganUntukDisimpan.id}) berhasil dibuat di database lokal.',
      );
    } catch (e, s) {
      Log.error('Gagal membuat pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelanggan() async {
    Log.info(
      'Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diarsipkan IS NULL AND isDeleted = ?',
        whereArgs: [0],
      );

      Log.info('Berhasil mengambil ${maps.length} pelanggan aktif.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil pelanggan aktif.', e: e, st: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getAllPelanggan() async {
    Log.info('Mengambil SEMUA data pelanggan dari database lokal.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pelanggan');

      Log.info('Berhasil mengambil total ${maps.length} pelanggan.');
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil semua data pelanggan.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<PelangganModel?> getPelangganById(String id) async {
    Log.info('Mencari pelanggan berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Pelanggan dengan ID: $id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      Log.warning('Pelanggan dengan ID: $id tidak ditemukan.');
      return null;
    } catch (e, s) {
      Log.error(
        'Gagal mencari pelanggan berdasarkan ID.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> updatePelanggan(PelangganModel pelanggan, {bool dariServer = false}) async {
    Log.info('Memulai pembaruan untuk pelanggan ID: ${pelanggan.id}');
    try {
      final data = pelanggan.copyWith(diperbarui: DateTime.now()).toSqlite();

      await _operasiDasar.perbarui('pelanggan', data, pelanggan.id, dariServer: dariServer);

      Log.info('Berhasil memperbarui pelanggan ID: ${pelanggan.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> deletePelanggan(String id, {bool softDelete = true, bool dariServer = false}) async {
    Log.info(
      'Memulai proses penghapusan untuk pelanggan ID: $id (softDelete: $softDelete)',
    );
    try {
      if (softDelete) {
        await _operasiDasar.perbarui(
            'pelanggan',
            {
              'isDeleted': 1,
              'diperbarui': DateTime.now().toIso8601String(),
            },
            id, dariServer: dariServer);
        Log.info('Berhasil melakukan soft delete pada pelanggan ID: $id.');
      } else {
        await _operasiDasar.hapus('pelanggan', id, dariServer: dariServer);
        Log.warning(
          'Berhasil melakukan hard delete (penghapusan permanen) pada pelanggan ID: $id.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menghapus pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPerubahan(DateTime since) async {
    Log.info('Mengambil perubahan pelanggan sejak: ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      Log.info(
        'Ditemukan ${maps.length} perubahan pelanggan sejak waktu yang ditentukan.',
      );
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error(
        'Gagal mengambil perubahan pelanggan.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> arsipkanPelanggan(String id, {bool dariServer = false}) async {
    Log.info('Mengarsipkan pelanggan ID: $id');
    try {
      final now = DateTime.now();
      await _operasiDasar.perbarui(
          'pelanggan',
          {
            'isDeleted': 1,
            'diarsipkan': now.toIso8601String(),
            'diperbarui': now.toIso8601String(),
          },
          id, dariServer: dariServer);
      Log.info('Berhasil mengarsipkan pelanggan ID: $id.');
    } catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  // diubah: Menambahkan `dariServer`
  Future<void> sisipkanAtauPerbaruiBatch(List<PelangganModel> items, {bool dariServer = false}) async {
    if (items.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${items.length} pelanggan.');
    try {
      final data = items.map((item) {
        // Kita tidak perlu mengatur `diperbarui` di sini karena OperasiDasar akan menanganinya jika perlu.
        return item.toSqlite();
      }).toList();

      await _operasiDasar.sisipkanAtauPerbaruiBatch('pelanggan', data, dariServer: dariServer);
      Log.info(
        'Berhasil menyelesaikan operasi batch untuk ${items.length} pelanggan.',
      );
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, st: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> getPelangganByIds(List<String> ids) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada pelanggan yang diambil.');
      return [];
    }
    Log.info('Mengambil data pelanggan untuk ${ids.length} ID.');
    try {
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} pelanggan berdasarkan list ID yang diberikan.',
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil pelanggan berdasarkan list ID.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }
}
