// path: lib/shared/model/event_model.dart

import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

/// Model data untuk Pengumuman (Event).
class EventModel implements HasId {
  @override
  final String id;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? updatedAt;

  /// Konstruktor untuk EventModel.
  EventModel({
    final String? id,
    required this.imageUrl,
    this.isActive = false,
    required this.createdAt,
    required this.startDate,
    required this.endDate,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4() {
    Log.info('EventModel created: $id');
  }

  EventModel copyWith({
    final String? id,
    final String? imageUrl,
    final bool? isActive,
    final DateTime? createdAt,
    final DateTime? startDate,
    final DateTime? endDate,
    final DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Membuat [EventModel] dari SQLite map.
  factory EventModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Creating EventModel from SQLite: ${map[NamaKolom.id]}');
    return EventModel(
      id: map[NamaKolom.id] as String? ?? '',
      imageUrl: map[NamaKolom.linkGambar] as String? ?? '',
      isActive: ParserUtil.parseBool(map[NamaKolom.statusAktif]),
      createdAt: ParserUtil.parseDateTime(map[NamaKolom.tanggalDibuat]) ??
          DateTime.now(),
      startDate: ParserUtil.parseDateTime(map[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      endDate: ParserUtil.parseDateTime(map[NamaKolom.tangglberakhir]) ??
          DateTime.now(),
      updatedAt: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.linkGambar: imageUrl,
      NamaKolom.statusAktif: isActive ? 1 : 0,
      NamaKolom.tanggalDibuat: createdAt.millisecondsSinceEpoch,
      NamaKolom.tanggalMulai: startDate.millisecondsSinceEpoch,
      NamaKolom.tangglberakhir: endDate.millisecondsSinceEpoch,
      NamaKolom.diperbaruiPada:
          (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  /// Membuat [EventModel] dari Supabase document.
  factory EventModel.fromSupabase(
      final String id, final Map<String, dynamic> data) {
    Log.info('Creating EventModel from Supabase: $id');
    return EventModel(
      id: id,
      imageUrl: data[NamaKolom.linkGambar] as String? ?? '',
      isActive: ParserUtil.parseBool(data[NamaKolom.statusAktif]),
      createdAt: ParserUtil.parseDateTime(data[NamaKolom.tanggalDibuat]) ??
          DateTime.now(),
      startDate: ParserUtil.parseDateTime(data[NamaKolom.tanggalMulai]) ??
          DateTime.now(),
      endDate: ParserUtil.parseDateTime(data[NamaKolom.tangglberakhir]) ??
          DateTime.now(),
      updatedAt: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
    );
  }

  /// Mengonversi [EventModel] ke map untuk penyimpanan Supabase.
  Map<String, dynamic> toSupabase() {
    return {
      NamaKolom.id: id,
      NamaKolom.linkGambar: imageUrl,
      NamaKolom.statusAktif: isActive,
      NamaKolom.tanggalMulai: startDate.toIso8601String(),
      NamaKolom.tangglberakhir: endDate.toIso8601String(),
      NamaKolom.tanggalDibuat: createdAt.toIso8601String(),
      NamaKolom.diperbaruiPada: (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }
}
