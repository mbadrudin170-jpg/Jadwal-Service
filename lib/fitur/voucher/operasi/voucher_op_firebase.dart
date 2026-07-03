// lib/fitur/voucher/operasi/voucher_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/shared/debug/log.dart';

class VoucherOpFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _koleksiVoucher = 'voucher'; // ganti sesuai nama koleksimu

  /// Mengambil semua dokumen voucher dari Firestore.
  /// Perhatian: jika data sangat banyak, pertimbangkan pagination.
  Future<List<VoucherModel>> ambilSemua() async {
    try {
      final snapshot = await _firestore.collection(_koleksiVoucher).get();
      final vouchers = snapshot.docs.map((doc) {
        return VoucherModel.fromFirebase(doc.id, doc.data());
      }).toList();
      return vouchers;
    } on Exception catch (e, s) {
      Log.error('Error di ambilSemua: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<VoucherModel> tambah({required VoucherModel voucher}) async {
    try {
      final data = voucher.toFirebase();
      final docRef = await _firestore.collection(_koleksiVoucher).add(data);
      return voucher.copyWith(id: docRef.id);
    } on Exception catch (e, s) {
      Log.error('Error di tambah: $e', e: e, s: s);
      rethrow;
    }
  }
}

final voucherOpFirebaseProvider = Provider<VoucherOpFirebase>((ref) {
  return VoucherOpFirebase();
});
