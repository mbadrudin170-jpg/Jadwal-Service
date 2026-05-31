// path: lib/shared/utils/sync_manager.dart

// diperbaiki: Mengubah semua metode menjadi statis agar konsisten dengan kelas utilitas lainnya.
// diperbaiki: Menambahkan konstruktor privat untuk mencegah instansiasi.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/preference_service.dart';
import 'package:wifi/shared/debug/log.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  Log.info('Membuat instance SyncManager melalui Riverpod provider');
  return SyncManager();
});


class SyncManager {
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
