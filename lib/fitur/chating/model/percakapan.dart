// lib/fitur/chating/model/percakapan.dart
import 'package:wifi/fitur/chating/model/chating_model.dart';

class Percakapan {
  final String id;
  final List<String> idPartisipan;
  final String? judul;
  final Pesan? pesanTerakhir;
  final String? pratinjauPesanTerakhir;
  final DateTime? waktuPesanTerakhir;
  final int jumlahBelumDibaca;

  const Percakapan({
    required this.id,
    required this.idPartisipan,
    this.judul,
    this.pesanTerakhir,
    this.pratinjauPesanTerakhir,
    this.waktuPesanTerakhir,
    this.jumlahBelumDibaca = 0,
  });

  String get tampilkanJudul {
    if (judul != null && judul!.isNotEmpty) return judul!;
    if (idPartisipan.isNotEmpty) return idPartisipan.join(', ');
    return 'Percakapan';
  }
}
