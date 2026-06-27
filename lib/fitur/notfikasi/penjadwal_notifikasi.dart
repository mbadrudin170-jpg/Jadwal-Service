// path: lib/fitur/notfikasi/penjadwal_notifikasi.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';

class PenjadwalNotifikasi {
  static Future<void> aturNotifikasiLangganan(
    LayananNotifikasi layananNotifikasi,
    final String userId, {
    @visibleForTesting TransaksiOpFirebase? transaksiOp,
  }) async {
    Log.info(
      'Memulai pengecekan untuk penjadwalan notifikasi untuk pengguna: $userId',
    );
    final idNotifikasiAkhir = userId.hashCode;
    final idNotifikasiTengah = '${userId}_midpoint'.hashCode;

    // ID untuk AlarmManager harus unik per alarm.
    final int idAlarm = idNotifikasiAkhir;

    try {
      final transaksiOpFirebase = transaksiOp ?? TransaksiOpFirebase();

      // Dapatkan transaksi lunas terbaru yang akan datang dari Firebase.
      final transaksi = await transaksiOpFirebase
          .ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId);

      // Logika utama penjadwalan notifikasi
      if (transaksi != null &&
          transaksi.tanggalMulai != null &&
          transaksi.tanggalBerakhir != null &&
          transaksi.tanggalBerakhir!.isAfter(DateTime.now())) {
        // -- Penjadwalan Notifikasi & Alarm Akhir Periode --
        final waktuJadwal = transaksi.tanggalBerakhir!;
        Log.info(
          'Langganan aktif ditemukan (ID: ${transaksi.id}). Menjadwalkan notifikasi & alarm akhir pada $waktuJadwal',
        );

        // 1. Jadwalkan Notifikasi Visual
        await layananNotifikasi.perbaruiJadwalNotifikasi(
          id: idNotifikasiAkhir,
          title: 'Langganan Telah Berakhir',
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.',
          jadwal: waktuJadwal,
          payload: 'subscription_expired',
        );

        // 2. Jadwalkan Alarm untuk Eksekusi Background
        await AndroidAlarmManager.oneShotAt(
          waktuJadwal,
          idAlarm,
          _callbackAlarm, // Fungsi top-level
          exact: true, // Memastikan eksekusi tepat waktu
          wakeup: true, // Membangunkan perangkat jika dalam mode sleep
        );
        Log.info(
          'Alarm untuk ID $idAlarm berhasil dijadwalkan pada $waktuJadwal',
        );

        // -- Logika untuk Notifikasi Tengah Periode (tidak berubah) --
        final totalDurasi = transaksi.tanggalBerakhir!.difference(
          transaksi.tanggalMulai!,
        );
        final durasiTengah = totalDurasi.inSeconds ~/ 2;
        final tanggalTengah = transaksi.tanggalMulai!.add(
          Duration(seconds: durasiTengah),
        );

        if (tanggalTengah.isAfter(DateTime.now())) {
          Log.info(
            'Menjadwalkan notifikasi tengah periode pada $tanggalTengah',
          );
          await layananNotifikasi.perbaruiJadwalNotifikasi(
            id: idNotifikasiTengah,
            title: 'Status Langganan Anda',
            body:
                'Masa aktif paket Anda sudah berjalan 50%. Terima kasih telah menggunakan layanan kami.',
            jadwal: tanggalTengah,
            payload: 'subscription_midpoint',
          );
        } else {
          Log.info(
            'Tanggal tengah periode sudah lewat. Membatalkan notifikasi jika ada.',
          );
          await layananNotifikasi.batalNotifikasi(idNotifikasiTengah);
        }
      } else {
        // Jika tidak ada langganan aktif, batalkan semua notifikasi DAN alarm.
        Log.info(
          'Tidak ada langganan aktif. Membatalkan semua notifikasi dan alarm untuk pengguna ini.',
        );
        await layananNotifikasi.batalNotifikasi(idNotifikasiAkhir);
        await layananNotifikasi.batalNotifikasi(idNotifikasiTengah);
        await AndroidAlarmManager.cancel(idAlarm);
        Log.info('Alarm dengan ID $idAlarm juga dibatalkan.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengatur notifikasi dari Firebase', e: e, s: st);
      // Jika terjadi error, coba batalkan semua notifikasi dan alarm untuk kebersihan.
      await layananNotifikasi.batalNotifikasi(idNotifikasiAkhir);
      await layananNotifikasi.batalNotifikasi(idNotifikasiTengah);
      await AndroidAlarmManager.cancel(idAlarm);
      Log.info('Alarm dengan ID $idAlarm juga dibatalkan karena error.');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _callbackAlarm() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    final container = ProviderContainer();
    try {
      final service = container.read(arsipLanggananKadaluarsaServiceProvider);
      await service.prosesArsipLanggananKadaluarsa();
    } catch (e, st) {
      Log.error('Gagal menjalankan callback alarm', e: e, s: st);
    } finally {
      container.dispose();
    }
  } catch (e, st) {
    Log.error('Gagal inisialisasi callback alarm', e: e, s: st);
  }
}
