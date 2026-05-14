// // Path: lib/model/riwayat_langganan_model.dart
// // diubah: Penamaan metode diseragamkan dan logika Firebase disesuaikan.
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../enum/status_pembayaran.dart';
// import 'package:uuid/uuid.dart';

// class RiwayatLanggananModel {
//   final String id;
//   final String idPelanggan;
//   final String idPaket;
//   final String namaPaket;
//   final int hargaPaket;
//   final int durasiPaket;
//   final String tipeDurasiPaket;
//   final int jumlahPoinDiperoleh;
//   final DateTime tanggalMulai;
//   final DateTime tanggalBerakhir;
//   final StatusPembayaran status;
//   final DateTime? diperbarui;
//   final DateTime? diarsipkan;
//   final bool isDeleted;
//   RiwayatLanggananModel({
//     String? id,
//     required this.idPelanggan,
//     required this.idPaket,
//     required this.namaPaket,
//     required this.hargaPaket,
//     required this.durasiPaket,
//     required this.tipeDurasiPaket,
//     this.jumlahPoinDiperoleh = 0,
//     required this.tanggalMulai,
//     required this.tanggalBerakhir,
//     required this.status,
//     this.diperbarui,
//     this.diarsipkan,
//     this.isDeleted = false,
//   }) : id = id ?? const Uuid().v4();

//   RiwayatLanggananModel copyWith({
//     String? id,
//     String? idPelanggan,
//     String? idPaket,
//     String? namaPaket,
//     int? hargaPaket,
//     int? durasiPaket,
//     String? tipeDurasiPaket,
//     int? jumlahPoinDiperoleh,
//     DateTime? tanggalMulai,
//     DateTime? tanggalBerakhir,
//     StatusPembayaran? status,
//     DateTime? diperbarui,
//     DateTime? diarsipkan,
//     bool? isDeleted,
//   }) {
//     return RiwayatLanggananModel(
//       id: id ?? this.id,
//       idPelanggan: idPelanggan ?? this.idPelanggan,
//       idPaket: idPaket ?? this.idPaket,
//       namaPaket: namaPaket ?? this.namaPaket,
//       hargaPaket: hargaPaket ?? this.hargaPaket,
//       durasiPaket: durasiPaket ?? this.durasiPaket,
//       tipeDurasiPaket: tipeDurasiPaket ?? this.tipeDurasiPaket,
//       jumlahPoinDiperoleh: jumlahPoinDiperoleh ?? this.jumlahPoinDiperoleh,
//       tanggalMulai: tanggalMulai ?? this.tanggalMulai,
//       tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
//       status: status ?? this.status,
//       diperbarui: diperbarui ?? this.diperbarui,
//       diarsipkan: diarsipkan ?? this.diarsipkan,
//       isDeleted: isDeleted ?? this.isDeleted,
//     );
//   }

//   static DateTime? _parseDateTime(dynamic dateValue) {
//     if (dateValue == null) return null;
//     if (dateValue is Timestamp) return dateValue.toDate();
//     if (dateValue is DateTime) return dateValue;
//     if (dateValue is String) return DateTime.tryParse(dateValue);
//     return null;
//   }

//   // =========================
//   // SQLITE
//   // =========================

//   factory RiwayatLanggananModel.fromSqlite(Map<String, dynamic> map) {
//     return RiwayatLanggananModel(
//       id: map['id'] ?? const Uuid().v4(),
//       idPelanggan: map['id_pelanggan'] ?? '',
//       idPaket: map['id_paket'] ?? '',
//       namaPaket: map['nama_paket'] ?? 'Tidak Diketahui',
//       hargaPaket: (map['harga_paket'] as num? ?? 0).toInt(),
//       durasiPaket: (map['durasi_paket'] as num? ?? 0).toInt(),
//       tipeDurasiPaket: map['tipe_durasi_paket'] ?? 'hari',
//       jumlahPoinDiperoleh: (map['jumlah_poin_diperoleh'] as num? ?? 0).toInt(),
//       tanggalMulai: _parseDateTime(map['tanggal_mulai']) ?? DateTime.now(),
//       tanggalBerakhir:
//           _parseDateTime(map['tanggal_berakhir']) ?? DateTime.now(),
//       status: StatusPembayaran.values.firstWhere(
//         (e) => e.name == map['status'],
//         orElse: () => StatusPembayaran.lunas,
//       ),
//       diperbarui: _parseDateTime(map['diperbarui']),
//       diarsipkan: _parseDateTime(map['diarsipkan']),
//       isDeleted: map['isDeleted'] == 1,
//     );
//   }

//   Map<String, dynamic> toSqlite() {
//     return {
//       'id': id,
//       'id_pelanggan': idPelanggan,
//       'id_paket': idPaket,
//       'nama_paket': namaPaket,
//       'harga_paket': hargaPaket,
//       'durasi_paket': durasiPaket,
//       'tipe_durasi_paket': tipeDurasiPaket,
//       'jumlah_poin_diperoleh': jumlahPoinDiperoleh,
//       'tanggal_mulai': tanggalMulai.toIso8601String(),
//       'tanggal_berakhir': tanggalBerakhir.toIso8601String(),
//       'status': status.name,
//       'diperbarui': diperbarui?.toIso8601String(),
//       'diarsipkan': diarsipkan?.toIso8601String(),
//       'isDeleted': isDeleted ? 1 : 0,
//     };
//   }

//   // =========================
//   // FIREBASE
//   // =========================

//   factory RiwayatLanggananModel.fromFirebase(
//     String id,
//     Map<String, dynamic> data,
//   ) {
//     return RiwayatLanggananModel(
//       id: id,
//       idPelanggan: data['id_pelanggan'] ?? '',
//       idPaket: data['id_paket'] ?? '',
//       namaPaket: data['nama_paket'] ?? 'Tidak Diketahui',
//       hargaPaket: (data['harga_paket'] as num? ?? 0).toInt(),
//       durasiPaket: (data['durasi_paket'] as num? ?? 0).toInt(),
//       tipeDurasiPaket: data['tipe_durasi_paket'] ?? 'hari',
//       jumlahPoinDiperoleh: (data['jumlah_poin_diperoleh'] as num? ?? 0).toInt(),
//       tanggalMulai: _parseDateTime(data['tanggal_mulai']) ?? DateTime.now(),
//       tanggalBerakhir:
//           _parseDateTime(data['tanggal_berakhir']) ?? DateTime.now(),
//       status: StatusPembayaran.values.firstWhere(
//         (e) => e.name == data['status'],
//         orElse: () => StatusPembayaran.lunas,
//       ),
//       diperbarui: _parseDateTime(data['diperbarui']),
//       diarsipkan: _parseDateTime(data['diarsipkan']),
//       isDeleted: data['isDeleted'] == true,
//     );
//   }

//   Map<String, dynamic> toFirebase() {
//     return {
//       'id': id,
//       'id_pelanggan': idPelanggan,
//       'id_paket': idPaket,
//       'nama_paket': namaPaket,
//       'harga_paket': hargaPaket,
//       'durasi_paket': durasiPaket,
//       'tipe_durasi_paket': tipeDurasiPaket,
//       'jumlah_poin_diperoleh': jumlahPoinDiperoleh,
//       'tanggal_mulai': Timestamp.fromDate(tanggalMulai),
//       'tanggal_berakhir': Timestamp.fromDate(tanggalBerakhir),
//       'status': status.name,
//       'diperbarui': FieldValue.serverTimestamp(),
//       'isDeleted': isDeleted,
//       if (diarsipkan != null) 'diarsipkan': Timestamp.fromDate(diarsipkan!),
//     };
//   }
// }
