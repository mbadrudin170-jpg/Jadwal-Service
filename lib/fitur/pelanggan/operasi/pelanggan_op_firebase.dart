// path: lib/fitur/pelanggan/operasi/pelanggan_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PelangganOpFirebase {
  final FirebaseFirestore _firestore;
  final BaseOpFirebase _baseOpFirebase;
  final String _namaKoleksi = NamaTabel.pelanggan;

  PelangganOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOpFirebase,
  }) : _firestore = firestore,
       _baseOpFirebase = baseOpFirebase {
    Log.info('CustomerOpFirebase diinisialisasi.');
  }

  CollectionReference get _koleksiPelanggan =>
      _firestore.collection(_namaKoleksi);

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembuatan pelanggan: ${pelanggan.id}');
    await _baseOpFirebase.sisipkan(
      _namaKoleksi,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  Future<void> perbaruiPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembaruan pelanggan: ${pelanggan.id}');
    await _baseOpFirebase.update(
      _namaKoleksi,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  Future<void> softDelete(String id) async {
    Log.info('Mendelegasikan soft delete pelanggan: $id');
    await _baseOpFirebase.hapusSementara(_namaKoleksi, id);
  }

  Future<void> perbaruiTerakhirAktif(String id) async {
    Log.info('Mendelegasikan update last active untuk: $id');
    await _baseOpFirebase.update(_namaKoleksi, id, {
      NamaKolom.terkahirAktif: FieldValue.serverTimestamp(),
    });
  }

  Future<void> simpanTokenFCM(String id, String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM kosong, penyimpanan dibatalkan.');
      return;
    }
    Log.info('Mendelegasikan penyimpanan token FCM untuk: $id');
    await _baseOpFirebase.update(_namaKoleksi, id, {'fcmToken': token});
  }

  Future<List<PelangganModel>> ambilSemuaPelanggan() async {
    Log.info('Mengambil semua pelanggan aktif...');
    try {
      final querySnapshot = await _koleksiPelanggan
          .where(NamaKolom.dihapus, isEqualTo: false)
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
      return [];
    }
  }

  Stream<PelangganModel?> ambilStreanPelanggan(String id) {
    Log.info('Streaming data pelanggan untuk: $id');
    return _koleksiPelanggan
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return PelangganModel.fromFirebase(
              snapshot.id,
              snapshot.data()! as Map<String, dynamic>,
            );
          }
          return null;
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream pelanggan untuk: $id', e: e, s: s);
        });
  }

  Future<PelangganModel?> ambilBerdasarkanId(String id) async {
    try {
      final doc = await _koleksiPelanggan.doc(id).get();
      if (doc.exists) {
        return PelangganModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil pelanggan: $e', e: e, s: s);
      return null;
    }
  }
}
