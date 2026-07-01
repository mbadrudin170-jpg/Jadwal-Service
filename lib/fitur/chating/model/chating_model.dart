// lib/fitur/chating/model/chating_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/lampiran.dart';

part 'chating_model.freezed.dart';
part 'chating_model.g.dart';

@freezed
abstract class Pesan with _$Pesan {
  const factory Pesan({
    required String id,
    @JsonKey(name: 'id_percakapan') required String idPercakapan,
    @JsonKey(name: 'id_pengirim') required String idPengirim,
    String? teks,
    @JsonKey(name: 'dibuat_pada') required DateTime dibuatPada,
    @JsonKey(name: 'diedit_pada') DateTime? dieditPada,
    @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)
    @Default(StatusPesan.terkirim)
    StatusPesan status,
    @Default([]) List<Lampiran> lampiran,
    @JsonKey(name: 'balasan_untuk') String? balasanUntuk,
    @Default({}) Map<String, int> reaksi,
    Map<String, dynamic>? metadata,
    @JsonKey(
      name: 'dihapus',
      fromJson: _boolFromDynamic,
      toJson: _boolToDynamic,
    )
    @Default(false)
    bool dihapus,
    @JsonKey(
      name: 'diarsipkan_pada',
      fromJson: dateTimeFromDynamic,
      toJson: dateTimeToDynamic,
    )
    DateTime? diarsipkanPada,
  }) = _Pesan;

  factory Pesan.fromJson(Map<String, dynamic> json) => _$PesanFromJson(json);

  // Tambahkan factory khusus Supabase
  factory Pesan.fromSupabase(Map<String, dynamic> data) {
    return Pesan(
      id: data['id'] as String,
      idPercakapan: data['id_percakapan'] as String,
      idPengirim: data['id_pengirim'] as String,
      teks: data['teks'] as String?,
      dibuatPada: dateTimeFromDynamic(data['dibuat_pada'])!,
      dieditPada: dateTimeFromDynamic(data['diedit_pada']),
      status: _statusFromJson(data['status'] as String?),
      lampiran:
          (data['lampiran'] as List<dynamic>?)
              ?.map((e) => Lampiran.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      balasanUntuk: data['balasan_untuk'] as String?,
      reaksi:
          (data['reaksi'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      metadata: data['metadata'] as Map<String, dynamic>?,
      dihapus: _boolFromDynamic(data['dihapus']),
      diarsipkanPada: dateTimeFromDynamic(data['diarsipkan_pada']),
    );
  }
}

// --- Converter untuk enum StatusPesan ---
StatusPesan _statusFromJson(String? value) {
  if (value == null) return StatusPesan.terkirim;
  return StatusPesan.values.firstWhere(
    (s) => s.name == value,
    orElse: () => StatusPesan.terkirim,
  );
}

String _statusToJson(StatusPesan status) => status.name;

bool _boolFromDynamic(dynamic value) {
  if (value is bool) return value; // Firebase / Supabase → langsung bool
  if (value is int) return value == 1; // SQLite → 0/1 jadi bool
  if (value is String) {
    return value == 'true' || value == '1';
  }
  return false;
}

dynamic _boolToDynamic(bool value) {
  // default: simpan sebagai bool (Supabase/Firebase)
  return value;
}

// kalau mau ke SQLite, bisa buat fungsi khusus:
int _boolToInt(bool value) => value ? 1 : 0;

DateTime? dateTimeFromDynamic(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is String) {
    return DateTime.parse(value).toUtc();
  }
  if (value is Timestamp) {
    return value.toDate().toUtc();
  }
  throw ArgumentError('Unsupported DateTime format: $value');
}

dynamic dateTimeToDynamic(DateTime? value, {String target = 'default'}) {
  if (value == null) return null;
  final utc = value.toUtc();

  switch (target) {
    case 'sqlite':
      return utc.millisecondsSinceEpoch; // int
    case 'firestore':
      return Timestamp.fromDate(utc); // Timestamp
    default:
      return utc.toIso8601String(); // string ISO8601
  }
}
