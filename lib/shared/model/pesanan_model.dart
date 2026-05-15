// path: lib/shared/model/pesanan_model.dart
// diubah: Memperbaiki toFirebase agar tidak selalu mengirim ServerTimestamp.
// diubah: Penamaan metode diseragamkan, logika Firebase disesuaikan, dan mengimplementasikan MemilikiId.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model untuk data pesanan.
class PesananModel implements MemilikiId {
  /// ID unik untuk setiap pesanan.
  @override
  final String id;

  /// ID pelanggan yang melakukan pesanan.
  final String idPelanggan;

  /// ID paket yang dipesan.
  final String idPaket;

  /// Tanggal pesanan dibuat.
  final DateTime tanggal;

  /// Status pesanan (misalnya, "baru", "diproses", "selesai").
  final String status;

  /// Waktu terakhir data diperbarui.
  final DateTime? diperbarui;

  /// Status apakah pesanan ini sudah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu pesanan ini diarsipkan.
  final DateTime? diarsipkan;

  /// Konstruktor untuk `PesananModel`.
  PesananModel({
    final String? id,
    required this.idPelanggan,
    required this.idPaket,
    required this.tanggal,
    required this.status,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari `PesananModel` dengan beberapa nilai yang diubah.
  PesananModel copyWith({
    final String? id,
    final String? idPelanggan,
    final String? idPaket,
    final DateTime? tanggal,
    final String? status,
    final DateTime? diperbarui,
    final bool? isDeleted,
    final DateTime? diarsipkan,
  }) {
    return PesananModel(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  /// Helper untuk mengurai nilai tanggal dari berbagai format.
  static DateTime? parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Membuat instance `PesananModel` dari data Map SQLite.
  factory PesananModel.fromSqlite(final Map<String, dynamic> map) {
    return PesananModel(
      id: map['id'] as String? ?? '',
      idPelanggan: map['id_pelanggan'] as String? ?? '',
      idPaket: map['id_paket'] as String? ?? '',
      tanggal: parseDateTime(map['tanggal']) ?? DateTime.now(),
      status: map['status'] as String? ?? 'baru',
      diperbarui: parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == 1,
      diarsipkan: parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengonversi `PesananModel` ke format Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggal': tanggal.millisecondsSinceEpoch,
      'status': status,
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch,
    };
  }

  /// Membuat instance `PesananModel` dari data Map Firebase.
  factory PesananModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return PesananModel(
      id: id,
      idPelanggan: data['id_pelanggan'] as String? ?? '',
      idPaket: data['id_paket'] as String? ?? '',
      tanggal: parseDateTime(data['tanggal']) ?? DateTime.now(),
      status: data['status'] as String? ?? 'baru',
      diperbarui: parseDateTime(data['diperbarui']),
      isDeleted: data['isDeleted'] == true,
      diarsipkan: parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengonversi `PesananModel` ke format Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'tanggal': Timestamp.fromDate(tanggal),
      'status': status,
      'diperbarui': diperbarui != null
          ? Timestamp.fromDate(diperbarui!)
          : FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
    };

    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }

    return data;
  }
}
