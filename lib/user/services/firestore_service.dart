// path: lib/user/services/firestore_service.dart
// diubah: Memperbaiki pemanggilan agar menggunakan fromFirebase untuk TransaksiModel.
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<PelangganModel?> ambilPelangganStream(String userId) {
    return _db.collection('pelanggan').doc(userId).snapshots().map((snapshot) =>
        snapshot.exists
            ? PelangganModel.fromFirebase(snapshot.id, snapshot.data()!)
            : null);
  }

  Future<PelangganModel?> ambilPelangganSekali(String userId) async {
    final doc = await _db.collection('pelanggan').doc(userId).get();
    return doc.exists
        ? PelangganModel.fromFirebase(doc.id, doc.data()!)
        : null;
  }

  Future<List<TransaksiModel>> ambilRiwayatLangganan(String pelangganId) async {
    final snapshot = await _db
        .collection('transaksi')
        .where('idPelanggan', isEqualTo: pelangganId)
        .orderBy('tanggalMulai', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TransaksiModel.fromFirebase(doc.id, doc.data()))
        .toList();
  }

  Future<List<TransaksiModel>> ambilRiwayatLanggananLengkap(
      String pelangganId) async {
    final snapshot = await _db
        .collection('transaksi')
        .where('idPelanggan', isEqualTo: pelangganId)
        .orderBy('tanggalPesan', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TransaksiModel.fromFirebase(doc.id, doc.data()))
        .toList();
  }

  Future<String> ambilNamaPaket(String idPaket) async {
    try {
      final doc = await _db.collection('paket').doc(idPaket).get();
      return doc.exists ? doc.data()!['nama'] as String : 'Paket Tidak Dikenal';
    } catch (e) {
      return 'Error';
    }
  }

  void sinkronkanJadwalNotifikasi(String userId) {
    // Implementasi placeholder
  }

  void hentikanSinkronisasiJadwal() {
    // Implementasi placeholder
  }
}
