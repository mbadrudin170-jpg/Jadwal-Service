// path: lib/shared/operasi/firebase_operasi/package_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

class PackageOpFirebase {
  final FirebaseFirestore db;

  PackageOpFirebase({required FirebaseFirestore firestore}) : db = firestore {
    Log.info('PackageOpFirebase diinisialisasi.');
  }

  CollectionReference get _collection =>
      db.collection(TableNameValue.get(TableName.package));

  Future<List<PackageModel>> ambilPaketPublik() async {
    try {
      Log.info('Mengambil paket publik untuk penukaran poin.');
      final querySnapshot = await _collection
          .where(ColumnNames.isPublic, isEqualTo: true)
          .where(ColumnNames.redemptionPoints, isGreaterThan: 0)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .get();
      Log.info(
          'Menemukan ${querySnapshot.docs.length} paket publik yang tidak dihapus.');
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PackageModel.fromFirebase(doc.id, data);
      }).toList();
    } on Exception catch (e, s) {
      Log.error('Error mengambil paket publik: $e', e: e, st: s);
      return [];
    }
  }

  Future<PackageModel?> ambilBerdasarkanId(String idPaket) async {
    try {
      Log.info('Mengambil model paket untuk ID: $idPaket');
      final doc = await _collection.doc(idPaket).get();
      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        final package = PackageModel.fromFirebase(doc.id, data);
        Log.info('Model paket ditemukan');
        return package;
      }
      Log.warning('Paket dengan ID $idPaket tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, st: s);
      return null;
    }
  }

  /// Mengambil data paket secara real-time berdasarkan ID.
  Stream<PackageModel?> ambilStreamBerdasarkanId(String idPaket) {
    Log.info('Memulai stream untuk paket ID: $idPaket');
    return _collection.doc(idPaket).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()! as Map<String, dynamic>;
        Log.info('Data paket diperbarui dari stream: $idPaket');
        return PackageModel.fromFirebase(snapshot.id, data);
      }
      Log.warning('Paket ID $idPaket tidak ditemukan di stream.');
      return null;
    }).handleError((Object e, StackTrace s) {
      Log.error('Error pada stream paket ID: $idPaket', e: e, st: s);
      return null;
    });
  }

  Future<void> hapusPaket(String idPaket) async {
    Log.warning('Memulai penghapusan permanen paket di Firestore: $idPaket');
    try {
      await _collection.doc(idPaket).delete();
      Log.info('Penghapusan permanen paket berhasil: $idPaket');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal menghapus paket secara permanen: $idPaket', e: e, st: s);
      rethrow;
    }
  }

  Future<void> hapusSementaraPaket(String idPaket) async {
    Log.info('Memulai soft delete paket di Firestore: $idPaket');
    try {
      await _collection.doc(idPaket).update({
        ColumnNames.isDeleted: true,
        ColumnNames.archivedAt: FieldValue.serverTimestamp(),
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Soft delete paket berhasil: $idPaket');
    } on FirebaseException catch (e, s) {
      Log.error('Gagal melakukan soft delete paket: $idPaket', e: e, st: s);
      rethrow;
    }
  }
}
