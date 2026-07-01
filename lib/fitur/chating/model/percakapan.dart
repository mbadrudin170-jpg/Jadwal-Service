// lib/fitur/chating/model/percakapan.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/fitur/chating/model/chating_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'percakapan.freezed.dart';

@freezed
abstract class Percakapan with _$Percakapan implements HasId {
  const Percakapan._();
  const factory Percakapan({
    required String id,
    @Default([]) List<String> idPartisipan,
    String? judul,
    Pesan? pesanTerakhir,
    String? pratinjauPesanTerakhir,
    DateTime? waktuPesanTerakhir,
    @Default(0) int jumlahBelumDibaca,
  }) = _Percakapan;

  /// Getter untuk tampilan judul (mengatasi error undefined getter)
  String get tampilkanJudul => judul ?? 'Tanpa Judul';

  /// Membuat [Percakapan] dari SQLite map.
  factory Percakapan.fromSqlite(Map<String, dynamic> map) {
    Log.info('Creating Percakapan from SQLite: ${map['id']}');
    return Percakapan(
      id: map['id'] as String? ?? '',
      idPartisipan:
          (map['id_partisipan'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      judul: map['judul'] as String?,
      pratinjauPesanTerakhir: map['pratinjau_pesan_terakhir'] as String?,
      waktuPesanTerakhir: ParserUtil.parseDateTime(map['waktu_pesan_terakhir']),
      jumlahBelumDibaca:
          int.tryParse(map['jumlah_belum_dibaca']?.toString() ?? '') ?? 0,
    );
  }

  /// Mengonversi [Percakapan] ke map untuk SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_partisipan': idPartisipan.join(','),
      'judul': judul,
      'pratinjau_pesan_terakhir': pratinjauPesanTerakhir,
      'waktu_pesan_terakhir': waktuPesanTerakhir?.millisecondsSinceEpoch,
      'jumlah_belum_dibaca': jumlahBelumDibaca,
    };
  }

  /// Membuat [Percakapan] dari Supabase document.
  factory Percakapan.fromSupabase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    Log.info('Creating Percakapan from Supabase: $id');
    return Percakapan(
      id: id,
      idPartisipan:
          (data['id_partisipan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      judul: data['judul'] as String?,
      pratinjauPesanTerakhir: data['pratinjau_pesan_terakhir'] as String?,
      waktuPesanTerakhir: ParserUtil.parseDateTime(
        data['waktu_pesan_terakhir'],
      ),
      jumlahBelumDibaca:
          int.tryParse(data['jumlah_belum_dibaca']?.toString() ?? '') ?? 0,
    );
  }

  /// Mengonversi [Percakapan] ke map untuk Supabase.
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'id_partisipan': idPartisipan,
      'judul': judul,
      'pratinjau_pesan_terakhir': pratinjauPesanTerakhir,
      'waktu_pesan_terakhir': waktuPesanTerakhir?.toIso8601String(),
      'jumlah_belum_dibaca': jumlahBelumDibaca,
    };
  }
}
