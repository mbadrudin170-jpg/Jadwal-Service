// path: lib/shared/services/user_activity_service.dart

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';

/// Service untuk menangani pelacakan aktivitas pengguna.
class LayananAktivitasUser {
  final PelangganOpFirebase _pelangganOpFirebase;
  final SharedPreferences _prefs;
  static const String kunciPingTerakhirAktif = 'last_activity_ping_timestamp';
  static const Duration jadwalPing = Duration(minutes: 5);

  LayananAktivitasUser({
    required PelangganOpFirebase pelangganOpFirebase,
    required SharedPreferences prefs,
  }) : _pelangganOpFirebase = pelangganOpFirebase,
       _prefs = prefs;

  Future<void> pingAktivitas(String id, {bool force = false}) async {
    if (id.isEmpty) {
      Log.warning('pingActivity: customerId kosong, proses dibatalkan.');
      return;
    }

    try {
      final pingTerakhir = _prefs.getInt(kunciPingTerakhirAktif);
      final now = DateTime.now();

      if (pingTerakhir != null && !force) {
        final waktuPingTerakhir = DateTime.fromMillisecondsSinceEpoch(
          pingTerakhir,
        );
        if (now.difference(waktuPingTerakhir) < jadwalPing) {
          Log.info(
            'pingActivity: Throttled. Panggilan dibatasi karena ping terakhir < ${jadwalPing.inMinutes} menit yang lalu.',
          );
          return;
        }
      }

      Log.info(
        'pingActivity: Mengirim ping aktivitas untuk user: $id (Force: $force)',
      );

      unawaited(_pelangganOpFirebase.perbaruiTerakhirAktif(id));

      await _prefs.setInt(kunciPingTerakhirAktif, now.millisecondsSinceEpoch);
      Log.info(
        'pingActivity: Timestamp ping terakhir diperbarui secara lokal.',
      );
    } catch (e, st) {
      Log.error(
        'pingActivity: Terjadi error pada logika throttling atau SharedPreferences.',
        e: e,
        s: st,
      );
      // Tidak melempar ulang agar tidak mengganggu aplikasi.
    }
  }
}
