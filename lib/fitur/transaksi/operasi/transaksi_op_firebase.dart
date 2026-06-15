// path: lib/fitur/transaksi/operasi/transaksi_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

/// Kelas untuk mengelola operasi terkait data transaksi di Firestore.
class TransaksiOpFirebase extends BaseOpFirebase {
  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  TransaksiOpFirebase({super.firestore}) {
    Log.info('TransactionOpFirebase diinisialisasi.');
  }

  /// Mendapatkan referensi ke koleksi transaction.
  CollectionReference get _koleksi =>
      firestore.collection(NamaTabel.transactions);

  /// Menambahkan transaksi baru ke Firestore.
  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    Log.info('Menambahkan transaksi baru: ${transaksi.id}');
    try {
      await sisipkan(
        NamaTabel.transactions,
        transaksi.id,
        transaksi.toFirebase(),
      );
      Log.info('Berhasil menambahkan transaksi: ${transaksi.id}');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menambahkan transaksi: ${transaksi.id}', e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil transaksi lunas terbaru dari seorang pengguna berdasarkan tanggal akhir.
  /// Digunakan untuk menentukan status langganan aktif di sisi user.
  Future<TransaksiModel?> ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info(
          'Mencari transaksi lunas terbaru dari Firebase untuk pengguna ID: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.statusPembayaran,
              isEqualTo: StatusPembayaran.paid.name)
          .where(NamaKolom.diHapus, isEqualTo: false)
          .orderBy(NamaKolom.tangglberakhir, descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Log.warning(
            'Tidak ada transaksi lunas yang aktif dari Firebase untuk pengguna ID: $idPelanggan');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      Log.info(
          'Transaksi lunas terbaru dari Firebase ditemukan untuk pengguna ID: $idPelanggan');
      return TransaksiModel.fromFirebase(doc.id, data);
    } on Exception catch (e, s) {
      Log.error(
          'Error mengambil transaksi lunas terbaru dari Firebase untuk pengguna ID: $idPelanggan',
          e: e,
          s: s);
      return null;
    }
  }

  /// Mengambil semua transaksi untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilBerdasarkanIdPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info('Mengambil semua transaksi untuk: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.diHapus, isEqualTo: false)
          .orderBy(NamaKolom.tanggal, descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} transaksi.');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransaksiModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil transaksi: $e', e: e, s: s);
      return [];
    }
  }

  /// Menghitung total poin yang dimiliki oleh pelanggan.
  Future<int> ambilTotalPoin(String idPelanggan) async {
    try {
      Log.info('Menghitung total poin untuk: $idPelanggan');
      final querySnapshot = await _koleksi
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          .where(NamaKolom.diHapus, isEqualTo: false)
          .where(NamaKolom.statusPembayaran,
              isEqualTo: StatusPembayaran.paid.name)
          .get();

      int totalPoin = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPoin += (data[NamaKolom.poinDidapat] as int? ?? 0);
        totalPoin -= (data[NamaKolom.poinDigunakan] as int? ?? 0);
      }
      Log.info('Total poin untuk $idPelanggan adalah $totalPoin');
      return totalPoin;
    } on Exception catch (e, s) {
      Log.error('Error menghitung total poin: $e', e: e, s: s);
      return 0;
    }
  }

  /// Menghapus transaksi dari Firestore secara permanen.
  Future<void> hapusTransaksi(String idTransaksi) async {
    Log.warning(
        'Memulai penghapusan permanen transaksi di Firestore: $idTransaksi');
    try {
      await hapusPermanen(NamaTabel.transactions, idTransaksi);
      Log.info('Penghapusan permanen transaksi berhasil: $idTransaksi');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus transaksi secara permanen: $idTransaksi',
          e: e, s: s);
      rethrow;
    }
  }

  /// Melakukan soft delete pada transaksi di Firestore.
  Future<void> hapusSementaraTransaksi(String idTransaksi) async {
    Log.info('Memulai soft delete transaksi di Firestore: $idTransaksi');
    try {
      await hapusSementara(NamaTabel.transactions, idTransaksi);
      Log.info('Soft delete transaksi berhasil: $idTransaksi');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete transaksi: $idTransaksi',
          e: e, s: s);
      rethrow;
    }
  }

  /// Mengambil daftar paket aktif (transaksi yang belum kedaluwarsa)
  /// untuk seorang pelanggan.
  Future<List<TransaksiModel>> ambilPaketAktifPelanggan(
    String idPelanggan,
  ) async {
    try {
      Log.info('Mulai mengambil paket aktif untuk pelanggan: $idPelanggan');
      // Ambil waktu saat ini
      final DateTime now = DateTime.now();

      final querySnapshot = await _koleksi
          // 1. Cari transaksi milik pelanggan yang benar
          .where(NamaKolom.idPelanggan, isEqualTo: idPelanggan)
          // 2. Pastikan transaksi tidak dihapus
          .where(NamaKolom.diHapus, isEqualTo: false)
          // 3. Filter utama: endDate harus lebih besar dari waktu sekarang
          .where(NamaKolom.tangglberakhir, isGreaterThan: now)
          .get();

      // Jika tidak ada dokumen yang cocok, kembalikan list kosong
      if (querySnapshot.docs.isEmpty) {
        Log.info('Tidak ada paket aktif yang ditemukan untuk: $idPelanggan');
        return [];
      }

      // Ubah setiap dokumen menjadi objek TransactionModel
      final daftarPaketAktif = querySnapshot.docs.map((doc) {
        return TransaksiModel.fromFirebase(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      Log.info(
          '${daftarPaketAktif.length} paket aktif ditemukan untuk: $idPelanggan');
      return daftarPaketAktif;
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengambil paket aktif untuk pelanggan $idPelanggan: $e',
        e: e,
        s: s,
      );
      // Kembalikan list kosong jika terjadi error agar aplikasi tidak crash
      return [];
    }
  }
}
