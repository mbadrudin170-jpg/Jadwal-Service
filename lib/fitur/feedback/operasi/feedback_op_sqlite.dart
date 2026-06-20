// path: lib/fitur/feedback/operasi/feedback_op_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

/// Kelas untuk operasi terkait data kritik dan saran di database lokal.
class FeedbackOpSqlite {
  final SqliteDatabase sqliteDb;
  final BaseOpSqlite baseOpSqlite;
  final String _namaTabel = NamaTabel.feedback;

  FeedbackOpSqlite({required this.sqliteDb, required this.baseOpSqlite});

  /// Menyimpan [FeedbackModel] baru ke dalam database.
  Future<void> tambahFeedback(
    final FeedbackModel feedback, {
    final bool dariServer = false,
  }) async {
    Log.info('Memulai createFeedback untuk data: ${feedback.toSqlite()}');
    try {
      final data = feedback
          .copyWith(diperbaruiPada: DateTime.now().toUtc())
          .toSqlite();

      await baseOpSqlite.sisipkan(_namaTabel, data, dariServer: dariServer);
      Log.info('Berhasil membuat kritik_saran dengan ID: ${feedback.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat createFeedback', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran dari database, diurutkan berdasarkan tanggal terbaru.
  Future<List<FeedbackModel>> ambilSemua() async {
    Log.info(
      'Memulai getAllFeedback (mengambil semua, diurutkan berdasarkan tanggal terbaru).',
    );
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      final daftarFeedback = List.generate(
        maps.length,
        (i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarFeedback.length} data kritik_saran.',
      );
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal saat getAllFeedback', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran yang aktif (tidak di-soft-delete).
  Future<List<FeedbackModel>> ambilSemuaFeedbackAktif() async {
    Log.info('Mengambil semua feedback aktif (dihapus = 0).');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.dihapus} = 0',
        orderBy: '${NamaKolom.tanggal} DESC',
      );
      final daftarFeedback = List.generate(
        maps.length,
        (i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${daftarFeedback.length} feedback aktif.');
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal mengambil feedback aktif', e: e, s: st);
      rethrow;
    }
  }

  Future<FeedbackModel> ambilBerdasarkanId(final String id) async {
    Log.info('Memulai getFeedbackById untuk ID: $id');
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final data = FeedbackModel.fromSqlite(maps.first);
        Log.info(
          'Kritik & saran dengan ID: $id ditemukan. Data: ${data.toSqlite()}',
        );
        return data;
      } else {
        Log.error('Kritik & saran dengan ID $id tidak ditemukan.');
        throw Exception('ID $id tidak ditemukan');
      }
    } catch (e, st) {
      Log.error('Gagal saat getFeedbackById untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran yang telah diubah sejak [sinkronisasiTerakhir].
  Future<List<FeedbackModel>> ambilPerubahan(
    DateTime sinkronisasiTerakhir,
  ) async {
    Log.info(
      'Memulai getChanges kritik_saran sejak: ${sinkronisasiTerakhir.toIso8601String()}',
    );
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: '${NamaKolom.diperbaruiPada} > ?',
        whereArgs: [sinkronisasiTerakhir.millisecondsSinceEpoch],
      );
      final daftarFeedback = List.generate(
        maps.length,
        (i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Ditemukan ${daftarFeedback.length} perubahan kritik_saran sejak ${sinkronisasiTerakhir.toIso8601String()}',
      );
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal saat getChanges kritik_saran', e: e, s: st);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [FeedbackModel] dalam satu batch.
  Future<void> sisipkanAtauPerbaruiBatch(
    final List<FeedbackModel> daftarFeedback, {
    final bool dariServer = false,
  }) async {
    Log.info(
      'Memulai insertOrUpdateBatch untuk ${daftarFeedback.length} item kritik_saran.',
    );
    if (daftarFeedback.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = daftarFeedback
          .map(
            (final item) => item
                .copyWith(diperbaruiPada: DateTime.now().toUtc())
                .toSqlite(),
          )
          .toList();
      await baseOpSqlite.sisipkanAtauPerbaruiBatch(
        _namaTabel,
        data,
        dariServer: dariServer,
      );
      Log.info(
        'Berhasil menyelesaikan insertOrUpdateBatch untuk ${daftarFeedback.length} item.',
      );
    } catch (e, st) {
      Log.error('Gagal saat insertOrUpdateBatch kritik_saran', e: e, s: st);
      rethrow;
    }
  }

  // ===========================================================================
  // DELETE (SOFT & HARD)
  // ===========================================================================

  /// Menghapus [FeedbackModel] dari database secara permanen.
  Future<void> delete(final String id, {final bool fromServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteFeedback (hard delete) untuk ID: $id',
    );
    try {
      await baseOpSqlite.delete(_namaTabel, id, dariServer: fromServer);
      Log.info('Berhasil menghapus permanen kritik_saran dengan ID: $id.');
    } on Exception catch (e, st) {
      Log.error('Gagal saat deleteFeedback untuk ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada satu feedback berdasarkan [id].
  Future<void> softDelete(
    final String id, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai soft delete untuk feedback ID: $id');
    try {
      await baseOpSqlite.softDelete(_namaTabel, id, dariServer: fromServer);
      Log.info('Berhasil soft delete feedback ID: $id.');
    } catch (e, st) {
      Log.error('Gagal saat soft delete feedback ID: $id', e: e, s: st);
      rethrow;
    }
  }

  /// Melakukan soft delete pada semua feedback.
  Future<int> softDeleteAll({final bool fromServer = false}) async {
    Log.info('Memulai soft delete untuk semua feedback');
    try {
      final count = await baseOpSqlite.softDeleteAll(
        _namaTabel,
        dariServer: fromServer,
      );
      Log.info('Berhasil soft delete semua feedback. Total: $count item.');
      return count;
    } catch (e, st) {
      Log.error('Gagal saat soft delete semua feedback', e: e, s: st);
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran dari database secara permanen.
  Future<void> deleteAll({final bool dariServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteAllFeedback. Ini adalah operasi destruktif.',
    );
    try {
      await baseOpSqlite.runComplexOperation<int>((
        final Transaction txn,
      ) async {
        final int count = await txn.delete(_namaTabel);
        Log.info(
          'Berhasil deleteAllFeedback. Total baris yang dihapus: $count',
        );
        return count;
      }, dariServer: dariServer);
    } catch (e, st) {
      Log.error('Gagal saat deleteAllFeedback', e: e, s: st);
      rethrow;
    }
  }

  /// Mengambil beberapa [FeedbackModel] berdasarkan daftar [ids].
  Future<List<FeedbackModel>> ambilBerdasarkanIds(List<String> ids) async {
    Log.info('Memulai getFeedbackByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getFeedbackByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await sqliteDb.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _namaTabel,
        where: 'id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
      final daftarFeedback = List.generate(
        maps.length,
        (final i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${daftarFeedback.length} data kritik_saran dari ${ids.length} ID yang diminta.',
      );
      return daftarFeedback;
    } catch (e, st) {
      Log.error('Gagal saat getFeedbackByIds', e: e, s: st);
      rethrow;
    }
  }
}
