// path: lib/shared/data/sync/download_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

class DownloadDataService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  final DompetOpSqlite _dompetOpSqlite;
  final KategoriOpSqlite _categoryOperation;
  final PaketOpSqlite _paketOpSqlite;
  final PelangganOpSqlite _pelangganOpSqlite;
  final PelangganAktifOpSqlite _activeCustomerOperation;
  final TransaksiOpsqlite _transactionOperation;
  final FeedbackOperation _feedbackOperation;
  final OrderOpsqlite _orderOperation;
  final SubKategoriOpSqlite _subCategoryOperation;
  final ApkVersionOperation _apkVersionOperation;
  final SettingsOpSqlite _settingsOperation;

  /// Konstruktor dengan injeksi dependensi (untuk produksi dan testing)
  DownloadDataService({
    required FirebaseFirestore firestore,
    required SyncManager syncManager,
    required DompetOpSqlite walletOperation,
    required KategoriOpSqlite categoryOperation,
    required PaketOpSqlite paketOpSqlite,
    required PelangganOpSqlite pelangganOpSqlite,
    required PelangganAktifOpSqlite activeCustomerOperation,
    required TransaksiOpsqlite transactionOperation,
    required FeedbackOperation feedbackOperation,
    required OrderOpsqlite orderOperation,
    required SubKategoriOpSqlite subCategoryOperation,
    required ApkVersionOperation apkVersionOperation,
    required SettingsOpSqlite settingsOperation,
  })  : _firestore = firestore,
        _syncManager = syncManager,
        _dompetOpSqlite = walletOperation,
        _categoryOperation = categoryOperation,
        _paketOpSqlite = paketOpSqlite,
        _pelangganOpSqlite = pelangganOpSqlite,
        _activeCustomerOperation = activeCustomerOperation,
        _transactionOperation = transactionOperation,
        _feedbackOperation = feedbackOperation,
        _orderOperation = orderOperation,
        _subCategoryOperation = subCategoryOperation,
        _apkVersionOperation = apkVersionOperation,
        _settingsOperation = settingsOperation {
    Log.info('DownloadDataService diinisialisasi dengan dependency injection.');
  }

  /// Konstruktor khusus untuk pengujian dengan dependensi mock.
  DownloadDataService.test({
    required final FirebaseFirestore firestore,
    required final SyncManager syncManager,
    required final DompetOpSqlite walletOperation,
    required final KategoriOpSqlite categoryOperation,
    required final PaketOpSqlite packageOperation,
    required final PelangganOpSqlite customerOperation,
    required final PelangganAktifOpSqlite activeCustomerOperation,
    required final TransaksiOpsqlite transactionOperation,
    required final FeedbackOperation feedbackOperation,
    required final OrderOpsqlite orderOperation,
    required final SubKategoriOpSqlite subCategoryOperation,
    required final ApkVersionOperation apkVersionOperation,
    required final SettingsOpSqlite settingsOperation,
  })  : _firestore = firestore,
        _syncManager = syncManager,
        _dompetOpSqlite = walletOperation,
        _categoryOperation = categoryOperation,
        _paketOpSqlite = packageOperation,
        _pelangganOpSqlite = customerOperation,
        _activeCustomerOperation = activeCustomerOperation,
        _transactionOperation = transactionOperation,
        _feedbackOperation = feedbackOperation,
        _orderOperation = orderOperation,
        _subCategoryOperation = subCategoryOperation,
        _apkVersionOperation = apkVersionOperation,
        _settingsOperation = settingsOperation {
    Log.info('DownloadDataService berhasil diinisialisasi untuk pengujian.');
  }

  /// Mengunduh semua data dari semua koleksi di Firebase.
  Future<void> downloadAllData() async {
    Log.info('Memulai prosedur orkestrasi unduh data massal.');
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        downloadActiveCustomerData(),
        downloadSettingsData(),
        downloadWalletData(),
        downloadCategoryData(),
        downloadPackageData(),
        downloadCustomerData(),
        downloadTransactionData(),
        downloadFeedbackData(),
        downloadOrderData(),
        downloadSubCategoryData(),
        downloadApkVersionData(),
      ]);

      stopwatch.stop();
      Log.info(
        'Prosedur unduh data massal selesai sepenuhnya. Total durasi: ${stopwatch.elapsed.inMilliseconds} ms.',
      );
    } catch (e, s) {
      Log.error(
        'Kegagalan kritis selama prosedur unduh massal.',
        e: e,
        s: s,
      );
      rethrow;
    }
  }

  /// Mengunduh data pengaturan dari Firebase.
  Future<void> downloadSettingsData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [SETTINGS]');
    try {
      final lastDownloadTime =
          await _syncManager.ambilTanggalTerakhirDownload();
      // Menggunakan konstanta NamaTabel.settings untuk nama koleksi
      const collectionName = NamaTabel.settings;
      // Menggunakan globalSettingsId dari settings_model.dart
      final docRef = _firestore.collection(collectionName).doc(idGlobalSetting);
      final doc = await docRef.get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Menggunakan ColumnNames.updatedAt untuk field 'diperbarui'
        if (data.containsKey(NamaKolom.diperbaruiPada)) {
          final dynamic fieldValue = data[NamaKolom.diperbaruiPada];

          if (fieldValue is! Timestamp) {
            Log.error(
                'Inkompatibilitas Tipe: Field "${NamaKolom.diperbaruiPada}" bukan Timestamp.');
            return;
          }

          final serverUpdateTime = fieldValue.toDate();

          if (serverUpdateTime.isAfter(lastDownloadTime)) {
            Log.info('Data pengaturan server lebih baru, memperbarui lokal.');
            final settings = SettingsModel.fromFirebase(data);
            await _settingsOperation.saveOrUpdateSettings(
              settings,
              fromServer: true,
            );
            Log.info('Update Settings lokal berhasil.');
          } else {
            Log.info('Data pengaturan lokal sudah sinkron.');
          }
        } else {
          Log.warning(
              'Dokumen pengaturan tidak memiliki field "${NamaKolom.diperbaruiPada}".');
        }
      } else {
        Log.warning('Dokumen pengaturan tidak ditemukan di server.');
      }
    } catch (e, s) {
      Log.error('Kesalahan sinkronisasi Settings.', e: e, s: s);
      rethrow;
    }
  }

  /// Mengunduh data dompet dari Firebase.
  Future<void> downloadWalletData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [WALLET]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<DompetModel>(
      collectionName: NamaTabel.wallet,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: DompetModel.fromFirebase,
      batchOperation: (final data) =>
          _dompetOpSqlite.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data kategori dari Firebase.
  Future<void> downloadCategoryData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [CATEGORY]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<KategoriModel>(
      collectionName: NamaTabel.category,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: KategoriModel.fromFirebase,
      batchOperation: (final data) =>
          _categoryOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data paket dari Firebase.
  Future<void> downloadPackageData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PACKAGE]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<PaketModel>(
      collectionName: NamaTabel.package,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: PaketModel.fromFirebase,
      batchOperation: (final data) =>
          _paketOpSqlite.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pelanggan dari Firebase.
  Future<void> downloadCustomerData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [CUSTOMER]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<PelangganModel>(
      collectionName: NamaTabel.customer,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: PelangganModel.fromFirebase,
      batchOperation: (final data) =>
          _pelangganOpSqlite.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pelanggan aktif dari Firebase.
  Future<void> downloadActiveCustomerData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [ACTIVE CUSTOMER]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<PelangganAktifModel>(
      collectionName: NamaTabel.activeCustomer,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: PelangganAktifModel.fromFirebase,
      batchOperation: (final data) =>
          _activeCustomerOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data transaksi dari Firebase.
  Future<void> downloadTransactionData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [TRANSACTION]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<TransaksiModel>(
      collectionName: NamaTabel.transactions,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: TransaksiModel.fromFirebase,
      batchOperation: (final data) =>
          _transactionOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data kritik dan saran dari Firebase.
  Future<void> downloadFeedbackData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [FEEDBACK]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<FeedbackModel>(
      collectionName: NamaTabel.feedback,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: FeedbackModel.fromFirebase,
      batchOperation: (final data) =>
          _feedbackOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data pesanan dari Firebase.
  Future<void> downloadOrderData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [ORDER]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<OrderModel>(
      collectionName: NamaTabel.customerOrder,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: OrderModel.fromFirebase,
      batchOperation: (final data) =>
          _orderOperation.insertOrUpdateBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data sub-kategori dari Firebase.
  Future<void> downloadSubCategoryData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [SUB CATEGORY]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<SubCategoryModel>(
      collectionName: NamaTabel.subCategory,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: SubCategoryModel.fromFirebase,
      batchOperation: (final data) =>
          _subCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data versi APK user dari Firebase.
  Future<void> downloadApkVersionData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [APK VERSION]');
    final lastDownloadTime = await _syncManager.ambilTanggalTerakhirDownload();
    await synchronizeCollection<VersiApkModel>(
      collectionName: NamaTabel.userApkVersion,
      lastDownloadTime: lastDownloadTime,
      fromFirebase: VersiApkModel.fromFirebase,
      batchOperation: (final data) =>
          _apkVersionOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Menyinkronkan satu koleksi dari Firebase ke database lokal.
  Future<void> synchronizeCollection<T>({
    required final String collectionName,
    required final DateTime lastDownloadTime,
    required final T Function(String id, Map<String, dynamic> data)
        fromFirebase,
    required final Future<void> Function(List<T>) batchOperation,
  }) async {
    Log.info(
      'Sinkronisasi Koleksi: Memeriksa [$collectionName] untuk data baru sejak $lastDownloadTime.',
    );
    try {
      // Menggunakan ColumnNames.updatedAt untuk field 'diperbarui'
      final snapshot = await _firestore
          .collection(collectionName)
          .where(NamaKolom.diperbaruiPada, isGreaterThan: lastDownloadTime)
          .get(const GetOptions(source: Source.server));

      if (snapshot.docs.isNotEmpty) {
        Log.info(
          'Ditemukan ${snapshot.docs.length} dokumen baru/diperbarui di [$collectionName].',
        );

        final List<T> dataList = [];
        for (final doc in snapshot.docs) {
          try {
            dataList.add(fromFirebase(doc.id, doc.data()));
          } on Exception catch (e, s) {
            Log.error(
              'Gagal memproses dokumen ${doc.id} di koleksi $collectionName',
              e: e,
              s: s,
            );
          }
        }

        if (dataList.isNotEmpty) {
          Log.info('Mengirim ${dataList.length} item ke operasi batch lokal.');
          await batchOperation(dataList);
          Log.info('Sinkronisasi masuk untuk [$collectionName] berhasil.');
        } else {
          Log.warning(
            'Tidak ada data valid untuk disimpan dari [$collectionName].',
          );
        }
      } else {
        Log.info('Koleksi [$collectionName] sudah sinkron.');
      }
    } on Exception catch (e, s) {
      Log.error(
        'Kegagalan sinkronisasi koleksi: $collectionName',
        e: e,
        s: s,
      );
      rethrow;
    }
  }
}

final downloadDataServiceProvider = Provider<DownloadDataService>((ref) {
  return DownloadDataService(
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(syncManagerProvider),
    walletOperation: ref.read(dompetOpSqliteProvider),
    categoryOperation: ref.read(kategoriOpSqliteProvider),
    paketOpSqlite: ref.read(paketOpSqliteProvider),
    pelangganOpSqlite: ref.read(pelangganOpSqliteProvider),
    activeCustomerOperation: ref.read(pelangganAktifOpSqliteProvider),
    transactionOperation: ref.read(transaksiOpSqliteProvider),
    feedbackOperation: ref.read(feedbackOperationProvider),
    orderOperation: ref.read(orderOperationProvider),
    subCategoryOperation: ref.read(subKategoriOpSqliteProvider),
    apkVersionOperation: ref.read(apkVersionOperationProvider),
    settingsOperation: ref.read(settingsOpSqliteProvider),
  );
});
