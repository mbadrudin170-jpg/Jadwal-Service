// path: lib/shared/operasi/paket_operasi.dart

import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/operasi_dasar.dart';

class PaketOperasi {
  final dbHelper = DatabaseHelper.instance;
  final OperasiDasar _operasiDasar = OperasiDasar();

  Future<void> createPaket(PaketModel paket) async {
    Log.info(
      'Mendelegasikan pembuatan paket ke OperasiDasar, method: createPaket, id: ${paket.id}',
    );
    try {
      final now = DateTime.now();
      final data = paket.copyWith(diperbarui: now).toSqlite();
      await _operasiDasar.sisipkan('paket', data);
      Log.info(
        'Berhasil mendelegasikan pembuatan paket, method: createPaket, id: ${paket.id}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan pembuatan paket, method: createPaket, id: ${paket.id}, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getAllPaket() async {
    Log.info('Memulai proses pengambilan semua data paket, method: getPaket');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        Log.info(
          'Berhasil mengambil ${maps.length} data paket, method: getPaket',
        );
      } else {
        Log.warning('Tidak ada data paket yang ditemukan, method: getPaket');
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil semua data paket, method: getPaket, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaket() async {
    Log.info(
      'Memulai proses pengambilan semua data paket aktif, method: getPaketAktif',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE isDeleted = 0
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        Log.info(
          'Berhasil mengambil ${maps.length} data paket aktif, method: getPaketAktif',
        );
      } else {
        Log.warning(
          'Tidak ada data paket aktif yang ditemukan, method: getPaketAktif',
        );
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil semua data paket aktif, method: getPaketAktif, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaketByIsPublic() async {
    Log.info(
      'Memulai proses pengambilan semua data paket publik, method: getPaketByIsPublic',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE tipe
            WHEN 'jam' THEN durasi
            WHEN 'hari' THEN durasi * 24
            WHEN 'bulan' THEN durasi * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE isDeleted = 0 AND isPublic = 1
        ORDER BY urutan ASC
      ''');

      if (maps.isNotEmpty) {
        Log.info(
          'Berhasil mengambil ${maps.length} data paket publik, method: getPaketByIsPublic',
        );
      } else {
        Log.warning(
          'Tidak ada data paket publik yang ditemukan, method: getPaketByIsPublic',
        );
      }
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil semua data paket publik, method: getPaketByIsPublic, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<PaketModel?> getPaketById(String id) async {
    Log.info(
      'Memulai pencarian paket berdasarkan ID, method: getPaketById, id: $id',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Paket ditemukan, method: getPaketById, id: $id');
        return PaketModel.fromSqlite(maps.first);
      } else {
        Log.warning(
          'Paket dengan ID $id tidak ditemukan, method: getPaketById',
        );
        return null;
      }
    } catch (e, s) {
      Log.error(
        'Gagal mencari paket berdasarkan ID, method: getPaketById, id: $id, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> updatePaket(PaketModel paket) async {
    Log.info(
      'Mendelegasikan pembaruan paket ke OperasiDasar, method: updatePaket, id: ${paket.id}',
    );
    try {
      final now = DateTime.now();
      final data = paket.copyWith(diperbarui: now).toSqlite();
      await _operasiDasar.perbarui('paket', data, paket.id);
      Log.info(
        'Berhasil mendelegasikan pembaruan paket, method: updatePaket, id: ${paket.id}',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan pembaruan paket, method: updatePaket, id: ${paket.id}, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> hapusPaket(String id) async {
    Log.info(
      'Mendelegasikan penghapusan paket ke OperasiDasar, method: hapusPaket, id: $id',
    );
    try {
      await _operasiDasar.hapus('paket', id);
      Log.info(
        'Berhasil mendelegasikan penghapusan paket, method: hapusPaket, id: $id',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan penghapusan paket, method: hapusPaket, id: $id, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> hapusSemuaPaket() async {
    Log.info(
      'Memulai proses penghapusan semua data paket, method: hapusSemuaPaket',
    );
    try {
      await _operasiDasar.jalankanOperasiKompleks((txn) async {
        int count = await txn.delete('paket');
        Log.info(
          'Berhasil menghapus semua data paket. Total terhapus: $count, method: hapusSemuaPaket',
        );
        return count;
      });
    } catch (e, s) {
      Log.error(
        'Gagal menghapus semua data paket, method: hapusSemuaPaket, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPerubahan(DateTime since) async {
    Log.info(
      'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}, method: getPerubahan',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'diperbarui > ?',
        whereArgs: [since.toIso8601String()],
      );
      if (maps.isNotEmpty) {
        Log.info(
          'Ditemukan ${maps.length} perubahan paket, method: getPerubahan',
        );
      } else {
        Log.info(
          'Tidak ada perubahan paket ditemukan sejak ${since.toIso8601String()}, method: getPerubahan',
        );
      }
      return List.generate(maps.length, (i) => PaketModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error(
        'Gagal mengambil perubahan paket, method: getPerubahan, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    Log.info(
      'Mendelegasikan proses batch ke OperasiDasar untuk ${items.length} item paket, method: sisipkanAtauPerbaruiBatch',
    );
    try {
      final dataList = items.map((item) => item.toSqlite()).toList();
      await _operasiDasar.sisipkanAtauPerbaruiBatch('paket', dataList);
      Log.info(
        'Berhasil mendelegasikan proses batch untuk ${items.length} item, method: sisipkanAtauPerbaruiBatch',
      );
    } catch (e, s) {
      Log.error(
        'Gagal mendelegasikan proses batch, method: sisipkanAtauPerbaruiBatch, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<List<PaketModel>> getPaketByIds(List<String> ids) async {
    Log.info(
      'Memulai pengambilan paket berdasarkan list ID, method: getPaketByIds, ids: $ids',
    );
    try {
      if (ids.isEmpty) {
        Log.warning(
          'List ID kosong, mengembalikan list kosong, method: getPaketByIds',
        );
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info(
        'Berhasil mengambil ${maps.length} paket dari ${ids.length} ID yang diminta, method: getPaketByIds',
      );
      return List.generate(maps.length, (i) {
        return PaketModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error(
        'Gagal mengambil paket berdasarkan list ID, method: getPaketByIds, error: $e',
        error: e,
        st: s,
      );
      rethrow;
    }
  }
}
