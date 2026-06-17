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

  /// mengecek apakah perangkat terhubung ke wifi ataupun data
  Future<bool> cekKoneksiLokal() async {
    Log.info('[Lokal] Memulai pemeriksaan status koneksi perangkat...');
    try {
      final hasilKoneksi = await _connectivity.checkConnectivity();
      Log.info('[Lokal] Hasil mentah konektivitas: $hasilKoneksi');

      final isOnline =
          hasilKoneksi.contains(ConnectivityResult.mobile) ||
          hasilKoneksi.contains(ConnectivityResult.wifi);

      if (isOnline) {
        Log.info('[Lokal] ✅ Sukses: Perangkat terhubung ke jaringan lokal.');
      } else {
        Log.warning('[Lokal] ❌ Gagal: Tidak ada koneksi jaringan lokal.');
      }
      return isOnline;
    } on Exception catch (e, st) {
      Log.error('[Lokal] ❌ Fatal: Gagal memeriksa koneksi lokal.', e: e, s: st);
      return false;
    }
  }

  Future<bool> cekInternet(WidgetRef ref) async {
    Log.info('[Internet] Memulai pemeriksaan status koneksi perangkat...');
    final lokal = await cekKoneksiLokal();
    if (!lokal) {
      Log.warning('[Internet] Gagal: Tidak ada koneksi lokal.');
      return false;
    }
    try {
      final hasilPing = await ref.read(pingProvider.future);
      final berhasil = hasilPing.response?.time != null;
      Log.info(berhasil ? 'Ping berhasil' : 'Ping gagal (timeout)');
      return berhasil;
    } catch (e) {
      Log.error('Ping error: $e');
      return false;
    }
  }
}
