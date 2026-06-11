// path: lib/shared/services/koneksi_internet_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wifi/shared/debug/log.dart';

final internetConnectionServiceProvider =
    Provider<KoneksiInternetService>((ref) {
  return KoneksiInternetService();
});

/// Kelas layanan untuk memeriksa status koneksi internet.
class KoneksiInternetService {
  final Connectivity _connectivity;

  KoneksiInternetService({
    Connectivity? connectivity,
    http.Client? httpClient,
    String? lookupUrl,
    Duration? timeoutDuration,
  }) : _connectivity = connectivity ?? Connectivity() {
    Log.info('InternetConnectionService diinisialisasi.');
  }

  /// mengecek apakah perangkat terhubung ke wifi ataupun data
  Future<bool> cekKoneksiLokal() async {
    Log.info('[Lokal] Memulai pemeriksaan status koneksi perangkat...');
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      Log.info('[Lokal] Hasil mentah konektivitas: $connectivityResult');

      final isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);

      if (isOnline) {
        Log.info('[Lokal] ✅ Sukses: Perangkat terhubung ke jaringan lokal.');
      } else {
        Log.warning('[Lokal] ❌ Gagal: Tidak ada koneksi jaringan lokal.');
      }
      return isOnline;
    } on Exception catch (e, st) {
      Log.error(
        '[Lokal] ❌ Fatal: Gagal memeriksa koneksi lokal.',
        e: e,
        st: st,
      );
      return false;
    }
  }
}
