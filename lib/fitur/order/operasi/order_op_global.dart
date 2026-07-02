// path lib/fitur/order/operasi/order_op_global.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/order/operasi/order_op_sqlite.dart';
import 'package:wifi/fitur/order/provider/order_provider.dart';
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
      } else {
        await _orderOpFirebase.tambahOrder(order);
      }
    } on Exception catch (e, s) {
      Log.error('Error ditambah: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }

  Future<void> perbarui(OrderModel order) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.perbarui(order);
      } else {
        await _orderOpFirebase.perbarui(order);
      }
    } on Exception catch (e, s) {
      Log.error('Error diperbarui: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }

  Future<void> softDelete(String id) async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.softDeleteorder(id);
      } else {
        await _orderOpFirebase.softDeleteOrder(id);
      }
    } on Exception catch (e, s) {
      Log.error('Error di softDelete: $e', e: e, s: s);
      // Error handling opsional
      rethrow;
    }
  }

  Future<void> softDeleteAll() async {
    try {
      if (RoleUtil.isAdmin(ref)) {
        await _orderOpSqlite.softDeleteAll();
      } else {
        await _orderOpFirebase.softDeleteAll();
      }
      unawaited(ref.read(orderProvider.notifier).refresh());
    } on Exception catch (e, s) {
      Log.error('Error di softDeleteAll: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<List<OrderModel>> ambilSemua() async {
    try {
      Log.info('fungsi ambil semua dijalankan');
      if (RoleUtil.isAdmin(ref)) {
        return await _orderOpSqlite.ambilSemua();
      } else {
        return await _orderOpFirebase.ambilSemua();
      }
    } on Exception catch (e, s) {
      Log.error('Error diambilSemua: $e', e: e, s: s);
      rethrow;
    }
  }
}

final orderOpGlobalProvider = Provider<OrderOpGlobal>((ref) {
  return OrderOpGlobal(ref: ref);
});
