// path: lib/shared/operasi/pesanan_operasi.dart
// diubah: Memastikan semua operasi tulis memperbarui timestamp `diperbarui` dengan UTC.
// diubah: Menambahkan konstruktor untuk dependency injection (DI) agar bisa di-test.

import 'package:meta/meta.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data pesanan di database lokal.
class PesananOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [OperasiDasar] untuk operasi CRUD dasar.
  @visibleForTesting
  final OperasiDasar operasiDasar;

  /// Konstruktor untuk [PesananOperasi].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [operasiDasar]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  PesananOperasi({
    final DatabaseHelper? dbHelper,
    final OperasiDasar? operasiDasar,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        operasiDasar = operasiDasar ?? OperasiDasar();

  /// Menyimpan [PesananModel] baru ke dalam database.
  Future<void> simpanPesanan(
    final PesananModel pesanan, {
    final bool dariServer = false,
  }) async {
    Log.info('Menyimpan pesanan baru ID: \${pesanan.id}');
    final pesananUntukDisimpan = pesanan.copyWith(
      diperbarui: DateTime.now().toUtc(),
    );
    await operasiDasar.sisipkan(
      'pesanan',
      pesananUntukDisimpan.toSqlite(),
      dariServer: dariServer,
    );
  }

  /// Mengambil semua pesanan dari database.
  Future<List<PesananModel>> ambilSemuaPesanan() async {
    Log.info('Mengambil semua pesanan dari database.');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      orderBy: 'tanggal DESC',
    );
    return maps.map(PesananModel.fromSqlite).toList();
  }

  /// Mengambil pesanan berdasarkan [status].
  Future<List<PesananModel>> ambilPesananByStatus(final String status) async {
    Log.info('Mengambil pesanan dengan status: \$status');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'tanggal DESC',
    );
    return maps.map(PesananModel.fromSqlite).toList();
  }

  /// Memperbarui status [PesananModel] berdasarkan [id].
  Future<void> updateStatusPesanan(
    final String id,
    final String status, {
    final bool dariServer = false,
  }) async {
    Log.info('Memperbarui status pesanan ID: \$id menjadi \$status');
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
      await operasiDasar.perbarui(
        'pesanan',
        pesananBaru.toSqlite(),
        id,
        dariServer: dariServer,
      );
      Log.info(
        'Status pesanan ID: \$id berhasil diperbarui beserta timestamp-nya.',
      );
    } else {
      Log.warning(
        'Gagal memperbarui status: Pesanan dengan ID: \$id tidak ditemukan.',
      );
    }
  }

  /// Menghapus [PesananModel] dari database berdasarkan [id].
  Future<void> hapusPesanan(
    final String id, {
    final bool dariServer = false,
  }) async {
    Log.info('Menghapus pesanan ID: \$id');
    await operasiDasar.hapus('pesanan', id, dariServer: dariServer);
  }

  /// Menyisipkan atau memperbarui sekumpulan [PesananModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<PesananModel> items, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai batch insert/update untuk \${items.length} pesanan.');
    if (items.isEmpty) return;
    final data = items
        .map(
          (final item) =>
              item.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite(),
        )
        .toList();
    await operasiDasar.sisipkanAtauPerbaruiBatch(
      'pesanan',
      data,
      dariServer: dariServer,
    );
    Log.info('Batch pesanan selesai.');
  }

  /// Mengambil beberapa [PesananModel] berdasarkan daftar [ids].
  Future<List<PesananModel>> getPesananByIds(final List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    Log.info('Mengambil pesanan untuk \${ids.length} ID.');
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pesanan',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    return List.generate(maps.length, (final i) {
      return PesananModel.fromSqlite(maps[i]);
    });
  }
}
