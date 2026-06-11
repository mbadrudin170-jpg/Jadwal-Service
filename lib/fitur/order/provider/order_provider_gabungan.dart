// path: lib/fitur/order/provider/order_provider_gabungan.dart

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

part 'order_provider_gabungan.g.dart';
part 'order_provider_gabungan.freezed.dart';

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
  FutureOr<OrderState> build(Ref ref) async {
    final orderOpFirebase = ref.watch(orderOpFirebaseProvider);
    final orderOperation = ref.watch(orderOperationProvider);
   final orders= await listOrder(ref);
    return OrderState(orders: orders,totalDaftar: );
  }
}

Future<void> sumberData(Ref ref) {
  final appRole = ref.watch(appRoleProvider);
  if (appRole == AppRole.admin) {
    final orderOpFirebase = ref.watch(orderOpFirebaseProvider);
  } else {
    final orderOperation = ref.watch(orderOperationProvider);
  }
  return Future.value();
}

@riverpod
Future<void> listOrder(Ref ref) async {
  final appRole = ref.watch(appRoleProvider);
  if (appRole == AppRole.admin) {
    final orderOpSqlite = ref.watch(orderOperationProvider);
    await orderOpSqlite.getAllOrders();
  } else {
    final userIdAsync = ref.watch(userIdProvider);
    final userId = userIdAsync.value;
    final orderOpFirebase = ref.watch(orderOpFirebaseProvider);
    if (userId != null) {
      orderOpFirebase.getAllByUserId(userId);
    }
  }
  return Future.value();
}
