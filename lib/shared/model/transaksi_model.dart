// path: lib/shared/model/transaksi_model.dart
// diubah: Seluruh penamaan properti/parameter kini pakai bahasa Inggris,
//         dan mengacu ke ColumnNames untuk konsistensi SQLite & Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/database_column_names.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/memiliki_id.dart';
import 'package:wifi/shared/model/paket_model.dart'; // Impor untuk TipeDurasi

/// Model yang merepresentasikan satu transaksi dalam aplikasi.
class TransactionModel implements MemilikiId {
  /// ID unik untuk transaksi, biasanya UUID.
  @override
  final String id;

  /// Tanggal dan waktu kapan transaksi dibuat.
  final DateTime date;

  /// Deskripsi atau catatan mengenai transaksi.
  final String description;

  /// Jumlah nominal dari transaksi.
  final double amount;

  /// Jenis transaksi (pemasukan, pengeluaran, transfer, langganan).
  final TipeTransaksiEnum type;

  /// ID dompet sumber dana.
  final String walletId;

  /// ID kategori utama dari transaksi.
  final String categoryId;

  /// ID dompet tujuan, hanya digunakan untuk transaksi tipe transfer.
  final String? destinationWalletId;

  /// ID pelanggan yang terkait dengan transaksi ini.
  final String? customerId;

  /// ID paket yang terkait, jika transaksi ini adalah aktivasi langganan.
  final String? packageId;

  /// ID sub-kategori dari transaksi.
  final String? subCategoryId;

  /// Status pembayaran untuk transaksi (misal: lunas, belum lunas).
  final StatusPembayaranEnum paymentStatus;

  /// Jumlah poin yang dihasilkan dari transaksi ini.
  final int earnedPoints;

  /// Jumlah poin yang digunakan dalam transaksi ini.
  final int usedPoints;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? updatedAt;

  /// Waktu kapan data ini diarsipkan.
  final DateTime? archivedAt;

  /// Penanda jika data ini telah dihapus (soft delete).
  final bool isDeleted;

  // Properti dari RiwayatLanggananModel yang digabung
  /// Durasi paket langganan (misal: 30).
  final int? packageDuration;

  /// Tipe durasi paket (misal: hari, bulan).
  final TipeDurasi? durationType;

  /// Tanggal mulai periode langganan.
  final DateTime? startDate;

  /// Tanggal berakhir periode langganan.
  final DateTime? endDate;

  /// Penanda jika transaksi ini merupakan aktivasi paket baru.
  final bool isActivated;

  /// Konstruktor utama untuk membuat instance [TransactionModel].
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
    this.paymentStatus = StatusPembayaranEnum.belumLunas,
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
  }) : id = id ?? const Uuid().v4();

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// Mengubah nilai dinamis menjadi DateTime.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    // Menangani millisecondsSinceEpoch dari SQLite (INTEGER)
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Helper untuk parsing enum dengan aman dari String.
  static T? _safeParseEnum<T extends Enum>(
      final List<T> values, final dynamic name) {
    if (name == null) return null;
    try {
      return values.firstWhere((final e) => e.name == name as String);
    } on Exception {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // SQLite
  // ---------------------------------------------------------------------------

  /// Factory constructor untuk membuat [TransactionModel] dari data SQLite.
  factory TransactionModel.fromSqlite(final Map<String, dynamic> map) {
    return TransactionModel(
      id: map[ColumnNames.id] as String? ?? '',
      date: _parseDateTime(map[ColumnNames.date]) ?? DateTime.now(),
      description: map[ColumnNames.description] as String? ?? '',
      amount: (map[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TipeTransaksiEnum.values, map[ColumnNames.type]) ??
          TipeTransaksiEnum.pengeluaran,
      walletId: map[ColumnNames.walletId] as String? ?? '',
      categoryId: map[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: map[ColumnNames.destinationWalletId] as String?,
      customerId: map[ColumnNames.customerId] as String?,
      packageId: map[ColumnNames.packageId] as String?,
      subCategoryId: map[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            StatusPembayaranEnum.values,
            map[ColumnNames.paymentStatus],
          ) ??
          StatusPembayaranEnum.belumLunas,
      earnedPoints: (map[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (map[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
      isDeleted: (map[ColumnNames.isDeleted] as int? ?? 0) == 1,
      packageDuration: (map[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(TipeDurasi.values, map[ColumnNames.durationType]),
      startDate: _parseDateTime(map[ColumnNames.startDate]),
      endDate: _parseDateTime(map[ColumnNames.endDate]),
      isActivated: (map[ColumnNames.isActivated] as int? ?? 0) == 1,
    );
  }

  /// Mengubah instance [TransactionModel] menjadi Map untuk disimpan di SQLite.
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

  // ---------------------------------------------------------------------------
  // Firebase
  // ---------------------------------------------------------------------------

  // TODO: Diperlukan migrasi data di Firebase sebelum model ini bisa diseragamkan.
  // - Ubah kunci field dari camelCase (e.g., durasiPaket) menjadi snake_case
  //   sesuai ColumnNames.
  // - Hapus penggunaan FieldValue.serverTimestamp() pada 'diperbarui'.
  // - Pastikan semua field DateTime yang ada di Firebase dikonversi ke UTC.
  // - Tambahkan field 'id' ke semua dokumen transaksi yang ada.
  // Setelah migrasi, method fromFirebase() dan toFirebase() harus diperbarui.

  /// Factory constructor untuk membuat [TransactionModel] dari data Firebase.
  factory TransactionModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      date: _parseDateTime(data[ColumnNames.date]) ?? DateTime.now(),
      description: data[ColumnNames.description] as String? ?? '',
      amount: (data[ColumnNames.amount] as num? ?? 0).toDouble(),
      type: _safeParseEnum(TipeTransaksiEnum.values, data[ColumnNames.type]) ??
          TipeTransaksiEnum.pengeluaran,
      walletId: data[ColumnNames.walletId] as String? ?? '',
      categoryId: data[ColumnNames.categoryId] as String? ?? '',
      destinationWalletId: data[ColumnNames.destinationWalletId] as String?,
      customerId: data[ColumnNames.customerId] as String?,
      packageId: data[ColumnNames.packageId] as String?,
      subCategoryId: data[ColumnNames.subCategoryId] as String?,
      paymentStatus: _safeParseEnum(
            StatusPembayaranEnum.values,
            data[ColumnNames.paymentStatus],
          ) ??
          StatusPembayaranEnum.belumLunas,
      earnedPoints: (data[ColumnNames.earnedPoints] as num? ?? 0).toInt(),
      usedPoints: (data[ColumnNames.usedPoints] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
      isDeleted: data[ColumnNames.isDeleted] as bool? ?? false,
      packageDuration: (data[ColumnNames.packageDuration] as num?)?.toInt(),
      durationType:
          _safeParseEnum(TipeDurasi.values, data[ColumnNames.durationType]),
      startDate: _parseDateTime(data[ColumnNames.startDate]),
      endDate: _parseDateTime(data[ColumnNames.endDate]),
      isActivated: data[ColumnNames.isActivated] as bool? ?? false,
    );
  }

  /// Mengubah instance [TransactionModel] menjadi Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      // 'id' tidak perlu disimpan karena sudah menjadi ID dokumen
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
      ColumnNames.updatedAt: updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.packageDuration: packageDuration,
      ColumnNames.durationType: durationType?.name,
      ColumnNames.startDate:
          startDate != null ? Timestamp.fromDate(startDate!) : null,
      ColumnNames.endDate:
          endDate != null ? Timestamp.fromDate(endDate!) : null,
      ColumnNames.isActivated: isActivated,
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Membuat salinan dari instance [TransactionModel] dengan beberapa nilai yang diubah.
  TransactionModel copyWith({
    final String? id,
    final DateTime? date,
    final String? description,
    final double? amount,
    final TipeTransaksiEnum? type,
    final String? walletId,
    final String? categoryId,
    final String? destinationWalletId,
    final String? customerId,
    final String? packageId,
    final String? subCategoryId,
    final StatusPembayaranEnum? paymentStatus,
    final int? earnedPoints,
    final int? usedPoints,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final bool? isDeleted,
    final int? packageDuration,
    final TipeDurasi? durationType,
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
}
