// path: lib/admin/providers/subscription_detail_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';

part 'subscription_detail_provider.g.dart';

// Model khusus untuk menampung data gabungan yang siap pakai di UI
class SubscriptionDetailState {
  final TransactionModel transaction;
  final CustomerModel? customer;
  final PackageModel? package;

  SubscriptionDetailState({
    required this.transaction,
    this.customer,
    this.package,
  });
}

@riverpod
Future<SubscriptionDetailState?> getSubscriptionDetail(
  Ref ref,
  String transactionId,
) async {
  // Ambil semua operation repo
  final txOp = ref.watch(transactionOperationProvider);
  final custOp = ref.watch(customerOperationProvider);
  final pkgOp = ref.watch(packageOperationProvider);

  // 1. Ambil data transaksi utama
  final transaction = await txOp.getTransactionById(transactionId);
  if (transaction == null) return null;

  // 2. Ambil data relasi secara paralel untuk menghemat waktu pemuatan
  final results = await Future.wait([
    transaction.customerId != null
        ? custOp.getById(transaction.customerId!)
        : Future.value(),
    transaction.packageId != null
        ? pkgOp.getById(transaction.packageId!)
        : Future.value(),
  ]);

  return SubscriptionDetailState(
    transaction: transaction,
    customer: results[0] as CustomerModel?,
    package: results[1] as PackageModel?,
  );
}
