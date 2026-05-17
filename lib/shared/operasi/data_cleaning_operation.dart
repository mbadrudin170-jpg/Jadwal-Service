// path: lib/shared/operasi/data_cleaning_operation.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/shared/services/data_cleaning_service.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/data/sqlite.dart (DatabaseHelper)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

/// Kelas untuk operasi pembersihan data di database lokal.
class DataCleaningOperation {
  final DatabaseHelper _dbHelper;

  /// Konstruktor untuk `DataCleaningOperation`.
  DataCleaningOperation({@visibleForTesting final DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [retentionDays] di semua tabel yang relevan secara atomik.
  Future<int> deleteAllExpiredArchivedData({
    required final int retentionDays,
  }) async {
    Log.info(
      'Memulai proses pembersihan data arsip yang lebih tua dari $retentionDays hari.',
    );

    final db = await _dbHelper.database;

    // DIUBAH: Menggunakan TableNameValue untuk mendefinisikan daftar nama tabel
    final List<String> tableList = [
      TableNameValue.get(TableName.customer), // pelanggan
      TableNameValue.get(TableName.activeCustomer), // pelanggan_aktif
      TableNameValue.get(TableName.package), // paket
      TableNameValue.get(TableName.category), // kategori
      TableNameValue.get(TableName.subCategory), // sub_kategori
      TableNameValue.get(TableName.transactions), // transaksi
      TableNameValue.get(TableName.wallet), // dompet
      TableNameValue.get(TableName.customerOrder), // pesanan
      TableNameValue.get(TableName.userApkVersion), // versi_apk_user
      TableNameValue.get(TableName.feedback), // kritik_saran
    ];

    // Kalkulasi waktu sekarang dilakukan di Dart dengan UTC untuk memastikan konsistensi.
    final timeLimit =
        DateTime.now().toUtc().subtract(Duration(days: retentionDays));
    final timeLimitEpoch = timeLimit.millisecondsSinceEpoch;
    Log.info(
      'Batas waktu untuk penghapusan arsip diatur ke: ${timeLimit.toIso8601String()} (UTC) / $timeLimitEpoch (Epoch)',
    );

    try {
      // Menggunakan Batch agar semua proses berjalan cepat dalam satu transaksi tunggal.
      final batch = db.batch();

      for (final table in tableList) {
        final query =
            'DELETE FROM $table WHERE ${ColumnNames.archivedAt} IS NOT NULL AND ${ColumnNames.archivedAt} <= ?';
        batch.rawDelete(query, [timeLimitEpoch]);
      }

      Log.info('Melakukan commit batch pembersihan data...');
      // batch.commit() mengembalikan list berisi baris yang terpengaruh untuk setiap query.
      final results = await batch.commit(noResult: false);

      // Menghitung total baris yang berhasil dihapus
      int totalDeleted = 0;
      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        if (result is int && result > 0) {
          totalDeleted += result;
          Log.info(
            '[${tableList[i]}] Berhasil menghapus $result baris data kadaluarsa.',
          );
        }
      }

      Log.info(
        'Total $totalDeleted baris data arsip kadaluarsa berhasil dihapus dari database.',
      );
      return totalDeleted;
    } catch (e, s) {
      Log.error('Gagal menjalankan batch pembersihan data data.', e: e, st: s);
      rethrow;
    }
  }
}
