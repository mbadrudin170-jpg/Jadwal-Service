// path lib/fitur/chating/model/chating_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/lampiran.dart';

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

  //   // Supabase → Pesan
  //   factory Pesan.fromSupabase(Map<String, dynamic> data) {
  //     return Pesan(
  //       id: data['id'] as String,
  //       idPercakapan: data['id_percakapan'] as String,
  //       idPengirim: data['id_pengirim'] as String,
  //       teks: data['teks'] as String?,
  //       dibuatPada: dateTimeFromDynamic(data['dibuat_pada'])!,
  //       dieditPada: dateTimeFromDynamic(data['diedit_pada']),
  //       status: _statusFromJson(data['status'] as String?),
  //       lampiran:
  //           (data['lampiran'] as List<dynamic>?)
  //               ?.map((e) => Lampiran.fromJson(e as Map<String, dynamic>))
  //               .toList() ??
  //           const [],
  //       balasanUntuk: data['balasan_untuk'] as String?,
  //       reaksi:
  //           (data['reaksi'] as Map<String, dynamic>?)?.map(
  //             (k, e) => MapEntry(k, (e as num).toInt()),
  //           ) ??
  //           const {},
  //       metadata: data['metadata'] as Map<String, dynamic>?,
  //       dihapus: _boolFromDynamic(data['dihapus']),
  //       diarsipkanPada: dateTimeFromDynamic(data['diarsipkan_pada']),
  //     );
  //   }

  //   // Pesan → Supabase
  //   Map<String, dynamic> toSupabase() {
  //     return {
  //       'id': id,
  //       'id_percakapan': idPercakapan,
  //       'id_pengirim': idPengirim,
  //       'teks': teks,
  //       'dibuat_pada': (dibuatPada), // ISO8601 string
  //       'diedit_pada': (dieditPada),
  //       'status': status.name,
  //       'lampiran': lampiran.map((l) => l.toJson()).toList(),
  //       'balasan_untuk': balasanUntuk,
  //       'reaksi': reaksi,
  //       'metadata': metadata,
  //       'dihapus': dihapus, // Supabase → bool
  //       'diarsipkan_pada': diarsipkanPada.toIso8601String,
  //     };
  //   }
  // }
}
