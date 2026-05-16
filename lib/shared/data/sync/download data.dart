// path: lib/shared/data/sync/download_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/active_customer_model.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/model/category_model.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/feedback_model.dart';
import 'package:wifi/shared/model/order_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/kritik_saran_operasi.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/active_customer_operation.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/pengaturan_operasi.dart';
import 'package:wifi/shared/operasi/pesanan_operasi.dart';
import 'package:wifi/shared/operasi/sub_kategori_operasi.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/versi_apk_user_operasi.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Layanan untuk mengunduh semua data dari Firebase.
class DownloadDataService {
  final FirebaseFirestore _firestore;
  final SyncManager _syncManager;

  // Operasi
  final WalletOperasi _walletOperasi;
  final CategoryOperasi _categoryOperasi;
  final PackageOperasi _packageOperasi;
  final CustomerOperasi _customerOperasi;
  final ActiveCustomerOperasi _activeCustomerOperasi;
  final TransactionOperasi _transactionOperasi;
  final KritikSaranOperasi _kritikSaranOperasi;
  final OrderOperasi _orderOperasi;
  final SubCategoryOperasi _subCategoryOperasi;
  final ApkVersionOperasi _apkVersionOperasi;
  final SettingsOperasi _settingsOperasi;

  /// Konstruktor untuk penggunaan produksi.
  DownloadDataService({
    final FirebaseFirestore? firestore,
    final SyncManager? syncManager,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _syncManager = syncManager ?? SyncManager(),
        _walletOperasi = WalletOperasi(),
        _categoryOperasi = CategoryOperasi(),
        _packageOperasi = PackageOperasi(),
        _customerOperasi = CustomerOperasi(),
        _activeCustomerOperasi = ActiveCustomerOperasi(),
        _transactionOperasi = TransactionOperasi(),
        _kritikSaranOperasi = KritikSaranOperasi(),
        _orderOperasi = OrderOperasi(),
        _subCategoryOperasi = SubCategoryOperasi(),
        _apkVersionOperasi = ApkVersionOperasi(),
        _settingsOperasi = SettingsOperasi() {
    Log.info('DownloadDataService berhasil diinisialisasi untuk produksi.');
  }

  /// Konstruktor khusus untuk pengujian dengan dependensi mock.
  DownloadDataService.test({
    required final FirebaseFirestore firestore,
    required final SyncManager syncManager,
    required final WalletOperasi walletOperasi,
    required final CategoryOperasi categoryOperasi,
    required final PackageOperasi packageOperasi,
    required final CustomerOperasi customerOperasi,
    required final ActiveCustomerOperasi activeCustomerOperasi,
    required final TransactionOperasi transactionOperasi,
    required final KritikSaranOperasi kritikSaranOperasi,
    required final OrderOperasi orderOperasi,
    required final SubCategoryOperasi subCategoryOperasi,
    required final ApkVersionOperasi apkVersionOperasi,
    required final SettingsOperasi settingsOperasi,
  })  : _firestore = firestore,
        _syncManager = syncManager,
        _walletOperasi = walletOperasi,
        _categoryOperasi = categoryOperasi,
        _packageOperasi = packageOperasi,
        _customerOperasi = customerOperasi,
        _activeCustomerOperasi = activeCustomerOperasi,
        _transactionOperasi = transactionOperasi,
        _kritikSaranOperasi = kritikSaranOperasi,
        _orderOperasi = orderOperasi,
        _subCategoryOperasi = subCategoryOperasi,
        _apkVersionOperasi = apkVersionOperasi,
        _settingsOperasi = settingsOperasi {
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
      final lastDownloadTime = await _syncManager.getLastDownloadTime();
      final docRef = _firestore.collection('pengaturan').doc(globalSettingsId);
      final doc = await docRef.get(const GetOptions(source: Source.server));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('diperbarui')) {
          final dynamic fieldValue = data['diperbarui'];

          if (fieldValue is! Timestamp) {
            Log.error(
                'Inkompatibilitas Tipe: Field "diperbarui" bukan Timestamp.');
            return;
          }

          final serverUpdateTime = fieldValue.toDate();

          if (serverUpdateTime.isAfter(lastDownloadTime)) {
            Log.info('Data pengaturan server lebih baru, memperbarui lokal.');
            final settings = SettingsModel.fromFirebase(data);
            await _settingsOperasi.saveOrUpdateSettings(
              settings,
              fromServer: true,
            );
            Log.info('Update Settings lokal berhasil.');
          } else {
            Log.info('Data pengaturan lokal sudah sinkron.');
          }
        } else {
          Log.warning('Dokumen pengaturan tidak memiliki field "diperbarui".');
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
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<WalletModel>(
      collectionName: 'dompet',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: WalletModel.fromFirebase,
      batchOperation: (final data) =>
          _walletOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data kategori dari Firebase.
  Future<void> downloadCategoryData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [CATEGORY]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<CategoryModel>(
      collectionName: 'kategori',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: CategoryModel.fromFirebase,
      batchOperation: (final data) =>
          _categoryOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data paket dari Firebase.
  Future<void> downloadPackageData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [PACKAGE]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<PackageModel>(
      collectionName: 'paket',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: PackageModel.fromFirebase,
      batchOperation: (final data) =>
          _packageOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data pelanggan dari Firebase.
  Future<void> downloadCustomerData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [CUSTOMER]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<CustomerModel>(
      collectionName: 'pelanggan',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: CustomerModel.fromFirebase,
      batchOperation: (final data) =>
          _customerOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data pelanggan aktif dari Firebase.
  Future<void> downloadActiveCustomerData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [ACTIVE CUSTOMER]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<ActiveCustomerModel>(
      collectionName: 'pelanggan_aktif',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: ActiveCustomerModel.fromFirebase,
      batchOperation: (final data) =>
          _activeCustomerOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data transaksi dari Firebase.
  Future<void> downloadTransactionData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [TRANSACTION]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<TransactionModel>(
      collectionName: 'transaksi',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: TransactionModel.fromFirebase,
      batchOperation: (final data) =>
          _transactionOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data kritik dan saran dari Firebase.
  Future<void> downloadFeedbackData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [FEEDBACK]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<FeedbackModel>(
      collectionName: 'kritik_saran',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: FeedbackModel.fromFirebase,
      batchOperation: (final data) =>
          _kritikSaranOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data pesanan dari Firebase.
  Future<void> downloadOrderData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [ORDER]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<OrderModel>(
      collectionName: 'pesan',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: OrderModel.fromFirebase,
      batchOperation: (final data) =>
          _orderOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data sub-kategori dari Firebase.
  Future<void> downloadSubCategoryData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [SUB CATEGORY]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<SubCategoryModel>(
      collectionName: 'sub_kategori',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: SubCategoryModel.fromFirebase,
      batchOperation: (final data) =>
          _subCategoryOperasi.insertOrUpdateBatch(data, fromServer: true),
    );
  }

  /// Mengunduh data versi APK user dari Firebase.
  Future<void> downloadApkVersionData() async {
    Log.info('Memulai sinkronisasi untuk koleksi: [APK VERSION]');
    final lastDownloadTime = await _syncManager.getLastDownloadTime();
    await synchronizeCollection<ApkVersionModel>(
      collectionName: 'versi_apk_user',
      lastDownloadTime: lastDownloadTime,
      fromFirebase: ApkVersionModel.fromFirebase,
      batchOperation: (final data) =>
          _apkVersionOperasi.insertOrUpdateBatch(data, fromServer: true),
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
      final snapshot = await _firestore
          .collection(collectionName)
          .where('diperbarui', isGreaterThan: lastDownloadTime)
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
