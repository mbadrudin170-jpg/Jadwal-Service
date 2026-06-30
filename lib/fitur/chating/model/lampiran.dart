// lib/fitur/chating/model/lampiran.dart
class Lampiran {
  final String id;
  final String url;
  final String tipe;
  final String? nama;
  final int? ukuran;

  const Lampiran({
    required this.id,
    required this.url,
    required this.tipe,
    this.nama,
    this.ukuran,
  });

  Lampiran copyWith({
    String? id,
    String? url,
    String? tipe,
    String? nama,
    int? ukuran,
  }) {
    return Lampiran(
      id: id ?? this.id,
      url: url ?? this.url,
      tipe: tipe ?? this.tipe,
      nama: nama ?? this.nama,
      ukuran: ukuran ?? this.ukuran,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'tipe': tipe,
        'nama': nama,
        'ukuran': ukuran,
      };

  factory Lampiran.fromJson(Map<String, dynamic> json) => Lampiran(
        id: json['id'] as String,
        url: json['url'] as String,
        tipe: json['tipe'] as String,
        nama: json['nama'] as String?,
        ukuran: json['ukuran'] as int?,
      );
}
