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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/status_upload_op_sqlite.dart';
import 'package:wifi/shared/utils/parser_util.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

class PengecekanDataBaruService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  final StatusUploadOpSqlite _statusUploadOpSqlite;

  /// Konstruktor dengan injeksi dependensi.
  PengecekanDataBaruService({
    required FirebaseFirestore firestore,
    required SyncManager syncManager,
    required StatusUploadOpSqlite uploadStatusOperation,
  })  : _firestore = firestore,
        _syncManager = syncManager,
        _statusUploadOpSqlite = uploadStatusOperation {
    Log.info('NewDataCheckService diinisialisasi dengan dependency injection.');
  }

  /// Memeriksa apakah ada data baru di SQLite yang perlu diunggah.
  ///
  /// Mengembalikan `true` jika ada data baru, `false` jika tidak.
  Future<bool> apakahSqliteAdaDataBaru() async {
    Log.info(
      'Memulai prosedur pengecekan data lokal di SQLite. Sistem akan memverifikasi apakah ada perubahan data yang belum diunggah ke server.',
    );

    try {
      Log.info(
        'Mengakses UploadStatusOperation untuk membaca nilai dari kolom need_upload di database internal. Ini adalah indikator utama apakah aplikasi memiliki payload baru.',
      );
      final bool result = await _statusUploadOpSqlite.ambilButuhUpload();

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
        s: s,
      );
      return false;
    }
  }

  /// Mereset status `need_upload` menjadi false.
  Future<void> resetButuhUpload() async {
    Log.info('Mereset bendera need_upload menjadi false.');
    try {
      await _statusUploadOpSqlite.resetStatusUpload();
      Log.info('Bendera need_upload berhasil direset.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mereset bendera need_upload.',
        e: e,
        s: s,
      );
    }
  }

  /// Memeriksa apakah ada data baru di Firebase yang perlu diunduh.
  ///
  /// Membandingkan waktu terakhir diunduh secara lokal dengan waktu terakhir
  /// diperbarui di Firebase.
  ///
  /// Mengembalikan `true` jika ada data baru, `false` jika tidak.
  Future<bool> apakahFirebaseAdaDataBaru({
    required final String namaKoleksi,
    required final String idDokumen,
  }) async {
    Log.info(
      'Memulai prosedur pembandingan timestamp server. Lokasi target koleksi: "$namaKoleksi", dokumen: "$idDokumen". Prosedur ini akan menentukan apakah aplikasi perlu mengunduh data terbaru.',
    );

    try {
      Log.info(
        'Mengambil metadata waktu unduhan terakhir dari penyimpanan preferensi lokal melalui SyncManager.',
      );
      final DateTime tanggalTerakhirDownload =
          await _syncManager.ambilTanggalTerakhirDownload();
      Log.info(
        'Timestamp unduhan lokal terakhir yang tercatat adalah: $tanggalTerakhirDownload',
      );

      Log.info(
        'Membangun referensi dokumen Firestore dan memulai permintaan pengambilan data langsung dari server cloud (Source.server).',
      );
      final DocumentReference docRef =
          _firestore.collection(namaKoleksi).doc(idDokumen);
      final DocumentSnapshot docSnapshot = await docRef.get(
        const GetOptions(source: Source.server),
      );

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Log.info(
          'Dokumen status ditemukan di server. Melakukan ekstraksi payload data untuk mencari field pembanding.',
        );
        final data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey(NamaKolom.updatedAt)) {
          Log.info(
            'Field "${NamaKolom.updatedAt}" ditemukan. Mem-parsing nilai: ${data[NamaKolom.updatedAt]}',
          );
          final DateTime? tanggalUpdateAt =
              ParserUtil.parseDateTime(data[NamaKolom.updatedAt]);

          if (tanggalUpdateAt == null) {
            Log.warning(
              'Gagal mem-parsing nilai "${NamaKolom.updatedAt}" dari server. '
              'Nilai tidak valid atau format tidak didukung. '
              'Mengasumsikan tidak ada data baru.',
            );
            return false;
          }

          Log.info('Waktu pembaruan di server adalah: $tanggalUpdateAt');

          final bool isAfter = tanggalUpdateAt.isAfter(tanggalTerakhirDownload);
          if (isAfter) {
            Log.info(
              'Kesimpulan: Waktu server ($tanggalUpdateAt) lebih baru daripada waktu lokal ($tanggalTerakhirDownload). PENGUNDUHAN DATA DIPERLUKAN untuk menjaga aktualitas data.',
            );
          } else {
            Log.info(
              'Kesimpulan: Waktu server tidak lebih baru daripada waktu lokal. Data aplikasi saat ini sudah sinkron dengan versi terbaru di server.',
            );
          }
          return isAfter;
        } else {
          Log.warning(
            'Struktur data dokumen di server tidak sesuai standar. Field "${NamaKolom.updatedAt}" tidak ditemukan. Sistem mengasumsikan tidak ada pembaruan untuk menghindari pengunduhan yang tidak perlu.',
          );
          return false;
        }
      } else {
        Log.warning(
          'Dokumen target "$idDokumen" tidak tersedia di koleksi "$namaKoleksi" pada server Firebase. Pastikan dokumen status global telah dibuat di konsol Firebase.',
        );
        return false;
      }
    } on Exception catch (e, s) {
      Log.error(
        'Terjadi kegagalan saat proses pembandingan waktu server dan lokal. Masalah mungkin terletak pada koneksi jaringan atau hak akses (Security Rules) Firebase Firestore.',
        e: e,
        s: s,
      );
      return false;
    }
  }
}

final pengecekanDataBaruBaruServiceProvider =
    Provider<PengecekanDataBaruService>((ref) {
  return PengecekanDataBaruService(
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(syncManagerProvider),
    uploadStatusOperation: ref.read(statusUploadOpSlite),
  );
});
