// path: lib/shared/operasi/pelanggan_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Menambahkan konstruktor untuk dependency injection (DI) agar bisa di-test.

import 'package:meta/meta.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data pelanggan di database lokal.
class PelangganOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [OperasiDasar] untuk operasi CRUD dasar.
  @visibleForTesting
  final OperasiDasar operasiDasar;

  /// Konstruktor untuk [PelangganOperasi].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [operasiDasar]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  PelangganOperasi({
    final DatabaseHelper? dbHelper,
    final OperasiDasar? operasiDasar,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        operasiDasar = operasiDasar ?? OperasiDasar();

  /// Menyimpan [PelangganModel] baru ke dalam database.
  Future<void> createPelanggan(
    final PelangganModel pelanggan, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai pembuatan pelanggan dengan ID: \${pelanggan.id}');
    try {
      final pelangganUntukDisimpan = pelanggan.copyWith(
        diperbarui: DateTime.now().toUtc(),
      );
      final data = pelangganUntukDisimpan.toSqlite();

      await operasiDasar.sisipkan('pelanggan', data, dariServer: dariServer);

      Log.info(
        'Pelanggan (ID: \${pelangganUntukDisimpan.id}) berhasil dibuat di database lokal.',
      );
    } catch (e, s) {
      Log.error('Gagal membuat pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang aktif (tidak diarsipkan dan tidak dihapus).
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

      Log.info('Berhasil mengambil \${maps.length} pelanggan aktif.');
      return List.generate(maps.length, (final i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil pelanggan aktif.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan, termasuk yang diarsipkan dan dihapus.
  Future<List<PelangganModel>> getAllPelanggan() async {
    Log.info('Mengambil SEMUA data pelanggan dari database lokal.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pelanggan');

      Log.info('Berhasil mengambil total \${maps.length} pelanggan.');
      return List.generate(maps.length, (final i) {
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

  /// Mengambil [PelangganModel] berdasarkan [id].
  Future<PelangganModel?> getPelangganById(final String id) async {
    Log.info('Mencari pelanggan berdasarkan ID: \$id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Pelanggan dengan ID: \$id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      Log.warning('Pelanggan dengan ID: \$id tidak ditemukan.');
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

  /// Memperbarui [PelangganModel] yang ada di database.
  Future<void> updatePelanggan(
    final PelangganModel pelanggan, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai pembaruan untuk pelanggan ID: \${pelanggan.id}');
    try {
      final data =
          pelanggan.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();

      await operasiDasar.perbarui(
        'pelanggan',
        data,
        pelanggan.id,
        dariServer: dariServer,
      );

      Log.info('Berhasil memperbarui pelanggan ID: \${pelanggan.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus [PelangganModel] dari database.
  ///
  /// Jika [softDelete] bernilai `true`, maka hanya akan menandai `isDeleted` menjadi `1`.
  /// Jika `false`, maka akan menghapus data secara permanen.
  Future<void> deletePelanggan(
    final String id, {
    final bool softDelete = true,
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai proses penghapusan untuk pelanggan ID: \$id (softDelete: \$softDelete)',
    );
    try {
      if (softDelete) {
        await operasiDasar.perbarui(
          'pelanggan',
          {
            'isDeleted': 1,
            'diperbarui': DateTime.now().toUtc().millisecondsSinceEpoch,
          },
          id,
          dariServer: dariServer,
        );
        Log.info('Berhasil melakukan soft delete pada pelanggan ID: \$id.');
      } else {
        await operasiDasar.hapus('pelanggan', id, dariServer: dariServer);
        Log.warning(
          'Berhasil melakukan hard delete (penghapusan permanen) pada pelanggan ID: \$id.',
        );
      }
    } catch (e, s) {
      Log.error('Gagal menghapus pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua pelanggan yang telah diubah sejak [since].
  Future<List<PelangganModel>> getPerubahan(final DateTime since) async {
    Log.info('Mengambil perubahan pelanggan sejak: \${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'diperbarui > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info(
        'Ditemukan \${maps.length} perubahan pelanggan sejak waktu yang ditentukan.',
      );
      return List.generate(
        maps.length,
        (final i) => PelangganModel.fromSqlite(maps[i]),
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

  /// Mengarsipkan [PelangganModel] berdasarkan [id].
  Future<void> arsipkanPelanggan(final String id, {final bool dariServer = false}) async {
    Log.info('Mengarsipkan pelanggan ID: \$id');
    try {
      final now = DateTime.now().toUtc();
      await operasiDasar.perbarui(
        'pelanggan',
        {
          'isDeleted': 1,
          'diarsipkan': now.millisecondsSinceEpoch,
          'diperbarui': now.millisecondsSinceEpoch,
        },
        id,
        dariServer: dariServer,
      );
      Log.info('Berhasil mengarsipkan pelanggan ID: \$id.');
    } catch (e, s) {
      Log.error('Gagal mengarsipkan pelanggan.', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [PelangganModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<PelangganModel> items, {
    final bool dariServer = false,
  }) async {
    if (items.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk \${items.length} pelanggan.');
    try {
      final data = items.map((final item) {
        return item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();
      }).toList();

      await operasiDasar.sisipkanAtauPerbaruiBatch(
        'pelanggan',
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan operasi batch untuk \${items.length} pelanggan.',
      );
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [PelangganModel] berdasarkan daftar [ids].
  Future<List<PelangganModel>> getPelangganByIds(final List<String> ids) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada pelanggan yang diambil.');
      return [];
    }
    Log.info('Mengambil data pelanggan untuk \${ids.length} ID.');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pelanggan',
        where: 'id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil \${maps.length} pelanggan berdasarkan list ID yang diberikan.',
      );
      return List.generate(maps.length, (final i) {
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
