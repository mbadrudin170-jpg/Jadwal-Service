// path: lib/fitur/database/provider/operasi_sqlite_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_operation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/kategori_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'operasi_sqlite_provider.g.dart';

/// Provider untuk menyediakan instance dari [PaketOpSqlite].
@Riverpod(keepAlive: true)
PaketOpSqlite paketOpSqlite(Ref ref) {
  Log.info('Membuat instance PackageOperation via @riverpod...');

  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return PaketOpSqlite(
    sqliteDb: sqliteDb,
    basOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [TransaksiOpsqlite].
@Riverpod(keepAlive: true)
TransaksiOpsqlite transaksiOpSqlite(Ref ref) {
  Log.info('Membuat instance TransactionOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return TransaksiOpsqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [PelangganOpSqlite].
@Riverpod(keepAlive: true)
PelangganOpSqlite pelangganOpSqlite(Ref ref) {
  Log.info('Membuat instance CustomerOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return PelangganOpSqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [PelangganAktifOpSqlite].
@Riverpod(keepAlive: true)
PelangganAktifOpSqlite pelangganAktifOpSqlite(Ref ref) {
  Log.info('Membuat instance ActiveCustomerOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);
  final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
  final layananNotifikasi = ref.watch(layananNotifikasiProvider);

  return PelangganAktifOpSqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
    pelangganOpSqlite: pelangganOpSqlite,
    layananNotifikasi: layananNotifikasi,
  );
}

/// Provider untuk menyediakan instance dari [ApkVersionOperation].
@Riverpod(keepAlive: true)
ApkVersionOperation apkVersionOperation(Ref ref) {
  Log.info('Membuat instance ApkVersionOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return ApkVersionOperation(
    dbHelper: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [KategoriOpSqlite].
@Riverpod(keepAlive: true)
KategoriOpSqlite kategoriOpSqlite(Ref ref) {
  Log.info('Membuat instance CategoryOperation via @riverpod...');
  final sqlitedb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return KategoriOpSqlite(
    sqlitedb: sqlitedb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [DataCleaningOperation].
@Riverpod(keepAlive: true)
DataCleaningOperation dataCleaningOperation(Ref ref) {
  Log.info('Membuat instance DataCleaningOperation via @riverpod...');
  return DataCleaningOperation();
}

/// Provider untuk menyediakan instance dari [FeedbackOperation].
@Riverpod(keepAlive: true)
FeedbackOperation feedbackOperation(Ref ref) {
  Log.info('Membuat instance FeedbackOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return FeedbackOperation(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

@Riverpod(keepAlive: true)
OrderOpsqlite orderOperation(Ref ref) {
  Log.info('Membuat instance OrderOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);
  return OrderOpsqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [SettingsOpSqlite].
@Riverpod(keepAlive: true)
SettingsOpSqlite settingsOpSqlite(Ref ref) {
  Log.info('Membuat instance SettingsOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return SettingsOpSqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [SubKategoriOpSqlite].
@Riverpod(keepAlive: true)
SubKategoriOpSqlite subKategoriOpSqlite(Ref ref) {
  Log.info('Membuat instance SubCategoryOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return SubKategoriOpSqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [DompetOpSqlite].
@Riverpod(keepAlive: true)
DompetOpSqlite dompetOpSqlite(Ref ref) {
  Log.info('Membuat instance WalletOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return DompetOpSqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
  );
}
