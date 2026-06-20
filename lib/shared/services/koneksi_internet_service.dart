// path: lib/shared/services/koneksi_internet_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wifi/fitur/speedtest/provider/ping_provider.dart';
import 'package:wifi/shared/debug/log.dart';

final koneksiInternetServiceProvider = Provider<KoneksiInternetService>((ref) {
  return KoneksiInternetService();
});

/// Kelas layanan untuk memeriksa status koneksi internet.
class KoneksiInternetService {
  final Connectivity _connectivity;

  KoneksiInternetService({
    Connectivity? connectivity,
    http.Client? httpClient,
    String? urlPencarian,
    Duration? durasiBatasWaktu,
  }) : _connectivity = connectivity ?? Connectivity() {
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

  Future<bool> cekInternet(WidgetRef ref) async {
    Log.info('[Internet] Memulai pemeriksaan status koneksi perangkat...');

    // cek koneksi lokal dulu
    final lokal = await cekKoneksiLokal();
    if (!lokal) {
      Log.warning('[Internet] Gagal: Tidak ada koneksi lokal.');
      return false;
    }

    bool isConnected = false;

    try {
      isConnected = lokal;

      final hasilPing = await ref.read(pingProvider.future);
      isConnected = hasilPing.response?.time != null;

      Log.info(
        isConnected
            ? '[Internet] Ping berhasil'
            : '[Internet] Ping gagal (timeout)',
      );
      return isConnected;
    } on TimeoutException catch (e, st) {
      Log.warning('[Internet] Ping timeout: $e $st');
      return false;
    } catch (e, st) {
      Log.error('[Internet] Ping error: $e', e: e, s: st);
      return false;
    }
  }
}
