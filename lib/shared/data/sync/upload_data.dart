// path: lib/shared/data/sync/upload_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Layanan untuk mengunggah data dari database lokal (SQLite) ke Firestore.
class UploadDataService {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;

  /// Konstruktor untuk `UploadDataService`.
  UploadDataService({
    final DatabaseHelper? dbHelper,
    final FirebaseFirestore? firestore,
    final SyncManager? syncManager,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _syncManager = syncManager ?? SyncManager() {
    Log.info(
      'UploadDataService instance dibuat. '
      'Menggunakan DatabaseHelper: ${_dbHelper.hashCode}, '
      'FirebaseFirestore: ${_firestore.hashCode}, '
      'SyncManager: ${_syncManager.hashCode}',
    );
  }

  /// Mengunggah semua data dari semua tabel lokal ke koleksi Firestore yang sesuai.
  Future<void> uploadAllData() async {
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

    final List<Future<void>> uploadList = [
      uploadWalletData(),
      uploadCategoryData(),
      uploadFeedbackData(),
      uploadPackageData(),
      uploadActiveCustomerData(),
      uploadCustomerData(),
      uploadOrderData(),
      uploadTransactionData(),
      uploadSubCategoryData(),
      uploadApkVersionData(),
      uploadSettingsData(),
    ];

    Log.info(
      'Total ${uploadList.length} fungsi unggah spesifik telah disiapkan dan siap dieksekusi secara paralel.',
    );

    try {
      Log.info(
        'Menjalankan semua fungsi unggah secara paralel menggunakan Future.wait. '
        'Semua proses unggah akan berjalan bersamaan untuk efisiensi waktu.',
      );
      await Future.wait(uploadList);
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
        st: s,
      );
      rethrow;
    }
  }

  /// Mengunggah data dompet ke Firestore.
  Future<void> uploadWalletData() async {
    Log.info(
      'Memulai proses unggah data dompet. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk dompet: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<WalletModel>(
        TableNameValue.get(TableName.wallet),
        TableNameValue.get(TableName.wallet),
        WalletModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data dompet selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data kategori ke Firestore.
  Future<void> uploadCategoryData() async {
    Log.info(
      'Memulai proses unggah data kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kategori: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<CategoryModel>(
        TableNameValue.get(TableName.category),
        TableNameValue.get(TableName.category),
        CategoryModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data kategori selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data kritik dan saran ke Firestore.
  Future<void> uploadFeedbackData() async {
    Log.info(
      'Memulai proses unggah data kritik_saran. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk kritik_saran: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<FeedbackModel>(
        TableNameValue.get(TableName.feedback),
        TableNameValue.get(TableName.feedback),
        FeedbackModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data kritik_saran selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data paket ke Firestore.
  Future<void> uploadPackageData() async {
    Log.info(
      'Memulai proses unggah data paket. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk paket: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<PackageModel>(
        TableNameValue.get(TableName.package),
        TableNameValue.get(TableName.package),
        PackageModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data paket selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data pelanggan aktif ke Firestore.
  Future<void> uploadActiveCustomerData() async {
    Log.info(
      'Memulai proses unggah data pelanggan_aktif. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan_aktif: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<ActiveCustomerModel>(
        TableNameValue.get(TableName.activeCustomer),
        TableNameValue.get(TableName.activeCustomer),
        ActiveCustomerModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data pelanggan_aktif selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data pelanggan ke Firestore.
  Future<void> uploadCustomerData() async {
    Log.info(
      'Memulai proses unggah data pelanggan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pelanggan: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<CustomerModel>(
        TableNameValue.get(TableName.customer),
        TableNameValue.get(TableName.customer),
        CustomerModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data pelanggan selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data pesanan ke Firestore.
  Future<void> uploadOrderData() async {
    Log.info(
      'Memulai proses unggah data pesanan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pesanan: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<OrderModel>(
        TableNameValue.get(TableName.customerOrder),
        TableNameValue.get(TableName.customerOrder),
        OrderModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data pesanan selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data transaksi ke Firestore.
  Future<void> uploadTransactionData() async {
    Log.info(
      'Memulai proses unggah data transaksi. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk transaksi: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<TransactionModel>(
        TableNameValue.get(TableName.transactions),
        TableNameValue.get(TableName.transactions),
        TransactionModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data transaksi selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data sub-kategori ke Firestore.
  Future<void> uploadSubCategoryData() async {
    Log.info(
      'Memulai proses unggah data sub_kategori. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk sub_kategori: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<SubCategoryModel>(
        TableNameValue.get(TableName.subCategory),
        TableNameValue.get(TableName.subCategory),
        SubCategoryModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data sub_kategori selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data pengaturan ke Firestore.
  Future<void> uploadSettingsData() async {
    Log.info(
      'Memulai proses unggah data pengaturan. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk pengaturan: ${time.toIso8601String()}. '
        'Data pengaturan akan selalu diunggah, jadi waktu ini akan diabaikan pada level query.',
      );
      await uploadGenericData<SettingsModel>(
        TableNameValue.get(TableName.settings),
        TableNameValue.get(TableName.settings),
        SettingsModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data pengaturan selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data versi APK user ke Firestore.
  Future<void> uploadApkVersionData() async {
    Log.info(
      'Memulai proses unggah data versi_apk_user. Mengambil waktu sinkronisasi terakhir dari SyncManager.',
    );
    try {
      final time = await _syncManager.getLastUpload();
      Log.info(
        'Waktu sinkronisasi terakhir untuk versi_apk_user: ${time.toIso8601String()}. '
        'Hanya data yang diperbarui setelah waktu ini yang akan diunggah.',
      );
      await uploadGenericData<ApkVersionModel>(
        TableNameValue.get(TableName.userApkVersion),
        TableNameValue.get(TableName.userApkVersion),
        ApkVersionModel.fromSqlite,
        (final m) => m.toFirebase(),
        time,
      );
      Log.info('Proses unggah data versi_apk_user selesai dengan sukses.');
    } on Exception catch (e, s) {
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

  /// Mengunggah data secara generik dari tabel SQLite ke koleksi Firestore.
  ///
  /// [T] adalah tipe model data yang akan diunggah.
  /// [tableName] adalah nama tabel di SQLite.
  /// [collectionName] adalah nama koleksi di Firestore.
  /// [fromSqlite] adalah fungsi untuk mengonversi data dari SQLite ke model.
  /// [toFirebase] adalah fungsi untuk mengonversi model ke format data Firestore.
  /// [lastSyncTime] adalah waktu terakhir data disinkronkan.
  Future<void> uploadGenericData<T extends HasId>(
    final String tableName,
    final String collectionName,
    final T Function(Map<String, dynamic>) fromSqlite,
    final Map<String, dynamic> Function(T) toFirebase,
    final DateTime lastSyncTime,
  ) async {
    Log.info('========================================');
    Log.info('MEMULAI UNGGAH DATA GENERIK');
    Log.info('Tabel SQLite sumber: $tableName');
    Log.info('Koleksi Firestore tujuan: $collectionName');
    Log.info(
      'Waktu sinkronisasi terakhir: ${lastSyncTime.toIso8601String()}',
    );
    Log.info('Tipe data generik: $T');
    Log.info('========================================');

    try {
      Log.info('Mendapatkan instance database SQLite dari DatabaseHelper.');
      final db = await _dbHelper.database;
      Log.info('Instance database berhasil didapatkan.');

      List<Map<String, dynamic>> dataToUpload = [];

      if (tableName == TableNameValue.get(TableName.settings)) {
        Log.info(
          'Tabel $tableName adalah tabel khusus. Mengambil semua data tanpa filter waktu.',
        );
        dataToUpload = await db.query(tableName);
      } else {
        Log.info(
          'Melakukan query pada tabel $tableName dengan kondisi: '
          '${ColumnNames.updatedAt} > ${lastSyncTime.millisecondsSinceEpoch}',
        );
        dataToUpload = await db.query(
          tableName,
          where: '${ColumnNames.updatedAt} > ?',
          whereArgs: [lastSyncTime.millisecondsSinceEpoch],
        );
      }

      Log.info(
        'Query selesai. Jumlah data yang ditemukan untuk diunggah: ${dataToUpload.length} baris dari tabel $tableName.',
      );

      if (dataToUpload.isEmpty) {
        Log.info(
          'Tabel $tableName sudah sinkron dengan Firestore. '
          'Tidak ada data baru atau yang diperbarui sejak ${lastSyncTime.toIso8601String()}. '
          'Proses unggah untuk tabel ini dilewati.',
        );
        return;
      }

      Log.info(
        'Terdapat ${dataToUpload.length} data yang perlu diunggah dari tabel $tableName. '
        'Membuat Firestore batch operation untuk mengunggah data secara atomik.',
      );

      final batchFirestore = _firestore.batch();
      Log.info('Firestore batch berhasil dibuat.');

      int successCount = 0;
      final List<Map<String, dynamic>> failedData = [];

      for (int i = 0; i < dataToUpload.length; i++) {
        final map = dataToUpload[i];
        Log.info(
          'Memproses data ke-${i + 1}/${dataToUpload.length} dari tabel $tableName.',
        );

        try {
          Log.info(
            'Mengkonversi data SQLite menjadi model $T menggunakan fungsi fromSqlite.',
          );
          final T data = fromSqlite(map);
          Log.info(
            'Konversi berhasil. ID data: ${data.id}. '
            'Membuat referensi dokumen Firestore pada koleksi $collectionName dengan ID ${data.id}.',
          );

          final docRef = _firestore.collection(collectionName).doc(data.id);

          Log.info(
            'Mengkonversi model menjadi Map<String, dynamic> menggunakan fungsi toFirebase.',
          );
          final firebaseData = toFirebase(data);
          Log.info(
            'Konversi ke format Firestore berhasil. '
            'Jumlah field yang akan diunggah: ${firebaseData.length}.',
          );

          Log.info(
            'Menambahkan operasi set dengan merge:true ke batch Firestore untuk dokumen $collectionName/${data.id}. '
            'Merge:true akan menggabungkan data baru dengan data yang sudah ada tanpa menghapus field lain.',
          );
          batchFirestore.set(docRef, firebaseData, SetOptions(merge: true));

          successCount++;
          Log.info(
            'Data ke-${i + 1} (ID: ${data.id}) berhasil ditambahkan ke batch Firestore.',
          );
          // ignore: avoid_catches_without_on_clauses, justification: 'diperlukan untuk menangkap semua jenis error termasuk ArgumentError agar data korup tidak menghentikan proses unggah'
        } catch (e, s) {
          failedData.add(map);
          Log.error(
            'Gagal memproses data ke-${i + 1} dari tabel $tableName. '
            'Data ini akan dilewati dan tidak dimasukkan ke batch. '
            'Data SQLite: $map',
            e: e,
            st: s,
          );
        }
      }

      Log.info(
        'Semua data selesai diproses. '
        'Total: ${dataToUpload.length} data, '
        'Sukses ditambahkan ke batch: $successCount, '
        'Gagal: ${failedData.length}.',
      );

      if (failedData.isNotEmpty) {
        Log.warning(
          'Ditemukan ${failedData.length} dari ${dataToUpload.length} data yang gagal dikonversi untuk tabel $tableName. '
          'Data yang gagal akan dilewati.',
        );
      }

      if (successCount > 0) {
        Log.info(
          'Melakukan commit batch Firestore. '
          'Mengirim $successCount dokumen ke koleksi $collectionName secara atomik.',
        );
        await batchFirestore.commit();
        Log.info(
          'Batch commit berhasil. '
          '$successCount dokumen dari tabel $tableName berhasil diunggah ke Firestore koleksi $collectionName.',
        );
      } else {
        Log.warning(
          'Tidak ada data yang berhasil diproses untuk tabel $tableName. '
          'Batch commit tidak dilakukan karena tidak ada data valid untuk diunggah.',
        );
      }

      Log.info('========================================');
      Log.info('PROSES UNGGAH DATA GENERIK SELESAI');
      Log.info('Tabel: $tableName -> Koleksi: $collectionName');
      Log.info('Total data diunggah: $successCount dokumen');
      Log.info('========================================');
    } on Exception catch (e, s) {
      Log.error(
        'Gagal mengunggah data untuk tabel $tableName ke koleksi Firestore $collectionName. '
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
