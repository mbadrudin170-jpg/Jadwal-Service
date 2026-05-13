// path: lib/data/services/pengecekan_waktu_sync_services.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/data/services/pengecekan_data_baru.dart';
import 'package:wifi/shared/data/sync/unduh_data.dart';
import 'package:wifi/shared/data/sync/unggah_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

class PengecekanWaktuSyncService {
  final SyncManager _syncManager;
  final LayananUnggahData _layananUnggah;
  final LayananUnduhData _layananUnduh;
  final PengecekanDataBaruService _pengecekanDataBaru;
  // ditambah: Tambahkan instance firestore untuk memperbarui status global
  final FirebaseFirestore _firestore;

  PengecekanWaktuSyncService({
    SyncManager? syncManager,
    LayananUnggahData? layananUnggah,
    LayananUnduhData? layananUnduh,
    PengecekanDataBaruService? pengecekanDataBaru,
    FirebaseFirestore? firestore,
  })  : _syncManager = syncManager ?? SyncManager(),
        _layananUnggah = layananUnggah ?? LayananUnggahData(),
        _layananUnduh = layananUnduh ?? LayananUnduhData(),
        _pengecekanDataBaru = pengecekanDataBaru ?? PengecekanDataBaruService(),
        _firestore = firestore ?? FirebaseFirestore.instance {
    Log.info(
      'Inisialisasi PengecekanWaktuSyncService berhasil. Seluruh dependensi utama seperti SyncManager (pengelola status), LayananUnggah (pengiriman data), LayananUnduh (penerimaan data), dan PengecekanDataBaruService (detektor perubahan) telah disuntikkan ke dalam sistem dan siap digunakan.',
    );
  }

  Future<void> jalankanPengecekanDanSinkronisasi() async {
    Log.info(
      'Memulai siklus orkestrasi sinkronisasi global. Prosedur ini akan menjalankan dua fase utama secara berurutan: Fase Sinkronisasi Keluar (Upload) untuk memastikan data lokal terkirim ke cloud, kemudian Fase Sinkronisasi Masuk (Download) untuk memastikan data lokal tetap aktual dengan cloud.',
    );

    // diubah: Tangkap status apakah ada data yang diunggah.
    final bool adaDataDiunggah = await _cekDanJalankanUnggah();

    // diubah: Jika ada data yang diunggah, perbarui dokumen status global.
    if (adaDataDiunggah) {
      Log.info(
        'Pemicu sinkronisasi: Ada data baru yang diunggah. Memperbarui dokumen status/global di server.',
      );
      await _updateStatusGlobal();
    }

    Log.info(
      'Fase Pertama (Unggah) telah diselesaikan atau dilewati. Melanjutkan ke Fase Kedua: Memulai prosedur pemeriksaan pembaruan data di server cloud.',
    );

    await _cekDanJalankanUnduh();

    Log.info(
      'Seluruh siklus jalankanPengecekanDanSinkronisasi() telah berakhir dengan sukses. Status sinkronisasi lokal dan server kini seharusnya berada dalam kondisi konsisten.',
    );
  }

  // diubah: Fungsi ini sekarang mengembalikan boolean.
  Future<bool> _cekDanJalankanUnggah() async {
    Log.info(
      'Menjalankan fungsi internal _cekDanJalankanUnggah(). Sistem akan melakukan inspeksi pada database SQLite lokal untuk mendeteksi adanya entri data baru atau perubahan yang belum ditandai sebagai tersinkronisasi.',
    );

    try {
      final bool apakahAdaDataUntukDiunggah =
          await _pengecekanDataBaru.apakahSqliteAdaDataBaru();

      if (apakahAdaDataUntukDiunggah) {
        Log.info(
          'Deteksi Berhasil: Ditemukan data baru di penyimpanan lokal yang memerlukan sinkronisasi ke cloud. Mempersiapkan pemanggilan LayananUnggahData untuk memproses migrasi data.',
        );
        await _layananUnggah.unggahSemuaData();
        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnggah(waktuSekarang);
        Log.info(
          'Metadata sinkronisasi berhasil diperbarui. Waktu terakhir unggah (last_upload_timestamp) kini disetel pada: $waktuSekarang.',
        );
        return true; // diubah: Kembalikan true karena ada data yang diunggah.
      } else {
        Log.info(
          'Hasil Pengecekan: Tidak ditemukan record baru atau perubahan data pada database SQLite lokal. Melewati fase pengunggahan untuk menghemat bandwidth dan sumber daya sistem.',
        );
        return false; // diubah: Kembalikan false karena tidak ada data yang diunggah.
      }
    } catch (e, s) {
      Log.error(
        'Kegagalan Operasional: Terjadi kesalahan fatal selama fase pengecekan atau pengunggahan data lokal ke server. Proses sinkronisasi keluar dihentikan secara paksa untuk mencegah korupsi data.',
        e: e,
        st: s,
      );
      return false; // diubah: Kembalikan false jika terjadi error.
    }
  }

  // ditambah: Fungsi baru untuk membuat/memperbarui dokumen status global.
  Future<void> _updateStatusGlobal() async {
    try {
      await _firestore.collection('status').doc('global').set(
          {'diperbarui': FieldValue.serverTimestamp()},
          SetOptions(merge: true));
      Log.info(
        'Dokumen status/global berhasil diperbarui dengan server timestamp.',
      );
    } catch (e, s) {
      Log.error(
        'Gagal memperbarui dokumen status/global di Firestore.',
        e: e,
        st: s,
      );
    }
  }

  Future<void> _cekDanJalankanUnduh() async {
    Log.info(
      'Menjalankan fungsi internal _cekDanJalankanUnduh(). Sistem akan melakukan handshake dengan Firebase Firestore untuk memeriksa apakah ada pembaruan data dari admin atau user lain yang perlu diterapkan di database lokal.',
    );

    try {
      Log.info(
        // diubah: Memperbaiki nama koleksi dari data_baru ke status.
        'Mengirim permintaan pengecekan ke Firebase melalui apakahFirebaseAdaDataBaru() pada koleksi: "status", dokumen: "global". Mencari perbedaan timestamp antara server dan lokal.',
      );

      final bool apakahAdaDataBaruDiServer =
          await _pengecekanDataBaru.apakahFirebaseAdaDataBaru(
        namaKoleksi: 'status', // diubah: Nama koleksi diperbaiki.
        idDokumen: 'global',
      );

      if (apakahAdaDataBaruDiServer) {
        Log.info(
          'Deteksi Server: Server cloud memiliki data yang lebih baru dibandingkan database lokal. Menginisiasi proses pengunduhan data secara menyeluruh.',
        );

        await _layananUnduh.unduhSemuaData();
        final waktuSekarang = DateTime.now();
        await _syncManager.setTerakhirUnduh(waktuSekarang);

        Log.info(
          'Sinkronisasi masuk selesai. Metadata last_download_timestamp telah diperbarui menjadi: $waktuSekarang. Data lokal kini identik dengan data server.',
        );
      } else {
        Log.info(
          'Hasil Pengecekan Server: Cloud tidak memiliki pembaruan data (data lokal sudah up-to-date). Menghentikan fase pengunduhan untuk efisiensi.',
        );
      }
    } catch (e, s) {
      Log.error(
        'Kegagalan Operasional: Terjadi error saat mencoba mengambil atau memproses data baru dari server cloud ke penyimpanan lokal.',
        e: e,
        st: s,
      );
    }
  }
}
