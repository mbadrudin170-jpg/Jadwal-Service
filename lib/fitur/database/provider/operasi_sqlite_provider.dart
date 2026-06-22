// path: lib/fitur/database/provider/operasi_sqlite_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_op_sqlite.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/kategori/operasi/sub_kategori_op_sqlite.dart';
import 'package:wifi/fitur/order/operasi/order_op_sqlite.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/fitur/versi_apk/operasi/versi_apk_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/pembersihan_data_operasi.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'operasi_sqlite_provider.g.dart';

/// Provider untuk menyediakan instance dari [PaketOpSqlite].
@Riverpod(keepAlive: true)
PaketOpSqlite paketOpSqlite(Ref ref) {
  Log.info('Membuat instance PackageOperation via @riverpod...');

  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return PaketOpSqlite(sqliteDb: sqliteDb, basOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [TransaksiOpSqlite].
@Riverpod(keepAlive: true)
TransaksiOpSqlite transaksiOpSqlite(Ref ref) {
  Log.info('Membuat instance TransactionOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return TransaksiOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [PelangganOpSqlite].
@Riverpod(keepAlive: true)
PelangganOpSqlite pelangganOpSqlite(Ref ref) {
  Log.info('Membuat instance CustomerOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return PelangganOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [PelangganAktifOpSqlite].
@Riverpod(keepAlive: true)
PelangganAktifOpSqlite pelangganAktifOpSqlite(Ref ref) {
  Log.info('Membuat instance ActiveCustomerOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);
  final pelangganOpSqlite = ref.watch(pelangganOpSqliteProvider);
  final layananNotifikasi = ref.watch(layananNotifikasiProvider);
final transaksiOpSqlite=ref.watch(transaksiOpSqliteProvider);
  return PelangganAktifOpSqlite(
    sqliteDb: sqliteDb,
    baseOpSqlite: baseOpSqlite,
    pelangganOpSqlite: pelangganOpSqlite,
    layananNotifikasi: layananNotifikasi,
    transaksiOpSqlite: transaksiOpSqlite,
  );
}

/// Provider untuk menyediakan instance dari [VersiApkOpSqlite].
@Riverpod(keepAlive: true)
VersiApkOpSqlite versiApkOpSqlite(Ref ref) {
  Log.info('Membuat instance ApkVersionOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return VersiApkOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [KategoriOpSqlite].
@Riverpod(keepAlive: true)
KategoriOpSqlite kategoriOpSqlite(Ref ref) {
  Log.info('Membuat instance CategoryOperation via @riverpod...');
  final sqlitedb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return KategoriOpSqlite(sqlitedb: sqlitedb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [PembersihanDataOperasi].
@Riverpod(keepAlive: true)
PembersihanDataOperasi pembersihanDataOperasi(Ref ref) {
  Log.info('Membuat instance DataCleaningOperation via @riverpod...');
  return PembersihanDataOperasi();
}

/// Provider untuk menyediakan instance dari [FeedbackOpSqlite].
@Riverpod(keepAlive: true)
FeedbackOpSqlite feedbackOpSqlite(Ref ref) {
  Log.info('Membuat instance FeedbackOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return FeedbackOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

@Riverpod(keepAlive: true)
OrderOpsqlite orderOpSqlite(Ref ref) {
  Log.info('Membuat instance OrderOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);
  return OrderOpsqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [SettingsOpSqlite].
@Riverpod(keepAlive: true)
SettingsOpSqlite settingsOpSqlite(Ref ref) {
  Log.info('Membuat instance SettingsOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return SettingsOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [SubKategoriOpSqlite].
@Riverpod(keepAlive: true)
SubKategoriOpSqlite subKategoriOpSqlite(Ref ref) {
  Log.info('Membuat instance SubCategoryOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return SubKategoriOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}

/// Provider untuk menyediakan instance dari [DompetOpSqlite].
@Riverpod(keepAlive: true)
DompetOpSqlite dompetOpSqlite(Ref ref) {
  Log.info('Membuat instance WalletOperation via @riverpod...');
  final sqliteDb = ref.watch(sqliteDatabaseProvider);
  final baseOpSqlite = ref.watch(baseOpSqliteProvider);

  return DompetOpSqlite(sqliteDb: sqliteDb, baseOpSqlite: baseOpSqlite);
}
