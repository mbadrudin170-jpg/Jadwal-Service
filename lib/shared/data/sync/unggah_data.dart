// path: lib/shared/data/sync/unggah_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/model/kritik_saran_model.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/model/pelanggan_aktif_model.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/model/pengaturan_model.dart';
import 'package:wifi/shared/model/pesanan_model.dart';
import 'package:wifi/shared/model/sub_kategori_model.dart';
import 'package:wifi/shared/model/transaksi_model.dart';
import 'package:wifi/shared/model/versi_apk_user_model.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

class LayananUnggahData {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;

  LayananUnggahData({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
    SyncManager? syncManager,
  }) : _dbHelper = dbHelper ?? DatabaseHelper.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _syncManager = syncManager ?? SyncManager() {
    Log.info(
      'LayananUnggahData instance dibuat. '
      'Menggunakan DatabaseHelper: ${_dbHelper.hashCode}, '
      'FirebaseFirestore: ${_firestore.hashCode}, '
      'SyncManager: ${_syncManager.hashCode}',
    );
  }

  Future<void> unggahSemuaData() async {
    Log.info('========================================');
    Log.info('MEMULAI PROSES UNGGAH SEMUA DATA KE FIREBASE');
    Log.info(
      'Proses ini akan mengunggah 11 jenis data (tabel) dari SQLite lokal ke Firestore.',
    );
    Log.info('========================================');

    Log.info(
      'Menyiapkan daftar Future untuk semua fungsi unggah spesifik. '
      'Semua fungsi akan dijalankan secara paralel menggunakan Future.wait.',
    );

    final List<Future<void>> daftarUnggah = [
      unggahDataDompet(),
      unggahDataKategori(),
      unggahDataKritikSaran(),
      unggahDataPaket(),
      unggahDataPelangganAktif(),
      unggahDataPelanggan(),
      unggahDataPesanan(),
      unggahDataTransaksi(),
      unggahDataSubKategori(),
      unggahDataVersiApkUser(),
      unggahDataPengaturan(),
    ];

    Log.info(
      'Total ${daftarUnggah.length} fungsi unggah spesifik telah disiapkan dan siap dieksekusi secara paralel.',
    );

    try {
      Log.info(
        'Menjalankan semua fungsi unggah secara paralel menggunakan Future.wait. '
        'Semua proses unggah akan berjalan bersamaan untuk efisiensi waktu.',
      );
      await Future.wait(daftarUnggah);
      Log.info('========================================');
      Log.info('PROSES UNGGAH SEMUA DATA SELESAI DENGAN SUKSES');
      Log.info(
        'Semua 11 jenis data berhasil diunggah ke Firestore tanpa error.',
      );
      Log.info('========================================');
    } catch (e, s) {
      Log.error(
        'Gagal selama proses unggah massal ke Firestore. '
        'Satu atau lebih fungsi unggah spesifik mengalami kegagalan. '
        'Proses unggah tidak dapat diselesaikan sepenuhnya. '
        'Error ini akan dilempar ulang ke service layer untuk penanganan lebih lanjut.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  // --- FUNGSI UNGGAH SPESIFIK (POLA UJI COBA) ---

  Future<void> unggahDataDompet() async {
    Log.info(
      'Memulai proses unggah data dompet. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk dompet: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<DompetModel>(
        'dompet',
        'dompet',
        DompetModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data dompet selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data dompet. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataKategori() async {
    Log.info(
      'Memulai proses unggah data kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<KategoriModel>(
        'kategori',
        'kategori',
        KategoriModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data kategori selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataKritikSaran() async {
    Log.info(
      'Memulai proses unggah data kritik_saran. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kritik_saran: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<KritikSaranModel>(
        'kritik_saran',
        'kritik_saran',
        KritikSaranModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data kritik_saran selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data kritik_saran. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataPaket() async {
    Log.info(
      'Memulai proses unggah data paket. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk paket: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PaketModel>(
        'paket',
        'paket',
        PaketModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data paket selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data paket. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataPelangganAktif() async {
    Log.info(
      'Memulai proses unggah data pelanggan_aktif. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan_aktif: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PelangganAktifModel>(
        'pelanggan_aktif',
        'pelanggan_aktif',
        PelangganAktifModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pelanggan_aktif selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data pelanggan_aktif. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataPelanggan() async {
    Log.info(
      'Memulai proses unggah data pelanggan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PelangganModel>(
        'pelanggan',
        'pelanggan',
        PelangganModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pelanggan selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data pelanggan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataPesanan() async {
    Log.info(
      'Memulai proses unggah data pesanan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pesanan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<PesananModel>(
        'pesanan',
        'pesan',
        PesananModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pesanan selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data pesanan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataTransaksi() async {
    Log.info(
      'Memulai proses unggah data transaksi. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk transaksi: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<TransaksiModel>(
        'transaksi',
        'transaksi',
        TransaksiModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data transaksi selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data transaksi. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataSubKategori() async {
    Log.info(
      'Memulai proses unggah data sub_kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk sub_kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<SubKategoriModel>(
        'sub_kategori',
        'sub_kategori',
        SubKategoriModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data sub_kategori selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data sub_kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataPengaturan() async {
    Log.info(
      'Memulai proses unggah data pengaturan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pengaturan: ${waktu.toIso8601String()}. '
        'Data pengaturan akan selalu diunggah, jadi waktu ini akan diabaikan pada level query.',
      );
      await unggahDataGenerik<PengaturanModel>(
        'pengaturan',
        'pengaturan',
        PengaturanModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pengaturan selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data pengaturan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataVersiApkUser() async {
    Log.info(
      'Memulai proses unggah data versi_apk_user. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.getTerakhirUnggah();
      Log.info(
        'Waktu sinkronisasi terakhir untuk versi_apk_user: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await unggahDataGenerik<VersiApkUserModel>(
        'versi_apk_user',
        'versi_apk_user',
        VersiApkUserModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data versi_apk_user selesai dengan sukses.');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data versi_apk_user. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  Future<void> unggahDataGenerik<T>(
    String namaTabel,
    String namaKoleksi,
    T Function(Map<String, dynamic>) fromSqlite,
    Map<String, dynamic> Function(T) toFirebase,
    DateTime waktuSinkronisasiTerakhir,
  ) async {
    Log.info('========================================');
    Log.info('MEMULAI UNGGAH DATA GENERIK');
    Log.info('Tabel SQLite sumber: $namaTabel');
    Log.info('Koleksi Firestore tujuan: $namaKoleksi');
    Log.info(
      'Waktu sinkronisasi terakhir: ${waktuSinkronisasiTerakhir.toIso8601String()}',
    );
    Log.info('Tipe data generik: $T');
    Log.info('========================================');

    try {
      Log.info('Mendapatkan instance database SQLite dari DatabaseHelper.');
      final db = await _dbHelper.database;
      Log.info('Instance database berhasil didapatkan.');

      List<Map<String, dynamic>> dataUntukDiunggah;

      // diubah: Kondisi khusus untuk tabel 'pengaturan' agar selalu diunggah, mengabaikan filter waktu.
      if (namaTabel == 'pengaturan') {
        Log.info(
          'Tabel $namaTabel adalah tabel khusus. Mengambil semua data tanpa filter waktu.',
        );
        dataUntukDiunggah = await db.query(namaTabel);
      } else {
        Log.info(
          'Melakukan query pada tabel $namaTabel dengan kondisi: '
          'diperbarui > ${waktuSinkronisasiTerakhir.toIso8601String()}.',
        );
        dataUntukDiunggah = await db.query(
          namaTabel,
          where: 'diperbarui > ?',
          whereArgs: [waktuSinkronisasiTerakhir.toIso8601String()],
        );
      }

      Log.info(
        'Query selesai. Jumlah data yang ditemukan untuk diunggah: ${dataUntukDiunggah.length} baris dari tabel $namaTabel.',
      );

      if (dataUntukDiunggah.isEmpty) {
        Log.info(
          'Tabel $namaTabel sudah sinkron dengan Firestore. '
          'Tidak ada data baru atau yang diperbarui sejak ${waktuSinkronisasiTerakhir.toIso8601String()}. '
          'Proses unggah untuk tabel ini dilewati.',
        );
        return;
      }

      Log.info(
        'Terdapat ${dataUntukDiunggah.length} data yang perlu diunggah dari tabel $namaTabel. '
        'Membuat Firestore batch operation untuk mengunggah data secara atomik.',
      );

      final batchFirestore = _firestore.batch();
      Log.info('Firestore batch berhasil dibuat.');

      int counterSukses = 0;
      int counterError = 0;

      for (int i = 0; i < dataUntukDiunggah.length; i++) {
        final map = dataUntukDiunggah[i];
        Log.info(
          'Memproses data ke-${i + 1}/${dataUntukDiunggah.length} dari tabel $namaTabel.',
        );

        try {
          Log.info(
            'Mengkonversi data SQLite menjadi model $T menggunakan fungsi fromSqlite.',
          );
          final T data = fromSqlite(map);
          final model = data as dynamic;
          Log.info(
            'Konversi berhasil. ID data: ${model.id}. '
            'Membuat referensi dokumen Firestore pada koleksi $namaKoleksi dengan ID ${model.id}.',
          );

          final docRef = _firestore.collection(namaKoleksi).doc(model.id);

          Log.info(
            'Mengkonversi model menjadi Map<String, dynamic> menggunakan fungsi toFirebase.',
          );
          final firebaseData = toFirebase(data);
          Log.info(
            'Konversi ke format Firestore berhasil. '
            'Jumlah field yang akan diunggah: ${firebaseData.length}.',
          );

          Log.info(
            'Menambahkan operasi set dengan merge:true ke batch Firestore untuk dokumen $namaKoleksi/${model.id}. '
            'Merge:true akan menggabungkan data baru dengan data yang sudah ada tanpa menghapus field lain.',
          );
          batchFirestore.set(docRef, firebaseData, SetOptions(merge: true));

          counterSukses++;
          Log.info(
            'Data ke-${i + 1} (ID: ${model.id}) berhasil ditambahkan ke batch Firestore.',
          );
        } catch (e, s) {
          counterError++;
          // diubah: Menggunakan Log.error yang menerima parameter e dan st.
          Log.error(
            'Gagal memproses data ke-${i + 1} dari tabel $namaTabel. '
            'Data ini akan dilewati dan tidak dimasukkan ke batch. '
            'Data SQLite: $map',
            e: e,
            st: s,
          );
        }
      }

      Log.info(
        'Semua data selesai diproses. '
        'Total: ${dataUntukDiunggah.length} data, '
        'Sukses ditambahkan ke batch: $counterSukses, '
        'Gagal: $counterError.',
      );

      if (counterSukses > 0) {
        Log.info(
          'Melakukan commit batch Firestore. '
          'Mengirim $counterSukses dokumen ke koleksi $namaKoleksi secara atomik.',
        );
        await batchFirestore.commit();
        Log.info(
          'Batch commit berhasil. '
          '$counterSukses dokumen dari tabel $namaTabel berhasil diunggah ke Firestore koleksi $namaKoleksi.',
        );
      } else {
        Log.warning(
          'Tidak ada data yang berhasil diproses untuk tabel $namaTabel. '
          'Batch commit tidak dilakukan karena tidak ada data valid untuk diunggah.',
        );
      }

      Log.info('========================================');
      Log.info('PROSES UNGGAH DATA GENERIK SELESAI');
      Log.info('Tabel: $namaTabel -> Koleksi: $namaKoleksi');
      Log.info('Total data diunggah: $counterSukses dokumen');
      Log.info('========================================');
    } catch (e, s) {
      Log.error(
        'Gagal mengunggah data untuk tabel $namaTabel ke koleksi Firestore $namaKoleksi. '
        'Proses unggah data generik mengalami kegagalan. '
        'Kemungkinan penyebab: koneksi database SQLite terputus, '
        'koneksi Firestore gagal, data corrupt, atau format data tidak sesuai. '
        'Error ini akan dilempar ulang ke fungsi pemanggil.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }
}
