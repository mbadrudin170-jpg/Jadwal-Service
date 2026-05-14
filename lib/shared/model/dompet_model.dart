// path: lib/shared/model/dompet_model.dart
// Fitur: Model Data
// Tujuan: Mendefinisikan struktur data untuk dompet, termasuk konversi dari/ke format SQLite dan Firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model data untuk entitas dompet dalam aplikasi.
///
/// Kelas ini merepresentasikan dompet pengguna dengan properti seperti nama, saldo,
/// dan status sinkronisasi.
class DompetModel implements MemilikiId {
  /// ID unik untuk setiap dompet, dibuat secara otomatis jika tidak disediakan.
  @override
  final String id;

  /// Nama yang diberikan pengguna untuk dompet ini. Wajib diisi.
  final String namaDompet;

  /// Jumlah saldo saat ini di dalam dompet.
  final double saldo;

  /// Timestamp kapan data ini terakhir kali diperbarui di server atau lokal.
  final DateTime? diperbarui;

  /// Status soft delete. Jika `true`, dompet dianggap telah dihapus.
  final bool isDeleted;

  /// Timestamp kapan dompet ini diarsipkan. `null` jika tidak diarsipkan.
  final DateTime? diarsipkan;

  /// Membuat instance [DompetModel].
  ///
  /// Jika [id] tidak disediakan, ID unik akan dibuat menggunakan `Uuid().v4()`.
  DompetModel({
    String? id,
    required this.namaDompet,
    required this.saldo,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan [DompetModel] dengan beberapa field yang diperbarui.
  ///
  /// Berguna untuk pembaruan data secara immutable.
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

  /// Helper internal untuk mengurai nilai tanggal dari berbagai format.
  ///
  /// Menerima [Timestamp] dari Firestore atau [String] format ISO-8601 dari SQLite.
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Membuat instance [DompetModel] dari data map SQLite.
  ///
  /// Factory constructor ini menangani konversi tipe data dari format
  /// yang disimpan di database lokal.
  factory DompetModel.fromSqlite(Map<String, dynamic> map) {
    return DompetModel(
      id: map['id'] as String?,
      namaDompet: (map['namaDompet'] as String?) ?? '',
      saldo: (map['saldo'] as num?)?.toDouble() ?? 0.0,
      diperbarui: _parseDateTime(map['diperbarui']),
      isDeleted: map['isDeleted'] == 1,
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengonversi instance [DompetModel] menjadi map untuk disimpan di SQLite.
  ///
  /// [DateTime] diubah menjadi format String ISO-8601 dan boolean menjadi integer.
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

  /// Membuat instance [DompetModel] dari dokumen Firestore.
  ///
  /// [id] dokumen diambil secara terpisah dari snapshot.
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

  /// Mengonversi instance [DompetModel] menjadi map untuk disimpan di Firestore.
  ///
  /// `diperbarui` akan selalu diisi dengan `FieldValue.serverTimestamp()`
  /// untuk sinkronisasi waktu yang akurat.
  Map<String, dynamic> toFirebase() {
    final data = <String, dynamic>{
      'id': id,
      'namaDompet': namaDompet,
      'saldo': saldo,
      'diperbarui': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }
    return data;
// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart

// TODO: tugas selanjutnya adalah merubah semua data yang disimpan ke sqlite kolom  tanggal diubah  ke millisecondsSinceEpoch, dan menyesuaikan tipe nya dengan sqlite.dart

