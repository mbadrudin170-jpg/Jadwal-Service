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

  Future<bool> cekDuplikasiTeleponDanPassword(
    String telepon,
    String kataSandi, {
    String? excludeId,
  }) async {
    try {
      Query query = _koleksiPelanggan
          .where(NamaKolom.telepon, isEqualTo: telepon)
          .where(NamaKolom.kataSandi, isEqualTo: kataSandi)
          .where(NamaKolom.dihapus, isEqualTo: false);

      // Jika excludeId diberikan, exclude pelanggan dengan ID tersebut
      if (excludeId != null && excludeId.isNotEmpty) {
        query = query.where(NamaKolom.id, isNotEqualTo: excludeId);
      }

      final snapshot = await query.limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e, s) {
      Log.error('Gagal mengecek duplikasi pelanggan di Firebase', e: e, s: s);
      rethrow;
    }
  }

  Future<void> tambahPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembuatan pelanggan: ${pelanggan.id}');
    final isDuplicate = await cekDuplikasiTeleponDanPassword(
      pelanggan.telepon,
      pelanggan.kataSandi,
    );

    if (isDuplicate) {
      throw Exception('Nomor telepon dan password sudah digunakan.');
    }
    await _baseOpFirebase.sisipkan(
      _namaKoleksi,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  Future<void> perbaruiPelanggan(PelangganModel pelanggan) async {
    Log.info('Mendelegasikan pembaruan pelanggan: ${pelanggan.id}');
    final isDuplicate = await cekDuplikasiTeleponDanPassword(
      pelanggan.telepon,
      pelanggan.kataSandi,
      excludeId: pelanggan.id,
    );

    if (isDuplicate) {
      throw Exception('Nomor telepon dan password sudah digunakan.');
    }
    await _baseOpFirebase.update(
      _namaKoleksi,
      pelanggan.id,
      pelanggan.toFirebase(),
    );
  }

  Future<void> softDelete(String id) async {
    Log.info('Mendelegasikan soft delete pelanggan: $id');
    await _baseOpFirebase.softDelete(_namaKoleksi, id);
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

  Future<List<PelangganModel>> ambilSemua({
    bool tampilkanYangDiarsip = true,
  }) async {
    Log.info(
      'Mengambil semua pelanggan. Tampilkan yang diarsip: $tampilkanYangDiarsip',
    );
    try {
      Query query = _koleksiPelanggan;

      if (tampilkanYangDiarsip) {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      } else {
        query = query.where(NamaKolom.dihapus, isEqualTo: false);
      }
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        Log.warning('Tidak ada pelanggan yang ditemukan.');
        return [];
      }
      final pelanggan = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) {
              Log.warning(
                'Data pelanggan dengan ID ${doc.id} bernilai null, dilewati.',
              );
              return null;
            }
            return PelangganModel.fromFirebase(doc.id, data);
          })
          .whereType<PelangganModel>()
          .toList();
      Log.info('Berhasil mengambil ${pelanggan.length} pelanggan.');
      return pelanggan;
    } on Exception catch (e, s) {
      Log.error('Gagal mengambil semua pelanggan', e: e, s: s);
      return [];
    }
  }

  Stream<PelangganModel?> ambilStreamBerdasarkanId(String id) {
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
