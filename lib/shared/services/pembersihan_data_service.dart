// path: lib/services/pembersihan_data_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/operasi/pembersihan_data_operasi.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';

/// Kelas layanan untuk membersihkan data secara berkala.
class PembersihanDataService {
  static const String _keyLastCleanup = 'last_cleanup_timestamp';

  final PembersihanDataOperasi _operasi = PembersihanDataOperasi();
  // ditambahkan: Instance untuk operasi pengaturan.
  final PengaturanOperasi _pengaturanOperasi = PengaturanOperasi();

  /// Lock sederhana untuk mencegah eksekusi ganda
  static bool _sedangBerjalan = false;

  /// Menjalankan pembersihan data jika sudah waktunya (24 jam sekali).
  Future<void> jalankanJikaPerlu() async {
    Log.info('Memicu fungsi pengecekan rutin pembersihan data...');

    // 🚫 Cegah double eksekusi
    if (_sedangBerjalan) {
      Log.warning(
        'Operasi ditolak karena ada proses pembersihan yang masih berjalan di latar belakang.',
      );
      return;
    }

    _sedangBerjalan = true;
    Log.info('Lock diaktifkan. Memulai evaluasi waktu pembersihan terakhir.');

    try {
      Log.info(
        'Mengakses SharedPreferences untuk mengambil timestamp pembersihan terakhir...',
      );
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      final lastCleanupMillis = prefs.getInt(_keyLastCleanup);

      if (lastCleanupMillis != null) {
        final lastCleanup = DateTime.fromMillisecondsSinceEpoch(
          lastCleanupMillis,
        );

        final selisih = now.difference(lastCleanup);
        Log.info(
          'Terakhir dibersihkan pada $lastCleanup (Selisih: ${selisih.inHours} jam).',
        );

        // 🚫 Kalau belum 24 jam → stop
        if (selisih < const Duration(hours: 24)) {
          Log.info(
            'Pembersihan data dilewati. Belum mencapai batas siklus 24 jam.',
          );
          return;
        }
      } else {
        Log.info(
          'Data pembersihan terakhir tidak ditemukan. Ini kemungkinan eksekusi pertama kali.',
        );
      }

      Log.info(
        'Kondisi terpenuhi. Memulai proses pembersihan data arsip kadaluarsa...',
      );

      // ditambahkan: Mengambil pengaturan untuk mendapatkan batas hari dinamis.
      Log.info(
        'Mengambil konfigurasi "Hapus Otomatis" dari tabel pengaturan...',
      );
      final PengaturanModel pengaturan =
          await _pengaturanOperasi.getPengaturan();
      final int batasHari = pengaturan.hapusOtomatisDataArsip;

      Log.info(
        'Konfigurasi aktif ditemukan. Batas retensi arsip adalah: $batasHari hari.',
      );

      // ✅ Simpan dulu timestamp (anti loop kalau crash)
      Log.info('Memperbarui timestamp pembersihan terakhir ke sistem storage.');
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // diubah: Memanggil fungsi dengan parameter 'batasHari' dari pengaturan.
      Log.info('Menjalankan query penghapusan data masal pada DB...');
      final totalTerhapus = await _operasi.hapusSemuaDataArsipKadaluarsa(
        batasHari: batasHari,
      );

      if (totalTerhapus > 0) {
        Log.info(
          'Pembersihan data selesai dengan sukses. Total item yang dihapus: $totalTerhapus data.',
        );
      } else {
        Log.info(
          'Proses selesai. Tidak ada data yang kadaluarsa untuk dihapus pada siklus ini.',
        );
      }
    } on Exception catch  (e, s) {
      Log.error(
        'Terjadi error fatal saat mencoba membersihkan data otomatis!',
        e: e,
        st: s,
      );
    } finally {
      _sedangBerjalan = false;
      Log.info('Lock dilepaskan. Servis kembali ke status standby.');
    }
  }
}
