// path: lib/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

class PelangganOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite _baseOpSqlite;
  final String _tabel = NamaTabel.pelanggan;

  PelangganOpSqlite({
    required this.sqliteDb,
    required BaseOpSqlite baseOpSqlite,
  }) : _baseOpSqlite = baseOpSqlite {
    Log.info('CustomerOperation diinisialisasi');
  }

  // path: lib/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart

  Future<bool> _ambilBerdasarkanTeleponDanKataSandi(
    String telepon,
    String kataSandi, {
    String? excludeId,
  }) async {
    try {
      final db = await sqliteDb.database;

      // Log untuk debugging
      Log.info('Mengecek kombinasi telepon dan password', {
        'telepon': telepon,
        'kataSandi': kataSandi,
        'excludeId': excludeId,
      });

      String sql =
          '''
      SELECT COUNT(*) as count
      FROM ${NamaTabel.pelanggan}
      WHERE ${NamaKolom.telepon} = ? 
        AND ${NamaKolom.kataSandi} = ? 
        AND ${NamaKolom.dihapus} = 0
    ''';
      final args = <dynamic>[telepon, kataSandi];
      if (excludeId != null && excludeId.isNotEmpty) {
        sql += ' AND ${NamaKolom.id} != ?';
        args.add(excludeId);
      }
      final result = await db.rawQuery(sql, args);
      final count = Sqflite.firstIntValue(result) ?? 0;
      Log.info('Hasil pengecekan duplikasi', {
        'count': count,
        'isDuplicate': count > 0,
      });

      return count > 0;
    } catch (e, st) {
      Log.error('Gagal mengecek duplikasi pelanggan', e: e, s: st);
      rethrow;
    }
  }

  Future<void> tambahPelanggan(
    PelangganModel pelanggan, {
    bool dariServer = false,
  }) async {
    final bool isDuplicate = await _ambilBerdasarkanTeleponDanKataSandi(
      pelanggan.telepon,
      pelanggan.kataSandi,
    );
    if (isDuplicate) {
      Log.warning('Data pelanggan duplikat ditemukan.', {
        'telepon': pelanggan.telepon,
        'nama': pelanggan.nama,
      });
      throw Exception(
        'Pelanggan dengan nomor telepon dan password ini sudah ada.',
      );
    }
    Log.info('Memulai pembuatan customer dengan ID: ${pelanggan.id}');
    try {
      final pelangganBaru = pelanggan.copyWith(
        diperbaruiPada: DateTime.now().toUtc(),
      );
      final data = pelangganBaru.toSqlite();
      await _baseOpSqlite.sisipkan(_tabel, data, dariServer: dariServer);
      Log.info(
        'Customer (ID: ${pelangganBaru.id}) berhasil dibuat di database lokal.',
      );
    } on DatabaseException catch (e, s) {
      Log.error('Gagal membuat customer.', e: e, s: s);
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Nomor telepon sudah terdaftar.');
      }
      rethrow;
    }
  }

  Future<List<PelangganModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    Log.info('Mengambil SEMUA data customer dari database lokal.');
    try {
      final db = await sqliteDb.database;
      final query = tampilkanYangDiarsip
          ? null
          : '${NamaKolom.dihapus}=0 AND ${NamaKolom.diarsipkanPada} is NULL';
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: query,
        orderBy: '${NamaKolom.nama} ASC',
      );
      final daftarPelanggan = List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
      return daftarPelanggan;
    } catch (e, s) {
      Log.error('Gagal mengambil semua data customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<PelangganModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mencari customer berdasarkan ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Customer dengan ID: $id ditemukan.');
        return PelangganModel.fromSqlite(maps.first);
      }
      Log.info('Customer dengan ID: $id tidak ditemukan (hasil valid).');
      return null;
    } catch (e, s) {
      Log.error('Gagal mencari customer berdasarkan ID.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbaruiPelanggan(
    PelangganModel pelanggan, {
    bool dariServer = false,
  }) async {
    final bool isDuplicate = await _ambilBerdasarkanTeleponDanKataSandi(
      pelanggan.telepon,
      pelanggan.kataSandi,
      excludeId: pelanggan.id,
    );

    if (isDuplicate) {
      Log.warning('Data pelanggan duplikat ditemukan saat update.', {
        'telepon': pelanggan.telepon,
        'nama': pelanggan.nama,
        'id': pelanggan.id,
      });
      throw Exception(
        'Pelanggan dengan nomor telepon dan password ini sudah ada.',
      );
    }
    Log.info('Memulai pembaruan untuk customer ID: ${pelanggan.id}');
    try {
      final data = pelanggan
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();

      await _baseOpSqlite.update(
        _tabel,
        data,
        pelanggan.id,
        dariServer: dariServer,
      );

      Log.info('Berhasil memperbarui customer ID: ${pelanggan.id}.');
    } catch (e, s) {
      Log.error('Gagal memperbarui customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String id, {bool dariServer = false}) async {
    Log.info('Memulai proses soft delete untuk customer ID: $id');
    try {
      await _baseOpSqlite.softDelete(_tabel, id, dariServer: dariServer);
      Log.info('Berhasil melakukan soft delete pada customer ID: $id.');
    } catch (e, s) {
      Log.error('Gagal menghapus customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<int> softDeleteSemua({bool dariServer = false}) async {
    Log.info('Memulai proses soft delete untuk semua customer.');
    try {
      final total = await _baseOpSqlite.softDeleteAll(
        _tabel,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil melakukan soft delete pada semua customer. Total: $total',
      );
      return total;
    } catch (e, s) {
      Log.error('Gagal melakukan soft delete pada semua customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> ambilPerubahanSejak(DateTime sejak) async {
    Log.info('Mengambil perubahan customer sejak: ${sejak.toIso8601String()}');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [sejak.toUtc().millisecondsSinceEpoch],
      );
      Log.info(
        'Ditemukan ${maps.length} perubahan customer sejak waktu yang ditentukan.',
      );
      return List.generate(
        maps.length,
        (i) => PelangganModel.fromSqlite(maps[i]),
      );
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan customer.', e: e, s: s);
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(
    List<PelangganModel> pelanggan, {
    bool dariServer = false,
  }) async {
    if (pelanggan.isEmpty) {
      Log.info('Tidak ada item untuk diproses dalam batch.');
      return;
    }
    Log.info('Memulai batch insert/update untuk ${pelanggan.length} customer.');
    try {
      final data = pelanggan.map((item) {
        return item.copyWith(diperbaruiPada: DateTime.now().toUtc()).toSqlite();
      }).toList();

      await _baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _tabel,
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan operasi batch untuk ${pelanggan.length} customer.',
      );
    } catch (e, s) {
      Log.error('Gagal menjalankan operasi batch.', e: e, s: s);
      rethrow;
    }
  }

  Future<List<PelangganModel>> ambilPelangganBerdasarkanId(
    List<String> ids,
  ) async {
    if (ids.isEmpty) {
      Log.info('List ID kosong, tidak ada customer yang diambil.');
      return [];
    }
    Log.info('Mengambil data customer untuk ${ids.length} ID.');
    try {
      final db = await sqliteDb.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        _tabel,
        where: '${NamaKolom.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} customer berdasarkan list ID.',
      );
      return List.generate(maps.length, (i) {
        return PelangganModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil customer berdasarkan list ID.', e: e, s: s);
      rethrow;
    }
  }
}
