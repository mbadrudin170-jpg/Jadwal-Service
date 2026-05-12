// path: lib/model/transaksi_model.dart
// diubah: Model digabungkan dengan RiwayatLanggananModel dan denormalisasi data dihapus.
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/enum/tipe_transaksi_enum.dart';
import 'package:wifi/shared/model/paket_model.dart'; // Impor untuk TipeDurasi
import 'package:cloud_firestore/cloud_firestore.dart';

// ditambahkan: tipe 'langganan' untuk mencatat aktivasi/penukaran paket.

class TransaksiModel {
  final String id;
  final DateTime tanggal;
  final String keterangan;
  final double jumlah;
  final TipeTransaksi tipe;
  final String idDompet;
  final String idKategori;
  final String? idDompetTujuan;
  final String? idPelanggan;
  final String? idPaket;
  final String? idSubKategori;
  final StatusPembayaranEnum statusPembayaran;
  final int poinYangDihasilkan;
  final int poinYangDigunakan;
  final DateTime? diperbarui;
  final DateTime? diarsipkan;
  final bool isDeleted;

  // ditambahkan: Properti dari RiwayatLanggananModel
  final int? durasiPaket;
  final TipeDurasi? tipeDurasiPaket;
  final DateTime? tanggalMulai;
  final DateTime? tanggalBerakhir;
  final bool aktivasiPaket;

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

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) return dateValue.toDate();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) return DateTime.tryParse(dateValue);
    return null;
  }

  factory TransaksiModel.fromSqlite(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as String,
      tanggal: _parseDateTime(map['tanggal']) ?? DateTime.now(),
      keterangan: map['keterangan'] ?? '',
      jumlah: (map['jumlah'] as num? ?? 0).toDouble(),
      tipe: TipeTransaksi.values.firstWhere(
        (e) => e.name == map['tipe'],
        orElse: () => TipeTransaksi.pengeluaran,
      ),
      idDompet: map['id_dompet'] ?? '',
      idKategori: map['id_kategori'] ?? '',
      idDompetTujuan: map['id_dompet_tujuan'],
      idPelanggan: map['id_pelanggan'],
      idPaket: map['id_paket'],
      idSubKategori: map['id_sub_kategori'],
      statusPembayaran: StatusPembayaranEnum.values.firstWhere(
        (e) => e.name == map['status_pembayaran'],
        orElse: () => StatusPembayaranEnum.belumLunas,
      ),
      poinYangDihasilkan: (map['poin_yang_dihasilkan'] as num? ?? 0).toInt(),
      poinYangDigunakan: (map['poin_yang_digunakan'] as num? ?? 0).toInt(),
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
      isDeleted: (map['isDeleted'] == 1),
      durasiPaket: (map['durasi_paket'] as num?)?.toInt(),
      tipeDurasiPaket: map['tipe_durasi_paket'] != null
          ? TipeDurasi.values.byName(map['tipe_durasi_paket'])
          : null,
      tanggalMulai: _parseDateTime(map['tanggal_mulai']),
      tanggalBerakhir: _parseDateTime(map['tanggal_berakhir']),
      aktivasiPaket: map['aktivasi_paket'] == 1,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
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
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'durasi_paket': durasiPaket,
      'tipe_durasi_paket': tipeDurasiPaket?.name,
      'tanggal_mulai': tanggalMulai?.toIso8601String(),
      'tanggal_berakhir': tanggalBerakhir?.toIso8601String(),
      'aktivasi_paket': aktivasiPaket ? 1 : 0,
    };
  }

  factory TransaksiModel.fromFirebase(String id, Map<String, dynamic> data) {
    return TransaksiModel(
      id: id,
      tanggal: _parseDateTime(data['tanggal']) ?? DateTime.now(),
      keterangan: data['keterangan'] ?? '',
      jumlah: (data['jumlah'] as num? ?? 0).toDouble(),
      tipe: TipeTransaksi.values.firstWhere(
        (e) => e.name == data['tipe'],
        orElse: () => TipeTransaksi.pengeluaran,
      ),
      idDompet: data['id_dompet'] ?? '',
      idKategori: data['id_kategori'] ?? '',
      idDompetTujuan: data['id_dompet_tujuan'],
      idPelanggan: data['id_pelanggan'],
      idPaket: data['id_paket'],
      idSubKategori: data['id_sub_kategori'],
      statusPembayaran: StatusPembayaranEnum.values.firstWhere(
        (e) => e.name == data['status_pembayaran'],
        orElse: () => StatusPembayaranEnum.belumLunas,
      ),
      poinYangDihasilkan: (data['poin_yang_dihasilkan'] as num? ?? 0).toInt(),
      poinYangDigunakan: (data['poin_yang_digunakan'] as num? ?? 0).toInt(),
      diperbarui: _parseDateTime(data['diperbarui']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
      isDeleted: data['isDeleted'] ?? false,
      durasiPaket: (data['durasiPaket'] as num?)?.toInt(),
      tipeDurasiPaket: data['tipeDurasiPaket'] != null
          ? TipeDurasi.values.byName(data['tipeDurasiPaket'])
          : null,
      tanggalMulai: _parseDateTime(data['tanggalMulai']),
      tanggalBerakhir: _parseDateTime(data['tanggalBerakhir']),
      aktivasiPaket: data['aktivasiPaket'] ?? false,
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'tanggal': tanggal,
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
      'diarsipkan': diarsipkan,
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
