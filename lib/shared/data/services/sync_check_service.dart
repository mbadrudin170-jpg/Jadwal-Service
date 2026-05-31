// path: lib/shared/data/services/sync_check_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/data/services/new_data_check_service.dart';
import 'package:wifi/shared/data/sync/download_data.dart';
import 'package:wifi/shared/data/sync/upload_data.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Layanan untuk mengorkestrasi proses sinkronisasi data.
class SyncCheckService {
  final SyncManager _syncManager;
  final UploadDataService _uploadService;
  final DownloadDataService _downloadService;
  final NewDataCheckService _newDataCheck;
  final FirebaseFirestore _firestore;

  /// Konstruktor dengan injeksi dependensi (wajib).
  SyncCheckService({
    required SyncManager syncManager,
    required UploadDataService uploadService,
    required DownloadDataService downloadService,
    required NewDataCheckService newDataCheck,
    required FirebaseFirestore firestore,
  })  : _syncManager = syncManager,
        _uploadService = uploadService,
        _downloadService = downloadService,
        _newDataCheck = newDataCheck,
        _firestore = firestore {
    Log.info('SyncCheckService diinisialisasi dengan dependency injection.');
  }

  /// Menjalankan seluruh proses pengecekan dan sinkronisasi data.
  Future<void> runSyncCheck() async {
    Log.info('Memulai siklus orkestrasi sinkronisasi global.');

    final bool hasUploadedData = await _checkAndRunUpload();
    await _checkAndRunDownload();

    if (hasUploadedData) {
      Log.info(
          'Pemicu sinkronisasi: Ada data baru yang berhasil diunggah ke server.');
      await _updateGlobalStatus();
    }

    Log.info('Seluruh siklus runSyncCheck() telah berakhir dengan sukses.');
  }

  Future<bool> _checkAndRunUpload() async {
    try {
      final bool hasDataToUpload = await _newDataCheck.hasNewSqliteData();

      if (hasDataToUpload) {
        await _uploadService.uploadAllData();
        final DateTime now = DateTime.now();
        await _syncManager.setLastUpload(now);
        await _newDataCheck.resetNeedUpload();
        Log.info('Metadata sinkronisasi berhasil diperbarui: $now.');
        return true;
      } else {
        Log.info('Tidak ditemukan record baru. Melewati fase pengunggahan.');
        return false;
      }
    } on Exception catch (e, s) {
      Log.error('Kegagalan Operasional saat unggah.', e: e, st: s);
      return false;
    }
  }

  Future<void> _updateGlobalStatus() async {
    try {
      await _firestore
          .collection(TableNameValue.get(TableName.statusGlobal))
          .doc(globalStatusId)
          .set(
        {ColumnNames.updatedAt: FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      Log.info(
          'Dokumen ${TableNameValue.get(TableName.statusGlobal)}/global berhasil diperbarui.');
    } on Exception catch (e, s) {
      Log.error(
          'Gagal memperbarui dokumen ${TableNameValue.get(TableName.statusGlobal)}/global.',
          e: e,
          st: s);
    }
  }

  Future<void> _checkAndRunDownload() async {
    try {
      final bool hasNewServerData = await _newDataCheck.hasNewFirebaseData(
        collectionName: TableNameValue.get(TableName.statusGlobal),
        documentId: globalStatusId,
      );

      if (hasNewServerData) {
        await _downloadService.downloadAllData();
        final DateTime now = DateTime.now();
        await _syncManager.setLastDownload(now);
        Log.info('Sinkronisasi masuk selesai: $now.');
      } else {
        Log.info('Cloud tidak memiliki pembaruan data.');
      }
    } on Exception catch (e, s) {
      Log.error('Kegagalan Operasional saat unduh.', e: e, st: s);
    }
  }
}

// ============================================================
// Provider Riverpod untuk SyncCheckService
// ============================================================
final syncCheckServiceProvider = Provider<SyncCheckService>((ref) {
  return SyncCheckService(
    syncManager: ref.read(syncManagerProvider),
    uploadService: ref.read(uploadDataServiceProvider), // harus sudah ada
    downloadService: ref.read(downloadDataServiceProvider), // sudah ada
    newDataCheck: ref.read(newDataCheckServiceProvider), // harus sudah ada
    firestore: FirebaseFirestore.instance,
  );
});
