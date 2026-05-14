// path: lib/shared/utils/sync_manager.dart

import 'package:wifi/shared/data/services/preferensi_service.dart';
import 'package:wifi/shared/debug/log.dart';

/// Manajer untuk mengelola timestamp sinkronisasi data.
///
/// Menyimpan dan mengambil timestamp terakhir unduh dan unggah
/// melalui [PreferensiService], serta menyediakan fungsi reset.
class SyncManager {
  /// Mengambil timestamp terakhir unduh.
  ///
  /// Mengembalikan [DateTime] dari [PreferensiService], atau
  /// Epoch 0 jika belum pernah disimpan.
  Future<DateTime> getTerakhirUnduh() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferensiService');
    final result = await PreferensiService.getTerakhirUnduh();
    final a = result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $a');
    return a;
  }

  /// Menyimpan timestamp terakhir unduh.
  Future<void> setTerakhirUnduh(final DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unduh: $time');
    await PreferensiService.setTerakhirUnduh(time);
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  /// Mengambil timestamp terakhir unggah.
  ///
  /// Mengembalikan [DateTime] dari [PreferensiService], atau
  /// Epoch 0 jika belum pernah disimpan.
  Future<DateTime> getTerakhirUnggah() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferensiService');
    final result = await PreferensiService.getTerakhirUnggah();
    final a = result ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $a');
    return a;
  }

  /// Menyimpan timestamp terakhir unggah.
  Future<void> setTerakhirUnggah(final DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unggah: $time');
    await PreferensiService.setTerakhirUnggah(time);
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  /// Mereset semua timestamp sinkronisasi (unduh dan unggah).
  Future<void> resetWaktuSinkronisasi() async {
    Log.warning('MERESET WAKTU SINKRONISASI (UNDUH & UNGGAH)');
    await PreferensiService.resetWaktuSinkronisasi();
    Log.info('Waktu sinkronisasi (unduh dan unggah) berhasil di-reset.');
  }
}
