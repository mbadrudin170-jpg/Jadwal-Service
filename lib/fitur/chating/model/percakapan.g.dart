// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'percakapan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Percakapan _$PercakapanFromJson(Map<String, dynamic> json) => _Percakapan(
  id: json['id'] as String,
  idPartisipan:
      (json['idPartisipan'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  judul: json['judul'] as String?,
  pesanTerakhir: json['pesanTerakhir'] == null
      ? null
      : Pesan.fromJson(json['pesanTerakhir'] as Map<String, dynamic>),
  pratinjauPesanTerakhir: json['pratinjauPesanTerakhir'] as String?,
  waktuPesanTerakhir: json['waktuPesanTerakhir'] == null
      ? null
      : DateTime.parse(json['waktuPesanTerakhir'] as String),
  jumlahBelumDibaca: (json['jumlahBelumDibaca'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PercakapanToJson(_Percakapan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'idPartisipan': instance.idPartisipan,
      'judul': instance.judul,
      'pesanTerakhir': instance.pesanTerakhir,
      'pratinjauPesanTerakhir': instance.pratinjauPesanTerakhir,
      'waktuPesanTerakhir': instance.waktuPesanTerakhir?.toIso8601String(),
      'jumlahBelumDibaca': instance.jumlahBelumDibaca,
    };
