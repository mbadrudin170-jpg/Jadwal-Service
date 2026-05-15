// path: lib/shared/operasi/pembersihan_data_operasi.dart
// diubah: Mengganti datetime('now') SQLite dengan kalkulasi UTC di Dart untuk mencegah bug zona waktu.

import 'package:flutter/foundation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk operasi pembersihan data di database lokal.
class PembersihanDataOperasi {
  final DatabaseHelper _dbHelper;

  /// Konstruktor untuk `PembersihanDataOperasi`.
  PembersihanDataOperasi({@visibleForTesting final DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Fungsi utama untuk menghapus semua data arsip
  /// yang sudah lebih tua dari [batasHari] di semua tabel yang relevan.
  Future<int> hapusSemuaDataArsipKadaluarsa({required final int batasHari}) async {
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
      'kritik_saran',
    ];

    // diubah: Kalkulasi waktu sekarang dilakukan di Dart dengan UTC untuk memastikan konsistensi.
    // Ini menghilangkan ketergantungan pada fungsi `datetime('now')` SQLite yang bisa ambigu (lokal vs UTC).
    final batasWaktu =
        DateTime.now().toUtc().subtract(Duration(days: batasHari));
    final batasWaktuEpoch = batasWaktu.millisecondsSinceEpoch;
    Log.info(
      'Batas waktu untuk penghapusan arsip diatur ke: ${batasWaktu.toIso8601String()} (UTC) / $batasWaktuEpoch (Epoch)',
    );

    for (final tabel in daftarTabel) {
      try {
        // diubah: Menggunakan parameterized query untuk keamanan dan kejelasan.
        // Membandingkan data `diarsipkan` (yang disimpan sebagai UTC) dengan `batasWaktu` (yang juga UTC).
        final query =
            'DELETE FROM $tabel WHERE diarsipkan IS NOT NULL AND diarsipkan <= ?';
        final hasil = await db.rawDelete(query, [batasWaktuEpoch]);

        if (hasil > 0) {
          Log.info(
            '[$tabel] Dihapus $hasil baris yang diarsipkan lebih dari $batasHari hari (sebelum ${batasWaktu.toIso8601String()}).',
          );
        }

        totalTerhapus += hasil;
      } on Exception catch (e, s) {
        Log.error('Gagal membersihkan tabel $tabel.', e: e, st: s);
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
