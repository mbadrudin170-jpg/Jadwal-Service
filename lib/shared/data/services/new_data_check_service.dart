// path: lib/shared/data/services/new_data_check_service.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai service pengecekan data baru untuk sinkronisasi.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/operasi/upload_status_operation.dart (UploadStatusOperation)
//   - lib/shared/utils/sync_manager.dart (SyncManager)
//   - lib/shared/debug/log.dart (Log)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/upload_status_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Layanan untuk memeriksa apakah ada data baru di SQLite atau Firebase.
class NewDataCheckService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  final UploadStatusOperation _uploadStatusOperation;

  /// Konstruktor untuk NewDataCheckService.
  ///
  /// Menginisialisasi [_firestore], [_syncManager], dan [_uploadStatusOperation].
  /// Jika tidak ada instance yang diberikan, maka akan membuat instance baru.
  NewDataCheckService({
    final FirebaseFirestore? firestore,
    final SyncManager? syncManager,
    final UploadStatusOperation? uploadStatusOperation,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _syncManager = syncManager ?? SyncManager(),
        _uploadStatusOperation =
            uploadStatusOperation ?? UploadStatusOperation() {
    Log.info(
      'Inisialisasi NewDataCheckService berhasil. Komponen FirebaseFirestore untuk akses cloud, SyncManager untuk manajemen waktu lokal, dan UploadStatusOperation untuk akses bendera SQLite telah siap digunakan.',
    );
  }

  /// Memeriksa apakah ada data baru di SQLite yang perlu diunggah.
  ///
  /// Mengembalikan `true` jika ada data baru, `false` jika tidak.
  Future<bool> hasNewSqliteData() async {
    Log.info(
      'Memulai prosedur pengecekan data lokal di SQLite. Sistem akan memverifikasi apakah ada perubahan data yang belum diunggah ke server.',
    );

    try {
      Log.info(
        'Mengakses UploadStatusOperation untuk membaca nilai dari kolom need_upload di database internal. Ini adalah indikator utama apakah aplikasi memiliki payload baru.',
      );
      final bool result = await _uploadStatusOperation.getNeedUpload();

      if (result) {
        Log.info(
          'Hasil pengecekan SQLite: Ditemukan bendera need_upload bernilai TRUE. Aplikasi memiliki data baru yang harus segera disinkronisasikan ke server.',
        );
      } else {
        Log.info(
          'Hasil pengecekan SQLite: Bendera need_upload bernilai FALSE. Tidak ada perubahan data lokal yang memerlukan tindakan pengunggahan saat ini.',
        );
      }
      return result;
    } on Exception catch (e, s) {
      Log.error(
        'Gagal melakukan pengecekan status need_upload pada SQLite. Terjadi kesalahan pada query database atau akses file database lokal terhambat.',
        e: e,
        st: s,
      );
      return false;
    }
  }

  /// Mereset status `need_upload` menjadi false.
  Future<void> resetNeedUpload() async {
    Log.info('Mereset bendera need_upload menjadi false.');
    try {
      await _uploadStatusOperation.resetNeedUpload();
      Log.info('Bendera need_upload berhasil direset.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mereset bendera need_upload.',
        e: e,
        st: s,
      );
    }
  }

  /// Memeriksa apakah ada data baru di Firebase yang perlu diunduh.
  ///
  /// Membandingkan waktu terakhir diunduh secara lokal dengan waktu terakhir
  /// diperbarui di Firebase.
  ///
  /// Mengembalikan `true` jika ada data baru, `false` jika tidak.
  Future<bool> hasNewFirebaseData({
    required final String collectionName,
    required final String documentId,
  }) async {
    Log.info(
      'Memulai prosedur pembandingan timestamp server. Lokasi target koleksi: "$collectionName", dokumen: "$documentId". Prosedur ini akan menentukan apakah aplikasi perlu mengunduh data terbaru.',
    );

    try {
      Log.info(
        'Mengambil metadata waktu unduhan terakhir dari penyimpanan preferensi lokal melalui SyncManager.',
      );
      final DateTime localTime = await _syncManager.getLastDownload();
      Log.info(
        'Timestamp unduhan lokal terakhir yang tercatat adalah: $localTime',
      );

      Log.info(
        'Membangun referensi dokumen Firestore dan memulai permintaan pengambilan data langsung dari server cloud (Source.server).',
      );
      final DocumentReference docRef =
          _firestore.collection(collectionName).doc(documentId);
      final DocumentSnapshot docSnapshot = await docRef.get(
        const GetOptions(source: Source.server),
      );

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Log.info(
          'Dokumen status ditemukan di server. Melakukan ekstraksi payload data untuk mencari field pembanding.',
        );
        final data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('diperbarui')) {
          Log.info(
            'Field "diperbarui" ditemukan pada dokumen server. Mengonversi tipe data Timestamp Firestore ke objek DateTime Dart.',
          );
          final DateTime serverTime =
              (data['diperbarui'] as Timestamp).toDate();
          Log.info('Waktu pembaruan di server adalah: $serverTime');

          final bool isAfter = serverTime.isAfter(localTime);
          if (isAfter) {
            Log.info(
              'Kesimpulan: Waktu server ($serverTime) lebih baru daripada waktu lokal ($localTime). PENGUNDUHAN DATA DIPERLUKAN untuk menjaga aktualitas data.',
            );
          } else {
            Log.info(
              'Kesimpulan: Waktu server tidak lebih baru daripada waktu lokal. Data aplikasi saat ini sudah sinkron dengan versi terbaru di server.',
            );
          }
          return isAfter;
        } else {
          Log.warning(
            'Struktur data dokumen di server tidak sesuai standar. Field "diperbarui" tidak ditemukan. Sistem mengasumsikan tidak ada pembaruan untuk menghindari pengunduhan yang tidak perlu.',
          );
          return false;
        }
      } else {
        Log.warning(
          'Dokumen target "$documentId" tidak tersedia di koleksi "$collectionName" pada server Firebase. Pastikan dokumen status global telah dibuat di konsol Firebase.',
        );
        return false;
      }
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kegagalan saat proses pembandingan waktu server dan lokal. Masalah mungkin terletak pada koneksi jaringan atau hak akses (Security Rules) Firebase Firestore.',
        e: e,
        st: s,
      );
      return false;
    }
  }
}
