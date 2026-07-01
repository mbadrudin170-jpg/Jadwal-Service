// path: lib/fitur/order/provider/order_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/user/providers/user_provider.dart';

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
  @override
  FutureOr<OrderState> build() async {
    return _loadData();
  }

  Future<OrderState> _loadData() async {
    try {
      final daftarPesanan = await ref.watch(daftarPesananProvider.future);
      return OrderState(
        daftarOrder: daftarPesanan,
        totalDaftar: daftarPesanan.length,
      );
    } on Exception catch (e, s) {
      Log.error('Error di _loadData: $e', e: e, s: s);
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

  void invalidateOrderProvider() {
    ref.invalidate(daftarPesananProvider);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<OrderModel>> daftarPesanan(Ref ref) async {
  if (RoleUtil.isAdmin(ref)) {
    final orderOpSqlite = ref.read(orderOpSqliteProvider);
    return await orderOpSqlite.ambilSemua();
  } else {
    final userId = await ref.watch(userIdProvider.future);
    final orderOpFirebase = ref.read(orderOpFirebaseProvider);
    if (userId != null) {
      return await orderOpFirebase.ambilBerdasarkanIdPelanggan(userId).first;
    }
  }
  return [];
}
