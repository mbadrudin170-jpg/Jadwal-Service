// path: lib/shared/model/feedback_model.dart
// diperbarui: Mengganti nama variabel ke bahasa Inggris dan memperbaiki metode toFirebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model for feedback data from users.
class FeedbackModel implements HasId {
  @override
  final String id;

  /// The content of the feedback.
  final String content;

  /// The date the feedback was created.
  final DateTime? date;

  /// The ID of the user who submitted the feedback.
  final String userId;

  /// The last time the data was updated.
  final DateTime? updatedAt;

  /// The status of whether this feedback has been deleted (soft delete).
  final bool isDeleted;

  /// The time this feedback was archived.
  final DateTime? archivedAt;

  /// Constructor to create a [FeedbackModel] instance.
  FeedbackModel({
    final String? id,
    required this.content,
    this.date,
    required this.userId,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('FeedbackModel created: $id, userId: $userId');
  }

  /// Creates a copy of [FeedbackModel] with some updated fields.
  FeedbackModel copyWith({
    final String? id,
    final String? content,
    final DateTime? date,
    final String? userId,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a date value from various data types.
  static DateTime? parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    Log.warning('Failed to parse date: $dateValue');
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

  /// Creates a [FeedbackModel] instance from SQLite data.
  factory FeedbackModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating FeedbackModel from SQLite: ${map[ColumnNames.id]}');
    return FeedbackModel(
      id: map[ColumnNames.id] as String?,
      content: map[ColumnNames.content] as String? ?? '',
      userId: map[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(map[ColumnNames.date]),
      updatedAt: parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date?.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [FeedbackModel] instance from Firebase data.
  factory FeedbackModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating FeedbackModel from Firebase: $id');
    return FeedbackModel(
      id: id,
      content: data[ColumnNames.content] as String? ?? '',
      userId: data[ColumnNames.userId] as String? ?? '',
      date: parseDateTime(data[ColumnNames.date]),
      updatedAt: parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      archivedAt: parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts [FeedbackModel] to a Map format for Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.content: content,
      ColumnNames.userId: userId,
      ColumnNames.date: date != null ? Timestamp.fromDate(date!.toUtc()) : null,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          updatedAt != null ? Timestamp.fromDate(updatedAt!.toUtc()) : null,
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
