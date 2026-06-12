// path: lib/fitur/database/provider/operasi_sqlite_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/feedback/operasi/feedback_operation.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/apk_version_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/data_cleaning_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_Op_Sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/sub_category_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

part 'operasi_sqlite_provider.g.dart';

/// Provider untuk menyediakan instance dari [PaketOpSqlite].
@Riverpod(keepAlive: true)
PaketOpSqlite packageOperation(Ref ref) {
  Log.info('Membuat instance PackageOperation via @riverpod...');

  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return PaketOpSqlite(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [TransactionOperation].
@Riverpod(keepAlive: true)
TransactionOperation transactionOperation(Ref ref) {
  Log.info('Membuat instance TransactionOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return TransactionOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [CustomerOperation].
@Riverpod(keepAlive: true)
CustomerOperation customerOperation(Ref ref) {
  Log.info('Membuat instance CustomerOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return CustomerOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [ActiveCustomerOperation].
@Riverpod(keepAlive: true)
ActiveCustomerOperation activeCustomerOperation(Ref ref) {
  Log.info('Membuat instance ActiveCustomerOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);
  final customerOperation = ref.watch(customerOperationProvider);
  final notifikasiServis = ref.watch(notifikasiServisProvider);

  return ActiveCustomerOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
    customerOperation: customerOperation,
    notifikasiServis: notifikasiServis,
  );
}

/// Provider untuk menyediakan instance dari [ApkVersionOperation].
@Riverpod(keepAlive: true)
ApkVersionOperation apkVersionOperation(Ref ref) {
  Log.info('Membuat instance ApkVersionOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return ApkVersionOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [CategoryOperation].
@Riverpod(keepAlive: true)
CategoryOperation categoryOperation(Ref ref) {
  Log.info('Membuat instance CategoryOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return CategoryOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
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
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return FeedbackOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

@Riverpod(keepAlive: true)
OrderOperation orderOperation(Ref ref) {
  Log.info('Membuat instance OrderOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);
  return OrderOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [SettingsOperation].
@Riverpod(keepAlive: true)
SettingsOperation settingsOperation(Ref ref) {
  Log.info('Membuat instance SettingsOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return SettingsOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [SubCategoryOperation].
@Riverpod(keepAlive: true)
SubCategoryOperation subCategoryOperation(Ref ref) {
  Log.info('Membuat instance SubCategoryOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return SubCategoryOperation(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}

/// Provider untuk menyediakan instance dari [DompetOpSqlite].
@Riverpod(keepAlive: true)
DompetOpSqlite walletOperation(Ref ref) {
  Log.info('Membuat instance WalletOperation via @riverpod...');
  final dbHelper = ref.watch(sqliteDatabaseProvider);
  final baseOperation = ref.watch(baseOperationProvider);

  return DompetOpSqlite(
    dbHelper: dbHelper,
    baseOperation: baseOperation,
  );
}
