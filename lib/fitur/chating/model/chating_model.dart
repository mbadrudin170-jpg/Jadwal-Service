// lib/fitur/chating/model/pesan.dart
import 'package:wifi/fitur/chating/enum/status_pesan_enum.dart';
import 'package:wifi/fitur/chating/model/lampiran.dart';

class Pesan {
  final String id;
  final String idPercakapan;
  final String idPengirim;
  final String? teks;
  final DateTime dibuatPada;
  final DateTime? dieditPada;
  final StatusPesan status;
  final List<Lampiran> lampiran;
  final String? balasanUntuk;
  final Map<String, int> reaksi;
  final Map<String, dynamic>? metadata;
  final bool dihapus;
  final DateTime? diarsipkanPada;

  const Pesan({
    required this.id,
    required this.idPercakapan,
    required this.idPengirim,
    this.teks,
    required this.dibuatPada,
    this.dieditPada,
    this.status = StatusPesan.terkirim,
    this.lampiran = const [],
    this.balasanUntuk,
    this.reaksi = const {},
    this.metadata,
    this.dihapus = false,
    this.diarsipkanPada,
  });

  bool dariSaya(String idPenggunaSaatIni) => idPengirim == idPenggunaSaatIni;

  Pesan copyWith({
    String? id,
    String? idPercakapan,
    String? idPengirim,
    String? teks,
    DateTime? dibuatPada,
    DateTime? dieditPada,
    StatusPesan? status,
    List<Lampiran>? lampiran,
    String? balasanUntuk,
    Map<String, int>? reaksi,
    Map<String, dynamic>? metadata,
    bool? dihapus,
    DateTime? diarsipkanPada,
  }) {
    return Pesan(
      id: id ?? this.id,
      idPercakapan: idPercakapan ?? this.idPercakapan,
      idPengirim: idPengirim ?? this.idPengirim,
      teks: teks ?? this.teks,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      dieditPada: dieditPada ?? this.dieditPada,
      status: status ?? this.status,
      lampiran: lampiran ?? this.lampiran,
      balasanUntuk: balasanUntuk ?? this.balasanUntuk,
      reaksi: reaksi ?? this.reaksi,
      metadata: metadata ?? this.metadata,
      dihapus: dihapus ?? this.dihapus,
      diarsipkanPada: diarsipkanPada ?? this.diarsipkanPada,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_percakapan': idPercakapan,
    'id_pengirim': idPengirim,
    'teks': teks,
    'dibuat_pada': dibuatPada.toIso8601String(),
    'diedit_pada': dieditPada?.toIso8601String(),
    'status': status.name,
    'lampiran': lampiran.map((l) => l.toJson()).toList(),
    'balasan_untuk': balasanUntuk,
    'reaksi': reaksi,
    'metadata': metadata,
    'dihapus': dihapus,
    'diarsipkan_pada': diarsipkanPada?.toIso8601String(),
  };

  factory Pesan.fromJson(Map<String, dynamic> json) => Pesan(
    id: json['id'] as String,
    idPercakapan: json['id_percakapan'] as String,
    idPengirim: json['id_pengirim'] as String,
    teks: json['teks'] as String?,
    dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
    dieditPada: json['diedit_pada'] != null
        ? DateTime.parse(json['diedit_pada'] as String)
        : null,
    status: StatusPesan.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => StatusPesan.terkirim,
    ),
    lampiran:
        (json['lampiran'] as List<dynamic>?)
            ?.map((l) => Lampiran.fromJson(l as Map<String, dynamic>))
            .toList() ??
        [],
    balasanUntuk: json['balasan_untuk'] as String?,
    reaksi:
        (json['reaksi'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
    metadata: json['metadata'] as Map<String, dynamic>?,
    dihapus: json['dihapus'] as bool? ?? false,
    diarsipkanPada: json['diarsipkan_pada'] != null
        ? DateTime.parse(json['diarsipkan_pada'] as String)
        : null,
  );
}
