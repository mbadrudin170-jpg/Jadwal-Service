// path: lib/fitur/notfikasi/pengingat_paket_belum_lunas.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

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
      final prefs = await _ref.read(sharedPreferencesProvider.future);
      final hariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final terakhirNotif = prefs.getString('last_notif_date') ?? '';

      if (terakhirNotif == hariIni) {
        Log.info('[PengingatTagihan] Notifikasi sudah tampil hari ini, dilewati.');
        return;
      }

      // Ambil transaksi dengan status belum lunas dari provider
      final transaksiState = await _ref.read(transaksiProvider.future);
      final daftarBelumLunas = transaksiState.transaksi
          .where((t) => t.statusPembayaran == StatusPembayaran.unpaid)
          .toList();

      if (daftarBelumLunas.isNotEmpty) {
        Log.info(
          '[PengingatTagihan] Ditemukan ${daftarBelumLunas.length} paket belum lunas.',
        );
        await _notifServis.tampilkanNotifikasiLangsung(
          title: 'Pengingat Tagihan',
          body:
              'Anda memiliki ${daftarBelumLunas.length} paket yang belum lunas. Segera lakukan pembayaran.',
        );
        await prefs.setString('last_notif_date', hariIni);
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
      // Tidak perlu menampilkan toast ke user karena ini proses background,
      // cukup log saja.
    }
  }
}

/// Provider untuk service pengingat.
final pengingatServiceProvider = Provider<PengingatService>((ref) {
  final notifServis = ref.watch(layananNotifikasiProvider);
  return PengingatService(ref, notifServis);
});