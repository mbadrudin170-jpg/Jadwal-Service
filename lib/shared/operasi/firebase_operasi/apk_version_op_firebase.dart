// path: lib/shared/operasi/firebase_operasi/apk_version_op_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/apk_version_model.dart';

/// Kelas untuk menangani operasi Firebase untuk `ApkVersionModel`.
class ApkVersionOpFirebase {
  final FirebaseFirestore _firestore;

  /// Konstruktor untuk inisialisasi dengan instansi FirebaseFirestore opsional.
  ApkVersionOpFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referensi koleksi dengan konverter untuk `ApkVersionModel`.
  late final CollectionReference<ApkVersionModel> _colection = _firestore
      .collection(NamaTabel.userApkVersion)
      .withConverter<ApkVersionModel>(
        fromFirestore: (snapshot, _) =>
            ApkVersionModel.fromFirebase(snapshot.id, snapshot.data()!),
        toFirestore: (model, _) => model.toFirebase(),
      );

  /// Mengambil versi APK terbaru yang aktif (tidak dihapus, tidak diarsipkan) satu kali.
  ///
  /// Mengembalikan `Future` yang berisi `ApkVersionModel` terbaru atau `null`.
  Future<ApkVersionModel?> getVersiTerbaru() async {
    Log.info('Memulai mengambil versi APK terbaru');
    try {
      final query = await _colection
          .where(NamaKolom.isDeleted, isEqualTo: false)
          .where(NamaKolom.archivedAt, isNull: true)
          .orderBy(NamaKolom.updatedAt, descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        Log.info('Versi APK terbaru berhasil diambil', data.toFirebase());
        return data;
      }
      Log.warning('Tidak ada versi APK aktif yang ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Error saat mengambil versi APK', e: e, s: st);
      rethrow;
    }
  }
}
