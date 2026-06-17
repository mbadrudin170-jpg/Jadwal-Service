// path: lib/fitur/order/provider/order_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

part 'order_provider.g.dart';
part 'order_provider.freezed.dart';

@freezed
abstract class OrderState with _$OrderState {
  const factory OrderState({
    @Default([]) List<OrderModel> orders,
    @Default(0) int totalDaftar,
  }) = _OrderState;
}

@riverpod
class Order extends _$Order {
  @override
  FutureOr<OrderState> build() async {
    final daftarPesanan = await ref.watch(daftarPesananProvider.future);
    return OrderState(orders: daftarPesanan, totalDaftar: daftarPesanan.length);
  }
}

@riverpod
Future<List<OrderModel>> daftarPesanan(Ref ref) async {
  final appRole = ref.watch(appRoleProvider);
  if (appRole == AppRole.admin) {
    final orderOpSqlite = ref.watch(orderOpSqliteProvider);
    return await orderOpSqlite.ambilSemuaOrder();
  } else {
    final userId = ref.watch(userIdProvider).value;
    final orderOpFirebase = ref.watch(orderOpFirebaseProvider);
    if (userId != null) {
      return await orderOpFirebase.getAllByUserId(userId).first;
    }
  }
  return [];
}
