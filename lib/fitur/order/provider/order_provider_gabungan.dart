// path: lib/fitur/order/provider/order_provider_gabungan.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

part 'order_provider_gabungan.g.dart';

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
