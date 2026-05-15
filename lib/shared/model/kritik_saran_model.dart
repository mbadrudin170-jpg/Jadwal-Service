// path: lib/shared/model/kritik_saran_model.dart
// diubah: Memperbaiki toFirebase agar tidak selalu mengirim ServerTimestamp.
// diubah: Penamaan metode diseragamkan dan logika Firebase diperbaiki.
// diubah: Mengganti nama fungsi helper internal dari _parseDateTime menjadi parseDateTime untuk menghilangkan peringatan lint.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';
// TODO: rencana selanjutnya adalah meambahkan kolom diarsipkan
/// Model untuk data kritik dan saran dari pengguna.
class KritikSaranModel implements MemilikiId {
  /// ID unik untuk setiap entri kritik dan saran.
  @override
  final String id;

  /// Isi dari kritik atau saran yang diberikan oleh pengguna.
  final String isi;

  /// Tanggal kapan kritik atau saran ini dibuat.
  final DateTime? tanggal;

  /// ID pengguna yang memberikan kritik atau saran.
  final String userId;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? diperbarui;

  /// Konstruktor untuk membuat instance `KritikSaranModel`.
  KritikSaranModel({
    final String? id,
    required this.isi,
    this.tanggal,
    required this.userId,
    this.diperbarui,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari `KritikSaranModel` dengan beberapa nilai yang diubah.
  KritikSaranModel copyWith({
    final String? id,
    final String? isi,
    final DateTime? tanggal,
    final String? userId,
    final DateTime? diperbarui,
  }) {
    return KritikSaranModel(
      id: id ?? this.id,
      isi: isi ?? this.isi,
      tanggal: tanggal ?? this.tanggal,
      userId: userId ?? this.userId,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }

  /// Helper untuk mengurai nilai tanggal dari berbagai format.
  static DateTime? parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
    return null;
  }

  /// Membuat instance `KritikSaranModel` dari data Map SQLite.
  factory KritikSaranModel.fromSqlite(final Map<String, dynamic> map) {
    return KritikSaranModel(
      id: map['id'] as String?,
      isi: map['isi'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      tanggal: parseDateTime(map['tanggal']), // ← Pakai parseDateTime
      diperbarui: parseDateTime(map['diperbarui']), // ← Pakai parseDateTime
    );
  }

  /// Mengonversi `KritikSaranModel` ke format Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal?.millisecondsSinceEpoch, // ← Konversi ke int
      'userId': userId,
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // ← Konversi ke int
    };
  }

  /// Membuat instance `KritikSaranModel` dari data Map Firebase.
  factory KritikSaranModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return KritikSaranModel(
      id: id,
      isi: data['isi'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      tanggal: parseDateTime(data['tanggal']) ?? DateTime.now(),
      diperbarui: parseDateTime(data['diperbarui']),
    );
  }

  /// Mengonversi `KritikSaranModel` ke format Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'isi': isi,
      'tanggal': tanggal != null ? Timestamp.fromDate(tanggal!) : FieldValue.serverTimestamp(),
      'userId': userId,
      'diperbarui': diperbarui != null
          ? Timestamp.fromDate(diperbarui!)
          : FieldValue.serverTimestamp(),
    };
  }
}
