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

  /// Streams the latest active (non-deleted, non-archived) APK version.
  ///
  /// Returns a stream that emits the latest `ApkVersionModel` or `null` if none is found.
  Stream<ApkVersionModel?> streamLatestApkVersion() {
    Log.info('Memulai streaming versi APK terbaru');
    try {
      return _apkVersionCollection
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .where(ColumnNames.archivedAt, isNull: true)
          .orderBy(ColumnNames.updatedAt, descending: true)
          .limit(1)
          .snapshots()
          .map((final snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          Log.info('Menerima update streaming versi APK', data.toFirebase());
          return data;
        }
        Log.warning('Stream: Tidak ada versi APK aktif yang ditemukan');
        return null;
      }).handleError((final Object e, final StackTrace st) {
        Log.error('Error pada stream versi APK', e: e, st: st);
        // The stream will emit the error, which should be handled by the listener.
      });
    } on Exception catch (e, st) {
      Log.error('Gagal memulai stream versi APK', e: e, st: st);
      return Stream.error(e);
    }
  }

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

  /// Adds a new APK version document to Firestore.
  Future<void> addApkVersion(final ApkVersionModel apkVersion) async {
    Log.info('Menambahkan versi APK baru', apkVersion.toFirebase());
    try {
      await _apkVersionCollection.doc(apkVersion.id).set(apkVersion);
      Log.info('Versi APK baru berhasil ditambahkan', {'id': apkVersion.id});
    } on Exception catch (e, st) {
      Log.error('Gagal menambahkan versi APK baru',
          e: e, st: st, data: apkVersion.toFirebase());
      rethrow;
    }
  }

  /// Updates an existing APK version document in Firestore.
  ///
  /// Merges data by default and updates the `updatedAt` timestamp.
  Future<void> updateApkVersion(final ApkVersionModel apkVersion) async {
    Log.info('Memperbarui versi APK', apkVersion.toFirebase());
    try {
      // Ensure updatedAt is always current on update
      final modelToUpdate = apkVersion.copyWith(updatedAt: DateTime.now());
      await _apkVersionCollection
          .doc(modelToUpdate.id)
          .set(modelToUpdate, SetOptions(merge: true));
      Log.info('Versi APK berhasil diperbarui', {'id': apkVersion.id});
    } on Exception catch (e, st) {
      Log.error('Gagal memperbarui versi APK',
          e: e, st: st, data: apkVersion.toFirebase());
      rethrow;
    }
  }

  /// Soft deletes an APK version by setting `isDeleted` to true.
  Future<void> softDeleteApkVersion(final String id) async {
    Log.info('Memulai soft delete untuk versi APK ID: $id');
    try {
      await _apkVersionCollection.doc(id).update({
        ColumnNames.isDeleted: true,
        ColumnNames.updatedAt: FieldValue.serverTimestamp(),
      });
      Log.info('Versi APK dengan ID: $id berhasil di-soft delete');
    } on Exception catch (e, st) {
      Log.error('Gagal soft delete versi APK', e: e, st: st, data: {'id': id});
      rethrow;
    }
  }

  /// Archives an APK version by setting the `archivedAt` timestamp.
  Future<void> archiveApkVersion(final String id) async {
    Log.info('Mengarsipkan versi APK dengan ID: $id');
    try {
      final now = FieldValue.serverTimestamp();
      await _apkVersionCollection.doc(id).update({
        ColumnNames.archivedAt: now,
        ColumnNames.updatedAt: now,
      });
      Log.info('Versi APK dengan ID: $id berhasil diarsipkan');
    } on Exception catch (e, st) {
      Log.error('Gagal mengarsipkan versi APK', e: e, st: st, data: {'id': id});
      rethrow;
    }
  }
}
