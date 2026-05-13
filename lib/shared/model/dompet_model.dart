import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Model data untuk dompet pengguna.
class DompetModel {
  /// ID unik dompet, dihasilkan otomatis menggunakan UUID.
  final String id;

  /// Nama dompet yang diberikan pengguna.
  final String namaDompet;

  /// Saldo saat ini.
  final double saldo;

  /// Waktu terakhir data diperbarui.
  final DateTime? diperbarui;

  /// Menandakan apakah dompet sudah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu dompet diarsipkan, null jika belum diarsipkan.
  final DateTime? diarsipkan;

  /// Membuat instance [DompetModel] baru.
  DompetModel({
    String? id,
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan [DompetModel] dengan nilai yang diubah.
  DompetModel copyWith({
    String? id,
    String? namaDompet,
    double? saldo,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return DompetModel(
      id: id ?? this.id,
      namaDompet: namaDompet ?? this.namaDompet,
      saldo: saldo ?? this.saldo,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Mengonversi data SQLite ke [DompetModel].
  factory DompetModel.fromSqlite(Map<String, dynamic> map) {
    return DompetModel(
      id: map['id'] as String?,
      namaDompet: (map['namaDompet'] as String?) ?? '',
      saldo: (map['saldo'] as num?)?.toDouble() ?? 0.0,
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengonversi [DompetModel] ke format SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  /// Mengonversi data Firestore ke [DompetModel].
  factory DompetModel.fromFirebase(String id, Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      namaDompet: (data['namaDompet'] as String?) ?? '',
      saldo: (data['saldo'] as num?)?.toDouble() ?? 0.0,
      diperbarui: _parseDateTime(data['diperbarui']),
      isDeleted: (data['isDeleted'] as bool?) ?? false,
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengonversi [DompetModel] ke format Firestore.
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'diarsipkan': Timestamp.fromDate(diarsipkan!),
    };
  }
}
