// path: lib/shared/services/expired_subscription_check_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';

/// Service untuk memeriksa dan mengarsipkan langganan yang kadaluwarsa.
class ExpiredSubscriptionCheckService {
  final PelangganAktifOpSqlite _activeCustomerOperation;

  /// Konstruktor dengan injeksi dependensi.
  ExpiredSubscriptionCheckService({
    required PelangganAktifOpSqlite activeCustomerOperation,
  }) : _activeCustomerOperation = activeCustomerOperation {
    Log.info(
        'ExpiredSubscriptionCheckService diinisialisasi dengan dependency injection.');
  }

  /// Memproses semua pelanggan aktif, menemukan yang kedaluwarsa,
  /// dan mengarsipkannya.
  Future<void> processExpiredSubscriptions() async {
    Log.info('Memulai siklus pengecekan langganan yang kadaluwarsa...');
    try {
      final archivedCount =
          await _activeCustomerOperation.archiveExpiredCustomers();
      if (archivedCount > 0) {
        Log.info('Berhasil mengarsipkan $archivedCount langganan kadaluwarsa.');
      } else {
        Log.info('Tidak ada langganan kadaluwarsa.');
      }
    } on Exception catch (e, s) {
      Log.error('Gagal memproses langganan kadaluwarsa.', e: e, s: s);
    }
  }
}

// ============================================================
// Provider untuk ExpiredSubscriptionCheckService
// ============================================================
final expiredSubscriptionCheckServiceProvider =
    Provider<ExpiredSubscriptionCheckService>((ref) {
  return ExpiredSubscriptionCheckService(
    activeCustomerOperation: ref.read(activeCustomerOperationProvider),
  );
});
