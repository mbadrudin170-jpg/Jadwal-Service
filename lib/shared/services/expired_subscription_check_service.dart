// path: lib/shared/services/expired_subscription_check_service.dart

import 'package:flutter/foundation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';

/// Service ini bertanggung jawab untuk memeriksa dan mengarsipkan
/// langganan pelanggan aktif yang telah kedaluwarsa secara berkala.
class ExpiredSubscriptionCheckService {
  ActiveCustomerOperation _activeCustomerOperation = ActiveCustomerOperation();

  @visibleForTesting
  set activeCustomerOperation(final ActiveCustomerOperation operation) {
    _activeCustomerOperation = operation;
  }

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan memanggil operasi untuk mengarsipkan mereka.
  Future<void> processExpiredSubscriptions() async {
    Log.info(
      'Memulai siklus pengecekan dan pengarsipan langganan yang telah kedaluwarsa...',
    );

    try {
      Log.info(
        'Menghubungi ActiveCustomerOperation untuk mengeksekusi batch pengarsipan otomatis...',
      );

      final archivedCount =
          await _activeCustomerOperation.archiveExpiredCustomers();

      if (archivedCount > 0) {
        Log.info(
          'Operasi berhasil! Sebanyak $archivedCount data pelanggan kedaluwarsa telah dipindahkan ke tabel arsip.',
        );
      } else {
        Log.info(
          'Hasil pengecekan bersih. Tidak ditemukan data pelanggan yang memenuhi kriteria kedaluwarsa saat ini.',
        );
      }

      Log.info(
        'Seluruh rangkaian proses pengecekan langganan kedaluwarsa telah diselesaikan dengan sukses.',
      );
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kesalahan fatal selama proses pengolahan data kedaluwarsa!',
        e: e,
        st: s,
      );
    }
  }
}
