// path: lib/shared/services/notifikasi/penjadwal_notifikasi.dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';

class PenjadwalNotifikasi {
  static Future<void> aturNotifikasiLangganan(
    LayananNotifikasi notifikasiServis,
    final String userId,
  ) async {
    Log.info(
        'Memulai pengecekan untuk penjadwalan notifikasi untuk pengguna: $userId');
    final endNotificationId = userId.hashCode;
    final midNotificationId = '${userId}_midpoint'.hashCode;

    // ID untuk AlarmManager harus unik per alarm.
    final int alarmId = endNotificationId;

    try {
      final transactionOperation = TransactionOpFirebase();

      // Dapatkan transaksi lunas terbaru yang akan datang dari Firebase.
      final transaction = await transactionOperation
          .ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId);

      // Logika utama penjadwalan notifikasi
      if (transaction != null &&
          transaction.tanggalMulai != null &&
          transaction.tangglberakhir != null &&
          transaction.tangglberakhir!.isAfter(DateTime.now())) {
        // -- Penjadwalan Notifikasi & Alarm Akhir Periode --
        final scheduledTime = transaction.tangglberakhir!;
        Log.info(
            'Langganan aktif ditemukan (ID: ${transaction.id}). Menjadwalkan notifikasi & alarm akhir pada $scheduledTime');

        // 1. Jadwalkan Notifikasi Visual
        await notifikasiServis.perbaruiJadwalNotifikasi(
          id: endNotificationId,
          title: 'Langganan Telah Berakhir',
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.',
          jadwal: scheduledTime,
          payload: 'subscription_expired',
        );

        // 2. Jadwalkan Alarm untuk Eksekusi Background
        await AndroidAlarmManager.oneShotAt(
          scheduledTime,
          alarmId,
          _callbackAlarm, // Fungsi top-level
          exact: true, // Memastikan eksekusi tepat waktu
          wakeup: true, // Membangunkan perangkat jika dalam mode sleep
        );
        Log.info(
            'Alarm untuk ID $alarmId berhasil dijadwalkan pada $scheduledTime');

        // -- Logika untuk Notifikasi Tengah Periode (tidak berubah) --
        final totalDuration =
            transaction.tangglberakhir!.difference(transaction.tanggalMulai!);
        final midpointDuration = totalDuration.inSeconds ~/ 2;
        final midpointDate =
            transaction.tanggalMulai!.add(Duration(seconds: midpointDuration));

        if (midpointDate.isAfter(DateTime.now())) {
          Log.info('Menjadwalkan notifikasi tengah periode pada $midpointDate');
          await notifikasiServis.perbaruiJadwalNotifikasi(
            id: midNotificationId,
            title: 'Status Langganan Anda',
            body:
                'Masa aktif paket Anda sudah berjalan 50%. Terima kasih telah menggunakan layanan kami.',
            jadwal: midpointDate,
            payload: 'subscription_midpoint',
          );
        } else {
          Log.info(
              'Tanggal tengah periode sudah lewat. Membatalkan notifikasi jika ada.');
          await notifikasiServis.batalNotifikasi(midNotificationId);
        }
      } else {
        // Jika tidak ada langganan aktif, batalkan semua notifikasi DAN alarm.
        Log.info(
            'Tidak ada langganan aktif. Membatalkan semua notifikasi dan alarm untuk pengguna ini.');
        await notifikasiServis.batalNotifikasi(endNotificationId);
        await notifikasiServis.batalNotifikasi(midNotificationId);
        await AndroidAlarmManager.cancel(alarmId);
        Log.info('Alarm dengan ID $alarmId juga dibatalkan.');
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengatur notifikasi dari Firebase', e: e, s: st);
      // Jika terjadi error, coba batalkan semua notifikasi dan alarm untuk kebersihan.
      await notifikasiServis.batalNotifikasi(endNotificationId);
      await notifikasiServis.batalNotifikasi(midNotificationId);
      await AndroidAlarmManager.cancel(alarmId);
      Log.info('Alarm dengan ID $alarmId juga dibatalkan karena error.');
    }
  }
}

/// Fungsi callback yang akan dieksekusi oleh AlarmManager.
/// Harus berupa top-level function atau static method.
@pragma('vm:entry-point')
Future<void> _callbackAlarm() async {
  // Isolate baru tidak berbagi memori atau inisialisasi.
  // Kita harus menginisialisasi semua service yang dibutuhkan di sini.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Log.info('ALARM TERPICU: Memulai proses pengecekan langganan kedaluwarsa...');
  // Pastikan ExpiredSubscriptionCheckService diimpor dengan benar di atas.

  final container = ProviderContainer();
  try {
    final service = container.read(arsipLanggananKadaluarsaServiceProvider);
    await service.prosesArsipLanggananKadaluarsa();
  } finally {
    container.dispose();
  }
  Log.info('ALARM SELESAI: Proses pengecekan langganan kedaluwarsa selesai.');
}
