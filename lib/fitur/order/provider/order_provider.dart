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
  const OrderState._();
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
    final daftarOrder = await _orderOp.ambilSemua();
    Log.info('Mengambil data dari database');
    return OrderState(
      daftarOrder: daftarOrder,
      totalDaftar: daftarOrder.length,
    );
  }

  Future<OrderState> _loadData() async {
    try {
      Log.info('Fungsi _loadData di jalankan');
      final daftarOrder = await _orderOp.ambilSemua();
      Log.info('Mengambil data dari database');
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
      if (!state.hasValue) return;
      await _orderOp.tambah(order);
      final currentData = state.requireValue;
      state = AsyncData(
        currentData.copyWith(daftarOrder: [...currentData.daftarOrder, order]),
      );
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> perbarui(OrderModel order) async {
    try {
      if (!state.hasValue) return;
      await _orderOp.perbarui(order);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarOrder.map((t) {
        return t.id == order.id ? order : t;
      }).toList();
      state = AsyncData(currentData.copyWith(daftarOrder: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> softDelete(String idOrder) async {
    try {
      if (!state.hasValue) return;
      await _orderOp.softDelete(idOrder);
      final currentData = state.requireValue;
      final updatedList = currentData.daftarOrder
          .where((t) => t.id != idOrder)
          .toList();
      state = AsyncData(currentData.copyWith(daftarOrder: updatedList));
    } on Exception catch (e, s) {
      Log.error('Error hapus: $e', e: e, s: s);
      rethrow;
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
