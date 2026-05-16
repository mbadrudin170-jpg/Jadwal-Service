// path: lib/services/firebase_migration/firebase_migration_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

/// Layanan untuk menangani migrasi data di Firebase.
class FirebaseMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enum TableName tidak memiliki entri untuk 'riwayat_langganan'.
  final List<String> _isDeletedCollections = [
    TableName.wallet.name,
    TableName.category.name,
    TableName.package.name,
    TableName.activeCustomer.name,
    TableName.customer.name,
    TableName.order.name,
    TableName.subCategory.name,
    TableName.transaction.name,
    TableName.userApkVersion.name,
    TableName.feedback.name,
  ];

  /// Daftar mapping nama kolom lama ke nama kolom baru.
  /// Format: {nama_koleksi: {kolom_lama: kolom_baru}}
  final Map<String, Map<String, String>> _columnMigrations = {
    TableName.wallet.name: {
      'namaDompet': ColumnNames.name,
      'saldo': ColumnNames.balance,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.category.name: {
      'nama': ColumnNames.name,
      'tipe': ColumnNames.type,
      'id_sub_kategori': ColumnNames.subCategoryId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.subCategory.name: {
      'nama': ColumnNames.name,
      'id_kategori': ColumnNames.categoryId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.package.name: {
      'nama': ColumnNames.name,
      'harga': ColumnNames.price,
      'durasi': ColumnNames.duration,
      'tipe': ColumnNames.type,
      'jumlahPoin': ColumnNames.rewardPoints,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'poin_hadiah': ColumnNames.rewardPoints,
      'poin_penukaran': ColumnNames.redemptionPoints,
      'isPublic': ColumnNames.isPublic,
    },
    TableName.customer.name: {
      'nama': ColumnNames.name,
      'telepon': ColumnNames.phone,
      'alamat': ColumnNames.address,
      'password': ColumnNames.password,
      'mac_address': ColumnNames.macAddress,
      'status': ColumnNames.status,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.activeCustomer.name: {
      'id_pelanggan': ColumnNames.customerId,
      'id_paket': ColumnNames.packageId,
      'id_transaksi': ColumnNames.transactionId,
      'tanggal_mulai': ColumnNames.startDate,
      'tanggal_berakhir': ColumnNames.endDate,
      'status': ColumnNames.status,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.transaction.name: {
      'keterangan': ColumnNames.description,
      'jumlah': ColumnNames.amount,
      'tanggal': ColumnNames.date,
      'tipe': ColumnNames.type,
      'id_dompet': ColumnNames.walletId,
      'id_kategori': ColumnNames.categoryId,
      'id_sub_kategori': ColumnNames.subCategoryId,
      'id_pelanggan': ColumnNames.customerId,
      'id_paket': ColumnNames.packageId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'id_dompet_tujuan': ColumnNames.destinationWalletId,
      'poin_yang_dihasilkan': ColumnNames.earnedPoints,
      'poin_yang_digunakan': ColumnNames.usedPoints,
      'status_pembayaran': ColumnNames.paymentStatus,
      'durasi_paket': ColumnNames.packageDuration,
      'tipe_durasi_paket': ColumnNames.durationType,
      'tanggal_mulai': ColumnNames.startDate,
      'tanggal_berakhir': ColumnNames.endDate,
      'aktivasi_paket': ColumnNames.isActivated,
    },
    TableName.feedback.name: {
      'isi': ColumnNames.content,
      'tanggal': ColumnNames.date,
      'userId': ColumnNames.userId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.order.name: {
      'id_pelanggan': ColumnNames.customerId,
      'id_paket': ColumnNames.packageId,
      'tanggal': ColumnNames.date,
      'status': ColumnNames.status,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.userApkVersion.name: {
      'catatan_rilis': ColumnNames.releaseNotes,
      'nomor_build_terbaru': ColumnNames.latestBuildNumber,
      'tautan_unduhan': ColumnNames.downloadLinks,
      'versi_terbaru': ColumnNames.latestVersion,
      'wajib_update': ColumnNames.isUpdateRequired,
      'youtube_tutorial': ColumnNames.youtubeTutorial,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
    },
    TableName.setting.name: {
      'interval_sinkronisasi_otomatis': ColumnNames.autoSyncInterval,
      'hapus_otomatis_data_arsip': ColumnNames.autoDeleteArchiveDays,
      'mode_pemeliharaan': ColumnNames.maintenanceMode,
      'info_pemeliharaan': ColumnNames.maintenanceInfo,
      'diperbarui': ColumnNames.updatedAt,
    },
    TableName.uploadStatus.name: {
      'value': ColumnNames.value,
      'diperbarui': ColumnNames.updatedAt,
    },
    TableName.message.name: {
      'isi': ColumnNames.content,
      'tanggal': ColumnNames.date,
      'status': ColumnNames.status,
    },
  };

  /// Migrasi untuk field `isDeleted` dari int ke bool
  Future<void> _migrateIsDeleted(
    final String collectionName,
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    Log.info('Memulai migrasi isDeleted untuk koleksi: $collectionName');
    final QuerySnapshot snapshot =
        await _firestore.collection(collectionName).get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('isDeleted')) {
        final currentValue = data['isDeleted'];
        if (currentValue is int) {
          final bool newValue = currentValue == 1;
          batch.update(doc.reference, {'isDeleted': newValue});
          migratedCount++;
        }
      }
    }

    if (migratedCount > 0) {
      logs.add(
        '  - [isDeleted] $migratedCount dokumen akan dimigrasi di `$collectionName`.',
      );
      Log.info(
          'Migrasi isDeleted untuk $collectionName: $migratedCount dokumen');
    }
  }

  /// Migrasi untuk mengganti nama kolom berdasarkan mapping yang telah ditentukan.
  Future<void> _migrateColumnNames(
    final String collectionName,
    final Map<String, String> columnMapping,
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    Log.info('Memulai migrasi nama kolom untuk koleksi: $collectionName');

    // Cek apakah koleksi ada di Firestore
    final collectionRef = _firestore.collection(collectionName);
    final QuerySnapshot snapshot;
    try {
      snapshot = await collectionRef.limit(1).get();
    } on Exception catch (e) {
      Log.warning('Koleksi $collectionName tidak ditemukan, lewati migrasi', e);
      logs.add('  - Koleksi `$collectionName` tidak ditemukan, dilewati.');
      return;
    }

    if (snapshot.docs.isEmpty) {
      Log.info('Koleksi $collectionName kosong, lewati migrasi');
      return;
    }

    // Ambil semua dokumen untuk migrasi penuh
    final allDocs = await collectionRef.get();
    int totalRenamedCount = 0;
    final Map<String, int> renamedCountPerColumn = {};

    for (final doc in allDocs.docs) {
      final data = doc.data();
      final Map<String, dynamic> updateData = {};
      final Map<String, dynamic> deleteData = {};

      for (final entry in columnMapping.entries) {
        final oldColumnName = entry.key;
        final newColumnName = entry.value;

        // Cek apakah kolom lama ada di dokumen
        if (data.containsKey(oldColumnName)) {
          final oldValue = data[oldColumnName];

          // Hanya migrasi jika kolom baru belum ada
          if (!data.containsKey(newColumnName)) {
            updateData[newColumnName] = oldValue;
            deleteData[oldColumnName] = FieldValue.delete();
            renamedCountPerColumn[oldColumnName] =
                (renamedCountPerColumn[oldColumnName] ?? 0) + 1;
            totalRenamedCount++;
          } else {
            // Kolom baru sudah ada, hapus kolom lama saja
            deleteData[oldColumnName] = FieldValue.delete();
          }
        }
      }

      if (updateData.isNotEmpty || deleteData.isNotEmpty) {
        final Map<String, dynamic> finalUpdateData = {
          ...updateData,
          ...deleteData
        };
        batch.update(doc.reference, finalUpdateData);
      }
    }

    // Catat hasil migrasi per kolom
    for (final entry in renamedCountPerColumn.entries) {
      logs.add(
        '  - [${entry.key} -> ${columnMapping[entry.key]}] ${entry.value} dokumen dimigrasi di `$collectionName`.',
      );
    }

    if (totalRenamedCount > 0) {
      logs.add(
        '  Total: $totalRenamedCount perubahan nama kolom di `$collectionName`.',
      );
      Log.info(
          'Migrasi kolom untuk $collectionName: $totalRenamedCount perubahan');
    }
  }

  /// Migrasi untuk field `isPublic` menjadi `is_public` (khusus untuk koleksi package)
  Future<void> _migrateIsPublic(
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    Log.info('Memulai migrasi isPublic ke is_public di koleksi package');
    final QuerySnapshot snapshot =
        await _firestore.collection(TableName.package.name).get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Cek apakah kolom 'isPublic' ada
      if (data.containsKey('isPublic')) {
        final currentValue = data['isPublic'];
        // Cek apakah kolom 'is_public' sudah ada
        if (!data.containsKey(ColumnNames.isPublic)) {
          batch.update(doc.reference, {
            ColumnNames.isPublic: currentValue,
            'isPublic': FieldValue.delete(),
          });
          migratedCount++;
        } else {
          // Kolom is_public sudah ada, hapus isPublic saja
          batch.update(doc.reference, {
            'isPublic': FieldValue.delete(),
          });
        }
      }
    }

    if (migratedCount > 0) {
      logs.add(
        '  - [isPublic -> ${ColumnNames.isPublic}] $migratedCount dokumen akan dimigrasi di `${TableName.package.name}`.',
      );
      Log.info('Migrasi isPublic: $migratedCount dokumen');
    }
  }

  /// Migrasi untuk field di koleksi `user_apk_version`
  Future<void> _migrateUserApkVersion(
      final WriteBatch batch, final List<String> logs) async {
    Log.info('Memulai migrasi versi_apk_user');
    final QuerySnapshot snapshot =
        await _firestore.collection(TableName.userApkVersion.name).get();
    int migratedBuildCount = 0;
    int migratedLinkCount = 0;
    int migratedBuildAndLinkCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docRef = doc.reference;

      final dynamic oldBuildNumber = data[ColumnNames.latestBuildNumber];
      final dynamic oldDownloadLink = data[ColumnNames.downloadLinks];

      final Map<String, dynamic> updateData = {};
      bool buildNeedMigration = false;
      bool linkNeedMigration = false;

      // Migrasi nomor_build_terbaru (cek apakah masih dalam format lama)
      if (oldBuildNumber != null && oldBuildNumber is! Map) {
        buildNeedMigration = true;

        if (oldBuildNumber is int) {
          updateData[ColumnNames.latestBuildNumber] = {
            'universal': oldBuildNumber,
            'bit_32': 0,
            'bit_64': 0,
          };
        } else if (oldBuildNumber is String &&
            int.tryParse(oldBuildNumber) != null) {
          updateData[ColumnNames.latestBuildNumber] = {
            'universal': int.parse(oldBuildNumber),
            'bit_32': 0,
            'bit_64': 0,
          };
        } else {
          updateData[ColumnNames.latestBuildNumber] = {
            'universal': 0,
            'bit_32': 0,
            'bit_64': 0,
          };
        }
      }

      // Migrasi tautan_unduhan (cek apakah masih dalam format lama)
      if (oldDownloadLink != null && oldDownloadLink is! Map) {
        linkNeedMigration = true;

        if (oldDownloadLink is String && oldDownloadLink.isNotEmpty) {
          updateData[ColumnNames.downloadLinks] = {
            'universal': oldDownloadLink,
            'bit_32': '',
            'bit_64': '',
          };
        } else {
          updateData[ColumnNames.downloadLinks] = {
            'universal': '',
            'bit_32': '',
            'bit_64': '',
          };
        }
      }

      if (updateData.isNotEmpty) {
        batch.update(docRef, updateData);

        if (buildNeedMigration && linkNeedMigration) {
          migratedBuildAndLinkCount++;
        } else if (buildNeedMigration) {
          migratedBuildCount++;
        } else if (linkNeedMigration) {
          migratedLinkCount++;
        }
      }
    }

    if (migratedBuildCount > 0) {
      logs.add(
        '  - [${ColumnNames.latestBuildNumber}] $migratedBuildCount dokumen akan dimigrasi.',
      );
    }
    if (migratedLinkCount > 0) {
      logs.add(
        '  - [${ColumnNames.downloadLinks}] $migratedLinkCount dokumen akan dimigrasi.',
      );
    }
    if (migratedBuildAndLinkCount > 0) {
      logs.add(
        '  - [build + link] $migratedBuildAndLinkCount dokumen akan dimigrasi.',
      );
    }

    final totalMigrated =
        migratedBuildCount + migratedLinkCount + migratedBuildAndLinkCount;
    if (totalMigrated > 0) {
      logs.add(
        '  Total: $totalMigrated dokumen di `${TableName.userApkVersion.name}` akan dimigrasi.',
      );
      Log.info('Migrasi versi_apk_user: $totalMigrated dokumen');
    }
  }

  /// Migrasi untuk field `value` di koleksi `upload_status` (dari string ke boolean)
  Future<void> _migrateUploadStatusValue(
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    Log.info('Memulai migrasi value di koleksi upload_status');
    final QuerySnapshot snapshot =
        await _firestore.collection(TableName.uploadStatus.name).get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (data.containsKey(ColumnNames.value)) {
        final currentValue = data[ColumnNames.value];

        // Jika value masih berupa string '0' atau '1', konversi ke boolean
        if (currentValue is String &&
            (currentValue == '0' || currentValue == '1')) {
          final bool newValue = currentValue == '1';
          batch.update(doc.reference, {ColumnNames.value: newValue});
          migratedCount++;
        }
        // Jika value masih berupa int 0 atau 1, konversi ke boolean
        if (currentValue is int && (currentValue == 0 || currentValue == 1)) {
          final bool newValue = currentValue == 1;
          batch.update(doc.reference, {ColumnNames.value: newValue});
          migratedCount++;
        }
      }
    }

    if (migratedCount > 0) {
      logs.add(
        '  - [value] $migratedCount dokumen akan dimigrasi di `${TableName.uploadStatus.name}` (string/int ke boolean).',
      );
      Log.info('Migrasi upload_status value: $migratedCount dokumen');
    }
  }

  /// Menganalisis dan menjalankan semua migrasi data Firebase yang diperlukan.
  ///
  /// Ini termasuk:
  /// - Mengkonversi `isDeleted` dari `int` ke `bool` di berbagai koleksi.
  /// - Merestrukturisasi `nomor_build_terbaru` dan `tautan_unduhan` di `user_apk_version`.
  /// - Mengganti nama kolom sesuai dengan `ColumnNames`.
  /// - Mengkonversi `value` di `upload_status` dari string/int ke boolean.
  ///
  /// Sebuah [WriteBatch] digunakan untuk melakukan semua perubahan sekaligus.
  /// Callback [onProgress] memberikan umpan balik real-time tentang status migrasi.
  ///
  /// Melempar [Exception] jika ada langkah migrasi yang gagal, untuk menghentikan proses.
  /// Mengembalikan daftar pesan log yang merinci operasi yang dilakukan.
  Future<List<String>> runAllMigrations(
    final void Function(String message) onProgress,
  ) async {
    Log.info('Memulai semua migrasi Firebase');
    onProgress('Memulai semua migrasi...');
    final WriteBatch batch = _firestore.batch();
    final List<String> logs = [];
    int totalMigrations = 0;

    // 1. Migrasi isDeleted (int ke bool)
    onProgress('Menganalisis migrasi `isDeleted`...');
    for (final collectionName in _isDeletedCollections) {
      try {
        final List<String> collectionLogs = [];
        await _migrateIsDeleted(collectionName, batch, collectionLogs);
        if (collectionLogs.isNotEmpty) {
          logs.addAll(collectionLogs);
          totalMigrations++;
        }
      } on Exception catch (e, s) {
        final message =
            'Error saat menganalisis migrasi isDeleted untuk $collectionName: $e';
        Log.error(message, e: e, st: s);
        onProgress(message);
        // Tidak throw, lanjutkan ke koleksi berikutnya
      }
    }
    if (totalMigrations == 0) {
      logs.add('Tidak ada migrasi `isDeleted` yang perlu dilakukan.');
    }

    // 2. Migrasi nama kolom berdasarkan ColumnNames
    totalMigrations = 0;
    onProgress('Menganalisis migrasi nama kolom...');
    for (final entry in _columnMigrations.entries) {
      final collectionName = entry.key;
      final columnMapping = entry.value;
      try {
        final List<String> columnLogs = [];
        await _migrateColumnNames(
          collectionName,
          columnMapping,
          batch,
          columnLogs,
        );
        if (columnLogs.isNotEmpty) {
          logs.addAll(columnLogs);
          totalMigrations++;
        }
      } on Exception catch (e, s) {
        final message =
            'Error saat menganalisis migrasi kolom untuk $collectionName: $e';
        Log.error(message, e: e, st: s);
        onProgress(message);
        // Tidak throw, lanjutkan ke koleksi berikutnya
      }
    }
    if (totalMigrations == 0) {
      logs.add('Tidak ada migrasi nama kolom yang perlu dilakukan.');
    }

    // 3. Migrasi user_apk_version (restrukturisasi)
    int userApkVersionMigrations = 0;
    onProgress('Menganalisis migrasi `user_apk_version`...');
    try {
      final List<String> userApkVersionLogs = [];
      await _migrateUserApkVersion(batch, userApkVersionLogs);
      if (userApkVersionLogs.isNotEmpty) {
        logs.addAll(userApkVersionLogs);
        userApkVersionMigrations++;
      }
    } on Exception catch (e, s) {
      final message = 'Error saat menganalisis migrasi user_apk_version: $e';
      Log.error(message, e: e, st: s);
      onProgress(message);
      // Tidak throw, lanjutkan
    }
    if (userApkVersionMigrations == 0) {
      logs.add('Tidak ada migrasi `user_apk_version` yang perlu dilakukan.');
    }

    // 4. Migrasi isPublic (khusus package)
    int isPublicMigrations = 0;
    onProgress('Menganalisis migrasi `isPublic` di koleksi package...');
    try {
      final List<String> isPublicLogs = [];
      await _migrateIsPublic(batch, isPublicLogs);
      if (isPublicLogs.isNotEmpty) {
        logs.addAll(isPublicLogs);
        isPublicMigrations++;
      }
    } on Exception catch (e, s) {
      final message = 'Error saat menganalisis migrasi isPublic: $e';
      Log.error(message, e: e, st: s);
      onProgress(message);
      // Tidak throw, lanjutkan
    }
    if (isPublicMigrations == 0) {
      logs.add('Tidak ada migrasi `isPublic` yang perlu dilakukan.');
    }

    // 5. Migrasi upload_status value (string/int ke boolean)
    int uploadStatusMigrations = 0;
    onProgress('Menganalisis migrasi `value` di koleksi upload_status...');
    try {
      final List<String> uploadStatusLogs = [];
      await _migrateUploadStatusValue(batch, uploadStatusLogs);
      if (uploadStatusLogs.isNotEmpty) {
        logs.addAll(uploadStatusLogs);
        uploadStatusMigrations++;
      }
    } on Exception catch (e, s) {
      final message = 'Error saat menganalisis migrasi upload_status value: $e';
      Log.error(message, e: e, st: s);
      onProgress(message);
      // Tidak throw, lanjutkan
    }
    if (uploadStatusMigrations == 0) {
      logs.add('Tidak ada migrasi `upload_status value` yang perlu dilakukan.');
    }

    // Commit semua perubahan
    if (logs.isNotEmpty) {
      onProgress('Menjalankan semua perubahan...');
      try {
        await batch.commit();
        onProgress('Semua migrasi telah selesai dengan sukses!');
        Log.info('Semua migrasi Firebase berhasil di-commit');
      } on Exception catch (e, s) {
        final message = 'Gagal melakukan commit perubahan: $e';
        Log.error(
          message,
          e: e,
          st: s,
        );
        onProgress(message);
        throw Exception('Gagal menyimpan perubahan ke Firestore.');
      }
    } else {
      onProgress('Tidak ada data yang perlu dimigrasi.');
      Log.info('Tidak ada migrasi Firebase yang perlu dilakukan');
    }

    return logs;
  }
}
