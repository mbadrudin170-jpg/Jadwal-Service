// path: lib/shared/operasi/pembersihan_data_operasi.dart

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';

class PembersihanDataOperasi {
  // diubah: dbHelper sekarang final dan diinisialisasi di konstruktor.
  final DatabaseHelper _dbHelper;

  // diubah: Konstruktor untuk injeksi dependensi.
  PembersihanDataOperasi({@visibleForTesting DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [batasHari] di semua tabel yang relevan.
  Future<int> hapusSemuaDataArsipKadaluarsa({required int batasHari}) async {
    Log.info(
      'Memulai proses pembersihan data arsip yang lebih tua dari $batasHari hari.',
    );

    final db = await _dbHelper.database;
    int totalTerhapus = 0;

    final List<String> daftarTabel = [
      'pelanggan',
      'pelanggan_aktif',
      'paket',
      'kategori',
      'sub_kategori',
      'transaksi',
      'dompet',
      'pesanan',
      'versi_apk_user',
    ];

    for (final tabel in daftarTabel) {
      try {
        // Argumen `batasHari` diinterpolasi langsung ke dalam string
        // karena `?` tidak didukung di dalam fungsi `datetime()` sqflite.
        final query =
            '''
          DELETE FROM $tabel
          WHERE diarsipkan IS NOT NULL
          AND diarsipkan <= datetime('now', '-$batasHari days')
        ''';
        final hasil = await db.rawDelete(query);

        if (hasil > 0) {
          Log.info(
            '[$tabel] Dihapus $hasil baris yang diarsipkan lebih dari $batasHari hari.',
          );
        }

        totalTerhapus += hasil;
      } catch (e, s) {
        Log.error('Gagal membersihkan tabel $tabel.', error: e, stackTrace: s);
        // Lanjutkan ke tabel berikutnya meskipun ada error di satu tabel
        continue;
      }
    }

    Log.info(
      'Total $totalTerhapus baris data arsip kadaluarsa berhasil dihapus dari database.',
    );
    return totalTerhapus;
  }
}
