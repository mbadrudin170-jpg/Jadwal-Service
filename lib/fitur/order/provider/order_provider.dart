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

@Riverpod(keepAlive: true)
class Order extends _$Order {
  @override
  FutureOr<OrderState> build() async {
    Log.info('build orderProvider');
    return _loadData();
  }

  Future<OrderState> _loadData() async {
    try {
      Log.info('Fungsi _loadData di jalankan');
      final daftarOrder = await ref.read(orderOpGlobalProvider).ambilSemua();
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
      await ref.read(orderOpGlobalProvider).tambah(order);
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

  void invalidateOrderProvider() {
    ref.invalidateSelf();
  }
}

// @riverpod
// Future<List<OrderModel>> daftarPesanan(Ref ref) async {
//   if (RoleUtil.isAdmin(ref)) {
//     final orderOpSqlite = ref.read(orderOpSqliteProvider);
//     return await orderOpSqlite.ambilSemua();
//   } else {
//     final userId = await ref.watch(userIdProvider.future);
//     final orderOpFirebase = ref.read(orderOpFirebaseProvider);
//     if (userId != null) {
//       return await orderOpFirebase.ambilBerdasarkanIdPelanggan(userId).first;
//     }
//   }
//   return [];
// }

// @riverpod
// Future<List<OrderModel>> daftar(Ref ref, String id) async {
//   try {
//     final order = await ref.watch(orderProvider.future);
//     final daftarO = order.daftarOrder;
//     return daftarO.where((o) => o.idPelanggan == id).toList();
//   } on Exception catch (e, s) {
//     Log.error('Error didaftar: $e', e: e, s: s);
//     rethrow;
//   }
// }
