// path: lib/shared/services/koneksi_internet_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/speedtest/provider/ping_provider.dart';
import 'package:wifi/shared/debug/log.dart';

// 1. Masukkan 'ref' ke dalam service agar bisa membaca provider lain
final koneksiInternetServiceProvider = Provider<KoneksiInternetService>((ref) {
  return KoneksiInternetService(ref);
});

class KoneksiInternetService {
  final Connectivity _connectivity;
  final Ref _ref; // 2. Simpan referensi Ref di sini

  KoneksiInternetService(this._ref, {Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    Log.info('KoneksiInternetService diinisialisasi.');
  }

  Future<bool> cekKoneksiLokal() async {
    Log.info('[Lokal] Memulai pemeriksaan status koneksi perangkat...');
    try {
      final hasilKoneksi = await _connectivity.checkConnectivity();
      Log.info('[Lokal] Hasil mentah konektivitas: $hasilKoneksi');

      final isOnline =
          hasilKoneksi.contains(ConnectivityResult.mobile) ||
          hasilKoneksi.contains(ConnectivityResult.wifi) ||
          hasilKoneksi.contains(ConnectivityResult.ethernet) ||
          hasilKoneksi.contains(ConnectivityResult.vpn);

      if (isOnline) {
        Log.info('[Lokal] ✅ Sukses: Perangkat terhubung ke jaringan lokal.');
      } else {
        Log.warning('[Lokal] ❌ Gagal: Tidak ada koneksi jaringan lokal.');
      }
      return isOnline;
    } catch (e, st) {
      Log.error('[Lokal] ❌ Fatal: Gagal memeriksa koneksi lokal.', e: e, s: st);
      return false;
    }
  }

  // 3. Hapus parameter 'WidgetRef ref' karena sekarang menggunakan '_ref' internal
  Future<bool> cekInternet() async {
    Log.info('[Internet] Memulai pemeriksaan status koneksi perangkat...');

    final lokal = await cekKoneksiLokal();
    if (!lokal) {
      Log.warning('[Internet] Gagal: Tidak ada koneksi lokal.');
      return false;
    }

    try {
      // 4. Panggil httpPingProvider.future di sini
      // Karena menggunakan riverpod_annotation, nama provider otomatis menjadi 'httpPingProvider'
      final durasiMs = await _ref.read(httpPingProvider.future);

      Log.info('[Internet] HTTP Ping berhasil! Waktu respons: ${durasiMs}ms');
      return true;
    } on TimeoutException catch (e, st) {
      Log.warning('[Internet] HTTP Ping timeout: $e $st');
      return false;
    } catch (e, st) {
      Log.error('[Internet] HTTP Ping error/gagal: $e', e: e, s: st);
      return false;
    }
  }
}
