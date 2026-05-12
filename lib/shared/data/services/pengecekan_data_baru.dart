// path: lib/data/services/pengecekan_data_baru.dart
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/status_unggah_operasi.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengecekanDataBaruService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  final StatusUnggahOperasi _statusUnggahOperasi;

  PengecekanDataBaruService({
    FirebaseFirestore? firestore,
    SyncManager? syncManager,
    StatusUnggahOperasi? statusUnggahOperasi,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _syncManager = syncManager ?? SyncManager(),
       _statusUnggahOperasi = statusUnggahOperasi ?? StatusUnggahOperasi() {
    Log.info(
      'Inisialisasi PengecekanDataBaruService berhasil. Komponen FirebaseFirestore untuk akses cloud, SyncManager untuk manajemen waktu lokal, dan StatusUnggahOperasi untuk akses bendera SQLite telah siap digunakan.',
    );
  }

  Future<bool> apakahSqliteAdaDataBaru() async {
    Log.info(
      'Memulai prosedur pengecekan data lokal di SQLite. Sistem akan memverifikasi apakah ada perubahan data yang belum diunggah ke server.',
    );

    try {
      Log.info(
        'Mengakses StatusUnggahOperasi untuk membaca nilai dari kolom perlu_unggah di database internal. Ini adalah indikator utama apakah aplikasi memiliki payload baru.',
      );
      final bool hasil = await _statusUnggahOperasi.getPerluUnggah();

      if (hasil) {
        Log.info(
          'Hasil pengecekan SQLite: Ditemukan bendera perlu_unggah bernilai TRUE. Aplikasi memiliki data baru yang harus segera disinkronisasikan ke server.',
        );
      } else {
        Log.info(
          'Hasil pengecekan SQLite: Bendera perlu_unggah bernilai FALSE. Tidak ada perubahan data lokal yang memerlukan tindakan pengunggahan saat ini.',
        );
      }
      return hasil;
    } catch (e, s) {
      Log.error(
        'Gagal melakukan pengecekan status perlu_unggah pada SQLite. Terjadi kesalahan pada query database atau akses file database lokal terhambat.',
        e: e,
        st: s,
      );
      return false;
    }
  }

  Future<bool> apakahFirebaseAdaDataBaru({
    required String namaKoleksi,
    required String idDokumen,
  }) async {
    Log.info(
      'Memulai prosedur pembandingan timestamp server. Lokasi target koleksi: "$namaKoleksi", dokumen: "$idDokumen". Prosedur ini akan menentukan apakah aplikasi perlu mengunduh data terbaru.',
    );

    try {
      Log.info(
        'Mengambil metadata waktu unduhan terakhir dari penyimpanan preferensi lokal melalui SyncManager.',
      );
      final DateTime waktuLokal = await _syncManager.getTerakhirUnduh();
      Log.info(
        'Timestamp unduhan lokal terakhir yang tercatat adalah: $waktuLokal',
      );

      Log.info(
        'Membangun referensi dokumen Firestore dan memulai permintaan pengambilan data langsung dari server cloud (Source.server).',
      );
      final DocumentReference docRef = _firestore
          .collection(namaKoleksi)
          .doc(idDokumen);
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
          final DateTime waktuServer = (data['diperbarui'] as Timestamp)
              .toDate();
          Log.info('Waktu pembaruan di server adalah: $waktuServer');

          final bool isAfter = waktuServer.isAfter(waktuLokal);
          if (isAfter) {
            Log.info(
              'Kesimpulan: Waktu server ($waktuServer) lebih baru daripada waktu lokal ($waktuLokal). PENGUNDUHAN DATA DIPERLUKAN untuk menjaga aktualitas data.',
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
          'Dokumen target "$idDokumen" tidak tersedia di koleksi "$namaKoleksi" pada server Firebase. Pastikan dokumen status global telah dibuat di konsol Firebase.',
        );
        return false;
      }
    } catch (e, s) {
      Log.error(
        'Terjadi kegagalan saat proses pembandingan waktu server dan lokal. Masalah mungkin terletak pada koneksi jaringan atau hak akses (Security Rules) Firebase Firestore.',
        e: e,
        st: s,
      );
      return false;
    }
  }
}
