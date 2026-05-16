// path: lib/shared/model/feedback_model.dart
// diperbarui: Mengganti nama variabel ke bahasa Inggris dan memperbaiki metode toFirebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model untuk data kritik dan saran dari pengguna.
class FeedbackModel implements HasId {
  @override
  final String id;

  /// Isi dari kritik dan saran.
  final String content;

  /// Tanggal kritik dan saran dibuat.
  final DateTime? date;

  /// ID pengguna yang mengirimkan.
  final String userId;

  /// Waktu terakhir data diperbarui.
  final DateTime? updatedAt;

  /// Waktu data diarsipkan.
  final DateTime? archivedAt;

  /// Konstruktor untuk membuat instance [FeedbackModel].
  FeedbackModel({
    String? id,
    required this.content,
    this.date,
    required this.userId,
    this.updatedAt,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('FeedbackModel dibuat: $id, userId: $userId');
  }

  /// Membuat salinan [FeedbackModel] dengan beberapa field yang diperbarui.
  FeedbackModel copyWith({
    String? id,
    String? content,
    DateTime? date,
    String? userId,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Mengurai nilai tanggal dari berbagai tipe data.
  static DateTime? parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    Log.warning('Gagal mengurai tanggal: $dateValue');
    return null;
  }

  /// Membuat instance [FeedbackModel] dari data SQLite.
  factory FeedbackModel.fromSqlite(Map<String, dynamic> map) {
    Log.info('Membuat FeedbackModel dari SQLite: ${map[ColumnNames.id]}');
    return FeedbackModel(
      id: map[ColumnNames.id] as String?,
      content: map[ColumnNames.content] as String? ?? '',
      userId: map[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(map[ColumnNames.date]),
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Mengonversi [FeedbackModel] menjadi format Map untuk SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Membuat instance [FeedbackModel] dari data Firebase.
  factory FeedbackModel.fromFirebase(String id, Map<String, dynamic> data) {
    Log.info('Membuat FeedbackModel dari Firebase: $id');
    return FeedbackModel(
      id: id,
      content: data[ColumnNames.content] as String? ?? '',
      userId: data[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(data[ColumnNames.date]),
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  // TODO: Diperlukan migrasi data di Firebase sebelum model ini bisa diseragamkan.
  // - Ubah kunci field dari 'userId' menjadi 'user_id'.
  // Setelah migrasi, method toFirebase() dan fromFirebase() harus diperbarui
  // untuk menggunakan 'user_id' agar konsisten dengan model lain.

  /// Mengonversi [FeedbackModel] menjadi format Map untuk Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date != null ? Timestamp.fromDate(date!.toUtc()) : null,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!.toUtc()) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
