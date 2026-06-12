// path: lib/shared/data/sync/download_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/settings_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';
// lib/shared/data/sync/download_data.dart

class DownloadDataService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;
  final DompetOpSqlite _walletOperation;
  final CategoryOperation _categoryOperation;
  final PackageOperation _packageOperation;
  final CustomerOperation _customerOperation;
  final ActiveCustomerOperation _activeCustomerOperation;
  final TransactionOperation _transactionOperation;
  final FeedbackOperation _feedbackOperation;
  final OrderOperation _orderOperation;
  final SubCategoryOperation _subCategoryOperation;
  final ApkVersionOperation _apkVersionOperation;
  final SettingsOperation _settingsOperation;

  /// Konstruktor dengan injeksi dependensi (untuk produksi dan testing)
  DownloadDataService({
    required FirebaseFirestore firestore,
    required SyncManager syncManager,
    required DompetOpSqlite walletOperation,
    required CategoryOperation categoryOperation,
    required PackageOperation packageOperation,
    required CustomerOperation customerOperation,
    required ActiveCustomerOperation activeCustomerOperation,
    required TransactionOperation transactionOperation,
    required FeedbackOperation feedbackOperation,
    required OrderOperation orderOperation,
    required SubCategoryOperation subCategoryOperation,
    required ApkVersionOperation apkVersionOperation,
    required SettingsOperation settingsOperation,
  })  : _firestore = firestore,
        _syncManager = syncManager,
        _walletOperation = walletOperation,
        _categoryOperation = categoryOperation,
        _packageOperation = packageOperation,
        _customerOperation = customerOperation,
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
    required final CategoryOperation categoryOperation,
    required final PackageOperation packageOperation,
    required final CustomerOperation customerOperation,
    required final ActiveCustomerOperation activeCustomerOperation,
    required final TransactionOperation transactionOperation,
    required final FeedbackOperation feedbackOperation,
    required final OrderOperation orderOperation,
    required final SubCategoryOperation subCategoryOperation,
    required final ApkVersionOperation apkVersionOperation,
    required final SettingsOperation settingsOperation,
  })  : _firestore = firestore,
        _syncManager = syncManager,
        _walletOperation = walletOperation,
        _categoryOperation = categoryOperation,
        _packageOperation = packageOperation,
        _customerOperation = customerOperation,
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
    } on Exception catch (e, s) {
      Log.error(
        'Kegagalan kritis selama prosedur unduh massal.',
        e: e,
        st: s,
      );
      rethrow;
    }
  }

  /// Mengunduh data pengaturan dari Firebase.
  Future<void> downloadSettingsData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [SETTINGS]');
    try {
      final lastDownloadTime = await _syncManager.getLastDownload();
      // Menggunakan konstanta TableName.settings untuk nama koleksi
      final collectionName = TableNameValue.get(TableName.settings);
      // Menggunakan globalSettingsId dari settings_model.dart
      final docRef =
          _firestore.collection(collectionName).doc(globalSettingsId);
      final doc = await docRef.get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Menggunakan ColumnNames.updatedAt untuk field 'diperbarui'
        if (data.containsKey(ColumnNames.updatedAt)) {
          final dynamic fieldValue = data[ColumnNames.updatedAt];

          if (fieldValue is! Timestamp) {
            Log.error(
                'Inkompatibilitas Tipe: Field "${ColumnNames.updatedAt}" bukan Timestamp.');
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
              'Dokumen pengaturan tidak memiliki field "${ColumnNames.updatedAt}".');
        }
      } else {
        Log.warning('Dokumen pengaturan tidak ditemukan di server.');
      }
    } on Exception catch (e, s) {
      Log.error('Kesalahan sinkronisasi Settings.', e: e, st: s);
      rethrow;
    }
  }

  /// Mengunduh data dompet dari Firebase.
  Future<void> downloadWalletData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [WALLET]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<WalletModel>(
      collectionName: TableNameValue.get(TableName.wallet),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: WalletModel.fromFirebase,
      batchOperation: (final data) =>
          _walletOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data kategori dari Firebase.
  Future<void> downloadCategoryData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [CATEGORY]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<CategoryModel>(
      collectionName: TableNameValue.get(TableName.category),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: CategoryModel.fromFirebase,
      batchOperation: (final data) =>
          _categoryOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data paket dari Firebase.
  Future<void> downloadPackageData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PACKAGE]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<PackageModel>(
      collectionName: TableNameValue.get(TableName.package),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: PackageModel.fromFirebase,
      batchOperation: (final data) =>
          _packageOperation.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pelanggan dari Firebase.
  Future<void> downloadCustomerData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [CUSTOMER]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<CustomerModel>(
      collectionName: TableNameValue.get(TableName.customer),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: CustomerModel.fromFirebase,
      batchOperation: (final data) =>
          _customerOperation.sisipkanAtauPerbaruiBatch(data, dariServer: true),
    );
  }

  /// Mengunduh data pelanggan aktif dari Firebase.
  Future<void> downloadActiveCustomerData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [ACTIVE CUSTOMER]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<ActiveCustomerModel>(
      collectionName: TableNameValue.get(TableName.activeCustomer),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: ActiveCustomerModel.fromFirebase,
      batchOperation: (final data) =>
          _activeCustomerOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data transaksi dari Firebase.
  Future<void> downloadTransactionData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [TRANSACTION]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<TransactionModel>(
      collectionName: TableNameValue.get(TableName.transactions),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: TransactionModel.fromFirebase,
      batchOperation: (final data) =>
          _transactionOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data kritik dan saran dari Firebase.
  Future<void> downloadFeedbackData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [FEEDBACK]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<FeedbackModel>(
      collectionName: TableNameValue.get(TableName.feedback),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: FeedbackModel.fromFirebase,
      batchOperation: (final data) =>
          _feedbackOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data pesanan dari Firebase.
  Future<void> downloadOrderData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [ORDER]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<OrderModel>(
      collectionName: TableNameValue.get(TableName.customerOrder),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: OrderModel.fromFirebase,
      batchOperation: (final data) =>
          _orderOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data sub-kategori dari Firebase.
  Future<void> downloadSubCategoryData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [SUB CATEGORY]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<SubCategoryModel>(
      collectionName: TableNameValue.get(TableName.subCategory),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: SubCategoryModel.fromFirebase,
      batchOperation: (final data) =>
          _subCategoryOperation.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data versi APK user dari Firebase.
  Future<void> downloadApkVersionData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [APK VERSION]');
    final lastDownloadTime = await _syncManager.getLastDownload();
    await synchronizeCollection<ApkVersionModel>(
      collectionName: TableNameValue.get(TableName.userApkVersion),
      lastDownloadTime: lastDownloadTime,
      fromFirebase: ApkVersionModel.fromFirebase,
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
          .where(ColumnNames.updatedAt, isGreaterThan: lastDownloadTime)
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
              st: s,
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
        st: s,
      );
      rethrow;
    }
  }
}

final downloadDataServiceProvider = Provider<DownloadDataService>((ref) {
  return DownloadDataService(
    firestore: FirebaseFirestore.instance,
    syncManager: ref.read(syncManagerProvider),
    walletOperation: ref.read(walletOperationProvider),
    categoryOperation: ref.read(categoryOperationProvider),
    packageOperation: ref.read(packageOperationProvider),
    customerOperation: ref.read(customerOperationProvider),
    activeCustomerOperation: ref.read(activeCustomerOperationProvider),
    transactionOperation: ref.read(transactionOperationProvider),
    feedbackOperation: ref.read(feedbackOperationProvider),
    orderOperation: ref.read(orderOperationProvider),
    subCategoryOperation: ref.read(subCategoryOperationProvider),
    apkVersionOperation: ref.read(apkVersionOperationProvider),
    settingsOperation: ref.read(settingsOperationProvider),
  );
});
