// path: lib/shared/services/internet_connection_check.dart

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:wifi/shared/debug/log.dart';

final internetConnectionServiceProvider =
    Provider<InternetConnectionService>((ref) {
  return InternetConnectionService();
});

/// Kelas layanan untuk memeriksa status koneksi internet.
class InternetConnectionService {
  final Connectivity _connectivity;
  final http.Client _httpClient;

  /// URL target yang andal untuk memeriksa konektivitas internet.
  final String _lookupUrl;

  /// Durasi timeout untuk permintaan lookup.
  final Duration _timeoutDuration;

  InternetConnectionService({
    Connectivity? connectivity,
    http.Client? httpClient,
    String? lookupUrl,
    Duration? timeoutDuration,
  })  : _connectivity = connectivity ?? Connectivity(),
        _httpClient = httpClient ?? http.Client(),
        _lookupUrl = lookupUrl ?? 'google.com',
        _timeoutDuration = timeoutDuration ?? const Duration(seconds: 5) {
    Log.info('InternetConnectionService diinisialisasi.');
  }

  /// Memeriksa apakah perangkat memiliki koneksi lokal (WiFi atau Mobile).
  /// Ini adalah langkah pertama sebelum memeriksa akses internet sebenarnya.
  Future<bool> checkLocalConnection() async {
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

  /// Memeriksa apakah perangkat benar-benar bisa mengakses internet.
  /// Melakukan lookup ke alamat eksternal setelah memastikan koneksi lokal ada.
  Future<bool> isInternetAvailable() async {
    Log.info('[Internet] Memulai pemeriksaan konektivitas internet penuh...');

    // Langkah 1: Cek koneksi lokal terlebih dahulu.
    final hasLocalConnection = await checkLocalConnection();
    if (!hasLocalConnection) {
      Log.warning(
          '[Internet] ❌ Gagal: Pemeriksaan dihentikan karena tidak ada koneksi lokal.');
      return false;
    }

    // Langkah 2: Jika ada koneksi lokal, coba akses internet.
    Log.info(
        '[Internet] Koneksi lokal terdeteksi. Mencoba menghubungi $_lookupUrl...');
    try {
      final response = await _httpClient
          .get(Uri.https(_lookupUrl))
          .timeout(_timeoutDuration);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Log.info(
            '[Internet] ✅ Sukses: Berhasil menghubungi $_lookupUrl. Internet tersedia.');
        return true;
      }
      // Kondisi ini jarang terjadi, tapi tetap ditangani
      Log.warning(
          '[Internet] ❌ Gagal: Gagal menghubungi $_lookupUrl. Status code: ${response.statusCode}');
      return false;
    } on TimeoutException {
      Log.error(
          '[Internet] ❌ Gagal: Waktu habis saat mencoba menghubungi $_lookupUrl. (Timeout: ${_timeoutDuration.inSeconds} detik)');
      return false;
    } on SocketException catch (e, st) {
      Log.error(
        '[Internet] ❌ Gagal: Terjadi SocketException. Ini sering disebabkan oleh firewall, masalah DNS, atau tidak ada internet sama sekali. Error: ${e.message}',
        e: e,
        st: st,
      );
      return false;
    } on HandshakeException catch (e, st) {
      Log.error(
        '[Internet] ❌ Gagal: Terjadi HandshakeException. Ini sering disebabkan oleh firewall atau antivirus yang memblokir koneksi aman (TLS/SSL). Error: ${e.message}',
        e: e,
        st: st,
      );
      return false;
    } catch (e, st) {
      Log.error(
        '[Internet] ❌ Gagal: Terjadi kesalahan tidak terduga saat memeriksa konektivitas internet.',
        e: e,
        st: st,
      );
      return false;
    } finally {
      _httpClient.close();
    }
  }
}
