// path: lib/shared/services/data_cleaning_service.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai service pembersihan data berkala.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/settings_model.dart (SettingsModel)
//   - lib/shared/operasi/data_cleaning_operation.dart (DataCleaningOperation)
//   - lib/shared/operasi/settings_operation.dart (SettingsOperation)
//   - lib/shared/debug/log.dart (Log)

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';

/// Kelas layanan untuk membersihkan data secara berkala.
class DataCleaningService {
  static const String _keyLastCleanup = 'last_cleanup_timestamp';

  final DataCleaningOperation _operation = DataCleaningOperation();
  // ditambahkan: Instance untuk operasi pengaturan.
  final SettingsOperation _settingsOperation = SettingsOperation();

  /// Lock sederhana untuk mencegah eksekusi ganda
  static bool _isRunning = false;

  /// Menjalankan pembersihan data jika sudah waktunya (24 jam sekali).
  Future<void> runIfNeeded() async {
    Log.info('Memicu fungsi pengecekan rutin pembersihan data...');

    // 🚫 Cegah double eksekusi
    if (_isRunning) {
      Log.warning(
        'Operasi ditolak karena ada proses pembersihan yang masih berjalan di latar belakang.',
      );
      return;
    }

    _isRunning = true;
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

        final difference = now.difference(lastCleanup);
        Log.info(
          'Terakhir dibersihkan pada $lastCleanup (Selisih: ${difference.inHours} jam).',
        );

        // 🚫 Kalau belum 24 jam → stop
        if (difference < const Duration(hours: 24)) {
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
      final SettingsModel settings = await _settingsOperation.getSettings();
      final int retentionDays = settings.autoDeleteArchiveDays;

      Log.info(
        'Konfigurasi aktif ditemukan. Batas retensi arsip adalah: $retentionDays hari.',
      );

      // ✅ Simpan dulu timestamp (anti loop kalau crash)
      Log.info('Memperbarui timestamp pembersihan terakhir ke sistem storage.');
      await prefs.setInt(_keyLastCleanup, now.millisecondsSinceEpoch);

      // diubah: Memanggil fungsi dengan parameter 'retentionDays' dari pengaturan.
      Log.info('Menjalankan query penghapusan data masal pada DB...');
      final totalDeleted = await _operation.deleteAllExpiredArchivedData(
        retentionDays: retentionDays,
      );

      if (totalDeleted > 0) {
        Log.info(
          'Pembersihan data selesai dengan sukses. Total item yang dihapus: $totalDeleted data.',
        );
      } else {
        Log.info(
          'Proses selesai. Tidak ada data yang kadaluarsa untuk dihapus pada siklus ini.',
        );
      }
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi error fatal saat mencoba membersihkan data otomatis!',
        e: e,
        st: s,
      );
    } finally {
      _isRunning = false;
      Log.info('Lock dilepaskan. Servis kembali ke status standby.');
    }
  }
}
