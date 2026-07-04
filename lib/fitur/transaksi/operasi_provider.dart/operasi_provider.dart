// path: lib/fitur/transaksi/operasi_provider.dart/operasi_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

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
  TransaksiOpGlobal get _transaksiOp => ref.read(transaksiOpGlobalProvider);
  @override
  FutureOr<TransaksiTesState> build() async {
    final transaksi = await ref.read(transaksiOpGlobalProvider).ambilSemua();
    return TransaksiTesState(transaksi: transaksi);
  }

  Future<void> tambah(TransaksiModel transaksi) async {
    try {
      await _transaksiOp.tambahTransaksi(transaksi);
      final currentData = state.requireValue;
      state = AsyncData(
        currentData.copyWith(transaksi: [...currentData.transaksi, transaksi]),
      );
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }
}
