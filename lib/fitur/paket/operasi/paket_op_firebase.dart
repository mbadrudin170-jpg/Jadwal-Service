// path: lib/fitur/paket/operasi/paket_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';

class PaketOpFirebase {
  final FirebaseFirestore db;

  PaketOpFirebase({required FirebaseFirestore firestore}) : db = firestore {
    Log.info('PackageOpFirebase diinisialisasi.');
  }

  CollectionReference get _collection => db.collection(NamaTabel.paket);
  // Di paket_op_firebase.dart
  Future<void> tambahPaket(PaketModel paket) async {
    Log.info('Menambahkan paket ke Firebase: ${paket.id}');
    await _baseOp.sisipkan(_namaKoleksi, paket.id, paket.toFirebase());
  }

  Future<List<PaketModel>> ambilPaketPublik() async {
    try {
      Log.info('Mengambil paket publik untuk penukaran poin.');
      final querySnapshot = await _collection
          .where(NamaKolom.statusPublik, isEqualTo: true)
          .where(NamaKolom.poinPenukaran, isGreaterThan: 0)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .orderBy(NamaKolom.poinPenukaran)
          .get();
      Log.info(
        'Menemukan ${querySnapshot.docs.length} paket publik yang tidak dihapus.',
      );
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PaketModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket publik: $e', e: e, s: s);
      return [];
    }
  }

  Future<PaketModel?> ambilBerdasarkanId(String id) async {
    try {
      Log.info('Mengambil model paket untuk ID: $id');
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        final package = PaketModel.fromFirebase(doc.id, data);
        Log.info('Model paket ditemukan');
        return package;
      }
      Log.warning('Paket dengan ID $id tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, s: s);
      return null;
    }
  }

  /// Mengambil data paket secara real-time berdasarkan ID.
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

  Future<void> softDelete(String id) async {
    Log.info('Memulai soft delete paket di Firestore: $id');
    try {
      await _collection.doc(id).update({
        NamaKolom.dihapus: true,
        NamaKolom.diarsipkanPada: FieldValue.serverTimestamp(),
        NamaKolom.diperbaruiPada: FieldValue.serverTimestamp(),
      });
      Log.info('Soft delete paket berhasil: $id');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete paket: $id', e: e, s: s);
      rethrow;
    }
  }
}
