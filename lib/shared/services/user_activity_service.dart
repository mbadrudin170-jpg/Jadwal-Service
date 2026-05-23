// path: lib/shared/services/user_activity_service.dart
// PENTING: Panggil `UserActivityService().pingActivity(customerId)` dari UI
//          saat aplikasi pertama kali dibuka (misal di initState SplashScreen)
//          setelah memastikan pengguna sudah login.

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';

/// Service untuk menangani pelacakan aktivitas pengguna.
class UserActivityService {
  final CustomerOpFirebase _customerOpFirebase;

  /// Kunci untuk menyimpan timestamp ping terakhir di SharedPreferences.
  static const String _lastPingTimestampKey = 'last_activity_ping_timestamp';

  /// Durasi minimum antar ping untuk mencegah panggilan berlebihan.
  static const Duration _pingInterval = Duration(minutes: 5);

  /// Konstruktor, memungkinkan injeksi dependensi untuk pengujian.
  UserActivityService({
    final CustomerOpFirebase? customerOpFirebase,
  }) : _customerOpFirebase = customerOpFirebase ?? CustomerOpFirebase();

  /// Mengirim "ping" ke server untuk memperbarui waktu aktif terakhir pengguna.
  ///
  /// Fungsi ini memiliki mekanisme throttling: "ping" hanya akan dikirim jika
  /// panggilan terakhir sudah lebih dari `_pingInterval` yang lalu.
  ///
  /// Panggil fungsi ini saat aplikasi dibuka atau kembali ke foreground,
  /// dengan menyediakan `customerId` dari pengguna yang sedang login.
  Future<void> pingActivity(final String customerId) async {
    if (customerId.isEmpty) {
      Log.warning('pingActivity: customerId kosong, proses dibatalkan.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPingMillis = prefs.getInt(_lastPingTimestampKey);
      final now = DateTime.now();

      if (lastPingMillis != null) {
        final lastPingTime =
            DateTime.fromMillisecondsSinceEpoch(lastPingMillis);
        if (now.difference(lastPingTime) < _pingInterval) {
          Log.info(
              'pingActivity: Throttled. Panggilan dibatasi karena ping terakhir < ${_pingInterval.inMinutes} menit yang lalu.');
          return;
        }
      }

      Log.info('pingActivity: Mengirim ping aktivitas untuk user: $customerId');

      // Panggil update di Firebase.
      // Kita tidak 'await' agar tidak memblokir thread utama.
      // Fungsi updateLastActive sudah punya error handling internal.
      unawaited(_customerOpFirebase.updateLastActive(customerId));

      // Jika ping terkirim, perbarui timestamp lokal.// TODO : 
      await prefs.setInt(_lastPingTimestampKey, now.millisecondsSinceEpoch);
      Log.info('pingActivity: Timestamp ping terakhir diperbarui secara lokal.');
    } catch (e, st) {
      Log.error(
          'pingActivity: Terjadi error pada logika throttling atau SharedPreferences.',
          e: e,
          st: st);
      // Tidak melempar ulang agar tidak mengganggu aplikasi.
    }
  }
}
