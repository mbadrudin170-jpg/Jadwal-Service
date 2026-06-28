// path lib/fitur/order/operasi/order_op_global.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/order/operasi/order_op_sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class OrderOpGlobal {
  final Ref ref;

  OrderOpGlobal({required this.ref});

  OrderOpSqlite get _orderOpSqlite => ref.read(orderOpSqliteProvider);
  OrderOpFirebase get _orderOpFirebase => ref.read(orderOpFirebaseProvider);

  Future<void> tambah(OrderModel order) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.tambahOrder(order);
      }else{
        await _orderOpFirebase.tambahOrder(order);
      }
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }
}
