// path: lib/shared/model/customer_model.dart
// new file: Refactored from pelanggan_model.dart to use English naming conventions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model representing a customer's data.
class CustomerModel implements HasId {
  @override
  final String id;

  /// The name of the customer.
  final String name;

  /// The phone number of the customer.
  final String phone;

  /// The address of the customer.
  final String address;

  /// The password for the customer's account.
  final String password;

  /// The MAC address of the customer's device.
  final String macAddress;

  /// A flag indicating if the customer has been soft-deleted.
  final bool isDeleted;

  /// The timestamp of the last update.
  final DateTime? updatedAt;

  /// The timestamp of when the customer was archived.
  final DateTime? archivedAt;

  /// Creates a new instance of the [CustomerModel].
  CustomerModel({
    final String? id,
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.updatedAt,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CustomerModel created: $id, name: $name');
  }

  /// Creates a copy of the [CustomerModel] with updated fields.
  CustomerModel copyWith({
    final String? id,
    final String? name,
    final String? phone,
    final String? address,
    final String? password,
    final String? macAddress,
    final bool? isDeleted,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  /// Parses a dynamic value into a [DateTime] object.
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    Log.warning('Unrecognized DateTime format: $value');
    return null;
  }

  /// Parses a dynamic value into a boolean.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    Log.warning('Unrecognized Boolean format, defaulting to false: $value');
    return false;
  }

  /// Creates a [CustomerModel] from a SQLite map.
  factory CustomerModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[ColumnNames.id]}');
    return CustomerModel(
      id: map[ColumnNames.id] as String? ?? '',
      name: map[ColumnNames.name] as String? ?? '',
      phone: map[ColumnNames.phone] as String? ?? '',
      address: map[ColumnNames.address] as String? ?? '',
      password: map[ColumnNames.password] as String? ?? '',
      macAddress: map[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(map[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(map[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(map[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      ColumnNames.id: id,
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted ? 1 : 0,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
      ColumnNames.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [CustomerModel] from a Firebase document.
  factory CustomerModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return CustomerModel(
      id: id,
      name: data[ColumnNames.name] as String? ?? '',
      phone: data[ColumnNames.phone] as String? ?? '',
      address: data[ColumnNames.address] as String? ?? '',
      password: data[ColumnNames.password] as String? ?? '',
      macAddress: data[ColumnNames.macAddress] as String? ?? '',
      isDeleted: _parseBool(data[ColumnNames.isDeleted]),
      updatedAt: _parseDateTime(data[ColumnNames.updatedAt]),
      archivedAt: _parseDateTime(data[ColumnNames.archivedAt]),
    );
  }

  /// Converts the [CustomerModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      ColumnNames.name: name,
      ColumnNames.phone: phone,
      ColumnNames.address: address,
      ColumnNames.password: password,
      ColumnNames.macAddress: macAddress,
      ColumnNames.isDeleted: isDeleted,
      ColumnNames.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      ColumnNames.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
