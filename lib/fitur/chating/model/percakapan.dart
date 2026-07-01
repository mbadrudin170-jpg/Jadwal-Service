// lib/fitur/chating/model/percakapan.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';

part 'percakapan.freezed.dart';
part 'percakapan.g.dart';

@freezed
abstract class Percakapan with _$Percakapan {
  const factory Percakapan({
    required String id,
    @Default([]) List<String> idPartisipan,
    String? judul,
    Pesan? pesanTerakhir,
    String? pratinjauPesanTerakhir,
    DateTime? waktuPesanTerakhir,
    @Default(0) int jumlahBelumDibaca,
  }) = _Percakapan;

  factory Percakapan.fromJson(Map<String, dynamic> json) =>
      _$PercakapanFromJson(json);
}

extension PercakapanX on Percakapan {
  String get tampilkanJudul {
    if (judul != null && judul!.isNotEmpty) return judul!;
    if (idPartisipan.isNotEmpty) return idPartisipan.join(', ');
    return 'Percakapan';
  }
}
