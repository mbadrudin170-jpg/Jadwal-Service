// path: lib/shared/operasi/firebase_operasi/package_op_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Kelas untuk mengelola operasi terkait data paket di Firestore.
class PackageOpFirebase {
  /// Instance dari [FirebaseFirestore] untuk berinteraksi dengan database.
  final FirebaseFirestore db;

  /// Konstruktor untuk PackageOpFirebase.
  ///
  /// Membutuhkan instance [FirebaseFirestore] untuk diinjeksi,
  /// yang memungkinkan untuk pengujian dengan mock.
  PackageOpFirebase(this.db);

  /// Mengambil nama paket berdasarkan ID paket.
  ///
  /// [packageId]: ID dari paket yang ingin dicari.
  /// Mengembalikan nama paket sebagai [String].
  Future<String> getPackageName(final String packageId) async {
    try {
      Log.info('Mengambil nama paket untuk ID: $packageId');
      final doc = await db.collection('paket').doc(packageId).get();
      if (doc.exists && doc.data()!.containsKey('nama')) {
        final packageName = doc.data()!['nama'] as String;
        Log.info('Nama paket ditemukan: $packageName');
        return packageName;
      }
      Log.warning(
        'Paket dengan ID $packageId tidak ditemukan atau tidak memiliki nama.',
      );
      return 'Paket Tidak Ditemukan';
    } on Exception catch (e, s) {
      Log.error('Error mengambil nama paket: $e', e: e, st: s);
      return 'Error Memuat Paket';
    }
  }

  /// Mengambil model [PackageModel] lengkap berdasarkan ID paket.
  ///
  /// [packageId]: ID dari paket yang ingin dicari.
  /// Mengembalikan objek [PackageModel] jika ditemukan, jika tidak, null.
  Future<PackageModel?> getPackageModelById(final String packageId) async {
    try {
      Log.info('Mengambil model paket untuk ID: $packageId');
      final doc = await db.collection('paket').doc(packageId).get();
      if (doc.exists) {
        final package = PackageModel.fromFirebase(doc.id, doc.data()!);
        Log.info('Model paket ditemukan');
        return package;
      }
      Log.warning('Paket dengan ID $packageId tidak ditemukan untuk model.');
      return null;
    } on Exception catch (e, s) {
      Log.error('Error mengambil model paket: $e', e: e, st: s);
      return null;
    }
  }
}
