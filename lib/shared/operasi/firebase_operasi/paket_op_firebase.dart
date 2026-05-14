
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';

/// Kelas untuk mengelola operasi terkait data paket di Firestore.
class PaketOpFirebase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mengambil nama paket berdasarkan ID paket.
  ///
  /// [paketId]: ID dari paket yang ingin dicari.
  /// Mengembalikan nama paket sebagai [String].
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
  ///
  /// [paketId]: ID dari paket yang ingin dicari.
  /// Mengembalikan objek [PaketModel] jika ditemukan, jika tidak, null.
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
}
