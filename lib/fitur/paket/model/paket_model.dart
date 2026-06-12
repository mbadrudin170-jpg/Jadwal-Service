// path: lib/shared/model/paket_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

class PaketModel implements HasId {
  @override
  final String id;
  final String name;
  final int price;
  final int duration;
  final DurationType type;
  final int rewardPoints;
  final int redemptionPoints;
  final bool isPublic;
  final DateTime? updatedAt;
  final bool isDeleted;
  final DateTime? archivedAt;

  PaketModel({
    final String? id,
    required this.name,
    required this.price,
    required this.duration,
    required this.type,
    this.rewardPoints = 0,
    this.redemptionPoints = 0,
    this.isPublic = true,
    this.updatedAt,
    this.isDeleted = false,
    this.archivedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('PackageModel created: $id, name: $name');
  }

  PaketModel copyWith({
    final String? id,
    final String? name,
    final int? price,
    final int? duration,
    final DurationType? type,
    final int? rewardPoints,
    final int? redemptionPoints,
    final bool? isPublic,
    final DateTime? updatedAt,
    final bool? isDeleted,
    final DateTime? archivedAt,
  }) {
    return PaketModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      redemptionPoints: redemptionPoints ?? this.redemptionPoints,
      isPublic: isPublic ?? this.isPublic,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  static DurationType _parseType(final dynamic value) {
    return DurationType.values.firstWhere(
      (final e) => e.name == value,
      orElse: () => DurationType.days,
    );
  }

  factory PaketModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating PackageModel from SQLite: ${map[NamaKolom.id]}');
    return PaketModel(
      id: map[NamaKolom.id] as String?,
      name: map[NamaKolom.name] as String? ?? '',
      price: map[NamaKolom.price] as int? ?? 0,
      duration: map[NamaKolom.duration] as int? ?? 0,
      type: _parseType(map[NamaKolom.type]),
      rewardPoints: map[NamaKolom.rewardPoints] as int? ?? 0,
      redemptionPoints: map[NamaKolom.redemptionPoints] as int? ?? 0,
      isPublic: ParserUtil.parseBool(map[NamaKolom.isPublic]),
      isDeleted: ParserUtil.parseBool(map[NamaKolom.isDeleted]),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(map[NamaKolom.archivedAt]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.price: price,
      NamaKolom.duration: duration,
      NamaKolom.type: type.name,
      NamaKolom.rewardPoints: rewardPoints,
      NamaKolom.redemptionPoints: redemptionPoints,
      NamaKolom.isPublic: isPublic ? 1 : 0,
      NamaKolom.isDeleted: isDeleted ? 1 : 0,
      NamaKolom.updatedAt:
          (updatedAt ?? DateTime.now()).toUtc().millisecondsSinceEpoch,
      NamaKolom.archivedAt: archivedAt?.toUtc().millisecondsSinceEpoch,
    };
  }

  factory PaketModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating PackageModel from Firebase: $id');
    return PaketModel(
      id: id,
      name: data[NamaKolom.name] as String? ?? '',
      price: data[NamaKolom.price] as int? ?? 0,
      duration: data[NamaKolom.duration] as int? ?? 0,
      type: _parseType(data[NamaKolom.type]),
      rewardPoints: data[NamaKolom.rewardPoints] as int? ?? 0,
      redemptionPoints: data[NamaKolom.redemptionPoints] as int? ?? 0,
      isPublic: ParserUtil.parseBool(data[NamaKolom.isPublic]),
      isDeleted: ParserUtil.parseBool(data[NamaKolom.isDeleted]),
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.updatedAt]),
      archivedAt: ParserUtil.parseDateTime(data[NamaKolom.archivedAt]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.name: name,
      NamaKolom.price: price,
      NamaKolom.duration: duration,
      NamaKolom.type: type.name,
      NamaKolom.rewardPoints: rewardPoints,
      NamaKolom.redemptionPoints: redemptionPoints,
      NamaKolom.isPublic: isPublic,
      NamaKolom.isDeleted: isDeleted,
      NamaKolom.updatedAt:
          Timestamp.fromDate((updatedAt ?? DateTime.now()).toUtc()),
      NamaKolom.archivedAt:
          archivedAt != null ? Timestamp.fromDate(archivedAt!.toUtc()) : null,
    };
  }
}
