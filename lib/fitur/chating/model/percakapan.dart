// lib/fitur/chating/model/percakapan.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';

part 'percakapan.freezed.dart';

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
}
