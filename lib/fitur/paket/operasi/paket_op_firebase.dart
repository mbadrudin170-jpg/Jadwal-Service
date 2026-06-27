// path: lib/fitur/paket/operasi/paket_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

class PaketOpFirebase {
  final FirebaseFirestore db;
  final BaseOpFirebase _baseOp;
  final String _namaKoleksi = NamaTabel.paket;

  PaketOpFirebase({
    required FirebaseFirestore firestore,
    required BaseOpFirebase baseOp,
  }) : db = firestore,
       _baseOp = baseOp {
    Log.info('PackageOpFirebase diinisialisasi.');
  }

  CollectionReference get _collection => db.collection(_namaKoleksi);

  // ============================================================
  // ✅ OPERASI TULIS (WRITE) - Menggunakan BaseOpFirebase
  // ============================================================

  /// Menambahkan paket baru ke Firebase
  Future<void> tambahPaket(PaketModel paket) async {
    Log.info('Menambahkan paket ke Firebase: ${paket.id}');
    await _baseOp.sisipkan(_namaKoleksi, paket.id, paket.toFirebase());
  }

  /// Memperbarui paket yang sudah ada di Firebase
  Future<void> perbaruiPaket(PaketModel paket) async {
    Log.info('Memperbarui paket di Firebase: ${paket.id}');
    await _baseOp.update(_namaKoleksi, paket.id, paket.toFirebase());
  }

  /// Menghapus paket secara permanen dari Firebase
  Future<void> hapusPermanen(String id) async {
    Log.warning('Menghapus paket secara permanen: $id');
    await _baseOp.hapusPermanen(_namaKoleksi, id);
  }

  /// Soft delete paket di Firebase
  Future<void> softDelete(String id) async {
    Log.info('Memulai soft delete paket di Firestore: $id');
    await _baseOp.softDelete(_namaKoleksi, id);
  }

  /// Menyisipkan atau memperbarui banyak paket sekaligus (batch)
  Future<void> sisipkanAtauPerbaruiBatch(List<PaketModel> items) async {
    if (items.isEmpty) {
      Log.info('Batch paket: daftar kosong, operasi dibatalkan.');
      return;
    }

    Log.info(
      'Memulai batch insert/update untuk ${items.length} paket di Firestore',
    );

    final dataList = items.map((item) => item.toFirebase()).toList();
    await _baseOp.insertOrUpdateBatch(_namaKoleksi, dataList, NamaKolom.id);
  }

  // ============================================================
  // ✅ OPERASI BACA (READ) - Query Langsung
  // ============================================================

  /// Mengambil semua paket publik (statusPublik = true)
  Future<List<PaketModel>> ambilPaketPublik() async {
    try {
      Log.info('Mengambil paket publik dari firebase untuk penukaran poin.');
      final querySnapshot = await _collection
          .where(NamaKolom.statusPublik, isEqualTo: true)
          .where(NamaKolom.poinPenukaran, isGreaterThan: 0)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.poinPenukaran)
          .get();

      Log.info(
        'Menemukan ${querySnapshot.docs.length} paket publik dari firebase.',
      );
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PaketModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket publik firebase: $e', e: e, s: s);
      return [];
    }
  }

  /// Mengambil paket berdasarkan ID
  Future<PaketModel?> ambilBerdasarkanId(String id) async {
    try {
      Log.info('Mengambil paket untuk ID: $id');
      final doc = await _collection.doc(id).get();

      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        final package = PaketModel.fromFirebase(doc.id, data);
        Log.info('Paket ditemukan: ${package.nama}');
        return package;
      }

      Log.warning('Paket dengan ID $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket: $e', e: e, s: s);
      return null;
    }
  }

  /// Mengambil semua paket (termasuk yang tidak publik)
  Future<List<PaketModel>> ambilSemua() async {
    try {
      Log.info('Mengambil semua paket dari Firebase');
      final querySnapshot = await _collection
          .where(NamaKolom.dihapus, isEqualTo: false)
          .get();

      Log.info('Menemukan ${querySnapshot.docs.length} paket.');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PaketModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil semua paket: $e', e: e, s: s);
      return [];
    }
  }

  /// Mengambil beberapa paket berdasarkan daftar ID
  Future<List<PaketModel>> ambilBerdasarkanIds(List<String> ids) async {
    if (ids.isEmpty) {
      Log.warning('Daftar ID kosong, mengembalikan list kosong');
      return [];
    }

    try {
      Log.info('Mengambil ${ids.length} paket berdasarkan ID');
      final List<PaketModel> hasil = [];

      for (final id in ids) {
        final paket = await ambilBerdasarkanId(id);
        if (paket != null) {
          hasil.add(paket);
        }
      }

      Log.info('Berhasil mengambil ${hasil.length} dari ${ids.length} paket');
      return hasil;
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket berdasarkan IDs: $e', e: e, s: s);
      return [];
    }
  }

  // ============================================================
  // ✅ STREAM (REALTIME)
  // ============================================================

  /// Stream paket berdasarkan ID (real-time)
  Stream<PaketModel?> ambilStreamBerdasarkanId(String id) {
    Log.info('Memulai stream untuk paket ID: $id');
    return _collection
        .doc(id)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()! as Map<String, dynamic>;
            Log.info('Data paket diperbarui dari stream: $id');
            return PaketModel.fromFirebase(snapshot.id, data);
          }
          Log.warning('Paket ID $id tidak ditemukan di stream.');
          return null;
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream paket ID: $id', e: e, s: s);
          return null;
        });
  }

  /// Stream semua paket publik (real-time)
  Stream<List<PaketModel>> ambilStreamPaketPublik() {
    Log.info('Memulai stream paket publik');
    return _collection
        .where(NamaKolom.statusPublik, isEqualTo: true)
        .where(NamaKolom.dihapus, isEqualTo: false)
        .orderBy(NamaKolom.poinPenukaran)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return PaketModel.fromFirebase(doc.id, data);
          }).toList();
        })
        .handleError((Object e, StackTrace s) {
          Log.error('Error pada stream paket publik', e: e, s: s);
          return <PaketModel>[];
        });
  }
}
