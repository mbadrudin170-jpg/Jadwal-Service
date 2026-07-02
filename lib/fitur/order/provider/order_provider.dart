// path: lib/fitur/order/provider/order_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_global.dart';
import 'package:wifi/shared/debug/log.dart';

part 'order_provider.g.dart';
part 'order_provider.freezed.dart';

@freezed
abstract class OrderState with _$OrderState {
  const factory OrderState({
    @Default([]) List<OrderModel> daftarOrder,
    @Default(0) int totalDaftar,
  }) = _OrderState;
}

@riverpod
class Order extends _$Order {
  OrderOpGlobal get _orderOp => ref.read(orderOpGlobalProvider);

  @override
  FutureOr<OrderState> build() async {
    Log.info('build orderProvider');
    return _loadData();
  }

  Future<OrderState> _loadData() async {
    try {
      Log.info('Fungsi _loadData di jalankan');
      final daftarOrder = await _orderOp.ambilSemua();
      return OrderState(
        daftarOrder: daftarOrder,
        totalDaftar: daftarOrder.length,
      );
    } on Exception catch (e, s) {
      Log.error('Error di _loadData: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambah(OrderModel order) async {
    try {
      await _orderOp.tambah(order);
      await refresh();
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      await refresh();
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilBerdasarkanIdPelanggan(String id) async {
    try {
      List<OrderModel> daftarBaru = [];
      final daftar = state.asData?.value.daftarOrder;
      if (daftar != null) {
        daftarBaru = daftar.where((o) => o.idPelanggan == id).toList();
      }
      return daftarBaru;
    } on Exception catch (e, s) {
      Log.error('Error diambilBerdasarkanIdPelanggan: $e', e: e, s: s);
      return [];
    }
  }

  Future<void> refresh() async {
    try {
      state = await AsyncValue.guard(_loadData);
    } on Exception catch (e, s) {
      Log.error('Error direfresh: $e', e: e, s: s);
      rethrow;
    }
  }

  void invalidate() {
    ref.invalidateSelf();
  }
}
