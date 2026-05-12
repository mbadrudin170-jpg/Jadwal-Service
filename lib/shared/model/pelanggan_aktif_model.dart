// path: lib/model/pelanggan_aktif_model.dart

import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PelangganAktifModel {
  final String id;
  final String idPelanggan;
  final String idPaket;
  final String? idTransaksi;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final StatusPembayaranEnum status;
  final DateTime? diperbarui;
  final bool isDeleted;
  final DateTime? diarsipkan;

  PelangganAktifModel({
    String? id,
    required this.idPelanggan,
    required this.idPaket,
    this.idTransaksi,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.status,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPelanggan': idPelanggan,
      'idPaket': idPaket,
      'idTransaksi': idTransaksi,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalBerakhir': tanggalBerakhir.toIso8601String(),
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    Log.warning('Format DateTime tidak dikenali: $value');
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';

    Log.warning('Format Boolean tidak dikenali, default ke false: $value');
    return false;
  }

  factory PelangganAktifModel.fromSqlite(Map<String, dynamic> map) {
    try {
      // diubah: Menggunakan key snake_case 'tanggal_mulai' dan 'tanggal_berakhir' agar cocok dengan database.
      final tanggalMulai = _parseDateTime(map['tanggal_mulai']);
      final tanggalBerakhir = _parseDateTime(map['tanggal_berakhir']);

      // diubah: Menghapus fallback DateTime.now() yang berbahaya dan menggantinya dengan validasi.
      if (tanggalMulai == null) {
        throw ArgumentError.notNull('tanggal_mulai dari SQLite');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('tanggal_berakhir dari SQLite');
      }

      final model = PelangganAktifModel(
        id: map['id'] as String,
        idPelanggan: map['id_pelanggan'] as String? ?? '',
        idPaket: map['id_paket'] as String? ?? '',
        idTransaksi: map['id_transaksi'] as String?,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => StatusPembayaranEnum.lunas,
        ),
        diperbarui: _parseDateTime(map['diperbarui']),
        isDeleted: _parseBool(map['isDeleted']),
        diarsipkan: _parseDateTime(map['diarsipkan']),
      );

      Log.info('Data dimuat dari SQLite');
      return model;
    } catch (e, stack) {
      Log.error('Gagal parsing SQLite: $map', error: e, stackTrace: stack);
      rethrow;
    }
  }

  factory PelangganAktifModel.fromFirebase(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      // diubah: Menghapus fallback DateTime.now() yang berbahaya dan menggantinya dengan validasi.
      final tanggalMulai = _parseDateTime(data['tanggalMulai']);
      final tanggalBerakhir = _parseDateTime(data['tanggalBerakhir']);

      if (tanggalMulai == null) {
        throw ArgumentError.notNull('tanggalMulai dari Firebase');
      }
      if (tanggalBerakhir == null) {
        throw ArgumentError.notNull('tanggalBerakhir dari Firebase');
      }

      final model = PelangganAktifModel(
        id: id,
        idPelanggan: data['id_pelanggan'] as String? ?? '',
        idPaket: data['id_paket'] as String? ?? '',
        idTransaksi: data['id_transaksi'] as String?,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        status: StatusPembayaranEnum.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => StatusPembayaranEnum.lunas,
        ),
        diperbarui: _parseDateTime(data['diperbarui']),
        isDeleted: _parseBool(data['isDeleted']),
        diarsipkan: _parseDateTime(data['diarsipkan']),
      );

      Log.info('Data ditarik dari Firebase');
      return model;
    } catch (e, stack) {
      Log.error('Gagal parsing Firebase: $data', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggal_mulai': tanggalMulai.toIso8601String(), // snake_case
      'tanggal_berakhir': tanggalBerakhir.toIso8601String(), // snake_case
      'status': status.name,
      'diperbarui': diperbarui?.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggalMulai': Timestamp.fromDate(tanggalMulai), // camelCase
      'tanggalBerakhir': Timestamp.fromDate(tanggalBerakhir), // camelCase
      'status': status.name,
      'isDeleted': isDeleted,
      'diperbarui': FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }

    Log.api('Firestore/Pelanggan/$id', data, method: 'SET');
    return data;
  }

  PelangganAktifModel copyWith({
    String? id,
    String? idPelanggan,
    String? idPaket,
    String? idTransaksi,
    DateTime? tanggalMulai,
    DateTime? tanggalBerakhir,
    StatusPembayaranEnum? status,
    DateTime? diperbarui,
    bool? isDeleted,
    DateTime? diarsipkan,
  }) {
    return PelangganAktifModel(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      idPaket: idPaket ?? this.idPaket,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalBerakhir: tanggalBerakhir ?? this.tanggalBerakhir,
      status: status ?? this.status,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }
}
