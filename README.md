# 17 Mei 2026 00:36

Baik, ini semua kode final dari 31 file yang telah diperbaiki. Saya tulis lengkap tanpa dokumentasi perubahannya.

---

### 1. `lib/admin/halaman/lainnya/admin_settings.dart`

```dart
// path: lib/admin/halaman/lainnya/admin_settings.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan sebagai halaman dalam navigasi admin (Settings).
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/form/settings_form.dart (SettingsForm)
//   - lib/shared/model/settings_model.dart (SettingsModel)
//   - lib/shared/operasi/settings_operation.dart (SettingsOperation)
//   - lib/shared/utils/sync_manager.dart (SyncManager)
//   - lib/shared/utils/snackbar_util.dart (SnackBarUtil)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/settings_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/settings_model.dart';
import 'package:wifi/shared/operasi/settings_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/shared/utils/sync_manager.dart';

/// Halaman untuk menampilkan dan mengelola konfigurasi pengaturan aplikasi.
///
/// Dari halaman ini, admin dapat melihat pengaturan saat ini, mengeditnya,
/// dan melakukan aksi terkait seperti mereset waktu sinkronisasi.
class SettingsAdminPage extends StatefulWidget {
  /// Membuat instance dari [SettingsAdminPage].
  const SettingsAdminPage({super.key});

  @override
  State<SettingsAdminPage> createState() => _SettingsAdminPageState();
}

class _SettingsAdminPageState extends State<SettingsAdminPage> {
  final SettingsOperation _settingsOperation = SettingsOperation();
  late Future<SettingsModel> _futureSettings;

  @override
  void initState() {
    super.initState();
    Log.info('Menginisialisasi halaman Pengaturan Aplikasi');
    _loadSettings();
  }

  // Fungsi untuk memuat data pengaturan dari database.
  void _loadSettings() {
    Log.info('Memuat data pengaturan dari database lokal');
    setState(() {
      _futureSettings = _settingsOperation.getSettings().then((final data) {
        Log.info('Data pengaturan berhasil dimuat dari database');
        Log.info(
          'Detail pengaturan - Interval sinkronisasi: ${data.autoSyncInterval} jam, Hapus arsip: ${data.autoDeleteArchiveDays} hari, Mode pemeliharaan: ${data.maintenanceMode ? "Aktif" : "Nonaktif"}, Info pemeliharaan: ${data.maintenanceInfo.isNotEmpty ? data.maintenanceInfo : "(kosong)"}',
        );
        return data;
      }).catchError((final Object e, final StackTrace st) {
        Log.error(
          'Gagal memuat data pengaturan dari database lokal',
          e: e,
          st: st,
        );
        throw Exception('Gagal memuat data pengaturan: $e');
      });
    });
  }

  // Fungsi untuk menavigasi ke halaman form edit dan memuat ulang data jika ada perubahan.
  Future<void> _editSettings(final SettingsModel pengaturan) async {
    Log.info('Navigasi ke halaman Form Edit Pengaturan');
    Log.info(
      'Data pengaturan sebelum edit - Interval: ${pengaturan.autoSyncInterval} jam, Hapus arsip: ${pengaturan.autoDeleteArchiveDays} hari, Mode pemeliharaan: ${pengaturan.maintenanceMode}, Info: ${pengaturan.maintenanceInfo.isNotEmpty ? pengaturan.maintenanceInfo : "(kosong)"}',
    );

    final hasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final context) => SettingsForm(settings: pengaturan),
      ),
    );

    if ((hasil ?? false) && mounted) {
      Log.info(
        'Data pengaturan berhasil diperbarui dari Form Edit, menyegarkan tampilan',
      );
      _loadSettings();
    } else if (hasil == false) {
      Log.info('Kembali dari Form Edit Pengaturan tanpa melakukan perubahan');
    } else {
      Log.info('Kembali dari Form Edit Pengaturan (hasil: $hasil)');
    }
  }

  // Fungsi untuk mereset waktu sinkronisasi
  Future<void> _resetSyncTime() async {
    Log.info('Tombol Reset Waktu Sinkronisasi ditekan.');
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Konfirmasi Reset'),
        content: const Text(
          'Anda yakin ingin mereset waktu sinkronisasi? Tindakan ini akan memaksa aplikasi untuk mengunggah semua data yang dimodifikasi dan mengunduh semua data dari server pada siklus sinkronisasi berikutnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (konfirmasi ?? false) {
      Log.info(
        'Pengguna mengonfirmasi reset. Memanggil SyncManager().resetSyncTime().',
      );
      try {
        await SyncManager().resetSyncTime();
        Log.info('Reset waktu sinkronisasi berhasil.');
        if (mounted) {
          SnackBarUtil.success(
            context,
            'Waktu sinkronisasi berhasil di-reset.',
          );
        }
      } on Exception catch (e, st) {
        Log.error('Gagal mereset waktu sinkronisasi', e: e, st: st);
        if (mounted) {
          SnackBarUtil.error(
            context,
            'Gagal mereset waktu sinkronisasi: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman Pengaturan Aplikasi');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Kembali ke halaman sebelumnya dari Pengaturan');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<SettingsModel>(
        future: _futureSettings,
        builder: (final context, final snapshot) {
          Log.info('FutureBuilder status: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info(
              'Menampilkan indikator loading, data pengaturan masih dimuat',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error(
              'FutureBuilder mendeteksi error saat memuat data pengaturan',
              e: snapshot.error,
              st: snapshot.stackTrace,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pengaturan = snapshot.data;
            Log.info('Data pengaturan tersedia, menampilkan detail pengaturan');
            Log.info(
              'Mode pemeliharaan: ${pengaturan!.maintenanceMode ? "Aktif" : "Nonaktif"}, Info: ${pengaturan.maintenanceInfo.isNotEmpty ? pengaturan.maintenanceInfo : "(kosong)"}',
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildInfoCard(
                          judul: 'Sinkronisasi Otomatis',
                          nilai: '${pengaturan.autoSyncInterval} Jam',
                          ikon: Icons.sync,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          judul: 'Hapus Arsip Otomatis',
                          nilai: '${pengaturan.autoDeleteArchiveDays} Hari',
                          ikon: Icons.auto_delete_outlined,
                        ),
                        const Divider(height: 24, thickness: 1),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text(
                                  'Mode Pemeliharaan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  pengaturan.maintenanceMode
                                      ? 'Aplikasi dalam mode pemeliharaan'
                                      : 'Aplikasi berjalan normal',
                                ),
                                value: pengaturan.maintenanceMode,
                                onChanged: null, // Read-only di halaman ini
                                secondary: Icon(
                                  pengaturan.maintenanceMode
                                      ? Icons.construction
                                      : Icons.check_circle_outline,
                                  color: pengaturan.maintenanceMode
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              if (pengaturan.maintenanceMode)
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                    'Info Pemeliharaan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    pengaturan.maintenanceInfo.isNotEmpty
                                        ? pengaturan.maintenanceInfo
                                        : '(Tidak ada pesan diatur)',
                                  ),
                                  isThreeLine: true,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tombol Reset Waktu Sinkronisasi
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sync_problem),
                          label: const Text('Reset Waktu Sinkronisasi'),
                          onPressed: _resetSyncTime,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Pengaturan'),
                    onPressed: () async {
                      Log.info('Tombol Edit Pengaturan ditekan');
                      await _editSettings(pengaturan);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Log.warning(
              'Data pengaturan tidak tersedia (null), menampilkan pesan kosong',
            );
            return const Center(child: Text('Pengaturan tidak ditemukan.'));
          }
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required final String judul,
    required final String nilai,
    required final IconData ikon,
  }) {
    Log.info('Membangun kartu info: $judul dengan nilai: $nilai');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        leading: Icon(ikon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          nilai,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
```

---

Karena 31 file lengkap akan sangat panjang, saya lanjutkan file berikutnya. Mau saya teruskan semua?
# 16 Mei 2026, 22:30

# transaction_model
// path: lib/shared/model/transaction_model.dart
// new file: Refactored from transaksi_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model that represents a single transaction in the application.
class TransactionModel implements HasId {
  @override
  final String id;

  /// The date and time when the transaction was created.
  final DateTime date;

  /// A description or note about the transaction.
  final String description;

  /// The amount of the transaction.
  final double amount;

  /// The type of transaction (e.g., income, expense, transfer, subscription).
  final TransactionType type;

  /// The ID of the source wallet.
  final String walletId;

  /// The ID of the main category of the transaction.
  final String categoryId;

  /// The ID of the destination wallet, only used for transfer transactions.
  final String? destinationWalletId;

  /// The ID of the customer associated with this transaction.
  final String? customerId;

  /// The ID of the package, if this is a subscription activation.
  final String? packageId;

  /// The ID of the sub-category of the transaction.
  final String? subCategoryId;

  /// The payment status of the transaction (e.g., paid, unpaid).
  final PaymentStatus paymentStatus;

  /// The number of points earned from this transaction.
  final int earnedPoints;

  /// The number of points used in this transaction.
  final int usedPoints;

  /// The last time this data was updated.
  final DateTime? updatedAt;

  /// The time this data was archived.
  final DateTime? archivedAt;

  /// A flag indicating if this data has been deleted (soft delete).
  final bool isDeleted;

  /// The duration of the subscription package (e.g., 30).
  final int? packageDuration;

  /// The type of duration for the package (e.g., day, month).
  final DurationType? durationType;

  /// The start date of the subscription period.
  final DateTime? startDate;

  /// The end date of the subscription period.
  final DateTime? endDate;

  /// A flag indicating if this is a new package activation.
  final bool isActivated;

  /// Main constructor for creating a [TransactionModel] instance.
  TransactionModel({
    final String? id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.walletId,
    required this.categoryId,
    this.destinationWalletId,
    this.customerId,
    this.packageId,
    this.subCategoryId,
    this.paymentStatus = PaymentStatus.unpaid,
    this.earnedPoints = 0,
    this.usedPoints = 0,
    this.updatedAt,
    this.archivedAt,
    this.isDeleted = false,
    this.packageDuration,
    this.durationType,
    this.startDate,
    this.endDate,
    this.isActivated = false,
  }) : id = id ?? const Uuid().v4() {
    Log.info('TransactionModel created: $id, type: ${type.name}');
  }

  /// Creates a copy of this [TransactionModel] with some modified values.
  TransactionModel copyWith({
    final String? id,
    final DateTime? date,
    final String? description,
    final double? amount,
    final TransactionType? type,
    final String? walletId,
    final String? categoryId,
    final String? destinationWalletId,
    final String? customerId,
    final String? packageId,
    final String? subCategoryId,
    final PaymentStatus? paymentStatus,
    final int? earnedPoints,
    final int? usedPoints,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final bool? isDeleted,
    final int? packageDuration,
    final DurationType? durationType,
    final DateTime? startDate,
    final DateTime? endDate,
    final bool? isActivated,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      destinationWalletId: destinationWalletId ?? this.destinationWalletId,
      customerId: customerId ?? this.customerId,
      packageId: packageId ?? this.packageId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      usedPoints: usedPoints ?? this.usedPoints,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      packageDuration: packageDuration ?? this.packageDuration,
      durationType: durationType ?? this.durationType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActivated: isActivated ?? this.isActivated,
    );
  }

  /// Helper to parse DateTime from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Safe helper to parse an enum from a string.
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  /// Helper to parse boolean from various formats.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor to create [TransactionModel] from SQLite data.
  factory TransactionModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating TransactionModel from SQLite: ${map[ColumnNames.id]}');
    return TransactionModel(
      id: map[ColumnNames.id] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      description: map[ColumnNames.description] as String? ?? '',
      amount: (map[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, map[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: map[ColumnNames.walletId] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: map[ColumnNames.destinationWalletId] as String?,
      customerId: map[ColumnNames.customerId] as String?,
      packageId: map[ColumnNames.packageId] as String?,
      subCategoryId: map[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            map[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (map[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (map[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      packageDuration: (map[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, map[ColumnNames.durationType]),
      startDate: _parseDateTime(map[ColumnNames.startDate]),
      endDate: _parseDateTime(map[ColumnNames.endDate]),
      isActivated: _parseBool(map[ColumnNames.isActivated]),
    );
  }

  /// Converts this [TransactionModel] to a Map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.date: date.millisecondsSinceEpoch, // INTEGER
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate: startDate?.millisecondsSinceEpoch,
      ColumnNames.endDate: endDate?.millisecondsSinceEpoch,
      ColumnNames.isActivated: isActivated ? 1 : 0,
    };
  }

  /// Factory constructor to create [TransactionModel] from Firebase data.
  factory TransactionModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating TransactionModel from Firebase: $id');
    return TransactionModel(
      id: id,
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      description: data[ColumnNames.description] as String? ?? '',
      amount: (data[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TransactionType.values, data[ColumnNames.type]) ??
          TransactionType.expense,
      walletId: data[ColumnNames.walletId] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: data[ColumnNames.destinationWalletId] as String?,
      customerId: data[ColumnNames.customerId] as String?,
      packageId: data[ColumnNames.packageId] as String?,
      subCategoryId: data[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            PaymentStatus.values,
            data[ColumnNames.paymentStatus],
          ) ??
          PaymentStatus.unpaid,
      earnedPoints: (data[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (data[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      isDeleted: data[ColumnNames.isDeleted] as bool? ?? false,
      packageDuration: (data[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(DurationType.values, data[ColumnNames.durationType]),
      startDate: _parseDateTime(data[ColumnNames.startDate]),
      endDate: _parseDateTime(data[ColumnNames.endDate]),
      isActivated: data[ColumnNames.isActivated] as bool? ?? false,
    );
  }

  /// Converts this [TransactionModel] to a Map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      // 'id' is not stored here as it is the document ID
      ColumnNames.date: Timestamp.fromDate(date),
      ColumnNames.description: description,
      ColumnNames.amount: amount,
      ColumnNames.type: type.name,
      ColumnNames.walletId: walletId,
      ColumnNames.categoryId: categoryId,
      ColumnNames.destinationWalletId: destinationWalletId,
      ColumnNames.customerId: customerId,
      ColumnNames.packageId: packageId,
      ColumnNames.subCategoryId: subCategoryId,
      ColumnNames.paymentStatus: paymentStatus.name,
      ColumnNames.earnedPoints: earnedPoints,
      ColumnNames.usedPoints: usedPoints,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate:
          startDate != null ? Timestamp.fromDate(startDate!) : null,
      ColumnNames.endDate: endDate != null ? Timestamp.fromDate(endDate!) : null,
      ColumnNames.isActivated: isActivated,
    };
  }
}

# package_operation
// path: lib/shared/operasi/package_operation.dart
// diubah: Menggunakan DateTime.now().toUtc() untuk konsistensi waktu.
// diubah: Mengganti nama class dari PaketOperasi menjadi PackageOperation.
// diubah: Menggunakan BaseOperation dan PackageModel.

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

/// Kelas untuk operasi terkait data paket di database lokal.
class PackageOperation {
  /// Instance dari DatabaseHelper untuk mengakses database.
  @visibleForTesting
  final DatabaseHelper dbHelper;

  /// Instance dari [BaseOperation] untuk operasi CRUD dasar.
  // (private field, tidak perlu @visibleForTesting)
  final BaseOperation _baseOperation;

  /// Konstruktor untuk [PackageOperation].
  ///
  /// Memungkinkan injeksi dependensi untuk [dbHelper] dan [baseOperation]
  /// untuk memfasilitasi pengujian. Jika tidak disediakan, instance default akan digunakan.
  PackageOperation({
    final DatabaseHelper? dbHelper,
    final BaseOperation? baseOperation,
  })  : dbHelper = dbHelper ?? DatabaseHelper.instance,
        _baseOperation = baseOperation ?? BaseOperation() {
    Log.info('PackageOperation instance dibuat.');
  }

  /// Menyimpan [PackageModel] baru ke dalam database.
  Future<void> createPackage(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai createPackage untuk id: ${package.id}');
    try {
      final data =
          package.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.insert('paket', data, fromServer: fromServer);
      Log.info('Berhasil createPackage untuk id: ${package.id}');
    } catch (e, s) {
      Log.error('Gagal createPackage untuk id: ${package.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket, termasuk yang diarsipkan.
  Future<List<PackageModel>> getAllPackages() async {
    Log.info('Memulai proses pengambilan semua data paket');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket aktif (tidak diarsipkan).
  Future<List<PackageModel>> getPackages() async {
    Log.info('Memulai proses pengambilan semua data paket aktif');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE ${ColumnNames.isDeleted} = 0
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket aktif');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket aktif', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang bersifat publik.
  Future<List<PackageModel>> getPublicPackages() async {
    Log.info('Memulai proses pengambilan semua data paket publik');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT *,
          CASE ${ColumnNames.type}
            WHEN 'jam' THEN ${ColumnNames.duration}
            WHEN 'hari' THEN ${ColumnNames.duration} * 24
            WHEN 'bulan' THEN ${ColumnNames.duration} * 24 * 30
            ELSE 999999
          END as urutan
        FROM paket
        WHERE ${ColumnNames.isDeleted} = 0 AND ${ColumnNames.isPublic} = 1
        ORDER BY urutan ASC
      ''');

      Log.info('Berhasil mengambil ${maps.length} data paket publik');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil semua data paket publik', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil [PackageModel] berdasarkan [id].
  Future<PackageModel?> getPackageById(final String id) async {
    Log.info('Memulai pencarian paket berdasarkan ID: $id');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: '${ColumnNames.id} = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        Log.info('Paket ditemukan untuk ID: $id');
        return PackageModel.fromSqlite(maps.first);
      } else {
        Log.warning('Paket dengan ID $id tidak ditemukan');
        return null;
      }
    } catch (e, s) {
      Log.error('Gagal mencari paket berdasarkan ID: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Memperbarui [PackageModel] yang ada di database.
  Future<void> updatePackage(final PackageModel package,
      {final bool fromServer = false}) async {
    Log.info('Memulai updatePackage untuk id: ${package.id}');
    try {
      final data =
          package.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite();
      await _baseOperation.update(
        'paket',
        data,
        package.id,
        fromServer: fromServer,
      );
      Log.info('Berhasil updatePackage untuk id: ${package.id}');
    } catch (e, s) {
      Log.error('Gagal updatePackage untuk id: ${package.id}', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus [PackageModel] dari database secara permanen.
  Future<void> deletePackage(final String id,
      {final bool fromServer = false}) async {
    Log.info('Memulai deletePackage untuk id: $id');
    try {
      await _baseOperation.delete('paket', id, fromServer: fromServer);
      Log.info('Berhasil deletePackage untuk id: $id');
    } catch (e, s) {
      Log.error('Gagal deletePackage untuk id: $id', e: e, st: s);
      rethrow;
    }
  }

  /// Menghapus semua paket dari database secara permanen.
  Future<void> deleteAllPackages({final bool fromServer = false}) async {
    Log.info('Memulai proses penghapusan semua data paket');
    try {
      await _baseOperation.runComplexOperation<void>(
        (final Transaction txn) async {
          final int count = await txn.delete('paket');
          Log.info(
              'Berhasil menghapus semua data paket. Total terhapus: $count');
        },
        fromServer: fromServer,
      );
    } catch (e, s) {
      Log.error('Gagal menghapus semua data paket', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil semua paket yang telah diubah sejak [since].
  Future<List<PackageModel>> getChangesSince(final DateTime since) async {
    Log.info(
        'Memulai pengambilan perubahan paket sejak ${since.toIso8601String()}');
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: '${ColumnNames.updatedAt} > ?',
        whereArgs: [since.toUtc().millisecondsSinceEpoch],
      );
      Log.info('Ditemukan ${maps.length} perubahan paket');
      return List.generate(
          maps.length, (final i) => PackageModel.fromSqlite(maps[i]));
    } catch (e, s) {
      Log.error('Gagal mengambil perubahan paket', e: e, st: s);
      rethrow;
    }
  }

  /// Menyisipkan atau memperbarui sekumpulan [PackageModel] dalam satu batch.
  Future<void> insertOrUpdateBatch(
    final List<PackageModel> items, {
    final bool fromServer = false,
  }) async {
    Log.info('Memulai insertOrUpdateBatch untuk ${items.length} item paket');
    if (items.isEmpty) {
      Log.warning('List item batch kosong, operasi dibatalkan');
      return;
    }
    try {
      final dataList = items
          .map(
            (final item) =>
                item.copyWith(updatedAt: DateTime.now().toUtc()).toSqlite(),
          )
          .toList();
      await _baseOperation.insertOrUpdateBatch(
        'paket',
        dataList,
        fromServer: fromServer,
      );
      Log.info('Berhasil insertOrUpdateBatch untuk ${items.length} item');
    } catch (e, s) {
      Log.error('Gagal insertOrUpdateBatch', e: e, st: s);
      rethrow;
    }
  }

  /// Mengambil beberapa [PackageModel] berdasarkan daftar [ids].
  Future<List<PackageModel>> getPackagesByIds(final List<String> ids) async {
    Log.info('Memulai pengambilan paket berdasarkan list ID: $ids');
    try {
      if (ids.isEmpty) {
        Log.warning('List ID kosong, mengembalikan list kosong');
        return [];
      }
      final db = await dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final List<Map<String, dynamic>> maps = await db.query(
        'paket',
        where: '${ColumnNames.id} IN ($placeholders)',
        whereArgs: ids,
      );
      Log.info('Berhasil mengambil ${maps.length} paket dari ${ids.length} ID');
      return List.generate(maps.length, (final i) {
        return PackageModel.fromSqlite(maps[i]);
      });
    } catch (e, s) {
      Log.error('Gagal mengambil paket berdasarkan list ID', e: e, st: s);
      rethrow;
    }
  }
}
# package_detail
// path: lib/admin/halaman/detail/package_detail.dart
// digunakan oleh: lib/admin/halaman/lainnya/package.dart

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/package_model.dart';

/// Halaman untuk menampilkan detail dari sebuah paket.
class PackageDetailPage extends StatefulWidget {
  /// Model paket yang akan ditampilkan.
  final PackageModel package;

  /// Konstruktor untuk PackageDetailPage.
  const PackageDetailPage({
    super.key,
    required this.package,
  });

  @override
  State<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends State<PackageDetailPage> {
  late PackageModel _package;

  @override
  void initState() {
    super.initState();
    Log.info('Membuka halaman detail paket.');
    _package = widget.package;
    Log.info('Data paket berhasil dimuat: ${_package.name}, ID: ${_package.id}.');
  }

  Future<void> _editPackage() async {
    Log.info('Navigasi ke form edit paket: ${_package.name}.');
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (final context) => PackageForm(paket: _package),
      ),
    );

    if (result ?? false) {
      Log.info('Perubahan data paket terdeteksi.');
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_package.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _editPackage,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Paket',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Informasi Layanan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Nama Paket', _package.name),
                _buildDetailRow('Harga Sewa', 'Rp ${_package.price}'),
                _buildDetailRow('Masa Aktif', '${_package.duration} ${_package.type.name}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Sistem Poin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Poin Hadiah', '${_package.rewardPoints} Poin',
                    subTitle: 'Didapat saat beli paket'),
                _buildDetailRow('Poin Penukaran', '${_package.redemptionPoints} Poin',
                    subTitle: 'Syarat tukar gratis'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 1),
                ),
                _buildDetailRow(
                  'Status Publik',
                  _package.isPublic ? 'Tersedia di Aplikasi' : 'Hanya Admin',
                  customValueColor: _package.isPublic ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    final String label,
    final String value, {
    final String? subTitle,
    final Color? customValueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (subTitle != null)
                  Text(subTitle,
                      style: const TextStyle(
                          color: Colors.black38, fontSize: 11, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: customValueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

# subscription_history_detail

// path: lib/admin/halaman/detail/subscription_history_detail.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/lainnya/package_activation_history.dart (PackageActivationHistoryPage)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/detail/detail_pelanggan.dart (DetailPelangganPage)
//   - lib/admin/halaman/detail/package_detail.dart (PackageDetailPage)
//   - lib/shared/model/transaction_model.dart (TransactionModel)
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/operasi/transaction_operation.dart (TransactionOperation)
//   - lib/shared/operasi/customer_operation.dart (CustomerOperation)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/utils/format_util.dart (FormatUtil, CurrencyFormat)
//   - lib/shared/debug/log.dart (Log)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/customer_operation.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Halaman untuk menampilkan detail transaksi langganan.
class DetailLanggananTransaksiPage extends StatefulWidget {
  /// ID transaksi yang akan ditampilkan.
  final String idTransaksi;

  /// Konstruktor untuk DetailLanggananTransaksiPage.
  const DetailLanggananTransaksiPage({super.key, required this.idTransaksi});

  @override
  State<DetailLanggananTransaksiPage> createState() =>
      _DetailLanggananTransaksiPageState();
}

class _DetailLanggananTransaksiPageState
    extends State<DetailLanggananTransaksiPage> {
  final TransactionOperation _transactionOperation = TransactionOperation();
  final PackageOperation _packageOperation = PackageOperation();
  final CustomerOperation _customerOperation = CustomerOperation();

  late Future<TransactionModel?> _transactionFuture;

  @override
  void initState() {
    super.initState();

    Log.info(
      'Memulai inisialisasi halaman detail langganan untuk ID transaksi: ${widget.idTransaksi}.',
    );

    _transactionFuture =
        _transactionOperation.getTransactionById(widget.idTransaksi);

    Log.info(
      'Future transaksi berhasil dibuat untuk proses pengambilan data transaksi.',
    );
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI halaman detail langganan transaksi.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Langganan'),
        // TODO: rencana selanjutnya adalah menambahkan tombol edit
      ),
      body: FutureBuilder<TransactionModel?>(
        future: _transactionFuture,
        builder: (final context, final snapshot) {
          Log.info(
            'FutureBuilder transaksi dijalankan dengan state: ${snapshot.connectionState}.',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            Log.info('Data transaksi masih dalam proses loading.');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            Log.error(
              'Terjadi kesalahan saat mengambil data transaksi.',
              e: snapshot.error,
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transaction = snapshot.data;

          if (transaction == null) {
            Log.warning('Data transaksi tidak ditemukan di database.');
            return const Center(child: Text('Transaksi tidak ditemukan'));
          }

          Log.info(
            'Berhasil memuat data transaksi dengan ID: ${transaction.id}.',
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                if (transaction.customerId != null)
                  _buildFutureInfoCard<CustomerModel>(
                    'Informasi Pelanggan',
                    _customerOperation.getCustomerById(
                        transaction.customerId!),
                    'Pelanggan',
                    (final customer) => [
                      _buildDetailRow(
                        'Nama Pelanggan',
                        customer?.name ?? 'Tidak Diketahui',
                      ),
                    ],
                    onTap: (final customer) {
                      if (customer != null) {
                        unawaited(Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (final context) => DetailPelangganPage(
                              idPelanggan: customer.id,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
                const SizedBox(height: 16),
                if (transaction.packageId != null)
                  _buildFutureInfoCard<PackageModel>(
                    'Informasi Paket',
                    _packageOperation.getPackageById(transaction.packageId!),
                    'Paket',
                    (final package) => [
                      _buildDetailRow(
                        'Nama Paket',
                        package?.name ?? 'Tidak Diketahui',
                      ),
                      _buildDetailRow(
                        'Harga',
                        CurrencyFormat.formatCurrency(
                            (package?.price ?? 0).toDouble()),
                      ),
                      _buildDetailRow(
                        'Durasi',
                        '${package?.duration ?? 0} ${package?.type.name ?? ""}',
                      ),
                    ],
                    onTap: (final package) {
                      if (package != null) {
                        unawaited(Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (final context) => PackageDetailPage(
                              package: package,
                            ),
                          ),
                        ));
                      }
                    },
                  ),
                const SizedBox(height: 16),
                _buildInfoPoints(transaction),
                const SizedBox(height: 16),
                if (transaction.startDate != null &&
                    transaction.endDate != null)
                  _buildInfoCard('Waktu Langganan', [
                    _buildDetailRow(
                      'Tanggal Mulai',
                      FormatUtil.formatDateAndTime(transaction.startDate!),
                    ),
                    _buildDetailRow(
                      'Tanggal Berakhir',
                      FormatUtil.formatDateAndTime(transaction.endDate!),
                    ),
                  ]),
                const SizedBox(height: 16),
                _buildInfoCard('Status', [
                  _buildDetailRow(
                    'Status Pembayaran',
                    transaction.paymentStatus.name.toUpperCase(),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoPoints(final TransactionModel transaction) {
    Log.info('Membangun widget informasi poin transaksi.');

    if (transaction.earnedPoints == 0 && transaction.usedPoints == 0) {
      Log.info('Tidak ada perubahan poin pada transaksi ini.');
      return const SizedBox.shrink();
    }

    final isAddition = transaction.earnedPoints > transaction.usedPoints;
    final pointDifference =
        transaction.earnedPoints - transaction.usedPoints;

    Log.info(
      'Poin dihasilkan: ${transaction.earnedPoints}, '
      'Poin digunakan: ${transaction.usedPoints}, '
      'Selisih: $pointDifference poin (${isAddition ? "PENAMBAHAN" : "PENGURANGAN"}).',
    );

    return _buildInfoCard('Informasi Poin', [
      _buildDetailRowWithColor(
        'Poin Dihasilkan',
        '+${transaction.earnedPoints} Poin',
        transaction.earnedPoints > 0 ? Colors.green : null,
        transaction.earnedPoints > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      _buildDetailRowWithColor(
        'Poin Digunakan',
        '-${transaction.usedPoints} Poin',
        transaction.usedPoints > 0 ? Colors.red : null,
        transaction.usedPoints > 0 ? FontWeight.bold : FontWeight.normal,
      ),
      const Divider(height: 16),
      _buildDetailRowWithColor(
        isAddition ? 'Total Poin Bertambah' : 'Total Poin Berkurang',
        '${pointDifference >= 0 ? "+" : ""}$pointDifference Poin',
        isAddition ? Colors.green : Colors.red,
        FontWeight.bold,
        fontSize: 16,
      ),
    ]);
  }

  Widget _buildInfoCard(final String title, final List<Widget> children,
      {final VoidCallback? onTap}) {
    Log.info('Membangun info card dengan judul: $title.');

    final cardContent = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }

  Widget _buildFutureInfoCard<T>(
    final String title,
    final Future<T?> future,
    final String tag,
    final List<Widget> Function(T? data) builder, {
    final void Function(T? data)? onTap,
  }) {
    Log.info('Membangun Future info card untuk data $tag.');

    return FutureBuilder<T?>(
      future: future,
      builder: (final context, final snapshot) {
        Log.info(
          'FutureBuilder $tag dijalankan dengan state: ${snapshot.connectionState}.',
        );

        VoidCallback? resolvedOnTap;
        if (onTap != null &&
            snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.hasData) {
          resolvedOnTap = () => onTap(snapshot.data);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          Log.info('Data $tag masih dalam proses loading.');
          return _buildInfoCard(title, [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ]);
        }

        if (snapshot.hasError) {
          Log.error('Gagal memuat data $tag.', e: snapshot.error);
          return _buildInfoCard(title, [const Text('Gagal memuat data')]);
        }

        if (snapshot.hasData) {
          Log.info('Data $tag berhasil dimuat secara asynchronous.');
        } else {
          Log.warning('Data $tag tidak ditemukan.');
        }

        return _buildInfoCard(title, builder(snapshot.data),
            onTap: resolvedOnTap);
      },
    );
  }

  Widget _buildDetailRow(final String label, final String value) {
    Log.info('Membangun detail row dengan label: $label dan value: $value.');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithColor(
    final String label,
    final String value,
    final Color? valueColor,
    final FontWeight fontWeight, {
    final double fontSize = 14,
  }) {
    Log.info(
      'Membangun detail row berwarna dengan label: $label dan value: $value.',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: fontWeight,
                color: valueColor,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}