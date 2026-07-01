// lib/fitur/chating/model/lampiran.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lampiran.freezed.dart';

@freezed
abstract class Lampiran with _$Lampiran {
  const Lampiran._();
  const factory Lampiran({
    required String id,
    required String url,
    required String tipe, // 'gambar', 'file', 'audio'
    String? nama,
    int? ukuran, // dalam byte
  }) = _Lampiran;

  // helper untuk membuat dari Map (Supabase / JSON)
  factory Lampiran.fromMap(Map<String, dynamic> map) {
    return Lampiran(
      id: map['id'] as String? ?? '',
      url: map['url'] as String? ?? '',
      tipe: map['tipe'] as String? ?? '',
      nama: map['nama'] as String?,
      ukuran: (map['ukuran'] is int)
          ? map['ukuran'] as int
          : int.tryParse(map['ukuran']?.toString() ?? ''),
    );
  }

  // alias jika kamu ingin nama khusus Supabase
  factory Lampiran.fromSupabase(Map<String, dynamic> map) =>
      Lampiran.fromMap(map);

  // konversi ke Map untuk disimpan ke Supabase / JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'tipe': tipe,
      if (nama != null) 'nama': nama,
      if (ukuran != null) 'ukuran': ukuran,
    };
  }

  // alias toSupabase
  Map<String, dynamic> toSupabase() => toMap();
}
