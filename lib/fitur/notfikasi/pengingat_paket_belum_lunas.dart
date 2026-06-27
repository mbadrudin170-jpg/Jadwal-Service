// path lib/fitur/notfikasi/pengingat_paket_belum_lunas.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_provider.dart'
    hide layananNotifikasiProvider;

const String waktuTerkahirNotif = 'last_notif_date';

/// Service untuk mengecek paket belum lunas dan menampilkan notifikasi pengingat.
class PengingatService {
  final LayananNotifikasi _notifServis;
  final Ref _ref;

  PengingatService(this._ref, this._notifServis);

  /// Mengecek transaksi dengan status belum lunas dan menampilkan notifikasi
  /// jika ada dan belum pernah ditampilkan hari ini.
  Future<void> cekDanTampilkanPengingatTagihan() async {
    Log.info('[PengingatTagihan] Memulai pengecekan paket belum lunas.');

    try {
      final role = _ref.read(appRoleProvider);
      if (role == AppRole.admin) {
        return;
      }
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final hariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final terakhirNotif = prefs.getString(waktuTerkahirNotif) ?? '';
      if (terakhirNotif == hariIni) {
        Log.info(
          '[PengingatTagihan] Notifikasi sudah tampil hari ini, dilewati.',
        );
        return;
      }
      final userId = await _ref.read(userIdProvider.future);
      if (userId == null) {
        return;
      }
      final transaksiOpFirebase = _ref.read(transaksiOpFirebaseProvider);
      final daftarBelumLunas = await transaksiOpFirebase
          .ambilBelumLunasBerdasarkanIdPelanggan(userId);
      if (daftarBelumLunas.isNotEmpty) {
        Log.info(
          '[PengingatTagihan] Ditemukan ${daftarBelumLunas.length} paket belum lunas.',
        );
        await _notifServis.tampilkanNotifikasiLangsung(
          title: 'Pengingat Tagihan',
          body:
              'Anda memiliki ${daftarBelumLunas.length} paket yang belum lunas. Segera lakukan pembayaran.',
        );
        await prefs.setString(waktuTerkahirNotif, hariIni);
        Log.info('[PengingatTagihan] Notifikasi berhasil ditampilkan.');
      } else {
        Log.info('[PengingatTagihan] Tidak ada paket belum lunas.');
      }
    } on Exception catch (e, st) {
      Log.error(
        '[PengingatTagihan] Gagal mengecek atau menampilkan notifikasi.',
        e: e,
        s: st,
      );
    }
  }
}

/// Provider untuk service pengingat.
final pengingatServiceProvider = Provider<PengingatService>((ref) {
  final notifServis = ref.watch(layananNotifikasiProvider);
  return PengingatService(ref, notifServis);
});
