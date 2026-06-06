// path: lib/shared/operasi/data_cleaning_operation.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

/// Kelas untuk operasi pembersihan data di database lokal (SQLite) dan remote (Firestore).
class DataCleaningOperation {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore _firestore;

  /// Konstruktor untuk `DataCleaningOperation`.
  DataCleaningOperation({
    @visibleForTesting final DatabaseHelper? dbHelper,
    @visibleForTesting final FirebaseFirestore? firestore,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<int> deleteAllExpiredArchivedData({
    required final int retentionDays,
  }) async {
    Log.info(
      'Memulai proses pembersihan data arsip yang lebih tua dari $retentionDays hari (SQLite & Firestore).',
    );
    int totalDeletedCount = 0;
    final timeLimit =
        DateTime.now().toUtc().subtract(Duration(days: retentionDays));
    final timeLimitEpoch = timeLimit.millisecondsSinceEpoch;
    Log.info(
      'Batas waktu untuk penghapusan arsip diatur ke: ${timeLimit.toIso8601String()} (UTC)',
    );

    // Daftar nama tabel untuk SQLite dan koleksi untuk Firestore
    final List<String> tableAndCollectionList = [
      TableNameValue.get(TableName.customer),
      TableNameValue.get(TableName.activeCustomer),
      TableNameValue.get(TableName.package),
      TableNameValue.get(TableName.category),
      TableNameValue.get(TableName.subCategory),
      TableNameValue.get(TableName.transactions),
      TableNameValue.get(TableName.wallet),
      TableNameValue.get(TableName.customerOrder),
      TableNameValue.get(TableName.userApkVersion),
      TableNameValue.get(TableName.feedback),
      TableNameValue.get(TableName.notifikasi),
    ];

    // --- Langkah 1: Hapus dari Database Lokal (SQLite) ---
    final int sqliteDeleted = await _cleanSqlite(
      tableAndCollectionList,
      timeLimitEpoch,
    );
    totalDeletedCount += sqliteDeleted;

    // --- Langkah 2: Hapus dari Database Remote (Firestore) ---
    final int firestoreDeleted = await _cleanFirestore(
      tableAndCollectionList,
      timeLimit,
    );
    totalDeletedCount += firestoreDeleted;

    Log.info(
      'Proses pembersihan selesai. Total data terhapus: $totalDeletedCount (SQLite: $sqliteDeleted, Firestore: $firestoreDeleted).',
    );
    return totalDeletedCount;
  }

  /// Membersihkan data kadaluarsa dari database lokal SQLite.
  Future<int> _cleanSqlite(
      final List<String> tables, final int timeLimitEpoch) async {
    int totalDeleted = 0;
    try {
      final db = await _dbHelper.database;
      for (final table in tables) {
        final query =
            'DELETE FROM $table WHERE ${ColumnNames.archivedAt} IS NOT NULL AND ${ColumnNames.archivedAt} <= ?';
        final deletedRows = await db.rawDelete(query, [timeLimitEpoch]);
        if (deletedRows > 0) {
          Log.info(
              '[SQLite - $table] Berhasil menghapus $deletedRows baris data kadaluarsa.');
          totalDeleted += deletedRows;
        }
      }
      Log.info(
          'Total $totalDeleted baris data arsip kadaluarsa berhasil dihapus dari database SQLite.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan pembersihan data di SQLite.', e: e, st: s);
    }
    return totalDeleted;
  }

  /// Membersihkan data kadaluarsa dari database remote Firestore.
  Future<int> _cleanFirestore(
      final List<String> collections, final DateTime timeLimit) async {
    int totalDeleted = 0;
    try {
      Log.info('Memulai proses pembersihan data untuk Firestore...');

      // Membuat daftar semua query future
      final futures = collections.map((final collectionName) {
        // [DIPERBAIKI] Menambahkan filter `isDeleted: true` sesuai permintaan.
        // Sekarang, dokumen akan dihapus hanya jika isDeleted == true DAN archivedAt sudah kadaluarsa.
        // Ini membutuhkan composite index di Firestore: (isDeleted, archivedAt).
        return _firestore
            .collection(collectionName)
            .where(ColumnNames.isDeleted, isEqualTo: true)
            .where(ColumnNames.archivedAt, isLessThanOrEqualTo: timeLimit)
            .get();
      }).toList();

      // Menjalankan semua query secara paralel
      final snapshots = await Future.wait(futures);

      final batch = _firestore.batch();
      int docsFound = 0;

      for (int i = 0; i < snapshots.length; i++) {
        final snapshot = snapshots[i];
        if (snapshot.docs.isNotEmpty) {
          final collectionName = collections[i];
          Log.info(
            '[Firestore - $collectionName] Ditemukan ${snapshot.docs.length} dokumen kadaluarsa (isDeleted:true) untuk dihapus.',
          );
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
            docsFound++;
          }
        }
      }

      if (docsFound > 0) {
        Log.info(
            'Melakukan commit batch pembersihan data untuk Firestore ($docsFound dokumen)...');
        await batch.commit();
        totalDeleted = docsFound;
        Log.info(
          'Total $totalDeleted dokumen arsip kadaluarsa (isDeleted:true) berhasil dihapus dari Firestore.',
        );
      } else {
        Log.info(
            'Tidak ada data arsip kadaluarsa (isDeleted:true) untuk dihapus di Firestore.');
      }
    } catch (e, s) {
      Log.error('Gagal menjalankan batch pembersihan data di Firestore.',
          e: e, st: s);
      // Melempar error karena kegagalan di Firestore bisa jadi lebih kritis.
      rethrow;
    }
    return totalDeleted;
  }
}
