import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk mengelola operasi terkait notifikasi di Firestore.
class NotifikasiOpFirebase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<dynamic>? _notificationSubscription;

  /// Memulai sinkronisasi dan mendengarkan jadwal notifikasi dari Firestore.
  ///
  /// [userId]: ID pengguna untuk memfilter notifikasi.
  void sinkronkanJadwalNotifikasi(final String userId) {
    Log.info('Memulai sinkronisasi jadwal notifikasi untuk userId: $userId');
    final collectionRef =
        _db.collection('notifikasi').where('id_pelanggan', isEqualTo: userId);

    _notificationSubscription = collectionRef.snapshots().listen((final snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          if (data != null) {
            Log.info('Notifikasi baru diterima', data);
            // Di sini Anda bisa menambahkan logika untuk menampilkan notifikasi lokal
            // menggunakan flutter_local_notifications atau sejenisnya.
          }
        }
      }
    });
  }

  /// Menghentikan sinkronisasi dan berhenti mendengarkan jadwal notifikasi.
  Future<void> hentikanSinkronisasiJadwal() async {
    Log.info('Menghentikan sinkronisasi jadwal notifikasi.');
    await _notificationSubscription?.cancel();
  }
}
