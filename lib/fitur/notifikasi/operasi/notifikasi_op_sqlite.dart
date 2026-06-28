// path lib/fitur/notfikasi/operasi/notifikasi_op_sqlite.dart
// path: lib/fitur/notfikasi/operasi/notifikasi_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data notifikasi di database lokal.
class NotifikasiOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final String _namaTabel = NamaTabel.notifikasi;
  final DateTime _nowUtc = DateTime.now().toUtc();

  /// Konstruktor dengan injeksi dependensi.
  NotifikasiOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite {
    Log.info('NotifikasiOpSqlite diinisialisasi - Tabel: $_namaTabel');
  }

  // =========================
  // OPERASI TULIS (WRITE)
  // =========================

  /// Menambahkan notifikasi baru ke database.
  Future<void> tambahNotifikasi(
    NotifikasiModel notifikasi, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan notifikasi baru - ID: ${notifikasi.id}');
    try {
      final data = notifikasi.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.sisipkan(_namaTabel, data, dariServer: dariServer);
      Log.info('Notifikasi berhasil ditambahkan - ID: ${notifikasi.id}');
    } catch (e, st) {
      Log.error(
        'Gagal menambahkan notifikasi - ID: ${notifikasi.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Memperbarui notifikasi yang sudah ada di database.
  Future<void> perbaruiNotifikasi(
    NotifikasiModel notifikasi, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui notifikasi - ID: ${notifikasi.id}');
    try {
      final data = notifikasi.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await _baseOpSqlite.update(
        _namaTabel,
        data,
        notifikasi.id,
        dariServer: dariServer,
      );
      Log.info('Notifikasi berhasil diperbarui - ID: ${notifikasi.id}');
    } catch (e, st) {
      Log.error(
        'Gagal memperbarui notifikasi - ID: ${notifikasi.id}',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menandai notifikasi sebagai sudah dibaca.
  Future<void> tandaiSudahDibaca(String id, {bool dariServer = false}) async {
    Log.info('Menandai notifikasi sudah dibaca - ID: $id');
    try {
      final data = {
        NamaKolom.setatusDibaca: 1,
        NamaKolom.diperbaruiPada: _nowUtc.millisecondsSinceEpoch,
      };
      await _baseOpSqlite.update(_namaTabel, data, id, dariServer: dariServer);
      Log.info('Notifikasi berhasil ditandai sudah dibaca - ID: $id');
    } catch (e, st) {
      Log.error(
        'Gagal menandai notifikasi sudah dibaca - ID: $id',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Melakukan soft delete pada notifikasi berdasarkan ID.
  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Memulai soft delete notifikasi - ID: $id');
    try {
      await _baseOpSqlite.softDelete(_namaTabel, id, dariServer: dariServer);
      Log.info('Soft delete notifikasi berhasil - ID: $id');
    } catch (e, st) {
      Log.error('Gagal soft delete notifikasi - ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua notifikasi.
  Future<int> softDeleteAll({bool dariServer = false}) async {
    Log.info('Memulai soft delete semua notifikasi');
    try {
      final count = await _baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: dariServer,
      );
      Log.info('Soft delete semua notifikasi berhasil - Total: $count');
      return count;
    } catch (e, st) {
      Log.error('Gagal soft delete semua notifikasi', e: e, s: st);
      rethrow;
    }
  }

  /// Menghapus notifikasi secara permanen dari database.
  Future<void> hapusPermanen(String id, {bool dariServer = false}) async {
    Log.warning('Menghapus notifikasi secara permanen - ID: $id');
    try {
      await _baseOpSqlite.delete(_namaTabel, id, dariServer: dariServer);
      Log.info('Notifikasi berhasil dihapus permanen - ID: $id');
    } catch (e, st) {
      Log.error('Gagal menghapus permanen notifikasi - ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa notifikasi sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(
    List<NotifikasiModel> daftarNotifikasi, {
    bool dariServer = false,
  }) async {
    if (daftarNotifikasi.isEmpty) {
      Log.info('Daftar notifikasi kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarNotifikasi.length} notifikasi',
    );
    try {
      final data = daftarNotifikasi
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch ${daftarNotifikasi.length} notifikasi berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch notifikasi', e: e, s: st);
      rethrow;
    }
  }

  // =========================
  // OPERASI BACA (READ)
  // =========================

  /// Mengambil semua notifikasi dari database.
  Future<List<NotifikasiModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua notifikasi dari tabel $_namaTabel');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${hasil.length} notifikasi');
      return hasil;
    } catch (e, st) {
      Log.error('Gagal mengambil semua notifikasi', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua notifikasi yang aktif (belum dibaca dan belum dihapus).
  Future<List<NotifikasiModel>> ambilNotifikasiAktif() async {
    Log.info('Mengambil notifikasi aktif dari tabel $_namaTabel');
    try {
      final db = await sqliteDb.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where:
            '${NamaKolom.dihapus} = 0 AND ${NamaKolom.setatusDibaca} = 0 AND ${NamaKolom.tanggalTampil} <= ?',
        whereArgs: [now],
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${hasil.length} notifikasi aktif');
      return hasil;
    } catch (e, st) {
      Log.error('Gagal mengambil notifikasi aktif', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil notifikasi berdasarkan ID pengguna.
  Future<List<NotifikasiModel>> ambilBerdasarkanUserId(
    String userId, {
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil notifikasi untuk User ID: $userId');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? '${NamaKolom.userId} = ?'
          : '${NamaKolom.userId} = ? AND ${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        whereArgs: [userId],
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${hasil.length} notifikasi untuk User $userId',
      );
      return hasil;
    } catch (e, st) {
      Log.error(
        'Gagal mengambil notifikasi untuk User ID: $userId',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Mengambil notifikasi berdasarkan ID.
  Future<NotifikasiModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mengambil notifikasi berdasarkan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        final hasil = NotifikasiModel.fromSqlite(maps.first);
        Log.info('Notifikasi ditemukan - ID: $id');
        return hasil;
      }
      Log.info('Notifikasi dengan ID: $id tidak ditemukan');
      return null;
    } catch (e, st) {
      Log.error('Gagal mengambil notifikasi berdasarkan ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil notifikasi berdasarkan ID tujuan (misal: ID transaksi).
  Future<List<NotifikasiModel>> ambilBerdasarkanIdTujuan(
    String idTujuan, {
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil notifikasi untuk ID Tujuan: $idTujuan');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? '${NamaKolom.idTujuan} = ?'
          : '${NamaKolom.idTujuan} = ? AND ${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: query,
        whereArgs: [idTujuan],
        orderBy: '${NamaKolom.tanggalTampil} DESC',
      );
      final hasil = List.generate(
        maps.length,
        (i) => NotifikasiModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${hasil.length} notifikasi untuk ID Tujuan $idTujuan',
      );
      return hasil;
    } catch (e, st) {
      Log.error(
        'Gagal mengambil notifikasi untuk ID Tujuan: $idTujuan',
        e: e,
        s: st,
      );
      rethrow;
    }
  }

  /// Menghapus notifikasi berdasarkan ID tujuan.
  Future<void> hapusBerdasarkanIdTujuan(
    String idTujuan, {
    bool dariServer = false,
  }) async {
    Log.info('Menghapus notifikasi berdasarkan ID Tujuan: $idTujuan');
    try {
      await _baseOpSqlite.operasiKompleks<void>((Transaction txn) async {
        await txn.delete(
          _namaTabel,
          where: '${NamaKolom.idTujuan} = ?',
          whereArgs: [idTujuan],
        );
        Log.info('Notifikasi dengan ID Tujuan $idTujuan berhasil dihapus');
      }, dariServer: dariServer);
    } catch (e, st) {
      Log.error(
        'Gagal menghapus notifikasi berdasarkan ID Tujuan: $idTujuan',
        e: e,
        s: st,
      );
      rethrow;
    }
  }
}
