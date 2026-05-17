// path: lib/services/firebase_migration/firebase_migration_service.dart
// Diperbarui: Menambahkan fungsi hapus koleksi lama setelah migrasi berhasil.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';

/// Layanan untuk menangani migrasi data di Firebase.
/// - File ini digunakan oleh: lib/admin/halaman/lainnya/halaman_migrasi.dart
class FirebaseMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// TODO : migrasi tabel status
  final List<String> _isDeletedCollections = [
    TableNameValue.get(TableName.wallet),
    TableNameValue.get(TableName.category),
    TableNameValue.get(TableName.package),
    TableNameValue.get(TableName.activeCustomer),
    TableNameValue.get(TableName.customer),
    TableNameValue.get(TableName.customerOrder),
    TableNameValue.get(TableName.subCategory),
    TableNameValue.get(TableName.transactions),
    TableNameValue.get(TableName.userApkVersion),
    TableNameValue.get(TableName.feedback),
  ];

  final Map<String, Map<String, String>> _columnMigrations = {
    TableNameValue.get(TableName.wallet): {
      'namaDompet': ColumnNames.name,
      'saldo': ColumnNames.balance,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.category): {
      'nama': ColumnNames.name,
      'tipe': ColumnNames.type,
      'id_sub_kategori': ColumnNames.subCategoryId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.subCategory): {
      'nama': ColumnNames.name,
      'id_kategori': ColumnNames.categoryId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.package): {
      'nama': ColumnNames.name,
      'harga': ColumnNames.price,
      'durasi': ColumnNames.duration,
      'tipe': ColumnNames.type,
      'jumlahPoin': ColumnNames.earnedPoints,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'poin_hadiah': ColumnNames.rewardPoints,
      'poin_penukaran': ColumnNames.redemptionPoints,
      'isPublic': ColumnNames.isPublic,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.customer): {
      'nama': ColumnNames.name,
      'telepon': ColumnNames.phone,
      'alamat': ColumnNames.address,
      'password': ColumnNames.password,
      'mac_address': ColumnNames.macAddress,
      'status': ColumnNames.status,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.activeCustomer): {
      'id_pelanggan': ColumnNames.customerId,
      'id_paket': ColumnNames.packageId,
      'id_transaksi': ColumnNames.transactionId,
      'tanggalMulai': ColumnNames.startDate,
      'TanggalMulai': ColumnNames.startDate,
      'tanggal_mulai': ColumnNames.startDate,
      'tanggalBerakhir': ColumnNames.endDate,
      'TanggalBerakhir': ColumnNames.endDate,
      'tanggal_berakhir': ColumnNames.endDate,
      'status': ColumnNames.status,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.transactions): {
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
      'TanggalMulai': ColumnNames.startDate,
      'tanggal_berakhir': ColumnNames.endDate,
      'aktivasi_paket': ColumnNames.isActivated,
      'tanggalMulai': ColumnNames.startDate,
      'tanggalBerakhir': ColumnNames.endDate,
      'tipeDuraisiPaket': ColumnNames.durationType,
      'tipeDurasiPaket': ColumnNames.durationType,
      'aktivasiPaket': ColumnNames.isActivated,
      'durasiPaket': ColumnNames.packageDuration,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.feedback): {
      'isi': ColumnNames.content,
      'tanggal': ColumnNames.date,
      'userId': ColumnNames.userId,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.customerOrder): {
      'id_pelanggan': ColumnNames.customerId,
      'id_paket': ColumnNames.packageId,
      'tanggal': ColumnNames.date,
      'status': ColumnNames.status,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.userApkVersion): {
      'catatan_rilis': ColumnNames.releaseNotes,
      'nomor_build_terbaru': ColumnNames.latestBuildNumber,
      'tautan_unduhan': ColumnNames.downloadLinks,
      'versi_terbaru': ColumnNames.latestVersion,
      'wajib_update': ColumnNames.isUpdateRequired,
      'youtube_tutorial': ColumnNames.youtubeTutorial,
      'diperbarui': ColumnNames.updatedAt,
      'diarsipkan': ColumnNames.archivedAt,
      'isDeleted': ColumnNames.isDeleted,
    },
    TableNameValue.get(TableName.settings): {
      'interval_sinkronisasi_otomatis': ColumnNames.autoSyncInterval,
      'hapus_otomatis_data_arsip': ColumnNames.autoDeleteArchiveDays,
      'mode_pemeliharaan': ColumnNames.maintenanceMode,
      'info_pemeliharaan': ColumnNames.maintenanceInfo,
      'diperbarui': ColumnNames.updatedAt,
    },
    TableNameValue.get(TableName.uploadStatus): {
      'value': ColumnNames.value,
      'diperbarui': ColumnNames.updatedAt,
    },
    TableNameValue.get(TableName.message): {
      'isi': ColumnNames.content,
      'tanggal': ColumnNames.date,
      'status': ColumnNames.status,
    },
  };

  /// Migrasi data dari koleksi lama ke koleksi baru dengan MERGE (tidak menghapus field lain)
  Future<void> _migrateLegacyCollection({
    required final String legacyCollectionName,
    required final String newCollectionName,
    required final Map<String, String> columnMapping,
    required final WriteBatch batch,
    required final List<String> logs,
  }) async {
    Log.info(
        'Memulai migrasi dari koleksi "$legacyCollectionName" ke "$newCollectionName"');

    final QuerySnapshot snapshot;
    try {
      snapshot = await _firestore.collection(legacyCollectionName).get();
    } on Exception catch (e) {
      Log.warning(
          'Koleksi $legacyCollectionName tidak ditemukan, lewati migrasi', e);
      logs.add(
          '  - Koleksi `$legacyCollectionName` tidak ditemukan, dilewati.');
      return;
    }

    if (snapshot.docs.isEmpty) {
      Log.info('Koleksi $legacyCollectionName kosong, akan dihapus nanti.');
      logs.add('  - Koleksi `$legacyCollectionName` kosong, dilewati.');
      return;
    }

    int migratedCount = 0;
    final Map<String, int> renamedCount = {};

    for (final doc in snapshot.docs) {
      final oldData = doc.data() as Map<String, dynamic>;
      final updateData = <String, dynamic>{};

      // Salin semua data lama, lalu timpa dengan nama kolom baru
      updateData.addAll(oldData);

      for (final entry in columnMapping.entries) {
        final oldField = entry.key;
        final newField = entry.value;
        if (oldData.containsKey(oldField)) {
          // Salin nilai ke field baru
          updateData[newField] = oldData[oldField];
          // Hapus field lama dari data yang akan diupdate
          updateData.remove(oldField);
          renamedCount[oldField] = (renamedCount[oldField] ?? 0) + 1;
        }
      }

      // Konversi isDeleted dari int ke bool jika ada
      if (updateData.containsKey('isDeleted') &&
          updateData['isDeleted'] is int) {
        updateData['isDeleted'] = (updateData['isDeleted'] as int) == 1;
      }

      final newDocRef = _firestore.collection(newCollectionName).doc(doc.id);
      batch.set(newDocRef, updateData, SetOptions(merge: true));
      migratedCount++;
    }

    if (migratedCount > 0) {
      logs.add(
          '  - [Migrasi] $migratedCount dokumen dari `$legacyCollectionName` ke `$newCollectionName` disiapkan.');
      for (final entry in renamedCount.entries) {
        logs.add(
            '    - ${entry.key} -> ${columnMapping[entry.key]} : ${entry.value} field akan di-rename.');
      }
    }
  }

  /// Migrasi isDeleted dari int ke bool (untuk koleksi yang sudah ada)
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
      if (data.containsKey('isDeleted') && data['isDeleted'] is int) {
        final bool newValue = (data['isDeleted'] as int) == 1;
        batch.update(doc.reference, {'isDeleted': newValue});
        migratedCount++;
      }
    }
    if (migratedCount > 0) {
      logs.add(
          '  - [isDeleted] $migratedCount dokumen akan dimigrasi di `$collectionName`.');
    }
  }

  /// Memigrasi nama kolom ke format snake_case dengan menyalin nilai
  /// dan menghapus kolom lama.
  Future<void> _migrateColumnNames(
    final String collectionName,
    final Map<String, String> columnMapping,
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    final collectionRef = _firestore.collection(collectionName);
    final allDocs = await collectionRef.get();
    if (allDocs.docs.isEmpty) return;

    final Map<String, int> renamedCountPerColumn = {};

    for (final doc in allDocs.docs) {
      final data = doc.data();
      final Map<String, dynamic> updatePayload = {};

      for (final entry in columnMapping.entries) {
        final oldColumnName = entry.key;
        final newColumnName = entry.value;

        if (data.containsKey(oldColumnName) &&
            !data.containsKey(newColumnName)) {
          updatePayload[newColumnName] = data[oldColumnName];
          updatePayload[oldColumnName] = FieldValue.delete();

          renamedCountPerColumn[oldColumnName] =
              (renamedCountPerColumn[oldColumnName] ?? 0) + 1;
        }
      }
      if (updatePayload.isNotEmpty) {
        batch.update(doc.reference, updatePayload);
      }
    }

    for (final entry in renamedCountPerColumn.entries) {
      logs.add(
        '  - [RENAME: ${entry.key} -> ${columnMapping[entry.key]}] ${entry.value} dokumen di `$collectionName` akan di-rename.',
      );
    }
  }

  /// Migrasi untuk field `isPublic` menjadi `is_public`.
  Future<void> _migrateIsPublic(
      final WriteBatch batch, final List<String> logs) async {
    final collectionName = TableNameValue.get(TableName.package);
    final snapshot = await _firestore.collection(collectionName).get();
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('isPublic')) {
        batch.update(doc.reference, {
          ColumnNames.isPublic: data['isPublic'],
          'isPublic': FieldValue.delete(),
        });
        count++;
      }
    }
    if (count > 0) {
      logs.add(
          '  - [isPublic -> ${ColumnNames.isPublic}] $count dokumen akan dimigrasi.');
    }
  }

  /// Migrasi untuk field di koleksi `user_apk_version`.
  Future<void> _migrateUserApkVersion(
      final WriteBatch batch, final List<String> logs) async {
    final collectionName = TableNameValue.get(TableName.userApkVersion);
    final snapshot = await _firestore.collection(collectionName).get();
    int buildCount = 0;
    int linkCount = 0;
    int bothCount = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final update = <String, dynamic>{};
      bool buildNeed = false;
      bool linkNeed = false;
      final oldBuild = data[ColumnNames.latestBuildNumber];
      final oldLink = data[ColumnNames.downloadLinks];
      if (oldBuild != null && oldBuild is! Map) {
        buildNeed = true;
        int val = 0;
        if (oldBuild is int) {
          val = oldBuild;
        } else if (oldBuild is String) {
          val = int.tryParse(oldBuild) ?? 0;
        }
        update[ColumnNames.latestBuildNumber] = {
          'universal': val,
          'bit_32': 0,
          'bit_64': 0
        };
      }
      if (oldLink != null && oldLink is! Map) {
        linkNeed = true;
        String link = '';
        if (oldLink is String) {
          link = oldLink;
        }
        update[ColumnNames.downloadLinks] = {
          'universal': link,
          'bit_32': '',
          'bit_64': ''
        };
      }
      if (update.isNotEmpty) {
        batch.update(doc.reference, update);
        if (buildNeed && linkNeed) {
          bothCount++;
        } else if (buildNeed) {
          buildCount++;
        } else if (linkNeed) {
          linkCount++;
        }
      }
    }
    if (buildCount > 0) {
      logs.add(
          '  - [${ColumnNames.latestBuildNumber}] $buildCount dokumen dimigrasi.');
    }
    if (linkCount > 0) {
      logs.add(
          '  - [${ColumnNames.downloadLinks}] $linkCount dokumen dimigrasi.');
    }
    if (bothCount > 0) {
      logs.add('  - [build+link] $bothCount dokumen dimigrasi.');
    }
  }

  /// Migrasi untuk field `value` di koleksi `upload_status`.
  Future<void> _migrateUploadStatusValue(
      final WriteBatch batch, final List<String> logs) async {
    final collectionName = TableNameValue.get(TableName.uploadStatus);
    final snapshot = await _firestore.collection(collectionName).get();
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey(ColumnNames.value)) {
        final val = data[ColumnNames.value];
        if (val is String && (val == '0' || val == '1')) {
          batch.update(doc.reference, {ColumnNames.value: val == '1'});
          count++;
        } else if (val is int && (val == 0 || val == 1)) {
          batch.update(doc.reference, {ColumnNames.value: val == 1});
          count++;
        }
      }
    }
    if (count > 0) {
      logs.add('  - [value] $count dokumen dimigrasi di `$collectionName`.');
    }
  }

  /// Menghapus sebuah koleksi beserta semua dokumen di dalamnya.
  Future<void> _deleteCollection(
    final String collectionName,
    final List<String> logs,
    final void Function(String) onProgress,
  ) async {
    final checkSnapshot =
        await _firestore.collection(collectionName).limit(1).get();
    if (checkSnapshot.docs.isEmpty) {
      Log.info('Koleksi `$collectionName` tidak ada, tidak perlu dihapus.');
      return;
    }

    onProgress('Menghapus koleksi lama: `$collectionName`...');
    Log.info('Mempersiapkan penghapusan untuk koleksi: $collectionName');

    try {
      final snapshot = await _firestore.collection(collectionName).get();
      final deleteBatch = _firestore.batch();
      int docCount = 0;

      for (final doc in snapshot.docs) {
        deleteBatch.delete(doc.reference);
        docCount++;
      }

      if (docCount > 0) {
        await deleteBatch.commit();
        logs.add(
            '  - [HAPUS] Koleksi lama `$collectionName` ($docCount dokumen) telah dihapus.');
        Log.info(
            'Koleksi lama `$collectionName` ($docCount dokumen) berhasil dihapus.');
        onProgress('Koleksi `$collectionName` berhasil dihapus.');
      }
    } on Exception catch (e, s) {
      final message =
          'Gagal menghapus koleksi `$collectionName`. Mungkin sudah terhapus atau terjadi error.';
      Log.error(message, e: e, st: s);
      logs.add('  - [ERROR] $message');
    }
  }

  /// Menganalisis dan menjalankan semua migrasi data Firebase yang diperlukan.
  Future<List<String>> runAllMigrations(
      final void Function(String) onProgress) async {
    Log.info('Memulai semua migrasi Firebase');
    onProgress('Memulai semua migrasi...');
    final batch = _firestore.batch();
    final logs = <String>[];

    final Map<String, String> legacyToNew = {
      'dompet': TableNameValue.get(TableName.wallet),
      'kategori': TableNameValue.get(TableName.category),
      'sub_kategori': TableNameValue.get(TableName.subCategory),
      'paket': TableNameValue.get(TableName.package),
      'pelanggan': TableNameValue.get(TableName.customer),
      'pelanggan_aktif': TableNameValue.get(TableName.activeCustomer),
      'transaksi': TableNameValue.get(TableName.transactions),
      'kritik_saran': TableNameValue.get(TableName.feedback),
      'pesanan': TableNameValue.get(TableName.customerOrder),
      'versi_apk_user': TableNameValue.get(TableName.userApkVersion),
      'pengaturan': TableNameValue.get(TableName.settings),
      'status_unggah': TableNameValue.get(TableName.uploadStatus),
      'pesan': TableNameValue.get(TableName.message),
    };

    onProgress('Menganalisis migrasi koleksi lama...');
    for (final entry in legacyToNew.entries) {
      final mapping = _columnMigrations[entry.value];
      if (mapping != null) {
        await _migrateLegacyCollection(
          legacyCollectionName: entry.key,
          newCollectionName: entry.value,
          columnMapping: mapping,
          batch: batch,
          logs: logs,
        );
      }
    }

    onProgress('Menganalisis migrasi `isDeleted`...');
    for (final col in _isDeletedCollections) {
      await _migrateIsDeleted(col, batch, logs);
    }

    // NOTE: Proses rename di-handle di _migrateLegacyCollection,
    // pemanggilan _migrateColumnNames di sini untuk memastikan konsistensi
    // pada data yang mungkin sudah ada di koleksi baru.
    onProgress('Menganalisis ulang nama kolom di koleksi tujuan...');
    for (final entry in _columnMigrations.entries) {
      await _migrateColumnNames(entry.key, entry.value, batch, logs);
    }

    onProgress('Menganalisis migrasi khusus `user_apk_version`...');
    await _migrateUserApkVersion(batch, logs);
    onProgress('Menganalisis migrasi khusus `isPublic`...');
    await _migrateIsPublic(batch, logs);
    onProgress('Menganalisis migrasi khusus `upload_status value`...');
    await _migrateUploadStatusValue(batch, logs);

    if (logs.any((final log) => !log.contains('ditemukan, dilewati'))) {
      onProgress('Menjalankan semua perubahan data...');
      try {
        await batch.commit();
        onProgress('Perubahan data berhasil disimpan!');
        Log.info('Semua migrasi Firebase (batch utama) berhasil di-commit.');

        onProgress('Memulai proses pembersihan koleksi lama...');
        for (final legacyCollectionName in legacyToNew.keys) {
          await _deleteCollection(legacyCollectionName, logs, onProgress);
        }
        onProgress('✅ Semua migrasi dan pembersihan telah selesai!');
        logs.add('INFO: Pembersihan koleksi lama selesai.');
      } on Exception catch (e, s) {
        final message = 'Gagal melakukan commit perubahan: $e';
        Log.error(message, e: e, st: s);
        onProgress('❌ $message');
        throw Exception('Gagal menyimpan perubahan ke Firestore.');
      }
    } else {
      onProgress('Tidak ada data yang perlu dimigrasi.');
      Log.info('Tidak ada migrasi Firebase yang perlu dilakukan');
    }

    return logs;
  }
}
