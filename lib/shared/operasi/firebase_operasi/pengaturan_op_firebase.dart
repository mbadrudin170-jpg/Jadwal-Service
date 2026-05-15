// path: lib/shared/operasi/firebase_operasi/pengaturan_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk mengelola operasi terkait data pengaturan di Firestore.
class PengaturanOpFirebase {
  final FirebaseFirestore _db;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  /// Memungkinkan injeksi instance palsu untuk pengujian.
  PengaturanOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Mengambil pengaturan aplikasi dari Firestore.
  ///
  /// Mengembalikan nilai default jika dokumen tidak ditemukan atau terjadi error.
  Future<Map<String, dynamic>> getPengaturan() async {
    try {
      final DocumentSnapshot doc =
          await _db.collection('pengaturan').doc('app').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        Log.info('Pengaturan dari Firestore berhasil diambil.', data);
        return data ?? {};
      } else {
        Log.warning(
          'Dokumen pengaturan tidak ditemukan di Firestore, menggunakan nilai default.',
        );
        return {
          'modePemeliharaan': false,
          'infoPemeliharaan':
              'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
        };
      }
    } on Exception catch (e, s) {
      Log.error(
        'Error saat mengambil pengaturan dari Firestore.',
        e: e,
        st: s,
      );
      return {
        'modePemeliharaan': false,
        'infoPemeliharaan': 'Gagal memuat pengaturan. Menggunakan default.',
      };
    }
  }
}
