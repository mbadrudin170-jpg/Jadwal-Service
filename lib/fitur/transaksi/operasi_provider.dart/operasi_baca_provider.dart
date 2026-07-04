// path: lib/fitur/transaksi/operasi_provider.dart/operasi_baca_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/shared/debug/log.dart';

part 'operasi_baca_provider.g.dart';
part 'operasi_baca_provider.freezed.dart';

@freezed
abstract class OperasiBacaState with _$OperasiBacaState {
  const factory OperasiBacaState({
    @Default(0.0) double totalPemasukan,
    @Default(0.0) double totalPengeluaran,
    @Default(0.0) double total,
  }) = _OperasiBacaState;
}

@riverpod
class OperasiBacaProvider extends _$OperasiBacaProvider {
  @override
  FutureOr<OperasiBacaState> build() {
    return _loadData();
  }

  Future<OperasiBacaState> _loadData() async {
    try {
      final transaksi = ref.watch(transaksiProvider);
      final data = transaksi.value;
      return OperasiBacaState(
        totalPemasukan: data?.totalPemasukan ?? 0,
        totalPengeluaran: data?.totalPengeluaran ?? 0,
        total: data?.total ?? 0,
      );
    } on Exception catch (e, s) {
      Log.error('Error di Load_loadData(: $e', e: e, s: s);
      rethrow;
    }
  }
}
