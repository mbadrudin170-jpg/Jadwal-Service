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
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk operasi pembersihan data di database lokal.
class DataCleaningOperation {
  final DatabaseHelper _dbHelper;

  /// Konstruktor untuk `DataCleaningOperation`.
  DataCleaningOperation({@visibleForTesting final DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [retentionDays] di semua tabel yang relevan.
  Future<int> deleteAllExpiredArchivedData(
      {required final int retentionDays}) async {
    Log.info(
      'Memulai proses pembersihan data arsip yang lebih tua dari $retentionDays hari.',
    );

    final db = await _dbHelper.database;
    int totalDeleted = 0;

    final List<String> tableList = [
      'pelanggan',
      'pelanggan_aktif',
      'paket',
      'kategori',
      'sub_kategori',
      'transaksi',
      'dompet',
      'pesanan',
      'versi_apk_user',
      'kritik_saran',
    ];

    // Kalkulasi waktu sekarang dilakukan di Dart dengan UTC untuk memastikan konsistensi.
    final timeLimit =
        DateTime.now().toUtc().subtract(Duration(days: retentionDays));
    final timeLimitEpoch = timeLimit.millisecondsSinceEpoch;
    Log.info(
      'Batas waktu untuk penghapusan arsip diatur ke: ${timeLimit.toIso8601String()} (UTC) / $timeLimitEpoch (Epoch)',
    );

    for (final table in tableList) {
      try {
        final query =
            'DELETE FROM $table WHERE diarsipkan IS NOT NULL AND diarsipkan <= ?';
        final result = await db.rawDelete(query, [timeLimitEpoch]);

        if (result > 0) {
          Log.info(
            '[$table] Dihapus $result baris yang diarsipkan lebih dari $retentionDays hari (sebelum ${timeLimit.toIso8601String()}).',
          );
        }

        totalDeleted += result;
      } on Exception catch (e, s) {
        Log.error('Gagal membersihkan tabel $table.', e: e, st: s);
        continue;
      }
    }

    Log.info(
      'Total $totalDeleted baris data arsip kadaluarsa berhasil dihapus dari database.',
    );
    return totalDeleted;
  }
}
