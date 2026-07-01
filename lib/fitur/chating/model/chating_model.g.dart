// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pesan _$PesanFromJson(Map<String, dynamic> json) => _Pesan(
  id: json['id'] as String,
  idPercakapan: json['id_percakapan'] as String,
  idPengirim: json['id_pengirim'] as String,
  teks: json['teks'] as String?,
  dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
  dieditPada: json['diedit_pada'] == null
      ? null
      : DateTime.parse(json['diedit_pada'] as String),
  status: json['status'] == null
      ? StatusPesan.terkirim
      : _statusFromJson(json['status'] as String?),
  lampiran:
      (json['lampiran'] as List<dynamic>?)
          ?.map((e) => Lampiran.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  balasanUntuk: json['balasan_untuk'] as String?,
  reaksi:
      (json['reaksi'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  metadata: json['metadata'] as Map<String, dynamic>?,
  dihapus: json['dihapus'] == null ? false : _boolFromDynamic(json['dihapus']),
  diarsipkanPada: dateTimeFromDynamic(json['diarsipkan_pada']),
);

Map<String, dynamic> _$PesanToJson(_Pesan instance) => <String, dynamic>{
  'id': instance.id,
  'id_percakapan': instance.idPercakapan,
  'id_pengirim': instance.idPengirim,
  'teks': instance.teks,
  'dibuat_pada': instance.dibuatPada.toIso8601String(),
  'diedit_pada': instance.dieditPada?.toIso8601String(),
  'status': _statusToJson(instance.status),
  'lampiran': instance.lampiran,
  'balasan_untuk': instance.balasanUntuk,
  'reaksi': instance.reaksi,
  'metadata': instance.metadata,
  'dihapus': _boolToDynamic(instance.dihapus),
  'diarsipkan_pada': dateTimeToDynamic(instance.diarsipkanPada),
};
