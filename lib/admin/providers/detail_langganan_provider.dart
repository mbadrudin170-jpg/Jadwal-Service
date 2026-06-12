// path: lib/admin/providers/detail_langganan_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';

part 'detail_langganan_provider.g.dart';
part 'detail_langganan_provider.freezed.dart';

@freezed
abstract class DetailLanggananState with _$DetailLanggananState {
  const factory DetailLanggananState({
    TransactionModel? transaction,
    CustomerModel? customer,
    PackageModel? package,
  }) = _DetailLanggananState;
}

@riverpod
Future<DetailLanggananState?> ambilDetailLangganan(
  Ref ref,
  String idTransaksi,
) async {
  // Ambil semua operation repo
  final opTransaksi = ref.watch(transactionOperationProvider);
  final opPelanggan = ref.watch(customerOperationProvider);
  final opPaket = ref.watch(packageOperationProvider);

  // 1. Ambil data transaksi utama
  final transaksi = await opTransaksi.getTransactionById(idTransaksi);
  if (transaksi == null) return null;

  // 2. Ambil data relasi secara paralel untuk menghemat waktu pemuatan
  final hasil = await Future.wait([
    transaksi.customerId != null
        ? opPelanggan.getById(transaksi.customerId!)
        : Future<CustomerModel?>.value(),
    transaksi.packageId != null
        ? opPaket.getById(transaksi.packageId!)
        : Future<PackageModel?>.value(),
  ]);

  return DetailLanggananState(
    transaction: transaksi,
    customer: hasil[0] as CustomerModel?,
    package: hasil[1] as PackageModel?,
  );
}
