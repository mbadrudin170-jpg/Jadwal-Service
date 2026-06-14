// path: lib/shared/operasi/data_cleaning_operation.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk operasi pembersihan data di database lokal (SQLite) dan remote (Firestore).
class DataCleaningOperation {
  final SqliteDatabase _sqliteDb;
  final FirebaseFirestore _firestore;

  /// Konstruktor untuk `DataCleaningOperation`.
  DataCleaningOperation({
    @visibleForTesting final SqliteDatabase? sqliteDb,
    @visibleForTesting final FirebaseFirestore? firestore,
  })  : _sqliteDb = sqliteDb ?? SqliteDatabase.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<int> hapusPermanentDataYangDiarsip({
    required final int retentionDays,
  }) async {
    Log.info(
      'Memulai proses pembersihan data arsip yang lebih tua dari $retentionDays hari (SQLite & Firestore).',
    );
    int totalDataDihapus = 0;
    final timeLimit =
        DateTime.now().toUtc().subtract(Duration(days: retentionDays));
    final timeLimitEpoch = timeLimit.millisecondsSinceEpoch;
    Log.info(
      'Batas waktu untuk penghapusan arsip diatur ke: ${timeLimit.toIso8601String()} (UTC)',
    );

    // Daftar nama tabel untuk SQLite dan koleksi untuk Firestore
    final List<String> daftarTabelDanKoleksi = [
      NamaTabel.customer,
      NamaTabel.activeCustomer,
      NamaTabel.package,
      NamaTabel.category,
      NamaTabel.subCategory,
      NamaTabel.transactions,
      NamaTabel.wallet,
      NamaTabel.customerOrder,
      NamaTabel.userApkVersion,
      NamaTabel.feedback,
      NamaTabel.notification
    ];

    // --- Langkah 1: Hapus dari Database Lokal (SQLite) ---
    final int hapusDataSqlite = await _hapusDataSqlite(
      daftarTabelDanKoleksi,
      timeLimitEpoch,
    );
    totalDataDihapus += hapusDataSqlite;

    // --- Langkah 2: Hapus dari Database Remote (Firestore) ---
    final int hapusDataFirebase = await _hapusDataFirebase(
      daftarTabelDanKoleksi,
      timeLimit,
    );
    totalDataDihapus += hapusDataFirebase;

    Log.info(
      'Proses pembersihan selesai. Total data terhapus: $totalDataDihapus (SQLite: $hapusDataSqlite, Firestore: $hapusDataFirebase).',
    );
    return totalDataDihapus;
  }

  /// Membersihkan data kadaluarsa dari database lokal SQLite.
  Future<int> _hapusDataSqlite(List<String> tables, int timeLimitEpoch) async {
    int totalDihapus = 0;
    try {
      final db = await _sqliteDb.database;
      for (final table in tables) {
        final query =
            'DELETE FROM $table WHERE ${NamaKolom.archivedAt} IS NOT NULL AND ${NamaKolom.archivedAt} <= ?';
        final deletedRows = await db.rawDelete(query, [timeLimitEpoch]);
        if (deletedRows > 0) {
          Log.info(
              '[SQLite - $table] Berhasil menghapus $deletedRows baris data kadaluarsa.');
          totalDihapus += deletedRows;
        }
      }
      Log.info(
          'Total $totalDihapus baris data arsip kadaluarsa berhasil dihapus dari database SQLite.');
    } on Exception catch (e, s) {
      Log.error('Gagal menjalankan pembersihan data di SQLite.', e: e, s: s);
    }
    return totalDihapus;
  }

  /// Membersihkan data kadaluarsa dari database remote Firestore.
  Future<int> _hapusDataFirebase(
      List<String> koleksi, DateTime timeLimit) async {
    int totalDihapus = 0;
    try {
      Log.info('Memulai proses pembersihan data untuk Firestore...');

      // Membuat daftar semua query future
      final futures = koleksi.map((namaKleksi) {
        // [DIPERBAIKI] Menambahkan filter `isDeleted: true` sesuai permintaan.
        // Sekarang, dokumen akan dihapus hanya jika isDeleted == true DAN archivedAt sudah kadaluarsa.
        // Ini membutuhkan composite index di Firestore: (isDeleted, archivedAt).
        return _firestore
            .collection(namaKleksi)
            .where(NamaKolom.isDeleted, isEqualTo: true)
            .where(NamaKolom.archivedAt, isLessThanOrEqualTo: timeLimit)
            .get();
      }).toList();

      // Menjalankan semua query secara paralel
      final snapshots = await Future.wait(futures);

      final batch = _firestore.batch();
      int dokumenDitemukan = 0;

      for (int i = 0; i < snapshots.length; i++) {
        final snapshot = snapshots[i];
        if (snapshot.docs.isNotEmpty) {
          final namaKoleksi = koleksi[i];
          Log.info(
            '[Firestore - $namaKoleksi] Ditemukan ${snapshot.docs.length} dokumen kadaluarsa (isDeleted:true) untuk dihapus.',
          );
          for (final doc in snapshot.docs) {
            batch.delete(doc.reference);
            dokumenDitemukan++;
          }
        }
      }

      if (dokumenDitemukan > 0) {
        Log.info(
            'Melakukan commit batch pembersihan data untuk Firestore ($dokumenDitemukan dokumen)...');
        await batch.commit();
        totalDihapus = dokumenDitemukan;
        Log.info(
          'Total $totalDihapus dokumen arsip kadaluarsa (isDeleted:true) berhasil dihapus dari Firestore.',
        );
      } else {
        Log.info(
            'Tidak ada data arsip kadaluarsa (isDeleted:true) untuk dihapus di Firestore.');
      }
    } catch (e, s) {
      Log.error('Gagal menjalankan batch pembersihan data di Firestore.',
          e: e, s: s);
      // Melempar error karena kegagalan di Firestore bisa jadi lebih kritis.
      rethrow;
    }
    return totalDihapus;
  }
}
