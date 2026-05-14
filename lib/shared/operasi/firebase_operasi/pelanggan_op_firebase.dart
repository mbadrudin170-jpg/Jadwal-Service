// path: lib/shared/operasi/firebase_operasi/pelanggan_op_firebase.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';

/// Kelas ini menangani semua operasi terkait data pelanggan di Firestore.
class PelangganOpFirebase {
  // Membuat instance dari FirebaseFirestore untuk berinteraksi dengan database.
  // Koleksi 'pelanggan' akan menjadi target utama operasi di kelas ini.
  final CollectionReference _koleksiPelanggan =
      FirebaseFirestore.instance.collection('pelanggan');

  /// Memperbarui data pelanggan yang ada di Firestore berdasarkan ID-nya.
  ///
  /// [pelanggan]: Objek [PelangganModel] yang berisi data baru.
  /// ID dari objek ini akan digunakan untuk menemukan dokumen yang akan diperbarui.
  Future<void> perbaruiPelanggan(final PelangganModel pelanggan) async {
    Log.info(
      'Memulai pembaruan data pelanggan di Firestore untuk ID: ${pelanggan.id}',
    );
    try {
      // Mengonversi model ke Map, lalu menambahkan timestamp server.
      // Penggunaan `FieldValue.serverTimestamp()` adalah praktik terbaik
      // untuk memastikan waktu yang konsisten di semua klien, karena
      // waktu akan diisi oleh server Firestore itu sendiri.
      final dataToUpdate = pelanggan.toFirebase()
        ..['diperbarui'] = FieldValue.serverTimestamp();

      // Melakukan operasi update pada dokumen yang sesuai.
      await _koleksiPelanggan.doc(pelanggan.id).update(dataToUpdate);

      Log.info(
        'Pembaruan data pelanggan di Firestore untuk ID: ${pelanggan.id} berhasil.',
      );
    } on FirebaseException catch (e, s) {
      // Logging error jika terjadi kegagalan saat berinteraksi dengan Firestore.
      Log.error(
        'Gagal memperbarui data pelanggan di Firestore untuk ID: ${pelanggan.id}',
        e: e,
        st: s,
      );
      // Melemparkan kembali error agar dapat ditangani oleh lapisan pemanggil (UI).
      rethrow;
    }
  }

  /// Mengambil data pelanggan secara real-time (stream) berdasarkan ID pengguna.
  Stream<PelangganModel?> ambilPelangganStream(final String userId) {
    Log.info('Streaming data pelanggan untuk: $userId');
    return _koleksiPelanggan.doc(userId).snapshots().map((final snapshot) {
      if (snapshot.exists) {
        Log.info('Data pelanggan stream diperbarui.', snapshot.data());
        return PelangganModel.fromFirebase(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
      } else {
        Log.warning('Pelanggan dengan ID $userId tidak ditemukan di stream.');
        return null;
      }
    });
  }

  /// Mengambil data pelanggan sekali (one-time fetch) berdasarkan ID pengguna.
  Future<PelangganModel?> ambilPelangganSekali(final String userId) async {
    try {
      Log.info('Mengambil data pelanggan sekali untuk ID: $userId');
      final doc = await _koleksiPelanggan.doc(userId).get();
      if (doc.exists) {
        Log.info('Pelanggan ditemukan', doc.data());
        return PelangganModel.fromFirebase(
          doc.id,
          doc.data()! as Map<String, dynamic>,
        );
      }
      Log.warning('Pelanggan dengan ID $userId tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil pelanggan sekali: $e',
        e: e,
        st: s,
      );
      return null;
    }
  }

  /// Menyimpan atau memperbarui token FCM (Firebase Cloud Messaging) pengguna.
  Future<void> simpanTokenFCM(final String userId, final String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM null atau kosong, proses penyimpanan dibatalkan.');
      return;
    }

    Log.info('Menyimpan token FCM untuk pengguna: $userId');
    try {
      await _koleksiPelanggan.doc(userId).update({'fcmToken': token});
      Log.info('Token FCM berhasil disimpan ke Firestore.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal menyimpan token FCM ke Firestore untuk pengguna $userId',
        e: e,
        st: s,
      );
    }
  }
}
