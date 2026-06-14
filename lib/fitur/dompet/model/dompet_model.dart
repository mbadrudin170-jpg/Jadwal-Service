// path: lib/fitur/dompet/model/dompet_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // DIUBAH: Impor baru

/// Data model for a wallet entity in the application.
class DompetModel implements HasId {
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

  /// Creates an instance of [DompetModel].
  DompetModel({
    final String? id,
    required this.name,
    required this.balance,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('WalletModel created: $id, name: $name');
  }

  /// Creates a copy of [DompetModel] with updated fields.
  DompetModel copyWith({
    final String? id,
    final String? name,
    final double? balance,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return DompetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  // DIHAPUS: Helper parsing internal dipindahkan ke ParserUtil

  /// Creates a [DompetModel] instance from a SQLite map.
  factory DompetModel.fromSqlite(final Map<String, dynamic> map) {
    return DompetModel(
      id: map[NamaKolom.id] as String?,
      name: (map[NamaKolom.name] as String?) ?? '',
      balance: (map[NamaKolom.balance] as num?)?.toDouble() ?? 0.0,
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.updatedAt]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
    );
  }

  /// Converts this [DompetModel] instance into a map for SQLite storage.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.balance: balance,
      // DIUBAH: Memastikan updatedAt tidak pernah null
      NamaKolom.updatedAt: (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.archivedAt: archivedAt?.millisecondsSinceEpoch,
    };
  }

  /// Creates a [DompetModel] instance from a Firestore document.
  factory DompetModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      name: (data[NamaKolom.name] as String?) ?? '',
      balance: (data[NamaKolom.balance] as num?)?.toDouble() ?? 0.0,
      // DIUBAH: Menggunakan ParserUtil
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
    );
  }

  /// Converts this [DompetModel] instance into a map for Firestore storage.
  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.balance: balance,
      NamaKolom.isDeleted: isDeleted,
      // DIUBAH: Memastikan updatedAt tidak pernah null dan menggunakan .toUtc()
      NamaKolom.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      // DIUBAH: Menggunakan .toUtc() jika tidak null
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
