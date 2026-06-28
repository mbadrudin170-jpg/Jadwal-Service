// path: lib/fitur/order/operasi/order_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class OrderOpFirebase {
  final BaseOpFirebase _baseOp;
  final FirebaseFirestore _firestore;
  final String _namaKoleksi = NamaTabel.pesananPelanggan;

  OrderOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  }) : _firestore = firestore,
       _baseOp = baseOp {
    Log.info('OrderOpFirebase diinisialisasi.');
  }

  /// 1. Menambahkan pesanan baru
  Future<void> tambahOrder(OrderModel order) async {
    Log.info('Menambahkan pesanan baru: ${order.id}');
    await _baseOp.sisipkan(_namaKoleksi, order.id, order.toFirebase());
  }

  /// 2. Memperbarui pesanan yang ada
  Future<void> updateOrder(OrderModel order) async {
    Log.info('Memperbarui pesanan: ${order.id}');
    await _baseOp.update(_namaKoleksi, order.id, order.toFirebase());
  }

  /// 3. Menghapus pesanan (soft delete)
  Future<void> softDeleteOrder(String orderId) async {
    Log.info('Menghapus pesanan: $orderId');
    await _baseOp.softDelete(_namaKoleksi, orderId);
  }

  /// 4. Mendapatkan stream semua pesanan

  Stream<List<OrderModel>> getAllOrdersStream() {
    Log.info('Mendapatkan stream semua pesanan');
    return _firestore
        .collection(_namaKoleksi)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .orderBy(NamaKolom.diperbaruiPada, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
              .toList(),
        )
        .handleError((Object e, StackTrace st) {
          Log.error('Error mendapatkan stream pesanan', e: e, s: st);
          return <OrderModel>[];
        });
  }

  /// 5. Mendapatkan satu pesanan berdasarkan ID
  Future<OrderModel?> ambilBerdasarkanId(String id) async {
    Log.info('Mendapatkan pesanan by ID: $id');
    try {
      final doc = await _firestore.collection(_namaKoleksi).doc(id).get();
      if (doc.exists) {
        return OrderModel.fromFirebase(doc.id, doc.data()!);
      }
      return null;
    } catch (e, st) {
      Log.error(
        'Error mendapatkan pesanan by ID',
        e: e,
        s: st,
        data: {'orderId': id},
      );
      return null;
    }
  }

  /// Mendapatkan stream pesanan berdasarkan ID pengguna.
  Stream<List<OrderModel>> ambilBerdasarkanIdPelanggan(String idPelanggan) {
    try {
      return _firestore
          .collection(_namaKoleksi)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
                .toList(),
          );
    } catch (e, st) {
      Log.error(
        'Error mendapatkan stream pesanan by User ID',
        e: e,
        s: st,
        data: {'idPelanggan': idPelanggan},
      );
      return Stream.value([]);
    }
  }

  /// 6. Mendapatkan stream pesanan berdasarkan status
  Stream<List<OrderModel>> ambilStreamBerdasarkanStatus(
    StatusOrderEnum status,
  ) {
    return _firestore
        .collection(_namaKoleksi)
        .where(NamaKolom.status, isEqualTo: status.name)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .orderBy(NamaKolom.diperbaruiPada, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
              .toList(),
        )
        .handleError((Object e, StackTrace st) {
          Log.error(
            'Error mendapatkan stream pesanan berdasarkan status',
            e: e,
            s: st,
            data: {'status': status.name},
          );
          return <OrderModel>[];
        });
  }

  /// 7. Mendapatkan list pesanan berdasarkan status (satu kali panggil)
  Future<List<OrderModel>> getOrdersByStatus(StatusOrderEnum status) async {
    Log.info('Mendapatkan pesanan sekali panggil by status: ${status.name}');
    try {
      final snapshot = await _firestore
          .collection(_namaKoleksi)
          .where(NamaKolom.status, isEqualTo: status.name)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.diperbaruiPada, descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } catch (e, st) {
      Log.error(
        'Error mendapatkan list pesanan by status',
        e: e,
        s: st,
        data: {'status': status.name},
      );
      return [];
    }
  }

  /// 8. Menghitung jumlah pesanan berdasarkan status untuk pengguna tertentu
  Future<int> countOrdersByStatus(StatusOrderEnum status, String userId) async {
    Log.info(
      'Menghitung pesanan by status: ${status.name} untuk user: $userId',
    );
    try {
      Query query = _firestore
          .collection(_namaKoleksi)
          .where(NamaKolom.status, isEqualTo: status.name)
          .where(NamaKolom.dihapus, isEqualTo: false);

      // Jika userId disediakan (bukan admin), filter berdasarkan customerId
      if (userId.isNotEmpty) {
        query = query.where(NamaKolom.idPelanggan, isEqualTo: userId);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;
      Log.info(
        'Berhasil menghitung $count pesanan dengan status ${status.name}',
        {'status': status.name, 'userId': userId, 'jumlah': count},
      );
      return count;
    } catch (e, st) {
      Log.error(
        'Error menghitung pesanan by status',
        e: e,
        s: st,
        data: {'status': status.name, 'userId': userId},
      );
      return 0;
    }
  }
}
