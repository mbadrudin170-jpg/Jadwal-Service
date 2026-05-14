// path: lib/shared/model/transaksi_model.dart
// diubah: Model digabungkan dengan RiwayatLanggananModel dan denormalisasi data dihapus.
// diubah: Semua kolom tanggal disimpan sebagai millisecondsSinceEpoch (INTEGER) di SQLite.
// ditambah: Dokumentasi lengkap dan perbaikan tipe data untuk keamanan.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/memiliki_id.dart';
import 'package:wifi/shared/model/paket_model.dart'; // Impor untuk TipeDurasi

/// Model yang merepresentasikan satu transaksi dalam aplikasi.
///
/// Model ini mencakup semua jenis transaksi, termasuk pemasukan, pengeluaran,
/// transfer antar dompet, dan juga transaksi yang berhubungan dengan aktivasi
/// atau perpanjangan langganan paket.
class TransaksiModel implements MemilikiId {
  /// ID unik untuk transaksi, biasanya UUID.
  @override
  final String id;

  /// Tanggal dan waktu kapan transaksi dibuat.
  final DateTime tanggal;

  /// Deskripsi atau catatan mengenai transaksi.
  final String keterangan;

  /// Jumlah nominal dari transaksi.
  final double jumlah;

  /// Jenis transaksi (pemasukan, pengeluaran, transfer, langganan).
  final TipeTransaksi tipe;

  /// ID dompet sumber dana.
  final String idDompet;

  /// ID kategori utama dari transaksi.
  final String idKategori;

  /// ID dompet tujuan, hanya digunakan untuk transaksi tipe transfer.
  final String? idDompetTujuan;

  /// ID pelanggan yang terkait dengan transaksi ini.
  final String? idPelanggan;

  /// ID paket yang terkait, jika transaksi ini adalah aktivasi langganan.
  final String? idPaket;

  /// ID sub-kategori dari transaksi.
  final String? idSubKategori;

  /// Status pembayaran untuk transaksi (misal: lunas, belum lunas).
  final StatusPembayaranEnum statusPembayaran;

  /// Jumlah poin yang dihasilkan dari transaksi ini.
  final int poinYangDihasilkan;

  /// Jumlah poin yang digunakan dalam transaksi ini.
  final int poinYangDigunakan;

  /// Waktu terakhir data ini diperbarui.
  final DateTime? diperbarui;

  /// Waktu kapan data ini diarsipkan.
  final DateTime? diarsipkan;

  /// Penanda jika data ini telah dihapus (soft delete).
  final bool isDeleted;

  // Properti dari RiwayatLanggananModel yang digabung
  /// Durasi paket langganan (misal: 30).
  final int? durasiPaket;

  /// Tipe durasi paket (misal: hari, bulan).
  final TipeDurasi? tipeDurasiPaket;

  /// Tanggal mulai periode langganan.
  final DateTime? tanggalMulai;

  /// Tanggal berakhir periode langganan.
  final DateTime? tanggalBerakhir;

  /// Penanda jika transaksi ini merupakan aktivasi paket baru.
  final bool aktivasiPaket;

  /// Konstruktor utama untuk membuat instance [TransaksiModel].
  TransaksiModel({
    required this.id,
    required this.tanggal,
    required this.keterangan,
    required this.jumlah,
    required this.tipe,
    required this.idDompet,
    required this.idKategori,
    this.idDompetTujuan,
    this.idPelanggan,
    this.idPaket,
    this.idSubKategori,
    this.statusPembayaran = StatusPembayaranEnum.belumLunas,
    this.poinYangDihasilkan = 0,
    this.poinYangDigunakan = 0,
    this.diperbarui,
    this.diarsipkan,
    this.isDeleted = false,
    this.durasiPaket,
    this.tipeDurasiPaket,
    this.tanggalMulai,
    this.tanggalBerakhir,
    this.aktivasiPaket = false,
  });

  /// Helper untuk mengubah nilai dinamis menjadi DateTime.
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    // Menangani millisecondsSinceEpoch dari SQLite (INTEGER)
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }

  /// Helper untuk parsing enum dengan aman dari String.
  static T? _safeParseEnum<T extends Enum>(List<T> values, dynamic name) {
    if (name == null) return null;
    try {
      return values.firstWhere((e) => e.name == name as String);
    } on Exception {
      return null;
    }
  }

  /// Factory constructor untuk membuat [TransaksiModel] dari data SQLite.
  factory TransaksiModel.fromSqlite(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as String? ?? '',
      tanggal: _parseDateTime(map['tanggal']) ?? DateTime.now(),
      keterangan: map['keterangan'] as String? ?? '',
      jumlah: (map['jumlah'] as num? ?? 0).toDouble(),
      tipe: _safeParseEnum(TipeTransaksi.values, map['tipe']) ??
          TipeTransaksi.pengeluaran,
      idDompet: map['id_dompet'] as String? ?? '',
      idKategori: map['id_kategori'] as String? ?? '',
      idDompetTujuan: map['id_dompet_tujuan'] as String?,
      idPelanggan: map['id_pelanggan'] as String?,
      idPaket: map['id_paket'] as String?,
      idSubKategori: map['id_sub_kategori'] as String?,
      statusPembayaran: _safeParseEnum(
            StatusPembayaranEnum.values,
            map['status_pembayaran'],
          ) ??
          StatusPembayaranEnum.belumLunas,
      poinYangDihasilkan: (map['poin_yang_dihasilkan'] as num? ?? 0).toInt(),
      poinYangDigunakan: (map['poin_yang_digunakan'] as num? ?? 0).toInt(),
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
      durasiPaket: (map['durasi_paket'] as num?)?.toInt(),
      tipeDurasiPaket:
          _safeParseEnum(TipeDurasi.values, map['tipe_durasi_paket']),
      tanggalMulai: _parseDateTime(map['tanggal_mulai']),
      tanggalBerakhir: _parseDateTime(map['tanggal_berakhir']),
      aktivasiPaket: (map['aktivasi_paket'] as int? ?? 0) == 1,
    );
  }

  /// Mengubah instance [TransaksiModel] menjadi Map untuk disimpan di SQLite.
  /// Semua kolom tanggal disimpan sebagai millisecondsSinceEpoch (INTEGER).
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'tanggal': tanggal.millisecondsSinceEpoch, // INTEGER
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tipe': tipe.name,
      'id_dompet': idDompet,
      'id_kategori': idKategori,
      'id_dompet_tujuan': idDompetTujuan,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_sub_kategori': idSubKategori,
      'status_pembayaran': statusPembayaran.name,
      'poin_yang_dihasilkan': poinYangDihasilkan,
      'poin_yang_digunakan': poinYangDigunakan,
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // INTEGER atau NULL
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch, // INTEGER atau NULL
      'isDeleted': isDeleted ? 1 : 0,
      'durasi_paket': durasiPaket,
      'tipe_durasi_paket': tipeDurasiPaket?.name,
      'tanggal_mulai':
          tanggalMulai?.millisecondsSinceEpoch, // INTEGER atau NULL
      'tanggal_berakhir':
          tanggalBerakhir?.millisecondsSinceEpoch, // INTEGER atau NULL
      'aktivasi_paket': aktivasiPaket ? 1 : 0,
    };
  }

  /// Factory constructor untuk membuat [TransaksiModel] dari data Firebase.
  factory TransaksiModel.fromFirebase(String id, Map<String, dynamic> data) {
    return TransaksiModel(
      id: id,
      tanggal: _parseDateTime(data['tanggal']) ?? DateTime.now(),
      keterangan: data['keterangan'] as String? ?? '',
      jumlah: (data['jumlah'] as num? ?? 0).toDouble(),
      tipe: _safeParseEnum(TipeTransaksi.values, data['tipe']) ??
          TipeTransaksi.pengeluaran,
      idDompet: data['id_dompet'] as String? ?? '',
      idKategori: data['id_kategori'] as String? ?? '',
      idDompetTujuan: data['id_dompet_tujuan'] as String?,
      idPelanggan: data['id_pelanggan'] as String?,
      idPaket: data['id_paket'] as String?,
      idSubKategori: data['id_sub_kategori'] as String?,
      statusPembayaran: _safeParseEnum(
            StatusPembayaranEnum.values,
            data['status_pembayaran'],
          ) ??
          StatusPembayaranEnum.belumLunas,
      poinYangDihasilkan: (data['poin_yang_dihasilkan'] as num? ?? 0).toInt(),
      poinYangDigunakan: (data['poin_yang_digunakan'] as num? ?? 0).toInt(),
      diperbarui: _parseDateTime(data['diperbarui']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
      isDeleted: data['isDeleted'] as bool? ?? false,
      durasiPaket: (data['durasiPaket'] as num?)?.toInt(),
      tipeDurasiPaket:
          _safeParseEnum(TipeDurasi.values, data['tipeDurasiPaket']),
      tanggalMulai: _parseDateTime(data['tanggalMulai']),
      tanggalBerakhir: _parseDateTime(data['tanggalBerakhir']),
      aktivasiPaket: data['aktivasiPaket'] as bool? ?? false,
    );
  }

  /// Mengubah instance [TransaksiModel] menjadi Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    return {
      // 'id' tidak perlu disimpan karena sudah menjadi ID dokumen
      'tanggal': Timestamp.fromDate(tanggal),
      'keterangan': keterangan,
      'jumlah': jumlah,
      'tipe': tipe.name,
      'id_dompet': idDompet,
      'id_kategori': idKategori,
      'id_dompet_tujuan': idDompetTujuan,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_sub_kategori': idSubKategori,
      'status_pembayaran': statusPembayaran.name,
      'poin_yang_dihasilkan': poinYangDihasilkan,
      'poin_yang_digunakan': poinYangDigunakan,
      'diperbarui': FieldValue.serverTimestamp(),
      'diarsipkan': diarsipkan != null ? Timestamp.fromDate(diarsipkan!) : null,
      'isDeleted': isDeleted,
      'durasiPaket': durasiPaket,
      'tipeDurasiPaket': tipeDurasiPaket?.name,
      'tanggalMulai':
          tanggalMulai != null ? Timestamp.fromDate(tanggalMulai!) : null,
      'tanggalBerakhir':
          tanggalBerakhir != null ? Timestamp.fromDate(tanggalBerakhir!) : null,
      'aktivasiPaket': aktivasiPaket,
    };
  }

  /// Membuat salinan dari instance [TransaksiModel] dengan beberapa nilai yang diubah.
  TransaksiModel copyWith({
    String? id,
    DateTime? tanggal,
    String? keterangan,
    double? jumlah,
    TipeTransaksi? tipe,
    String? idDompet,
    String? idKategori,
    String? idDompetTujuan,
    String? idPelanggan,
    String? idPaket,
    String? idSubKategori,
    StatusPembayaranEnum? statusPembayaran,
    int? poinYangDihasilkan,
    int? poinYangDigunakan,
    DateTime? diperbarui,
    DateTime? diarsipkan,
    bool? isDeleted,
    int? durasiPaket,
    TipeDurasi? tipeDurasiPaket,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    bool? aktivasiPaket,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      keterangan: keterangan ?? this.keterangan,
      jumlah: jumlah ?? this.jumlah,
      tipe: tipe ?? this.tipe,
      idDompet: idDompet ?? this.idDompet,
      idKategori: idKategori ?? this.idKategori,
      idDompetTujuan: idDompetTujuan ?? this.idDompetTujuan,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      idSubKategori: idSubKategori ?? this.idSubKategori,
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
      poinYangDihasilkan: poinYangDihasilkan ?? this.poinYangDihasilkan,
      poinYangDigunakan: poinYangDigunakan ?? this.poinYangDigunakan,
      diperbarui: diperbarui ?? this.diperbarui,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      isDeleted: isDeleted ?? this.isDeleted,
      durasiPaket: durasiPaket ?? this.durasiPaket,
      tipeDurasiPaket: tipeDurasiPaket ?? this.tipeDurasiPaket,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      aktivasiPaket: aktivasiPaket ?? this.aktivasiPaket,
    );
  }
}
