// path: lib/fitur/investasi/operasi/investasi_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/investasi/model/dividen_model.dart';
import 'package:wifi/fitur/investasi/model/investasi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class InvestasiOpSqlite {
  final SqliteDatabase _sqliteDb;
  final BaseOpSqlite _baseOpSqlite;

  InvestasiOpSqlite({
    required SqliteDatabase sqliteDb,
    required BaseOpSqlite baseOpSqlite,
  }) : _sqliteDb = sqliteDb,
       _baseOpSqlite = baseOpSqlite {
    Log.info('InvestasiOpSqlite diinisialisasi.');
  }

  // ============================================================
  // OPERASI INVESTASI
  // ============================================================

  /// Menambahkan investasi baru
  Future<void> tambahInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan investasi baru - ID: ${investasi.id}');
    try {
      final data = investasi.toSqlite();
      await _baseOpSqlite.sisipkan(
        NamaTabel.investasi,
        data,
        dariServer: dariServer,
      );
      Log.info('Investasi berhasil ditambahkan - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error(
        'Gagal menambahkan investasi - ID: ${investasi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil semua investasi
  Future<List<InvestasiModel>> ambilSemuaInvestasi({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua data investasi');
    try {
      final db = await _sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.investasi,
        where: query,
        orderBy: '${NamaKolom.tanggalInvestasi} DESC',
      );
      final hasil = maps.map(InvestasiModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} data investasi');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil data investasi', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil investasi berdasarkan ID
  Future<InvestasiModel?> ambilInvestasiById(String id) async {
    Log.info('Mengambil investasi berdasarkan ID: $id');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.investasi,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        Log.info('Investasi ditemukan - ID: $id');
        return InvestasiModel.fromSqlite(maps.first);
      }
      Log.info('Investasi tidak ditemukan - ID: $id');
      return null;
    } catch (e, s) {
      Log.error('Gagal mengambil investasi - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil investasi berdasarkan ID investor
  Future<List<InvestasiModel>> ambilInvestasiByIdInvestor(
    String idInvestor,
  ) async {
    Log.info('Mengambil investasi untuk investor - ID: $idInvestor');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.investasi,
        where: '${NamaKolom.idInvestor} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [idInvestor],
        orderBy: '${NamaKolom.tanggalInvestasi} DESC',
      );
      final hasil = maps.map(InvestasiModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} investasi untuk investor');
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil investasi untuk investor - ID: $idInvestor',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Memperbarui investasi
  Future<void> perbaruiInvestasi(
    InvestasiModel investasi, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui investasi - ID: ${investasi.id}');
    try {
      final data = investasi.toSqlite();
      await _baseOpSqlite.update(
        NamaTabel.investasi,
        data,
        investasi.id,
        dariServer: dariServer,
      );
      Log.info('Investasi berhasil diperbarui - ID: ${investasi.id}');
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui investasi - ID: ${investasi.id}',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Soft delete investasi
  Future<void> softDeleteInvestasi(String id, {bool dariServer = false}) async {
    Log.info('Soft delete investasi - ID: $id');
    try {
      await _baseOpSqlite.softDelete(
        NamaTabel.investasi,
        id,
        dariServer: dariServer,
      );
      Log.info('Soft delete investasi berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete investasi - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  // ============================================================
  // OPERASI DIVIDEN
  // ============================================================

  /// Menambahkan dividen baru
  Future<void> tambahDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    Log.info('Menambahkan dividen baru - ID: ${dividen.id}');
    try {
      final data = dividen.toSqlite();
      await _baseOpSqlite.sisipkan(
        NamaTabel.dividen,
        data,
        dariServer: dariServer,
      );
      Log.info('Dividen berhasil ditambahkan - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal menambahkan dividen - ID: ${dividen.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua dividen
  Future<List<DividenModel>> ambilSemuaDividen({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil semua data dividen');
    try {
      final db = await _sqliteDb.database;
      final query = tampilkanYangDiarsip ? null : '${NamaKolom.dihapus} = 0';
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: query,
        orderBy: '${NamaKolom.tanggalPembagian} DESC',
      );
      final hasil = maps.map(DividenModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} data dividen');
      return hasil;
    } catch (e, s) {
      Log.error('Gagal mengambil data dividen', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID
  Future<DividenModel?> ambilDividenById(String id) async {
    Log.info('Mengambil dividen berdasarkan ID: $id');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        Log.info('Dividen ditemukan - ID: $id');
        return DividenModel.fromSqlite(maps.first);
      }
      Log.info('Dividen tidak ditemukan - ID: $id');
      return null;
    } catch (e, s) {
      Log.error('Gagal mengambil dividen - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID investor
  Future<List<DividenModel>> ambilDividenByIdInvestor(String idInvestor) async {
    Log.info('Mengambil dividen untuk investor - ID: $idInvestor');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: '${NamaKolom.idInvestor} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [idInvestor],
        orderBy: '${NamaKolom.tanggalPembagian} DESC',
      );
      final hasil = maps.map(DividenModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} dividen untuk investor');
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil dividen untuk investor - ID: $idInvestor',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengambil dividen berdasarkan ID investasi
  Future<List<DividenModel>> ambilDividenByIdInvestasi(
    String idInvestasi,
  ) async {
    Log.info('Mengambil dividen untuk investasi - ID: $idInvestasi');
    try {
      final db = await _sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        NamaTabel.dividen,
        where: '${NamaKolom.idInvestasi} = ? AND ${NamaKolom.dihapus} = 0',
        whereArgs: [idInvestasi],
        orderBy: '${NamaKolom.tanggalPembagian} DESC',
      );
      final hasil = maps.map(DividenModel.fromSqlite).toList();
      Log.info('Berhasil mengambil ${hasil.length} dividen untuk investasi');
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal mengambil dividen untuk investasi - ID: $idInvestasi',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Memperbarui dividen
  Future<void> perbaruiDividen(
    DividenModel dividen, {
    bool dariServer = false,
  }) async {
    Log.info('Memperbarui dividen - ID: ${dividen.id}');
    try {
      final data = dividen.toSqlite();
      await _baseOpSqlite.update(
        NamaTabel.dividen,
        data,
        dividen.id,
        dariServer: dariServer,
      );
      Log.info('Dividen berhasil diperbarui - ID: ${dividen.id}');
    } catch (e, s) {
      Log.error('Gagal memperbarui dividen - ID: ${dividen.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Soft delete dividen
  Future<void> softDeleteDividen(String id, {bool dariServer = false}) async {
    Log.info('Soft delete dividen - ID: $id');
    try {
      await _baseOpSqlite.softDelete(
        NamaTabel.dividen,
        id,
        dariServer: dariServer,
      );
      Log.info('Soft delete dividen berhasil - ID: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete dividen - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menandai dividen sebagai sudah dibayar
  Future<void> tandaiDividenDibayar(
    String id, {
    bool dariServer = false,
  }) async {
    Log.info('Menandai dividen sudah dibayar - ID: $id');
    try {
      await _baseOpSqlite.update(
        NamaTabel.dividen,
        {
          NamaKolom.sudahDibayar: 1,
          NamaKolom.diperbaruiPada: DateTime.now().millisecondsSinceEpoch,
        },
        id,
        dariServer: dariServer,
      );
      Log.info('Dividen berhasil ditandai sudah dibayar - ID: $id');
    } catch (e, s) {
      Log.error('Gagal menandai dividen sudah dibayar - ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa investasi sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatch(
    List<InvestasiModel> daftarInvestasi, {
    bool dariServer = false,
  }) async {
    if (daftarInvestasi.isEmpty) {
      Log.info('Daftar investasi kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarInvestasi.length} investasi',
    );
    try {
      final data = daftarInvestasi
          .map(
            (item) => item.copyWith(diperbaruiPada: DateTime.now()).toSqlite(),
          )
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        NamaTabel.investasi,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch ${daftarInvestasi.length} investasi berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch investasi', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui beberapa dividen sekaligus (batch).
  Future<void> sisipkanAtauPerbaruiBatchDividen(
    List<DividenModel> daftarDividen, {
    bool dariServer = false,
  }) async {
    if (daftarDividen.isEmpty) {
      Log.info('Daftar dividen kosong, batch dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${daftarDividen.length} dividen',
    );
    try {
      final data = daftarDividen
          .map(
            (item) => item.copyWith(diperbaruiPada: DateTime.now()).toSqlite(),
          )
          .toList();
      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        NamaTabel.dividen,
        data,
        dariServer: dariServer,
      );
      Log.info('Batch ${daftarDividen.length} dividen berhasil diproses');
    } catch (e, st) {
      Log.error('Gagal memproses batch dividen', e: e, s: st);
      rethrow;
    }
  }
}
