// path: lib/services/firebase_migration/firebase_migration_service.dart
// Diperbarui: Menambahkan migrasi khusus untuk koleksi singleton (status, settings).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/model/status_model.dart';

/// Layanan untuk menangani migrasi data di Firebase.
/// - File ini digunakan oleh: lib/admin/halaman/lainnya/halaman_migrasi.dart
class FirebaseMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _isDeletedCollections = [
    NamaTabel.wallet,
    NamaTabel.category,
    NamaTabel.package,
    NamaTabel.activeCustomer,
    NamaTabel.customer,
    NamaTabel.customerOrder,
    NamaTabel.subCategory,
    NamaTabel.transactions,
    NamaTabel.userApkVersion,
    NamaTabel.feedback,
  ];

  final Map<String, Map<String, String>> _columnMigrations = {
    NamaTabel.wallet: {
      'namaDompet': NamaKolom.name,
      'saldo': NamaKolom.balance,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.category: {
      'nama': NamaKolom.name,
      'tipe': NamaKolom.type,
      'id_sub_kategori': NamaKolom.subCategoryId,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.subCategory: {
      'nama': NamaKolom.name,
      'id_kategori': NamaKolom.categoryId,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.package: {
      'nama': NamaKolom.name,
      'harga': NamaKolom.price,
      'durasi': NamaKolom.duration,
      'tipe': NamaKolom.type,
      'jumlahPoin': NamaKolom.earnedPoints,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'poin_hadiah': NamaKolom.rewardPoints,
      'poin_penukaran': NamaKolom.redemptionPoints,
      'isPublic': NamaKolom.isPublic,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.customer: {
      'nama': NamaKolom.name,
      'telepon': NamaKolom.phone,
      'alamat': NamaKolom.address,
      'password': NamaKolom.password,
      'mac_address': NamaKolom.macAddress,
      'status': NamaKolom.status,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.activeCustomer: {
      'id_pelanggan': NamaKolom.customerId,
      'id_paket': NamaKolom.packageId,
      'id_transaksi': NamaKolom.transactionId,
      'tanggalMulai': NamaKolom.startDate,
      'TanggalMulai': NamaKolom.startDate,
      'tanggal_mulai': NamaKolom.startDate,
      'tanggalBerakhir': NamaKolom.endDate,
      'TanggalBerakhir': NamaKolom.endDate,
      'tanggal_berakhir': NamaKolom.endDate,
      'status': NamaKolom.status,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.transactions: {
      'keterangan': NamaKolom.description,
      'jumlah': NamaKolom.amount,
      'tanggal': NamaKolom.date,
      'tipe': NamaKolom.type,
      'id_dompet': NamaKolom.walletId,
      'id_kategori': NamaKolom.categoryId,
      'id_sub_kategori': NamaKolom.subCategoryId,
      'id_pelanggan': NamaKolom.customerId,
      'id_paket': NamaKolom.packageId,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'id_dompet_tujuan': NamaKolom.destinationWalletId,
      'poin_yang_dihasilkan': NamaKolom.earnedPoints,
      'poin_yang_digunakan': NamaKolom.usedPoints,
      'status_pembayaran': NamaKolom.paymentStatus,
      'durasi_paket': NamaKolom.packageDuration,
      'tipe_durasi_paket': NamaKolom.durationType,
      'TanggalMulai': NamaKolom.startDate,
      'tanggal_berakhir': NamaKolom.endDate,
      'aktivasi_paket': NamaKolom.isActivated,
      'tanggalMulai': NamaKolom.startDate,
      'tanggalBerakhir': NamaKolom.endDate,
      'tipeDuraisiPaket': NamaKolom.durationType,
      'tipeDurasiPaket': NamaKolom.durationType,
      'aktivasiPaket': NamaKolom.isActivated,
      'durasiPaket': NamaKolom.packageDuration,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.feedback: {
      'isi': NamaKolom.content,
      'tanggal': NamaKolom.date,
      'userId': NamaKolom.userId,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.customerOrder: {
      'id_pelanggan': NamaKolom.customerId,
      'id_paket': NamaKolom.packageId,
      'tanggal': NamaKolom.date,
      'status': NamaKolom.status,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.userApkVersion: {
      'catatan_rilis': NamaKolom.releaseNotes,
      'nomor_build_terbaru': NamaKolom.latestBuildNumber,
      'tautan_unduhan': NamaKolom.downloadLinks,
      'versi_terbaru': NamaKolom.latestVersion,
      'wajib_update': NamaKolom.isUpdateRequired,
      'youtube_tutorial': NamaKolom.youtubeTutorial,
      'diperbarui': NamaKolom.updatedAt,
      'diarsipkan': NamaKolom.archivedAt,
      'isDeleted': NamaKolom.isDeleted,
    },
    NamaTabel.settings: {
      'interval_sinkronisasi_otomatis': NamaKolom.autoSyncInterval,
      'hapus_otomatis_data_arsip': NamaKolom.autoDeleteArchiveDays,
      'mode_pemeliharaan': NamaKolom.maintenanceMode,
      'info_pemeliharaan': NamaKolom.maintenanceInfo,
      'diperbarui': NamaKolom.updatedAt,
    },
    NamaTabel.statusGlobal: {
      'diperbarui': NamaKolom.updatedAt,
    },
    NamaTabel.uploadStatus: {
      'value': NamaKolom.value,
      'diperbarui': NamaKolom.updatedAt,
    },
    NamaTabel.message: {
      'isi': NamaKolom.content,
      'tanggal': NamaKolom.date,
      'status': NamaKolom.status,
    },
  };

  /// Migrasi untuk koleksi yang hanya memiliki satu dokumen dengan ID tetap.
  Future<void> _migrateSingletonCollection({
    required final String legacyCollectionName,
    required final String newCollectionName,
    required final String newDocId,
    required final Map<String, String> columnMapping,
    required final WriteBatch batch,
    required final List<String> logs,
  }) async {
    Log.info(
        'Memulai migrasi singleton dari "$legacyCollectionName" ke "$newCollectionName" dengan ID "$newDocId"');

    final QuerySnapshot snapshot;
    try {
      snapshot =
          await _firestore.collection(legacyCollectionName).limit(1).get();
    } on Exception catch (e) {
      Log.warning(
          'Koleksi singleton $legacyCollectionName tidak ditemukan, lewati migrasi',
          e);
      logs.add(
          '  - Koleksi singleton `$legacyCollectionName` tidak ditemukan, dilewati.');
      return;
    }

    if (snapshot.docs.isEmpty) {
      Log.info(
          'Koleksi singleton $legacyCollectionName kosong, akan dihapus nanti.');
      logs.add(
          '  - Koleksi singleton `$legacyCollectionName` kosong, dilewati.');
      return;
    }

    // Hanya migrasi dokumen pertama yang ditemukan
    final doc = snapshot.docs.first;
    final oldData = doc.data() as Map<String, dynamic>;
    final updateData = <String, dynamic>{};

    updateData.addAll(oldData);

    final Map<String, int> renamedCount = {};

    for (final entry in columnMapping.entries) {
      final oldField = entry.key;
      final newField = entry.value;
      if (oldData.containsKey(oldField)) {
        updateData[newField] = oldData[oldField];
        updateData.remove(oldField);
        renamedCount[oldField] = (renamedCount[oldField] ?? 0) + 1;
      }
    }

    final newDocRef = _firestore.collection(newCollectionName).doc(newDocId);
    batch.set(newDocRef, updateData, SetOptions(merge: true));

    logs.add(
        '  - [Migrasi Singleton] Dokumen dari `$legacyCollectionName` ke `$newCollectionName/$newDocId` disiapkan.');
    for (final entry in renamedCount.entries) {
      logs.add(
          '    - ${entry.key} -> ${columnMapping[entry.key]} : 1 field akan di-rename.');
    }
  }

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
    const collectionName = NamaTabel.package;
    final snapshot = await _firestore.collection(collectionName).get();
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('isPublic')) {
        batch.update(doc.reference, {
          NamaKolom.isPublic: data['isPublic'],
          'isPublic': FieldValue.delete(),
        });
        count++;
      }
    }
    if (count > 0) {
      logs.add(
          '  - [isPublic -> ${NamaKolom.isPublic}] $count dokumen akan dimigrasi.');
    }
  }

  /// Migrasi untuk field di koleksi `user_apk_version`.
  Future<void> _migrateUserApkVersion(
    final WriteBatch batch,
    final List<String> logs,
  ) async {
    const collectionName = NamaTabel.userApkVersion;
    final snapshot = await _firestore.collection(collectionName).get();
    int buildCount = 0;
    int linkCount = 0;
    int bothCount = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final update = <String, dynamic>{};
      bool buildNeed = false;
      bool linkNeed = false;
      final oldBuild = data[NamaKolom.latestBuildNumber];
      final oldLink = data[NamaKolom.downloadLinks];
      if (oldBuild != null && oldBuild is! Map) {
        buildNeed = true;
        int val = 0;
        if (oldBuild is int) {
          val = oldBuild;
        } else if (oldBuild is String) {
          val = int.tryParse(oldBuild) ?? 0;
        }
        update[NamaKolom.latestBuildNumber] = {
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
        update[NamaKolom.downloadLinks] = {
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
          '  - [${NamaKolom.latestBuildNumber}] $buildCount dokumen dimigrasi.');
    }
    if (linkCount > 0) {
      logs.add(
          '  - [${NamaKolom.downloadLinks}] $linkCount dokumen dimigrasi.');
    }
    if (bothCount > 0) {
      logs.add('  - [build+link] $bothCount dokumen dimigrasi.');
    }
  }

  /// Migrasi untuk field `value` di koleksi `upload_status`.
  Future<void> _migrateUploadStatusValue(
      final WriteBatch batch, final List<String> logs) async {
    const collectionName = NamaTabel.uploadStatus;
    final snapshot = await _firestore.collection(collectionName).get();
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey(NamaKolom.value)) {
        final val = data[NamaKolom.value];
        if (val is String && (val == '0' || val == '1')) {
          batch.update(doc.reference, {NamaKolom.value: val == '1'});
          count++;
        } else if (val is int && (val == 0 || val == 1)) {
          batch.update(doc.reference, {NamaKolom.value: val == 1});
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
      Log.error(message, e: e, s: s);
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
      'dompet': NamaTabel.wallet,
      'kategori': NamaTabel.category,
      'sub_kategori': NamaTabel.subCategory,
      'paket': NamaTabel.package,
      'pelanggan': NamaTabel.customer,
      'pelanggan_aktif': NamaTabel.activeCustomer,
      'transaksi': NamaTabel.transactions,
      'kritik_saran': NamaTabel.feedback,
      'pesanan': NamaTabel.customerOrder,
      'versi_apk_user': NamaTabel.userApkVersion,
      'pengaturan': NamaTabel.settings,
      'status': NamaTabel.statusGlobal,
      'status_unggah': NamaTabel.uploadStatus,
      'pesan': NamaTabel.message,
    };

    onProgress('Menganalisis migrasi koleksi lama...');
    for (final entry in legacyToNew.entries) {
      final legacyName = entry.key;
      final newName = entry.value;
      final mapping = _columnMigrations[newName];

      if (mapping != null) {
        if (newName == NamaTabel.settings) {
          await _migrateSingletonCollection(
            legacyCollectionName: legacyName,
            newCollectionName: newName,
            newDocId: idGlobalSetting,
            columnMapping: mapping,
            batch: batch,
            logs: logs,
          );
        } else if (newName == NamaTabel.statusGlobal) {
          await _migrateSingletonCollection(
            legacyCollectionName: legacyName,
            newCollectionName: newName,
            newDocId: globalStatusId,
            columnMapping: mapping,
            batch: batch,
            logs: logs,
          );
        } else {
          await _migrateLegacyCollection(
            legacyCollectionName: legacyName,
            newCollectionName: newName,
            columnMapping: mapping,
            batch: batch,
            logs: logs,
          );
        }
      }
    }

    onProgress('Menganalisis migrasi `isDeleted`...');
    for (final col in _isDeletedCollections) {
      await _migrateIsDeleted(col, batch, logs);
    }

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

    if (logs.any((final log) =>
        !log.contains('ditemukan, dilewati') && !log.contains('kosong'))) {
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
        Log.error(message, e: e, s: s);
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
