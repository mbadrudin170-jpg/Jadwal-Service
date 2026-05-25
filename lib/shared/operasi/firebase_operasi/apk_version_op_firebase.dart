// path: lib/shared/operasi/firebase_operasi/apk_version_op_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';

/// A class to handle Firebase operations for `ApkVersionModel`.
class ApkVersionOpFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference with a converter for `ApkVersionModel`.
  late final CollectionReference<ApkVersionModel> _apkVersionCollection =
      _firestore
          .collection(TableNameValue.get(TableName.userApkVersion))
          .withConverter<ApkVersionModel>(
            fromFirestore: (final snapshot, final _) =>
                ApkVersionModel.fromFirebase(snapshot.id, snapshot.data()!),
            toFirestore: (final model, final _) => model.toFirebase(),
          );

  /// Fetches the latest active (non-deleted, non-archived) APK version once.
  ///
  /// Returns a `Future` completing with the latest `ApkVersionModel` or `null`.
  Future<ApkVersionModel?> getLatestApkVersion() async {
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
