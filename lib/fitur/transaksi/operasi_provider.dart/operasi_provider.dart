// path: lib/fitur/transaksi/operasi_provider.dart/operasi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';

part 'operasi_provider.freezed.dart';
part 'operasi_provider.g.dart';

@freezed
abstract class TransaksiTesState with _$TransaksiTesState {
  const factory TransaksiTesState({
    @Default([]) List<TransaksiModel> transaksi,
  }) = _TransaksiTesState;
}

@riverpod
class OperasiProvider extends _$OperasiProvider {
  @override
  FutureOr<TransaksiTesState> build() async {
    final transaksi = await ref.read(transaksiOpGlobalProvider).ambilSemua();
    return TransaksiTesState(transaksi: transaksi);
  }
}
