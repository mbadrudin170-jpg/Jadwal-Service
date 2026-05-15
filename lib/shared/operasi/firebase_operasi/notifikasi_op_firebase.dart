import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';

/// Kelas untuk mengelola operasi terkait notifikasi di Firestore.
class NotifikasiOpFirebase {
  final FirebaseFirestore _db;
  StreamSubscription<dynamic>? _notificationSubscription;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  /// Memungkinkan injeksi instance palsu untuk pengujian.
  NotifikasiOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Menyimpan token FCM pengguna ke Firestore.
  ///
  /// [userId]: ID unik pengguna.
  /// [token]: Token FCM yang akan disimpan.
  Future<void> simpanToken(final String userId, final String token) async {
    Log.info('Menyimpan token FCM untuk userId: $userId');
    try {
      await _db.collection('fcm_tokens').doc(userId).set({
        'token': token,
        'diperbaruiPada': FieldValue.serverTimestamp(),
      });
      Log.info('Token berhasil disimpan.');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan token', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus token FCM pengguna dari Firestore.
  ///
  /// [userId]: ID pengguna yang tokennya akan dihapus.
  Future<void> hapusToken(final String userId) async {
    Log.info('Menghapus token FCM untuk userId: $userId');
    try {
      await _db.collection('fcm_tokens').doc(userId).delete();
      Log.info('Token berhasil dihapus.');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus token', e: e, st: s);
      rethrow;
    }
  }

  /// Memulai sinkronisasi dan mendengarkan jadwal notifikasi dari Firestore.
  ///
  /// [userId]: ID pengguna untuk memfilter notifikasi.
  void sinkronkanJadwalNotifikasi(final String userId) {
    Log.info('Memulai sinkronisasi jadwal notifikasi untuk userId: $userId');
    final collectionRef =
        _db.collection('notifikasi').where('id_pelanggan', isEqualTo: userId);

    _notificationSubscription = collectionRef.snapshots().listen((final snapshot) {
      for (final docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          if (data != null) {
            Log.info('Notifikasi baru diterima', data);
            // Di sini Anda bisa menambahkan logika untuk menampilkan notifikasi lokal
            // menggunakan flutter_local_notifications atau sejenisnya.
          }
        }
      }
    }, onError: (final Object e, final StackTrace s) {
      Log.error('Error saat sinkronisasi notifikasi', e: e, st: s);
    },);
  }

  /// Menghentikan sinkronisasi dan berhenti mendengarkan jadwal notifikasi.
  Future<void> hentikanSinkronisasiJadwal() async {
    Log.info('Menghentikan sinkronisasi jadwal notifikasi.');
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }
}
