// path: lib/fitur/pelanggan/model/customer_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Model representing a customer's data.
class PelangganModel implements HasId {
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

  /// The timestamp of when the customer was last active.
  final DateTime? lastActiveAt;

  /// Creates a new instance of the [PelangganModel].
  PelangganModel({
    final String? id,
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.updatedAt,
    this.archivedAt,
    this.lastActiveAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('CustomerModel created: $id, name: $name');
  }

  /// Creates a copy of the [PelangganModel] with updated fields.
  PelangganModel copyWith({
    final String? id,
    final String? name,
    final String? phone,
    final String? address,
    final String? password,
    final String? macAddress,
    final bool? isDeleted,
    final DateTime? updatedAt,
    final DateTime? archivedAt,
    final DateTime? lastActiveAt,
  }) {
    return PelangganModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// Creates a [PelangganModel] from a SQLite map.
  factory PelangganModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating CustomerModel from SQLite: ${map[NamaKolom.id]}');
    return PelangganModel(
      id: map[NamaKolom.id] as String? ?? '',
      name: map[NamaKolom.name] as String? ?? '',
      phone: map[NamaKolom.phone] as String? ?? '',
      address: map[NamaKolom.address] as String? ?? '',
      password: map[NamaKolom.password] as String? ?? '',
      macAddress: map[NamaKolom.macAddress] as String? ?? '',
      // DIUBAH: Menggunakan ParserUtil
      isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
      lastActiveAt: ParserUtil.parseDateTime(map[NamaKolom.lastActiveAt]),
    );
  }

  /// Converts the [PelangganModel] to a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.phone: phone,
      NamaKolom.address: address,
      NamaKolom.password: password,
      NamaKolom.macAddress: macAddress,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.updatedAt: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.archivedAt: archivedAt?.millisecondsSinceEpoch,
      NamaKolom.lastActiveAt: lastActiveAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [PelangganModel] from a Firebase document.
  factory PelangganModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating CustomerModel from Firebase: $id');
    return PelangganModel(
      id: id,
      name: data[NamaKolom.name] as String? ?? '',
      phone: data[NamaKolom.phone] as String? ?? '',
      address: data[NamaKolom.address] as String? ?? '',
      password: data[NamaKolom.password] as String? ?? '',
      macAddress: data[NamaKolom.macAddress] as String? ?? '',
      isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
      lastActiveAt: ParserUtil.parseDateTime(data[NamaKolom.lastActiveAt]),
    );
  }

  /// Converts the [PelangganModel] to a map for Firebase storage.
  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.phone: phone,
      NamaKolom.address: address,
      NamaKolom.password: password,
      NamaKolom.macAddress: macAddress,
      NamaKolom.isDeleted: isDeleted,
      // DIUBAH: Memastikan updatedAt tidak pernah null dan menggunakan .toUtc()
      NamaKolom.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      // DIUBAH: Menggunakan .toUtc() jika tidak null
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
      NamaKolom.lastActiveAt: lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!.toUtc())
          : null,
    };
  }
}
