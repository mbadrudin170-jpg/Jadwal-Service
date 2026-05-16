// path: lib/shared/utils/sync_manager.dart

import 'package:wifi/shared/data/services/preference_service.dart';
import 'package:wifi/shared/debug/log.dart';

/// Manajer untuk mengelola timestamp sinkronisasi data.
///
/// Menyimpan dan mengambil timestamp terakhir unduh dan unggah
/// melalui [PreferenceService], serta menyediakan fungsi reset.
class SyncManager {
  /// Mengambil timestamp terakhir unduh.
  ///
  /// Mengembalikan [DateTime] dari [PreferenceService], atau
  /// Epoch 0 jika belum pernah disimpan.
  Future<DateTime> getLastDownload() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferenceService');
    final result = await PreferenceService.getLastDownload();
    final lastTime =
        result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $lastTime');
    return lastTime;
  }

  /// Menyimpan timestamp terakhir unduh.
  Future<void> setLastDownload(final DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unduh: $time');
    await PreferenceService.setLastDownload(time);
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  /// Mengambil timestamp terakhir unggah.
  ///
  /// Mengembalikan [DateTime] dari [PreferenceService], atau
  /// Epoch 0 jika belum pernah disimpan.
  Future<DateTime> getLastUpload() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferenceService');
    final result = await PreferenceService.getLastUpload();
    final lastTime =
        result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $lastTime');
    return lastTime;
  }

  /// Menyimpan timestamp terakhir unggah.
  Future<void> setLastUpload(final DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unggah: $time');
    await PreferenceService.setLastUpload(time);
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  /// Mereset semua timestamp sinkronisasi (unduh dan unggah).
  Future<void> resetSyncTime() async {
    Log.warning('MERESET WAKTU SINKRONISASI (UNDUH & UNGGAH)');
    await PreferenceService.resetSyncTime();
    Log.info('Waktu sinkronisasi (unduh dan unggah) berhasil di-reset.');
  }
}
