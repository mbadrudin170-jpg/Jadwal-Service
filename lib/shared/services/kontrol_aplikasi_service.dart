// path: lib/shared/services/kontrol_aplikasi_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';

// untuk mengontrol status aplikasi pengguna dari jarak jauh
class KontrolAplikasiService {
  // Mendapatkan referensi ke koleksi 'pengaturan' di Firestore.
  final CollectionReference _pengaturanRef = FirebaseFirestore.instance
      .collection('pengaturan');

  // untuk mendapatkan status maintenance dari firestore
  Future<bool> dapatkanStatusMaintenance() async {
    Log.info('Memulai pengambilan status maintenance dari Firestore...');

    try {
      // Mendapatkan dokumen 'status_aplikasi' dari koleksi.
      final doc = await _pengaturanRef.doc('status_aplikasi').get();

      Log.info('Dokumen "status_aplikasi" berhasil ditarik dari server');

      // Jika dokumen ada dan berisi field 'sedang_maintenance', kembalikan nilainya.
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('sedang_maintenance')) {
          final bool status = data['sedang_maintenance'] as bool;
          Log.info('Data ditemukan. Status maintenance saat ini: $status');
          return status;
        } else {
          Log.warning(
            'Dokumen ada, tetapi field "sedang_maintenance" tidak ditemukan. Data: $data',
          );
        }
      } else {
        Log.warning(
          'Dokumen "status_aplikasi" belum dibuat di Firestore. Menggunakan default false.',
        );
      }

      // Jika dokumen tidak ada atau field tidak ada, default ke false (tidak maintenance).
      Log.info('Menggunakan nilai default (false)');
      return false;
    } catch (e, s) {
      // Mencatat error jika gagal mengambil data.
      Log.error(
        'Gagal mengambil status maintenance dari database',
        e: e,
        st: s,
      );
      // Mengembalikan false sebagai fallback jika terjadi error.
      return false;
    }
  }

  // untuk mengubah status maintenance di firestore
  Future<void> aturStatusMaintenance(bool status) async {
    Log.info('Memproses perubahan status maintenance menjadi: $status');

    try {
      // Mengatur (atau membuat jika belum ada) dokumen 'status_aplikasi'
      // dengan field 'sedang_maintenance'.
      await _pengaturanRef.doc('status_aplikasi').set({
        'sedang_maintenance': status,
      });

      Log.info(
        '✨ Berhasil memperbarui status maintenance di Firestore menjadi: $status',
      );
    } catch (e, s) {
      // Mencatat error jika gagal menyimpan data.
      Log.error(
        'Gagal mengatur status maintenance ke database: $status',
        e: e,
        st: s,
      );
      // Melempar kembali error agar bisa ditangani di UI jika perlu.
      rethrow;
    }
  }
}
