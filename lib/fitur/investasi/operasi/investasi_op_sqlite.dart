// path: lib/fitur/investasi/operasi/investasi_op_sqlite.dart

import 'package:wifi/admin/data/sqlite.dart';
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

  Future<InvestasiModel?> ambilBerdasarkanId(String id) async {
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

  Future<List<InvestasiModel>> ambilBerdasarkanIdInvestor(
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

  Future<void> softDelete(String id, {bool dariServer = false}) async {
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
}
