import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/transaction_model.dart' show TransactionModel;
import 'package:wifi/shared/model/transaksi_model.dart';

/// Kelas untuk mengelola operasi terkait data transaksi di Firestore.
class TransaksiOpFirebase {
  final FirebaseFirestore _db;

  // diubah: Menambahkan konstruktor untuk injeksi dependensi.
  /// Konstruktor untuk inisialisasi dengan instance FirebaseFirestore.
  /// Memungkinkan injeksi instance palsu untuk pengujian.
  TransaksiOpFirebase({final FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Mengambil riwayat langganan (transaksi) untuk seorang pelanggan.
  ///
  /// [pelangganId]: ID dari pelanggan yang ingin dicari riwayatnya.
  /// Mengembalikan daftar [TransactionModel].
  Future<List<TransactionModel>> ambilRiwayatLangganan(
      final String pelangganId) async {
    try {
      Log.info('Mengambil riwayat langganan untuk pelanggan ID: $pelangganId');
      final querySnapshot = await _db
          .collection('transaksi')
          .where('id_pelanggan', isEqualTo: pelangganId)
          .orderBy('tanggal', descending: true)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} riwayat transaksi.');
      return querySnapshot.docs
          .map((final doc) => TransactionModel.fromFirebase(doc.id, doc.data()))
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

  /// Mengambil riwayat langganan lengkap untuk seorang pelanggan.
  ///
  /// [pelangganId]: ID dari pelanggan yang ingin dicari riwayatnya.
  /// Saat ini, fungsi ini hanya memanggil `ambilRiwayatLangganan`.
  Future<List<TransactionModel>> ambilRiwayatLanggananLengkap(
    final String pelangganId,
  ) {
    // TODO: Implementasi mungkin perlu dibedakan dari ambilRiwayatLangganan
    //       jika ada kebutuhan untuk mengambil data yang lebih detail.
    return ambilRiwayatLangganan(pelangganId);
  }
}
