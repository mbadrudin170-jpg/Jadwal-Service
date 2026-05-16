// path: lib/shared/operasi/feedback_operation.dart
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data kritik dan saran di database lokal.
class FeedbackOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  @visibleForTesting
  final BaseOperation baseOperation;

  /// Konstruktor untuk [FeedbackOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  FeedbackOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        baseOperation = baseOperation ?? BaseOperation();

  /// Menyimpan [FeedbackModel] baru ke dalam database.
  Future<void> createFeedback(
    final FeedbackModel feedback, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai createFeedback untuk data: ${feedback.toSqlite()}');
    try {
      final data =
          feedback.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();

      await baseOperation.insert(
        'kritik_saran',
        data,
        fromServer: fromServer,
      );
      Log.info('Berhasil membuat kritik_saran dengan ID: ${feedback.id}');
    } on Exception catch (e, st) {
      Log.error('Gagal saat createFeedback', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran dari database, diurutkan berdasarkan tanggal terbaru.
  Future<List<FeedbackModel>> getAllFeedback() async {
    Log.info(
      'Memulai getAllFeedback (mengambil semua, diurutkan berdasarkan tanggal terbaru).',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        orderBy: 'tanggal DESC',
      );
      final feedbackList = List.generate(
        maps.length,
        (final i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info('Berhasil mengambil ${feedbackList.length} data kritik_saran.');
      return feedbackList;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getAllFeedback', e: e, st: st);
      rethrow;
    }
  }

  /// Mengambil [FeedbackModel] berdasarkan [id].
  Future<FeedbackModel> getFeedbackById(final String id) async {
    Log.info('Memulai getFeedbackById untuk ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
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
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat getFeedbackById untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengambil semua kritik dan saran yang telah diubah sejak [lastSync].
  Future<List<FeedbackModel>> getChanges(final DateTime lastSync) async {
    Log.info(
      'Memulai getChanges kritik_saran sejak: ${lastSync.toIso8601String()}',
    );
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'diperbarui > ?',
        whereArgs: [lastSync.millisecondsSinceEpoch],
      );
      final feedbackList = List.generate(
        maps.length,
        (final i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Ditemukan ${feedbackList.length} perubahan kritik_saran sejak ${lastSync.toIso8601String()}',
      );
      return feedbackList;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat getChanges kritik_saran',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [FeedbackModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<FeedbackModel> feedbackList, {
    final bool fromServer = false,
  }) async {
    Log.info(
      'Memulai insertOrUpdateBatch untuk ${feedbackList.length} item kritik_saran.',
    );
    if (feedbackList.isEmpty) {
      Log.warning(
        'List item untuk batch kosong, tidak ada operasi yang dilakukan.',
      );
      return;
    }
    try {
      final data = feedbackList
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await baseOperation.insertOrUpdateBatch(
        'kritik_saran',
        data,
        fromServer: fromServer,
      );
      Log.info(
        'Berhasil menyelesaikan insertOrUpdateBatch untuk ${feedbackList.length} item.',
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat insertOrUpdateBatch kritik_saran',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus [FeedbackModel] dari database secara permanen.
  Future<void> deleteFeedback(final String id,
      {final bool fromServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteFeedback (hard delete) untuk ID: $id',
    );
    try {
      await baseOperation.delete('kritik_saran', id, fromServer: fromServer);
      Log.info('Berhasil menghapus permanen kritik_saran dengan ID: $id.');
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat deleteFeedback untuk ID: $id',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran dari database secara permanen.
  Future<void> deleteAllFeedback({final bool fromServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteAllFeedback. Ini adalah operasi destruktif.',
    );
    try {
      await baseOperation.runComplexOperation<int>(
        (final Transaction txn) async {
          final int count = await txn.delete('kritik_saran');
          Log.info(
            'Berhasil deleteAllFeedback. Total baris yang dihapus: $count',
          );
          return count;
        },
        fromServer: fromServer,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal saat deleteAllFeedback', e: e, st: st);
      rethrow;
    }
  }

  /// Menghapus semua kritik dan saran dari seorang pengguna berdasarkan [userId].
  Future<void> deleteByUserId(final String userId,
      {final bool fromServer = false}) async {
    Log.warning(
      'PERINGATAN: Memulai deleteByUserId (hard delete) untuk userId: $userId',
    );
    try {
      await baseOperation.runComplexOperation<int>(
        (final Transaction txn) async {
          final int deletedCount = await txn.delete(
            'kritik_saran',
            where: 'userId = ?',
            whereArgs: [userId],
          );
          Log.info(
            'Berhasil menghapus $deletedCount kritik & saran dari user: $userId',
          );
          return deletedCount;
        },
        fromServer: fromServer,
      );
    } on Exception catch (e, st) {
      Log.error(
        'Gagal saat deleteByUserId untuk userId: $userId',
        e: e,
        st: st,
      );
      rethrow;
    }
  }

  /// Mengunduh semua data kritik dan saran dari Firebase.
  static Future<List<FeedbackModel>> downloadFromFirebase() async {
    Log.info('Memulai pengunduhan data dari Firestore koleksi: kritik_saran.');
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('kritik_saran').get();
      final List<FeedbackModel> data = snapshot.docs
          .map(
            (final doc) => FeedbackModel.fromFirebase(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      Log.info(
        'Berhasil mengunduh ${data.length} data kritik dan saran dari Firebase.',
      );
      return data;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mengunduh data kritik dan saran dari Firebase',
        e: e,
        st: st,
      );
      return [];
    }
  }

  /// Mengambil beberapa [FeedbackModel] berdasarkan daftar [ids].
  Future<List<FeedbackModel>> getFeedbackByIds(final List<String> ids) async {
    Log.info('Memulai getFeedbackByIds untuk ${ids.length} ID.');
    if (ids.isEmpty) {
      Log.warning(
        'List ID untuk getFeedbackByIds kosong, mengembalikan list kosong.',
      );
      return [];
    }
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'kritik_saran',
        where: 'id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
      final feedbackList = List.generate(
        maps.length,
        (final i) => FeedbackModel.fromSqlite(maps[i]),
      );
      Log.info(
        'Berhasil mengambil ${feedbackList.length} data kritik_saran dari ${ids.length} ID yang diminta.',
      );
      return feedbackList;
    } on Exception catch (e, st) {
      Log.error('Gagal saat getFeedbackByIds', e: e, st: st);
      rethrow;
    }
  }
}
