// path: lib/fitur/chating/model/chating_model.dart

/// Status pengiriman pesan.
enum StatusPesan { mengirim, terkirim, diterima, dibaca, gagal }

/// Lampiran (gambar, file, audio) yang disertakan dalam pesan.
class Lampiran {
  final String id;
  final String url;
  final String tipe; // 'gambar', 'file', 'audio'
  final String? nama;
  final int? ukuran; // dalam byte

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

/// Model pesan obrolan.
class Pesan {
  final String id;
  final String idPercakapan;
  final String idPengirim;
  final String? teks;
  final DateTime dibuatPada;
  final DateTime? dieditPada;
  final StatusPesan status;
  final List<Lampiran> lampiran;
  final String? balasanUntuk; // ✅ Konsisten: id pesan yang dibalas
  final Map<String, int> reaksi; // emoji -> jumlah
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
    this.balasanUntuk, // ✅ Nama sudah disamakan
    this.reaksi = const {},
    this.metadata,
    this.dihapus = false,
    this.diarsipkanPada,
  });

  /// Mengecek apakah pesan ini dikirim oleh pengguna yang sedang login.
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
    String? balasanUntuk, // ✅ Konsisten
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
      balasanUntuk: balasanUntuk ?? this.balasanUntuk, // ✅ Perbaikan
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
    'balasan_untuk': balasanUntuk, // ✅ Mengambil dari properti yang benar
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
    status: StatusPesan.values.firstWhere((s) => s.name == json['status']),
    lampiran:
        (json['lampiran'] as List<dynamic>?)
            ?.map((l) => Lampiran.fromJson(l as Map<String, dynamic>))
            .toList() ??
        [],
    balasanUntuk: json['balasan_untuk'] as String?, // ✅ Sudah benar
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

/// Model percakapan.
class Percakapan {
  final String id;
  final List<String> idPartisipan;
  final String? judul;
  final Pesan? pesanTerakhir; // objek lengkap
  final String? pratinjauPesanTerakhir; // fallback cepat
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

  /// Menampilkan judul percakapan. Jika tidak ada, gunakan ID partisipan.
  String get tampilkanJudul {
    if (judul != null && judul!.isNotEmpty) return judul!;
    if (idPartisipan.isNotEmpty) return idPartisipan.join(', ');
    return 'Percakapan';
  }

  // fromJson / toJson dapat ditambahkan nanti sesuai kebutuhan
}
