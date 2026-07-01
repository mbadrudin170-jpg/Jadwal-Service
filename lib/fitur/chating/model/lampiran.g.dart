// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lampiran.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Lampiran _$LampiranFromJson(Map<String, dynamic> json) => _Lampiran(
  id: json['id'] as String,
  url: json['url'] as String,
  tipe: json['tipe'] as String,
  nama: json['nama'] as String?,
  ukuran: (json['ukuran'] as num?)?.toInt(),
);

Map<String, dynamic> _$LampiranToJson(_Lampiran instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'tipe': instance.tipe,
  'nama': instance.nama,
  'ukuran': instance.ukuran,
};
