// lib/fitur/chating/model/chating_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/lampiran.dart';
import 'package:wifi/shared/utils/parser_util.dart'; // tambahkan import

part 'chating_model.freezed.dart';

@freezed
abstract class Pesan with _$Pesan {
  const factory Pesan({
    required String id,
    required String idPercakapan,
    required String idPengirim,
    String? teks,
    required DateTime dibuatPada,
    DateTime? dieditPada,
    @Default(StatusPesan.terkirim) StatusPesan status,
    @Default([]) List<Lampiran> lampiran,
    String? balasanUntuk,
    @Default({}) Map<String, int> reaksi,
    Map<String, dynamic>? metadata,
    @Default(false) bool dihapus,
    DateTime? diarsipkanPada,
  }) = _Pesan;

  factory Pesan.fromSupabase(String id, Map<String, dynamic> data) {
    List<Lampiran> parseLampiran(dynamic v) {
      if (v == null) return [];
      if (v is List) {
        try {
          return v.cast<Map<String, dynamic>>().map(Lampiran.fromMap).toList();
        } catch (_) {
          return v
              .whereType<Map<String, dynamic>>()
              .map(Lampiran.fromMap)
              .toList();
        }
      }
      return [];
    }

    // Reaksi tetap manual
    Map<String, int> parseReaksi(dynamic v) {
      if (v == null) return {};
      if (v is Map) {
        return v.map(
          (key, value) => MapEntry(
            key.toString(),
            (value is int) ? value : int.tryParse(value?.toString() ?? '') ?? 0,
          ),
        );
      }
      return {};
    }

    final meta = data['metadata'];

    return Pesan(
      id: id,
      idPercakapan:
          data['id_percakapan'] as String? ??
          data['idPercakapan'] as String? ??
          '',
      idPengirim:
          data['id_pengirim'] as String? ?? data['idPengirim'] as String? ?? '',
      teks: data['teks'] as String?,
      dibuatPada:
          ParserUtil.parseDateTime(data['dibuat_pada'] ?? data['dibuatPada']) ??
          DateTime.now(),
      dieditPada: ParserUtil.parseDateTime(
        data['diedit_pada'] ?? data['dieditPada'],
      ),
      status:
          ParserUtil.safeParseEnum(
            StatusPesan.values,
            data['status']?.toString(),
          ) ??
          StatusPesan.terkirim,
      lampiran: parseLampiran(data['lampiran'] ?? data['attachments']),
      balasanUntuk:
          data['balasan_untuk'] as String? ?? data['balasanUntuk'] as String?,
      reaksi: parseReaksi(data['reaksi'] ?? data['reactions']),
      metadata: meta is Map ? Map<String, dynamic>.from(meta) : null,
      dihapus: ParserUtil.parseBool(data['dihapus']),
      diarsipkanPada: ParserUtil.parseDateTime(
        data['diarsipkan_pada'] ?? data['diarsipkanPada'],
      ),
    );
  }

  Map<String, dynamic> toSupabase() {
    // tidak berubah
    return {
      'id': id,
      'id_percakapan': idPercakapan,
      'id_pengirim': idPengirim,
      'teks': teks,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diedit_pada': dieditPada?.toIso8601String(),
      'status': status.toString().split('.').last,
      'lampiran': lampiran.map((l) => l.toMap()).toList(),
      'balasan_untuk': balasanUntuk,
      'reaksi': reaksi,
      'metadata': metadata,
      'dihapus': dihapus,
      'diarsipkan_pada': diarsipkanPada?.toIso8601String(),
    };
  }
}
