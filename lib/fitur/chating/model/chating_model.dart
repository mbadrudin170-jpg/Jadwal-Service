// lib/fitur/chating/model/chating_model.dart
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
    @JsonKey(name: 'diarsipkan_pada') DateTime? diarsipkanPada,
  }) = _Pesan;

  factory Pesan.fromJson(Map<String, dynamic> json) => _$PesanFromJson(json);
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
