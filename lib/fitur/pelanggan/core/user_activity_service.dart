// path: lib/shared/services/user_activity_service.dart

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';

/// Service untuk menangani pelacakan aktivitas pengguna.
class UserActivityService {
  final CustomerOpFirebase _customerOpFirebase;
  final SharedPreferences _prefs;
  static const String lastPingTimestampKey = 'last_activity_ping_timestamp';
  static const Duration pingInterval = Duration(minutes: 5);

  UserActivityService({
    required CustomerOpFirebase customerOpFirebase,
    required SharedPreferences prefs,
  })  : _customerOpFirebase = customerOpFirebase,
        _prefs = prefs;

  Future<void> pingActivity(
    final String customerId, {
    final bool force = false,
  }) async {
    if (customerId.isEmpty) {
      Log.warning('pingActivity: customerId kosong, proses dibatalkan.');
      return;
    }

    try {
      final lastPingMillis = _prefs.getInt(lastPingTimestampKey);
      final now = DateTime.now();

      if (lastPingMillis != null && !force) {
        final lastPingTime =
            DateTime.fromMillisecondsSinceEpoch(lastPingMillis);
        if (now.difference(lastPingTime) < pingInterval) {
          Log.info(
              'pingActivity: Throttled. Panggilan dibatasi karena ping terakhir < ${pingInterval.inMinutes} menit yang lalu.');
          return;
        }
      }

      Log.info(
          'pingActivity: Mengirim ping aktivitas untuk user: $customerId (Force: $force)');

      unawaited(_customerOpFirebase.perbaruiTerakhirAktif(customerId));

      await _prefs.setInt(lastPingTimestampKey, now.millisecondsSinceEpoch);
      Log.info(
          'pingActivity: Timestamp ping terakhir diperbarui secara lokal.');
    } catch (e, st) {
      Log.error(
          'pingActivity: Terjadi error pada logika throttling atau SharedPreferences.',
          e: e,
          s: st);
      // Tidak melempar ulang agar tidak mengganggu aplikasi.
    }
  }
}
