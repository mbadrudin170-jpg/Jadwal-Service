// path: lib/fitur/paket/operasi/paket_op_sqlite.dart

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data paket di database lokal.
class PaketOpSqlite {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final SqliteDatabase sqliteDb;

  /// Instance dari [BaseOpSqlite] untuk operasi CRUD dasar.
  final BaseOpSqlite basOpSqlite;
  final String _tabel = NamaTabel.paket;
  final _nowUtc = DateTime.now().toUtc();

  PaketOpSqlite({required this.sqliteDb, required this.basOpSqlite}) {
    Log.info('PackageOperation instance dibuat.');
  }

  /// Menyimpan [PaketModel] baru ke dalam database.
  Future<void> tambahPaket(PaketModel paket, {bool dariServer = false}) async {
    Log.info('Memulai createPackage untuk id: ${paket.id}');
    try {
      final data = paket.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await basOpSqlite.sisipkan(_tabel, data, dariServer: dariServer);
      Log.info('Berhasil createPackage untuk id: ${paket.id}');
    } catch (e, s) {
      Log.error('Gagal createPackage untuk id: ${paket.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua paket aktif (tidak diarsipkan).
  Future<List<PaketModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Memulai proses pengambilan semua data paket aktif');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus}=0 AND ${NamaKolom.diarsipkanPada} is NULL';
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${NamaKolom.tipe}
            WHEN 'jam' THEN ${NamaKolom.durasi}
            WHEN 'hari' THEN ${NamaKolom.durasi} * 24
            WHEN 'bulan' THEN ${NamaKolom.durasi} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tabel
        WHERE $query
        ORDER BY urutan ASC
      ''');
      Log.info('Berhasil mengambil ${maps.length} data paket aktif');
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket aktif', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang bersifat publik.
  Future<List<PaketModel>> ambilPaketPublik() async {
    Log.info('Memulai proses pengambilan semua data paket publik');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${NamaKolom.tipe}
            WHEN 'jam' THEN ${NamaKolom.durasi}
            WHEN 'hari' THEN ${NamaKolom.durasi} * 24
            WHEN 'bulan' THEN ${NamaKolom.durasi} * 24 * 30
            ELSE 999999
          END as urutan
        FROM $_tabel
        WHERE ${NamaKolom.dihapus} = 0 AND ${NamaKolom.statusPublik} = 1
        ORDER BY urutan ASC
      ''');
      final daftarPaket = List.generate(
        maps.length,
        (i) => PaketModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarPaket.length} data wallet.');
      return daftarPaket;
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket publik', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil [PaketModel] berdasarkan [id].
  Future<PaketModel?> ambilBerdasarkanId(String id) async {
    Log.info('Memulai pencarian paket berdasarkan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Paket ditemukan untuk ID: $id');
        return PaketModel.fromSqlite(maps.first);
      }
      Log.warning('Paket dengan ID $id tidak ditemukan');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari paket berdasarkan ID: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Memperbarui [PaketModel] yang ada di database.
  Future<void> perbaruiPaket(
    PaketModel paket, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai updatePaket untuk id: ${paket.id}');
    try {
      final data = paket.copyWith(diperbaruiPada: _nowUtc).toSqlite();
      await basOpSqlite.update(_tabel, data, paket.id, dariServer: dariServer);
      Log.info('Berhasil updatePaket untuk id: ${paket.id}');
    } catch (e, s) {
      Log.error('Gagal updatePaket untuk id: ${paket.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada [PaketModel] berdasarkan [id].
  Future<void> hapusSementara(String id, {bool dariServer = false}) async {
    Log.info('Memulai soft delete untuk paket id: $id');
    try {
      await basOpSqlite.softDelete(_tabel, id, dariServer: dariServer);
      Log.info('Berhasil soft delete untuk paket id: $id');
    } catch (e, s) {
      Log.error('Gagal soft delete untuk paket id: $id', e: e, s: s);
      rethrow;
    }
  }

  /// Menandai semua paket sebagai soft-deleted (diarsipkan).
  Future<int> hapusSementaraSemua({bool dariServer = false}) async {
    Log.info('Memulai soft-delete untuk semua paket');
    try {
      final count = await basOpSqlite.softDeleteAll(
        _tabel,
        dariServer: dariServer,
      );
      Log.info('Berhasil soft-delete semua paket. Total terupdate: $count');
      return count;
    } catch (e, s) {
      Log.error('Gagal soft-delete semua paket', e: e, s: s);
      rethrow;
    }
  }

  /// Menghapus semua paket dari database secara permanen.
  Future<void> hapusSemua({bool dariServer = false}) async {
    Log.info('Memulai proses penghapusan semua data paket');
    try {
      await basOpSqlite.runComplexOperation<void>((Transaction txn) async {
        final int count = await txn.delete(_tabel);
        Log.info('Berhasil menghapus semua data paket. Total terhapus: $count');
      }, dariServer: dariServer);
    } catch (e, s) {
      Log.error('Gagal menghapus semua data paket', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang telah diubah sejak [since].
  Future<List<PaketModel>> ambilPerubahanSejak(DateTime since) async {
    Log.info(
      'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}',
    );
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info('Ditemukan ${maps.length} perubahan paket');
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan paket', e: e, s: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [PaketModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    List<PaketModel> items, {
    bool dariServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item paket');
    if (items.isEmpty) {
      Log.warning('List item batch kosong, operasi dibatalkan');
      return;
    }
    try {
      final dataList = items
          .map((item) => item.copyWith(diperbaruiPada: _nowUtc).toSqlite())
          .toList();
      await basOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabel,
        dataList,
        dariServer: dariServer,
      );
      Log.info('Berhasil insertOrUpdateBatch untuk ${items.length} item');
    } catch (e, s) {
      Log.error('Gagal insertOrUpdateBatch', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [PaketModel] berdasarkan daftar [ids].
  Future<List<PaketModel>> ambilBerdasarkanBeberapaId(List<String> ids) async {
    Log.info('Memulai pengambilan paket berdasarkan list ID: $ids');
    try {
      if (ids.isEmpty) {
        Log.warning('List ID kosong, mengembalikan list kosong');
        return [];
      }
      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} paket dari ${ids.length} ID');
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil paket berdasarkan list ID', e: e, s: s);
      rethrow;
    }
  }
}
