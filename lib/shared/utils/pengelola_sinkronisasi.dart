// path: lib/shared/utils/sync_manager.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/layanan_preferensi.dart';
import 'package:wifi/shared/debug/log.dart';

final providerPengelolaSinkronisasi = Provider<PengelolaSinkronisasi>((ref) {
  Log.info('Membuat instance SyncManager melalui Riverpod provider');
  return PengelolaSinkronisasi();
});

class PengelolaSinkronisasi {
  Future<DateTime> ambilWaktuTerakhirUnduh() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferenceService');
    final hasil = await LayananPreferensi.ambilWaktuTerakhirUnduh();
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirUnduh(DateTime waktu) async {
    Log.info('Menyimpan timestamp terakhir unduh: $waktu');
    await LayananPreferensi.simpanWaktuTerakhirUnduh(waktu);
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  Future<DateTime> ambilWaktuTerakhirUnggah() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferenceService');
    final hasil = await LayananPreferensi.ambilWaktuTerakhirUnggah();
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirUnggah(DateTime waktu) async {
    Log.info('Menyimpan timestamp terakhir unggah: $waktu');
    await LayananPreferensi.simpanWaktuTerakhirUnggah(waktu);
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  Future<void> resetWaktuSinkronisasi() async {
    Log.warning('MERESET WAKTU SINKRONISASI (UNDUH & UNGGAH)');
    await LayananPreferensi.resetWaktuSinkronisasi();
    Log.info('Waktu sinkronisasi (unduh dan unggah) berhasil di-reset.');
  }
}
