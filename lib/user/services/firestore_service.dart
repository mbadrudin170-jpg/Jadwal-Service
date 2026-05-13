// path: lib/user/services/firestore_service.dart
// ditambah: Menambahkan fungsi simpanTokenFCM untuk menyimpan token notifikasi pengguna.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription? _notificationSubscription;

  Future<Map<String, dynamic>> getPengaturan() async {
    try {
      DocumentSnapshot doc =
          await _db.collection('pengaturan').doc('app').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        Log.info('Pengaturan dari Firestore berhasil diambil.', data);
        return data ?? {};
      } else {
        Log.warning(
            'Dokumen pengaturan tidak ditemukan di Firestore, menggunakan nilai default.');
        return {
          'modePemeliharaan': false,
          'infoPemeliharaan':
              'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.'
        };
      }
    } catch (e, s) {
      Log.error(
        'Error saat mengambil pengaturan dari Firestore.',
        e: e,
        st: s,
      );
      return {
        'modePemeliharaan': false,
        'infoPemeliharaan': 'Gagal memuat pengaturan. Menggunakan default.'
      };
    }
  }

  void sinkronkanJadwalNotifikasi(String userId) {
    Log.info('Memulai sinkronisasi jadwal notifikasi untuk userId: $userId');
    final collectionRef =
        _db.collection('notifikasi').where('id_pelanggan', isEqualTo: userId);

    _notificationSubscription = collectionRef.snapshots().listen((snapshot) {
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

  void hentikanSinkronisasiJadwal() {
    Log.info('Menghentikan sinkronisasi jadwal notifikasi.');
    _notificationSubscription?.cancel();
  }

  Stream<PelangganModel?> ambilPelangganStream(String userId) {
    Log.info('Streaming data pelanggan untuk: $userId');
    return _db.collection('pelanggan').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Log.info('Data pelanggan stream diperbarui.', snapshot.data());
        return PelangganModel.fromFirebase(snapshot.id, snapshot.data()!);
      } else {
        Log.warning('Pelanggan dengan ID $userId tidak ditemukan di stream.');
        return null;
      }
    });
  }

  Future<List<TransaksiModel>> ambilRiwayatLanggananLengkap(
      String pelangganId) async {
    return ambilRiwayatLangganan(pelangganId);
  }

  Future<PelangganModel?> ambilPelangganSekali(String userId) async {
    try {
      Log.info('Mengambil data pelanggan sekali untuk ID: $userId');
      final doc = await _db.collection('pelanggan').doc(userId).get();
      if (doc.exists) {
        Log.info('Pelanggan ditemukan', doc.data());
        return PelangganModel.fromFirebase(doc.id, doc.data()!);
      }
      Log.warning('Pelanggan dengan ID $userId tidak ditemukan.');
      return null;
    } catch (e, s) {
      Log.error(
        'Error mengambil pelanggan sekali: $e',
        e: e,
        st: s,
      );
      return null;
    }
  }

  Future<List<TransaksiModel>> ambilRiwayatLangganan(String pelangganId) async {
    try {
      Log.info('Mengambil riwayat langganan untuk pelanggan ID: $pelangganId');
      final querySnapshot = await _db
          .collection('transaksi')
          .where('id_pelanggan', isEqualTo: pelangganId)
          .orderBy('tanggal', descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} riwayat transaksi.');
      return querySnapshot.docs
          .map((doc) => TransaksiModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } catch (e, s) {
      Log.error(
        'Error mengambil riwayat langganan: $e',
        e: e,
        st: s,
      );
      return [];
    }
  }

  Future<String> ambilNamaPaket(String paketId) async {
    try {
      Log.info('Mengambil nama paket untuk ID: $paketId');
      final doc = await _db.collection('paket').doc(paketId).get();
      if (doc.exists && doc.data()!.containsKey('nama')) {
        final namaPaket = doc.data()!['nama'] as String;
        Log.info('Nama paket ditemukan: $namaPaket');
        return namaPaket;
      }
      Log.warning(
          'Paket dengan ID $paketId tidak ditemukan atau tidak memiliki nama.');
      return 'Paket Tidak Ditemukan';
    } catch (e, s) {
      Log.error('Error mengambil nama paket: $e', e: e, st: s);
      return 'Error Memuat Paket';
    }
  }

  Future<PaketModel?> ambilPaketModelById(String paketId) async {
    try {
      Log.info('Mengambil model paket untuk ID: $paketId');
      final doc = await _db.collection('paket').doc(paketId).get();
      if (doc.exists) {
        final paket = PaketModel.fromFirebase(doc.id, doc.data()!);
        Log.info('Model paket ditemukan', paket.toFirebase());
        return paket;
      }
      Log.warning('Paket dengan ID $paketId tidak ditemukan untuk model.');
      return null;
    } catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, st: s);
      return null;
    }
  }

  // ditambah: Fungsi untuk menyimpan atau memperbarui FCM token pengguna.
  Future<void> simpanTokenFCM(String userId, String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM null atau kosong, proses penyimpanan dibatalkan.');
      return;
    }

    Log.info('Menyimpan token FCM untuk pengguna: $userId');
    try {
      final docRef = _db.collection('pelanggan').doc(userId);
      await docRef.update({'fcmToken': token});
      Log.info('Token FCM berhasil disimpan ke Firestore.');
    } catch (e, s) {
      Log.error(
        'Gagal menyimpan token FCM ke Firestore untuk pengguna $userId',
        e: e,
        st: s,
      );
    }
  }
}
