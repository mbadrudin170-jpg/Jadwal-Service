// path: lib/fitur/order/operasi/order_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/ui/user/order_page.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class OrderOpFirebase extends BaseOpFirebase {
  final BaseOpFirebase _baseOp;
  final FirebaseFirestore _firestore;
  final String _collectionName = TableNameValue.get(TableName.customerOrder);

  OrderOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  })  : _firestore = firestore,
        _baseOp = baseOp {
    Log.info('OrderOpFirebase diinisialisasi.');
  }

  /// 1. Menambahkan pesanan baru
  Future<void> addOrder(OrderModel order) async {
    Log.info('Menambahkan pesanan baru: ${order.id}');
    await _baseOp.insert(_collectionName, order.id, order.toFirebase());
  }

  /// 2. Memperbarui pesanan yang ada
  Future<void> updateOrder(OrderModel order) async {
    Log.info('Memperbarui pesanan: ${order.id}');
    await _baseOp.update(_collectionName, order.id, order.toFirebase());
  }

  /// 3. Menghapus pesanan (soft delete)
  Future<void> softDeleteOrder(String orderId) async {
    Log.info('Menghapus pesanan: $orderId');
    await softDelete(_collectionName, orderId);
  }

  /// 4. Mendapatkan stream semua pesanan

  Stream<List<OrderModel>> getAllOrdersStream() {
    Log.info('Mendapatkan stream semua pesanan');
    return _firestore
        .collection(_collectionName)
        .where(ColumnNames.isDeleted, isEqualTo: false)
        .orderBy(ColumnNames.updatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
            .toList())
        .handleError((e, StackTrace st) {
      Log.error(
        'Error mendapatkan stream pesanan',
        e: e,
        st: st,
      );
      return [];
    });
  }

  /// 5. Mendapatkan satu pesanan berdasarkan ID
  Future<OrderModel?> getOrderById(String orderId) async {
    Log.info('Mendapatkan pesanan by ID: $orderId');
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromFirebase(doc.id, doc.data()!);
      }
      return null;
    } catch (e, st) {
      Log.error(
        'Error mendapatkan pesanan by ID',
        e: e,
        st: st,
        data: {'orderId': orderId},
      );
      return null;
    }
  }

  /// Mendapatkan stream pesanan berdasarkan ID pengguna.
  Stream<List<OrderModel>> getAllByUserId(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .where(ColumnNames.customerId, isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
              .toList());
    } catch (e, st) {
      Log.error(
        'Error mendapatkan stream pesanan by User ID',
        e: e,
        st: st,
        data: {'userId': userId},
      );
      return Stream.value([]);
    }
  }

  /// 6. Mendapatkan stream pesanan berdasarkan status
  Stream<List<OrderModel>> getStreamByStatus(StatusOrderEnum status) {
    return _firestore
        .collection(_collectionName)
        .where(ColumnNames.status, isEqualTo: status.name)
        .where(ColumnNames.isDeleted, isEqualTo: false)
        .orderBy(ColumnNames.updatedAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
            .toList())
        .handleError((e, StackTrace st) {
      Log.error(
        'Error mendapatkan stream pesanan berdasarkan status',
        e: e,
        st: st,
        data: {'status': status.name},
      );
      return [];
    });
  }

  /// 7. Mendapatkan list pesanan berdasarkan status (satu kali panggil)
  Future<List<OrderModel>> getOrdersByStatus(StatusOrderEnum status) async {
    Log.info('Mendapatkan pesanan sekali panggil by status: ${status.name}');
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where(ColumnNames.status, isEqualTo: status.name)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .orderBy(ColumnNames.updatedAt, descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } catch (e, st) {
      Log.error(
        'Error mendapatkan list pesanan by status',
        e: e,
        st: st,
        data: {'status': status.name},
      );
      return [];
    }
  }

  /// 8. Menghitung jumlah pesanan berdasarkan status

  Future<int> countOrdersByStatus(StatusOrderEnum status) async {
    Log.info('Menghitung pesanan by status: ${status.name}');
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where(ColumnNames.status, isEqualTo: status.name)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .count() // Menggunakan count() untuk efisiensi
          .get();
      return snapshot.count ?? 0;
    } catch (e, st) {
      Log.error(
        'Error menghitung pesanan by status',
        e: e,
        st: st,
        data: {'status': status.name},
      );
      return 0;
    }
  }
}
