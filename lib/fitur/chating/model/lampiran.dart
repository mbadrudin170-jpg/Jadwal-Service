// lib/fitur/chating/model/lampiran.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lampiran.freezed.dart';
part 'lampiran.g.dart';

@freezed
class Lampiran with _$Lampiran {
  const factory Lampiran({
    required String id,
    required String url,
    required String tipe, // 'gambar', 'file', 'audio'
    String? nama,
    int? ukuran, // dalam byte
  }) = _Lampiran;

  factory Lampiran.fromJson(Map<String, dynamic> json) =>
      _$LampiranFromJson(json);
}
