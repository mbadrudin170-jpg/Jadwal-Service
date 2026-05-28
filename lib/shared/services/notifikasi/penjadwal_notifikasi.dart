// path: lib/shared/services/notifikasi/penjadwal_notifikasi.dart
// baru: File ini berisi logika terpusat untuk menjadwalkan notifikasi langganan.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

/// Kelas utilitas untuk mengelola penjadwalan notifikasi terkait langganan.
class PenjadwalNotifikasi {
  /// Metode statis untuk mengatur (menjadwalkan atau membatalkan) notifikasi
  /// kadaluwarsa dan notifikasi tengah periode untuk seorang pengguna.
  ///
  /// [context] diperlukan untuk mengakses NotifikasiServis melalui Provider.
  /// [userId] adalah ID pengguna yang notifikasinya akan diatur.
  static Future<void> aturNotifikasiLangganan(
    final BuildContext context,
    final String userId,
  ) async {
    Log.info(
        'Memulai pengecekan untuk penjadwalan notifikasi untuk pengguna: $userId');
    final notifikasiServis =
        Provider.of<NotifikasiServis>(context, listen: false);

    // Definisikan ID unik untuk setiap jenis notifikasi.
    final endNotificationId = userId.hashCode;
    final midNotificationId = '${userId}_midpoint'.hashCode;

    try {
      final transactionOperation = TransactionOpFirebase();

      // Dapatkan transaksi lunas terbaru yang akan datang dari Firebase.
      final transaction =
          await transactionOperation.getLatestPaidTransactionByUserId(userId);

      // Logika utama penjadwalan notifikasi
      if (transaction != null &&
          transaction.startDate != null &&
          transaction.endDate != null &&
          transaction.endDate!.isAfter(DateTime.now())) {
        // -- 1. Jadwalkan Notifikasi di Akhir Periode --
        Log.info(
            'Langganan aktif ditemukan (ID: ${transaction.id}). Menjadwalkan notifikasi akhir pada ${transaction.endDate}');
        await notifikasiServis.perbaruiJadwalNotifikasi(
          id: endNotificationId,
          title: 'Langganan Telah Berakhir',
          body:
              'Masa aktif paket Anda telah berakhir. Perpanjang sekarang untuk terhubung lagi.',
          jadwal: transaction.endDate!,
          payload: 'subscription_expired',
        );

        // -- 2. Jadwalkan Notifikasi di Tengah Periode (50%) --
        final totalDuration =
            transaction.endDate!.difference(transaction.startDate!);
        final midpointDuration = totalDuration.inSeconds ~/ 2;
        final midpointDate =
            transaction.startDate!.add(Duration(seconds: midpointDuration));

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
          // Jika tanggal tengah sudah lewat, batalkan notifikasi tengah periode yg mungkin ada sebelumnya
          Log.info(
              'Tanggal tengah periode sudah lewat. Membatalkan notifikasi jika ada.');
          await notifikasiServis.batalNotifikasi(midNotificationId);
        }
      } else {
        // Jika tidak ada langganan lunas yang aktif, batalkan semua notifikasi terkait.
        Log.info(
            'Tidak ada langganan aktif. Membatalkan semua notifikasi untuk pengguna ini.');
        await notifikasiServis.batalNotifikasi(endNotificationId);
        await notifikasiServis.batalNotifikasi(midNotificationId);
      }
    } on Exception catch (e, st) {
      Log.error('Gagal mengatur notifikasi dari Firebase', e: e, st: st);
      // Jika terjadi error, coba batalkan semua notifikasi untuk kebersihan
      await notifikasiServis.batalNotifikasi(endNotificationId);
      await notifikasiServis.batalNotifikasi(midNotificationId);
    }
  }
}
