// path: lib/shared/data/sync/layanan_unggah_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/sinkronisasi/pengelola_sinkronisasi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/model/has_id.dart';

class LayananUnggahData {
  final SqliteDatabase _sqliteDb;
  final FirebaseFirestore _firestore;
  final PengelolaSinkronisasi _syncManager;

  LayananUnggahData({
    required SqliteDatabase sqliteDb,
    required FirebaseFirestore firestore,
    required PengelolaSinkronisasi syncManager,
  }) : _sqliteDb = sqliteDb,
       _firestore = firestore,
       _syncManager = syncManager {
    Log.info('UploadDataService diinisialisasi dengan dependency injection.');
  }

  /// Mengunggah semua data dari semua tabel lokal ke koleksi Firestore yang sesuai.
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

    final List<Future<void>> daftarTabel = [
      unggahDataDompet(),
      unggahDataKategori(),
      unggahDataFeedback(),
      unggahDataPaket(),
      unggahDataPelangganAktif(),
      uploadCustomerData(),
      uploadOrderData(),
      uploadDataTransaksi(),
      uploadSubCategoryData(),
      uploadApkVersionData(),
      uploadSettingsData(),
    ];

    Log.info(
      'Total ${daftarTabel.length} fungsi unggah spesifik telah disiapkan dan siap dieksekusi secara paralel.',
    );

    try {
      Log.info(
        'Menjalankan semua fungsi unggah secara paralel menggunakan Future.wait. '
        'Semua proses unggah akan berjalan bersamaan untuk efisiensi waktu.',
      );
      await Future.wait(daftarTabel);
      Log.info('========================================');
      Log.info('PROSES UNGGAH SEMUA DATA SELESAI DENGAN SUKSES');
      Log.info(
        'Semua 11 jenis data berhasil diunggah ke Firestore tanpa error.',
      );
      Log.info('========================================');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal selama proses unggah massal ke Firestore. '
        'Satu atau lebih fungsi unggah spesifik mengalami kegagalan. '
        'Proses unggah tidak dapat diselesaikan sepenuhnya. '
        'Error ini akan dilempar ulang ke service layer untuk penanganan lebih lanjut.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data dompet ke Firestore.
  Future<void> unggahDataDompet() async {
    Log.info(
      'Memulai proses unggah data dompet. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk dompet: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<DompetModel>(
        NamaTabel.dompet,
        NamaTabel.dompet,
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
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data kategori ke Firestore.
  Future<void> unggahDataKategori() async {
    Log.info(
      'Memulai proses unggah data kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<KategoriModel>(
        NamaTabel.kategori,
        NamaTabel.kategori,
        KategoriModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data kategori selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data kritik dan saran ke Firestore.
  Future<void> unggahDataFeedback() async {
    Log.info(
      'Memulai proses unggah data kritik_saran. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final terkahirUpload = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kritik_saran: ${terkahirUpload.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<FeedbackModel>(
        NamaTabel.feedback,
        NamaTabel.feedback,
        FeedbackModel.fromSqlite,
        (m) => m.toFirebase(),
        terkahirUpload,
      );
      Log.info('Proses unggah data kritik_saran selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data kritik_saran. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data paket ke Firestore.
  Future<void> unggahDataPaket() async {
    Log.info(
      'Memulai proses unggah data paket. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk paket: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PaketModel>(
        NamaTabel.paket,
        NamaTabel.paket,
        PaketModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data paket selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data paket. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pelanggan aktif ke Firestore.
  Future<void> unggahDataPelangganAktif() async {
    Log.info(
      'Memulai proses unggah data pelanggan_aktif. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan_aktif: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PelangganAktifModel>(
        NamaTabel.pelangganAktif,
        NamaTabel.pelangganAktif,
        PelangganAktifModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pelanggan_aktif selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pelanggan_aktif. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pelanggan ke Firestore.
  Future<void> uploadCustomerData() async {
    Log.info(
      'Memulai proses unggah data pelanggan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PelangganModel>(
        NamaTabel.pelanggan,
        NamaTabel.pelanggan,
        PelangganModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pelanggan selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pelanggan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pesanan ke Firestore.
  Future<void> uploadOrderData() async {
    Log.info(
      'Memulai proses unggah data pesanan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pesanan: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<OrderModel>(
        NamaTabel.pesananPelanggan,
        NamaTabel.pesananPelanggan,
        OrderModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pesanan selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pesanan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data transaksi ke Firestore.
  Future<void> uploadDataTransaksi() async {
    Log.info(
      'Memulai proses unggah data transaksi. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk transaksi: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<TransaksiModel>(
        NamaTabel.transaksi,
        NamaTabel.transaksi,
        TransaksiModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data transaksi selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data transaksi. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data sub-kategori ke Firestore.
  Future<void> uploadSubCategoryData() async {
    Log.info(
      'Memulai proses unggah data sub_kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk sub_kategori: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<SubKategoriModel>(
        NamaTabel.subKategori,
        NamaTabel.subKategori,
        SubKategoriModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data sub_kategori selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data sub_kategori. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data pengaturan ke Firestore.
  Future<void> uploadSettingsData() async {
    Log.info(
      'Memulai proses unggah data pengaturan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pengaturan: ${waktu.toIso8601String()}. '
        'Data pengaturan akan selalu diunggah, jadi waktu ini akan diabaikan pada level query.',
      );
      await uploadGenericData<SettingsModel>(
        NamaTabel.settings,
        NamaTabel.settings,
        SettingsModel.fromSqlite,
        (final m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data pengaturan selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data pengaturan. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data versi APK user ke Firestore.
  Future<void> uploadApkVersionData() async {
    Log.info(
      'Memulai proses unggah data versi_apk_user. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final waktu = await _syncManager.ambilWaktuTerakhirUnggahPreferensi();
      Log.info(
        'Waktu sinkronisasi terakhir untuk versi_apk_user: ${waktu.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<VersiApkModel>(
        NamaTabel.versiApkUser,
        NamaTabel.versiApkUser,
        VersiApkModel.fromSqlite,
        (m) => m.toFirebase(),
        waktu,
      );
      Log.info('Proses unggah data versi_apk_user selesai dengan sukses.');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data versi_apk_user. '
        'Kemungkinan penyebab: gagal membaca data dari SQLite, '
        'gagal mengambil waktu sinkronisasi, atau gagal menulis ke Firestore.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data secara generik dari tabel SQLite ke koleksi Firestore.
  ///
  /// [T] adalah tipe model data yang akan diunggah.
  /// [namaTabel] adalah nama tabel di SQLite.
  /// [namaKoleksi] adalah nama koleksi di Firestore.
  /// [fromSqlite] adalah fungsi untuk mengonversi data dari SQLite ke model.
  /// [toFirebase] adalah fungsi untuk mengonversi model ke format data Firestore.
  /// [waktuTerakhirSinkronisasi] adalah waktu terakhir data disinkronkan.
  Future<void> uploadGenericData<T extends HasId>(
    final String namaTabel,
    final String namaKoleksi,
    final T Function(Map<String, dynamic>) fromSqlite,
    final Map<String, dynamic> Function(T) toFirebase,
    final DateTime waktuTerakhirSinkronisasi,
  ) async {
    Log.info('========================================');
    Log.info('MEMULAI UNGGAH DATA GENERIK');
    Log.info('Tabel SQLite sumber: $namaTabel');
    Log.info('Koleksi Firestore tujuan: $namaKoleksi');
    Log.info(
      'Waktu sinkronisasi terakhir: ${waktuTerakhirSinkronisasi.toIso8601String()}',
    );
    Log.info('Tipe data generik: $T');
    Log.info('========================================');

    try {
      Log.info('Mendapatkan instance database SQLite dari DatabaseHelper.');
      final db = await _sqliteDb.database;
      Log.info('Instance database berhasil didapatkan.');

      List<Map<String, dynamic>> dataUntukDiunggah = [];

      if (namaTabel == NamaTabel.versiApkUser) {
        Log.info(
          'Tabel $namaTabel adalah tabel khusus. Mengambil semua data tanpa filter waktu.',
        );
        dataUntukDiunggah = await db.query(namaTabel);
      } else {
        Log.info(
          'Melakukan query pada tabel $namaTabel dengan kondisi: '
          '${NamaKolom.diperbaruiPada} > ${waktuTerakhirSinkronisasi.millisecondsSinceEpoch}',
        );
        dataUntukDiunggah = await db.query(
          namaTabel,
          where: '${NamaKolom.diperbaruiPada} > ?',
          whereArgs: [waktuTerakhirSinkronisasi.millisecondsSinceEpoch],
        );
      }

      Log.info(
        'Query selesai. Jumlah data yang ditemukan untuk diunggah: ${dataUntukDiunggah.length} baris dari tabel $namaTabel.',
      );

      if (dataUntukDiunggah.isEmpty) {
        Log.info(
          'Tabel $namaTabel sudah sinkron dengan Firestore. '
          'Tidak ada data baru atau yang diperbarui sejak ${waktuTerakhirSinkronisasi.toIso8601String()}. '
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
      int jumlahSukses = 0;
      final List<Map<String, dynamic>> failedData = [];
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
          if (data.id.isEmpty) {
            Log.warning(
              'Melewati data ke-${i + 1} dari tabel $namaTabel karena ID kosong. Data: $map',
            );
            failedData.add(map);
            continue;
          }
          Log.info(
            'Konversi berhasil. ID data: ${data.id}. '
            'Membuat referensi dokumen Firestore pada koleksi $namaKoleksi dengan ID ${data.id}.',
          );
          final docRef = _firestore.collection(namaKoleksi).doc(data.id);
          Log.info(
            'Mengkonversi model menjadi Map<String, dynamic> menggunakan fungsi toFirebase.',
          );
          final firebaseData = toFirebase(data);
          Log.info(
            'Konversi ke format Firestore berhasil. '
            'Jumlah field yang akan diunggah: ${firebaseData.length}.',
          );
          Log.info(
            'Menambahkan operasi set dengan merge:true ke batch Firestore untuk dokumen $namaKoleksi/${data.id}. '
            'Merge:true akan menggabungkan data baru dengan data yang sudah ada tanpa menghapus field lain.',
          );
          batchFirestore.set(docRef, firebaseData, SetOptions(merge: true));
          jumlahSukses++;
          Log.info(
            'Data ke-${i + 1} (ID: ${data.id}) berhasil ditambahkan ke batch Firestore.',
          );
        } catch (e, s) {
          failedData.add(map);
          Log.error(
            'Gagal memproses data ke-${i + 1} dari tabel $namaTabel. '
            'Data ini akan dilewati dan tidak dimasukkan ke batch. '
            'Data SQLite: $map',
            e: e,
            s: s,
          );
        }
      }

      Log.info(
        'Semua data selesai diproses. '
        'Total: ${dataUntukDiunggah.length} data, '
        'Sukses ditambahkan ke batch: $jumlahSukses, '
        'Gagal: ${failedData.length}.',
      );

      if (failedData.isNotEmpty) {
        Log.warning(
          'Ditemukan ${failedData.length} dari ${dataUntukDiunggah.length} data yang gagal dikonversi untuk tabel $namaTabel. '
          'Data yang gagal akan dilewati.',
        );
      }

      if (jumlahSukses > 0) {
        Log.info(
          'Melakukan commit batch Firestore. '
          'Mengirim $jumlahSukses dokumen ke koleksi $namaKoleksi secara atomik.',
        );
        await batchFirestore.commit();
        Log.info(
          'Batch commit berhasil. '
          '$jumlahSukses dokumen dari tabel $namaTabel berhasil diunggah ke Firestore koleksi $namaKoleksi.',
        );
      } else {
        Log.warning(
          'Tidak ada data yang berhasil diproses untuk tabel $namaTabel. '
          'Batch commit tidak dilakukan karena tidak ada data valid untuk diunggah.',
        );
      }

      Log.info('PROSES UNGGAH DATA GENERIK SELESAI');
      Log.info('Tabel: $namaTabel -> Koleksi: $namaKoleksi');
      Log.info('Total data diunggah: $jumlahSukses dokumen');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data untuk tabel $namaTabel ke koleksi Firestore $namaKoleksi. ',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}

final layananUnggahDataProvider = Provider<LayananUnggahData>((ref) {
  return LayananUnggahData(
    sqliteDb: ref.read(sqliteDatabaseProvider),
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(pengelolaSinkronisasiProvider),
  );
});
