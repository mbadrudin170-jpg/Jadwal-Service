// path lib/fitur/voucher/voucher_provider.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/fitur/voucher/operasi/voucher_op_firebase.dart';
import 'package:wifi/shared/debug/log.dart';

part 'voucher_provider.g.dart';
part 'voucher_provider.freezed.dart';

@freezed
abstract class VoucherState with _$VoucherState {
  const factory VoucherState({required List<VoucherModel> voucher}) =
      _VoucherState;
}

@riverpod
class Voucher extends _$Voucher {
  @override
  FutureOr<VoucherState> build() async {
    return _loadData();
  }

  Future<VoucherState> _loadData() async {
    try {
      final voucher = ref.read(voucherOpFirebaseProvider);
      final daftar = await voucher.ambilSemua();
      return VoucherState(voucher: daftar);
    } on Exception catch (e, s) {
      Log.error('Error di loadData: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambah(VoucherModel voucherBaru) async {
    try {
      final tersimpan = await ref
          .read(voucherOpFirebaseProvider)
          .tambah(voucher: voucherBaru);
      final currentState = state.value;
      if (currentState == null) {
        state = await AsyncValue.guard(_loadData);
        return;
      }
      final updatedList = [...currentState.voucher, tersimpan];
      state = AsyncData(currentState.copyWith(voucher: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      await _loadData();
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_loadData);
  }
}
