// path: lib/shared/utils/sync_manager.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/preference_service.dart';
import 'package:wifi/shared/debug/log.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  Log.info('Membuat instance SyncManager melalui Riverpod provider');
  return SyncManager();
});

class SyncManager {
  Future<DateTime> ambilWaktuTerakhirDownload() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferenceService');
    final hasil = await PreferenceService.ambilWaktuTerakhirDownload();
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirunduh(DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unduh: $time');
    await PreferenceService.simpanWaktuTerakhirunduh(time);
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  Future<DateTime> ambilWaktuTerakhirUnggah() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferenceService');
    final hasil = await PreferenceService.ambilWaktuTerakhirUnggah();
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerkahirUnggah(DateTime time) async {
    Log.info('Menyimpan timestamp terakhir unggah: $time');
    await PreferenceService.simpanWaktuTerkahirUnggah(time);
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  Future<void> resetWaktuSinkronisasi() async {
    Log.warning('MERESET WAKTU SINKRONISASI (UNDUH & UNGGAH)');
    await PreferenceService.resetWaktuSinkronisasi();
    Log.info('Waktu sinkronisasi (unduh dan unggah) berhasil di-reset.');
  }
}
