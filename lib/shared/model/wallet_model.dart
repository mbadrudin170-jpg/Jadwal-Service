// path: lib/shared/model/wallet_model.dart
// new file: Refactored from dompet_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/database_column_name.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Data model for a wallet entity in the application.
class WalletModel implements HasId {
  /// A unique ID for each wallet, generated automatically if not provided.
  @override
  final String id;

  /// The user-defined name for this wallet. This is required.
  final String name;

  /// The current balance of the wallet.
  final double balance;

  /// Timestamp of when this data was last updated on the server or locally.
  final DateTime? updatedAt;

  /// Soft delete status. If `true`, the wallet is considered deleted.
  final bool isDeleted;

  /// Timestamp of when this wallet was archived. `null` if not archived.
  final DateTime? archivedAt;

  /// Creates an instance of [WalletModel].
  WalletModel({
    final String? id,
    required this.name,
    required this.balance,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4();

  /// Creates a copy of [WalletModel] with updated fields.
  WalletModel copyWith({
    final String? id,
    final String? name,
    final double? balance,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Internal helper to parse a date value from various formats.
  static DateTime? _parseDateTime(final dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  /// Creates a [WalletModel] instance from a SQLite map.
  factory WalletModel.fromSqlite(final Map<String, dynamic> map) {
    return WalletModel(
      id: map[ColumnNames.id] as String?,
      name: (map[ColumnNames.name] as String?) ?? '',
      balance: (map[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      isDeleted: map[ColumnNames.isDeleted] == 1,
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [WalletModel] instance from a Firestore document.
  factory WalletModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return WalletModel(
      id: id,
      name: (data[ColumnNames.name] as String?) ?? '',
      balance: (data[ColumnNames.balance] as num?)?.toDouble() ?? 0.0,
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      isDeleted: (data[ColumnNames.isDeleted] as bool?) ?? false,
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts this [WalletModel] instance into a map for Firestore storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.balance: balance,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
