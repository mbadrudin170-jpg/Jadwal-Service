// path: lib/shared/operasi/firebase_operasi/package_op_firebase.dart
// diubah: Memperbaiki cast doc.data() ke Map<String, dynamic>.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Kelas untuk mengelola operasi terkait data paket di Firestore.
class PackageOpFirebase {
  /// Instance dari [FirebaseFirestore] untuk berinteraksi dengan database.
  final FirebaseFirestore db;

  /// Konstruktor untuk PackageOpFirebase.
  PackageOpFirebase(this.db);

  /// Mendapatkan referensi ke koleksi package.
  CollectionReference get _collection =>
      db.collection(TableNameValue.get(TableName.package));

  /// Mengambil nama paket berdasarkan ID paket.
  Future<String> getPackageName(final String packageId) async {
    try {
      Log.info('Mengambil nama paket untuk ID: $packageId');
      final doc = await _collection.doc(packageId).get();
      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        if (data.containsKey(ColumnNames.name)) {
          final packageName = data[ColumnNames.name] as String;
          Log.info('Nama paket ditemukan: $packageName');
          return packageName;
        }
      }
      Log.warning('Paket dengan ID $packageId tidak ditemukan.');
      return 'Paket Tidak Ditemukan';
    } on Exception catch (e, s) {
      Log.error('Error mengambil nama paket: $e', e: e, st: s);
      return 'Error Memuat Paket';
    }
  }

  /// Mengambil model [PackageModel] lengkap berdasarkan ID paket.
  Future<PackageModel?> getPackageModelById(final String packageId) async {
    try {
      Log.info('Mengambil model paket untuk ID: $packageId');
      final doc = await _collection.doc(packageId).get();
      if (doc.exists) {
        final data = doc.data()! as Map<String, dynamic>;
        final package = PackageModel.fromFirebase(doc.id, data);
        Log.info('Model paket ditemukan');
        return package;
      }
      Log.warning('Paket dengan ID $packageId tidak ditemukan.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, st: s);
      return null;
    }
  }
}
