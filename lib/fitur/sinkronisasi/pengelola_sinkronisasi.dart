import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/data/services/layanan_preferensi.dart'; // ← import
import 'package:wifi/shared/debug/log.dart';

final pengelolaSinkronisasiProvider = Provider<PengelolaSinkronisasi>((ref) {
  Log.info('Membuat instance SyncManager melalui Riverpod provider');
  return PengelolaSinkronisasi();
});

class PengelolaSinkronisasi {
  LayananPreferensi get _layananPrefs => LayananPreferensi();

  // Method dengan nama berbeda agar tidak bentrok
  Future<DateTime> ambilWaktuTerakhirUnduhPreferensi() async {
    Log.info('Meminta timestamp terakhir unduh dari PreferenceService');
    final hasil = await _layananPrefs
        .ambilWaktuTerakhirUnduh(); // ← fungsi top-level
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unduh yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirUnduhPreferensi(DateTime waktu) async {
    Log.info('Menyimpan timestamp terakhir unduh: $waktu');
    await _layananPrefs.simpanWaktuTerakhirUnduh(waktu); // ← fungsi top-level
    Log.info('Timestamp terakhir unduh berhasil disimpan');
  }

  Future<DateTime> ambilWaktuTerakhirUnggahPreferensi() async {
    Log.info('Meminta timestamp terakhir unggah dari PreferenceService');
    final hasil = await _layananPrefs
        .ambilWaktuTerakhirUnggah(); // ← fungsi top-level
    final waktuTerakhir =
        hasil ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Log.info('Timestamp terakhir unggah yang digunakan: $waktuTerakhir');
    return waktuTerakhir;
  }

  Future<void> simpanWaktuTerakhirUnggahPreferensi(DateTime waktu) async {
    Log.info('Menyimpan timestamp terakhir unggah: $waktu');
    await _layananPrefs.simpanWaktuTerakhirUnggah(waktu); // ← fungsi top-level
    Log.info('Timestamp terakhir unggah berhasil disimpan');
  }

  Future<void> resetWaktuSinkronisasiPreferensi() async {
    Log.warning('MERESET WAKTU SINKRONISASI (UNDUH & UNGGAH)');
    await _layananPrefs.resetWaktuSinkronisasi(); // ← fungsi top-level
    Log.info('Waktu sinkronisasi (unduh dan unggah) berhasil di-reset.');
  }
}
