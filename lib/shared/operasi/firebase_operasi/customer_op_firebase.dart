// path: lib/shared/operasi/firebase_operasi/customer_op_firebase.dart
// direfaktor total: Semua operasi tulis (create, update, delete, soft delete)
//                 sekarang sepenuhnya didelegasikan ke BaseOpFirebase.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas ini menangani semua operasi terkait data pelanggan di Firestore.
/// Bertindak sebagai lapisan "intent" yang mendelegasikan implementasi
/// ke BaseOpFirebase.
class CustomerOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOp;
  final String _collectionName = NamaTabel.customer;

  /// Konstruktor untuk inisialisasi.
  CustomerOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  })  : _firestore = firestore,
        _baseOp = baseOp {
    Log.info('CustomerOpFirebase diinisialisasi.');
  }

  /// Referensi ke koleksi pelanggan.
  CollectionReference get _customerCollection =>
      _firestore.collection(_collectionName);

  /// Membuat pelanggan baru di Firestore.
  Future<void> addPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembuatan pelanggan: ${pelanggan.id}');
    await _baseOp.sisipkan(
      _collectionName,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  /// Memperbarui data pelanggan yang ada di Firestore.
  Future<void> updatePelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembaruan pelanggan: ${pelanggan.id}');
    await _baseOp.update(
      _collectionName,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  /// Melakukan soft delete pada pelanggan di Firestore.
  Future<void> softDelete(String id) async {
    Log.info('Mendelegasikan soft delete pelanggan: $id');
    await _baseOp.hapusSementara(_collectionName, id);
  }

  /// Menghapus pelanggan dari Firestore secara permanen.
  /// PERHATIAN: Operasi ini tidak bisa dibatalkan!
  Future<void> hapusPelangganPermanen(String idPelanggan) async {
    Log.warning('Mendelegasikan penghapusan permanen pelanggan: $idPelanggan');
    await _baseOp.hapusPermanen(_collectionName, idPelanggan);
  }

  /// Memperbarui waktu terakhir pengguna aktif.
  Future<void> perbaruiTerakhirAktif(String id) async {
    Log.info('Mendelegasikan update last active untuk: $id');
    await _baseOp.update(_collectionName, id, {
      NamaKolom.terkahirAktif: FieldValue.serverTimestamp(),
    });
  }

  /// Menyimpan atau memperbarui token FCM pengguna.
  Future<void> simpanTokenFCM(String id, String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM kosong, penyimpanan dibatalkan.');
      return;
    }
    Log.info('Mendelegasikan penyimpanan token FCM untuk: $id');
    await _baseOp.update(_collectionName, id, {'fcmToken': token});
  }

  // =======================================================================
  // OPERASI BACA (Tidak didelegasikan karena spesifik untuk model)
  // =======================================================================

  /// Mengambil semua data pelanggan yang tidak di-soft-delete.
  Future<List<PelangganModel>> getAllPelanggan() async {
    Log.info('Mengambil semua pelanggan aktif...');
    try {
      final querySnapshot = await _customerCollection
          .where(NamaKolom.diHapus, isEqualTo: false)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.warning('Tidak ada pelanggan aktif yang ditemukan.');
        return [];
      }

      final pelanggan = querySnapshot.docs.map((doc) {
        return PelangganModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }).toList();

      Log.info('Berhasil mengambil ${pelanggan.length} pelanggan.');
      return pelanggan;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pelanggan', e: e, s: s);
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  /// Mengambil data pelanggan secara real-time (stream).
  Stream<PelangganModel?> getStreamPelanggan(String idPengguna) {
    Log.info('Streaming data pelanggan untuk: $idPengguna');
    return _customerCollection.doc(idPengguna).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return PelangganModel.fromFirebase(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
      }
      return null;
    }).handleError((Object e, StackTrace s) {
      Log.error('Error pada stream pelanggan untuk: $idPengguna', e: e, s: s);
    });
  }

  /// Mengambil data pelanggan sekali (one-time fetch).
  Future<PelangganModel?> getById(String idPengguna) async {
    try {
      final doc = await _customerCollection.doc(idPengguna).get();
      if (doc.exists) {
        return PelangganModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan $idPengguna tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil pelanggan: $e', e: e, s: s);
      return null;
    }
  }
}
