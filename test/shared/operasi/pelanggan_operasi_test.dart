// path: lib/shared/operasi/pelanggan_operasi.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

/// Kelas untuk operasi terkait data pelanggan di database lokal.
class PelangganOperasi {
  /// Instance dari DatabaseHelper untuk mengakses database.
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  /// Menyimpan [PelangganModel] baru ke dalam database.
  Future<void> createPelanggan(
    final PelangganModel pelanggan, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai pembuatan pelanggan dengan ID: ${pelanggan.id}');
    try {
      final pelangganUntukDisimpan = pelanggan.copyWith(
        diperbarui: DateTime.now().toUtc(),
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

      Log.info('Berhasil mengambil ${maps.length} pelanggan aktif.');
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

      Log.info('Berhasil mengambil total ${maps.length} pelanggan.');
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

  /// Memperbarui [PelangganModel] yang ada di database.
  Future<void> updatePelanggan(
    final PelangganModel pelanggan, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai pembaruan untuk pelanggan ID: ${pelanggan.id}');
    try {
      final data =
          pelanggan.copyWith(diperbarui: DateTime.now().toUtc()).toSqlite();

      await _operasiDasar.perbarui(
        'pelanggan',
        data,
        pelanggan.id,
        dariServer: dariServer,
      );

      Log.info('Berhasil memperbarui pelanggan ID: ${pelanggan.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui pelangg