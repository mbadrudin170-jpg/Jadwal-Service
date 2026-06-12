// path: lib/shared/operasi/firebase_operasi/apk_version_op_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';

/// Kelas untuk menangani operasi Firebase untuk `ApkVersionModel`.
class ApkVersionOpFirebase {
  final FirebaseFirestore _firestore;

  /// Konstruktor untuk inisialisasi dengan instansi FirebaseFirestore opsional.
  ApkVersionOpFirebase({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referensi koleksi dengan konverter untuk `ApkVersionModel`.
  late final CollectionReference<ApkVersionModel> _apkVersionCollection =
      _firestore
          .collection(TableNameValue.get(TableName.userApkVersion))
          .withConverter<ApkVersionModel>(
            fromFirestore: (final snapshot, final _) =>
                ApkVersionModel.fromFirebase(snapshot.id, snapshot.data()!),
            toFirestore: (final model, final _) => model.toFirebase(),
          );

  /// Mengambil versi APK terbaru yang aktif (tidak dihapus, tidak diarsipkan) satu kali.
  ///
  /// Mengembalikan `Future` yang berisi `ApkVersionModel` terbaru atau `null`.
  Future<ApkVersionModel?> ambilVersiTerbaru() async {
    Log.info('Memulai mengambil versi APK terbaru');
    try {
      final querySnapshot = await _apkVersionCollection
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .where(ColumnNames.archivedAt, isNull: true)
          .orderBy(ColumnNames.updatedAt, descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        Log.info('Versi APK terbaru berhasil diambil', data.toFirebase());
        return data;
      }
      Log.warning('Tidak ada versi APK aktif yang ditemukan');
      return null;
    } on Exception catch (e, st) {
      Log.error('Error saat mengambil versi APK', e: e, st: st);
      rethrow;
    }
  }
}
