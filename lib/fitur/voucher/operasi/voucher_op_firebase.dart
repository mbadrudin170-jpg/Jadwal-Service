// lib/fitur/voucher/operasi/voucher_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';

class VoucherOpFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _koleksiVoucher = 'voucher'; // ganti sesuai nama koleksimu

  /// Mengambil semua dokumen voucher dari Firestore.
  /// Perhatian: jika data sangat banyak, pertimbangkan pagination.
  Future<List<VoucherModel>> ambilSemua({
    bool tampilkanYangDiarsip = false,
  }) async {
    try {
      final snapshot =
          await (tampilkanYangDiarsip
                  ? _firestore.collection(_koleksiVoucher)
                  : _firestore
                        .collection(_koleksiVoucher)
                        .where(NamaKolom.dihapus, isEqualTo: false))
              .get();
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
      await _firestore.collection(_koleksiVoucher).doc(voucher.id).set(data);
      return voucher.copyWith(id: voucher.id);
    } on Exception catch (e, s) {
      Log.error('Error di tambah: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<VoucherModel> perbarui({required VoucherModel voucher}) async {
    try {
      final data = voucher.toFirebase();
      await _firestore.collection(_koleksiVoucher).doc(voucher.id).update(data);
      return voucher;
    } on Exception catch (e, s) {
      Log.error('Error di perbarui: $e', e: e, s: s);
      rethrow;
    }
  }

  Future<void> hapus(String idVoucher) async {
    try {
      await _firestore.collection(_koleksiVoucher).doc(idVoucher).update({
        NamaKolom.dihapus: true,
        NamaKolom.diarsipkanPada: Timestamp.fromDate(DateTime.now()),
      });
    } on Exception catch (e, s) {
      Log.error('Error di hapus: $e', e: e, s: s);
      rethrow;
    }
  }
}

final voucherOpFirebaseProvider = Provider<VoucherOpFirebase>((ref) {
  return VoucherOpFirebase();
});
