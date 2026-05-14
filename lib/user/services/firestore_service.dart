// TODO: File ini dalam proses untuk dihapus. Semua fungsi telah dipindahkan ke kelas operasi yang sesuai di `lib/shared/operasi/firebase_operasi/`. Jangan menambahkan kode baru di sini.

// path: lib/user/services/firestore_service.dart
// ditambah: Menambahkan fungsi simpanTokenFCM untuk menyimpan token notifikasi pengguna.
// diubah: Menjadikan `hentikanSinkronisasiJadwal` sebagai `async` dan menambahkan `await`.
// TODO: rencana selanjutnya adalah apakah fungsi disini dipisah
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';

/// Service untuk berinteraksi dengan Firestore.
///
/// Menyediakan fungsi-fungsi untuk mengambil, menyimpan, dan mengelola data
/// seperti pengaturan, pelanggan, transaksi, dan notifikasi.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<dynamic>? _notificationSubscription;

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

  /// Memulai sinkronisasi jadwal notifikasi untuk pengguna tertentu.
  ///
  /// Mendengarkan perubahan pada koleksi 'notifikasi' dan menampilkan log
  /// saat notifikasi baru ditambahkan.
  void sinkronkanJadwalNotifikasi(final String userId) {
    Log.info('Memulai sinkronisasi jadwal notifikasi untuk userId: $userId');
    final collectionRef =
        _db.collection('notifikasi').where('id_pelanggan', isEqualTo: userId);

    _notificationSubscription =
        collectionRef.snapshots().listen((final snapshot) {
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

  /// Menghentikan sinkronisasi jadwal notifikasi.
  Future<void> hentikanSinkronisasiJadwal() async {
    Log.info('Menghentikan sinkronisasi jadwal notifikasi.');
    await _notificationSubscription?.cancel();
  }

  /// Mengambil data pelanggan secara real-time (stream) berdasarkan ID pengguna.
  Stream<PelangganModel?> ambilPelangganStream(final String userId) {
    Log.info('Streaming data pelanggan untuk: $userId');
    return _db
        .collection('pelanggan')
        .doc(userId)
        .snapshots()
        .map((final snapshot) {
      if (snapshot.exists) {
        Log.info('Data pelanggan stream diperbarui.', snapshot.data());
        return PelangganModel.fromFirebase(snapshot.id, snapshot.data()!);
      } else {
        Log.warning('Pelanggan dengan ID $userId tidak ditemukan di stream.');
        return null;
      }
    });
  }

  /// Mengambil riwayat langganan lengkap untuk seorang pelanggan.
  ///
  /// Saat ini, fungsi ini hanya memanggil `ambilRiwayatLangganan`.
  Future<List<TransaksiModel>> ambilRiwayatLanggananLengkap(
    final String pelangganId,
  ) {
    return ambilRiwayatLangganan(pelangganId);
  }

  /// Mengambil data pelanggan sekali (one-time fetch) berdasarkan ID pengguna.
  Future<PelangganModel?> ambilPelangganSekali(final String userId) async {
    try {
      Log.info('Mengambil data pelanggan sekali untuk ID: $userId');
      final doc = await _db.collection('pelanggan').doc(userId).get();
      if (doc.exists) {
        Log.info('Pelanggan ditemukan', doc.data());
        return PelangganModel.fromFirebase(doc.id, doc.data()!);
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

  /// Mengambil riwayat langganan (transaksi) untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilRiwayatLangganan(
    final String pelangganId,
  ) async {
    try {
      Log.info('Mengambil riwayat langganan untuk pelanggan ID: $pelangganId');
      final querySnapshot = await _db
          .collection('transaksi')
          .where('id_pelanggan', isEqualTo: pelangganId)
          .orderBy('tanggal', descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} riwayat transaksi.');
      return querySnapshot.docs
          .map((final doc) => TransaksiModel.fromFirebase(doc.id, doc.data()))
          .toList();
    } on Exception catch (e, s) {
      Log.error(
        'Error mengambil riwayat langganan: $e',
        e: e,
        st: s,
      );
      return [];
    }
  }

  /// Mengambil nama paket berdasarkan ID paket.
  Future<String> ambilNamaPaket(final String paketId) async {
    try {
      Log.info('Mengambil nama paket untuk ID: $paketId');
      final doc = await _db.collection('paket').doc(paketId).get();
      if (doc.exists && doc.data()!.containsKey('nama')) {
        final namaPaket = doc.data()!['nama'] as String;
        Log.info('Nama paket ditemukan: $namaPaket');
        return namaPaket;
      }
      Log.warning(
        'Paket dengan ID $paketId tidak ditemukan atau tidak memiliki nama.',
      );
      return 'Paket Tidak Ditemukan';
    } on Exception catch (e, s) {
      Log.error('Error mengambil nama paket: $e', e: e, st: s);
      return 'Error Memuat Paket';
    }
  }

  /// Mengambil model [PaketModel] lengkap berdasarkan ID paket.
  Future<PaketModel?> ambilPaketModelById(final String paketId) async {
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
    } on Exception catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, st: s);
      return null;
    }
  }

  // ditambah: Fungsi untuk menyimpan atau memperbarui FCM token pengguna.
  /// Menyimpan atau memperbarui token FCM (Firebase Cloud Messaging) pengguna.
  Future<void> simpanTokenFCM(final String userId, final String? token) async {
    if (token == null || token.isEmpty) {
      Log.warning('Token FCM null atau kosong, proses penyimpanan dibatalkan.');
      return;
    }

    Log.info('Menyimpan token FCM untuk pengguna: $userId');
    try {
      final docRef = _db.collection('pelanggan').doc(userId);
      await docRef.update({'fcmToken': token});
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
