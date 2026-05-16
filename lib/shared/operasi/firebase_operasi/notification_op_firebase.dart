// path: lib/shared/operasi/firebase_operasi/notification_op_firebase.dart
// diubah: Menggunakan TableNameValue dan ColumnNames untuk semua referensi
//         koleksi dan kolom.
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/user/page/subscription_history_user.dart
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/constant/column_names.dart (ColumnNames)
//   - lib/shared/constant/table_name_value.dart (TableNameValue)

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

/// Kelas untuk mengelola operasi terkait notifikasi di Firestore.
class NotificationOpFirebase {
  final FirebaseFirestore _db;
  StreamSubscription<dynamic>? _notificationSubscription;

  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  NotificationOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Mendapatkan referensi ke koleksi fcm_tokens.
  CollectionReference get _fcmTokensCollection =>
      _db.collection(TableNameValue.get(TableName.fcmToken));

  /// Mendapatkan referensi ke koleksi notification.
  CollectionReference get _notificationCollection =>
      _db.collection(TableNameValue.get(TableName.notification));

  /// Menyimpan token FCM pengguna ke Firestore.
  Future<void> saveToken(final String userId, final String token) async {
    Log.info('Menyimpan token FCM untuk userId: $userId');
    try {
      await _fcmTokensCollection.doc(userId).set({
        ColumnNames.value: token,
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Token berhasil disimpan.');
    } on Exception catch (e, s) {
      Log.error('Gagal menyimpan token', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus token FCM pengguna dari Firestore.
  Future<void> deleteToken(final String userId) async {
    Log.info('Menghapus token FCM untuk userId: $userId');
    try {
      await _fcmTokensCollection.doc(userId).delete();
      Log.info('Token berhasil dihapus.');
    } on Exception catch (e, s) {
      Log.error('Gagal menghapus token', e: e, st: s);
      rethrow;
    }
  }

  /// Memulai sinkronisasi dan mendengarkan jadwal notifikasi dari Firestore.
  void syncNotificationSchedule(final String userId) {
    Log.info('Memulai sinkronisasi jadwal notifikasi untuk userId: $userId');
    final collectionRef = _notificationCollection.where(
      ColumnNames.customerId,
      isEqualTo: userId,
    );

    _notificationSubscription =
        collectionRef.snapshots().listen((final snapshot) {
      for (final docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          if (data != null) {
            Log.info('Notifikasi baru diterima', data);
          }
        }
      }
    }, onError: (final Object e, final StackTrace s) {
      Log.error('Error saat sinkronisasi notifikasi', e: e, st: s);
    });
  }

  /// Menghentikan sinkronisasi dan berhenti mendengarkan jadwal notifikasi.
  Future<void> stopSyncSchedule() async {
    Log.info('Menghentikan sinkronisasi jadwal notifikasi.');
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }
}
