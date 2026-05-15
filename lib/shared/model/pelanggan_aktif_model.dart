// path: lib/model/pelanggan_aktif_model.dart
// Diubah: Semua kolom tanggal disimpan sebagai millisecondsSinceEpoch (INTEGER) di SQLite.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/status_pembayaran_enum.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model untuk data pelanggan aktif.
class PelangganAktifModel implements MemilikiId {
  /// ID unik untuk setiap entri pelanggan aktif.
  @override
  final String id;

  /// ID pelanggan yang terkait dengan entri ini.
  final String idPelanggan;

  /// ID paket yang dibeli oleh pelanggan.
  final String idPaket;

  /// ID transaksi yang terkait dengan pembelian paket.
  final String? idTransaksi;

  /// Tanggal mulai aktifnya paket.
  final DateTime tanggalMulai;

  /// Tanggal berakhirnya paket.
  final DateTime tanggalBerakhir;

  /// Status pembayaran paket.
  final StatusPembayaranEnum status;

  /// Waktu terakhir data diperbarui.
  final DateTime? diperbarui;

  /// Status apakah entri ini sudah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu entri ini diarsipkan.
  final DateTime? diarsipkan;

  /// Konstruktor untuk `PelangganAktifModel`.
  PelangganAktifModel({
    final String? id,
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

  /// Membuat salinan dari `PelangganAktifModel` dengan beberapa nilai yang diubah.
  PelangganAktifModel copyWith({
    final String? id,
    final String? idPelanggan,
    final String? idPaket,
    final String? idTransaksi,
    final DateTime? tanggalMulai,
    final DateTime? tanggalBerakhir,
    final StatusPembayaranEnum? status,
    final DateTime? diperbarui,
    final bool? isDeleted,
    final DateTime? diarsipkan,
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

  /// Mengonversi `PelangganAktifModel` ke format JSON.
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

  /// Helper untuk mengurai nilai tanggal dari berbagai format.
  ///
  /// Menerima [Timestamp] dari Firestore, [int] millisecondsSinceEpoch dari SQLite,
  /// [DateTime], atau [String] format ISO-8601 (backward compatibility).
  static DateTime? _parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    // Menangani millisecondsSinceEpoch dari SQLite (INTEGER)
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    // Backward compatibility untuk data lama yang masih dalam format String
    if (value is String) return DateTime.tryParse(value);

    Log.warning('Format DateTime tidak dikenali: $value');
    return null;
  }

  /// Helper untuk mengurai nilai boolean dari berbagai format.
  static bool _parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';

    Log.warning('Format Boolean tidak dikenali, default ke false: $value');
    return false;
  }

  /// Membuat instance `PelangganAktifModel` dari data Map SQLite.
  factory PelangganAktifModel.fromSqlite(final Map<String, dynamic> map) {
    try {
      final tanggalMulai = _parseDateTime(map['tanggal_mulai']);
      final tanggalBerakhir = _parseDateTime(map['tanggal_berakhir']);

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
          (final e) => e.name == map['status'],
          orElse: () => StatusPembayaranEnum.lunas,
        ),
        diperbarui: _parseDateTime(map['diperbarui']),
        isDeleted: _parseBool(map['isDeleted']),
        diarsipkan: _parseDateTime(map['diarsipkan']),
      );

      Log.info('Data dimuat dari SQLite');
      return model;
    } catch (e, stack) {
      Log.error('Gagal parsing SQLite: $map', e: e, st: stack);
      rethrow;
    }
  }

  /// Membuat instance `PelangganAktifModel` dari data Map Firebase.
  factory PelangganAktifModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    try {
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
          (final e) => e.name == data['status'],
          orElse: () => StatusPembayaranEnum.lunas,
        ),
        diperbarui: _parseDateTime(data['diperbarui']),
        isDeleted: _parseBool(data['isDeleted']),
        diarsipkan: _parseDateTime(data['diarsipkan']),
      );

      Log.info('Data ditarik dari Firebase');
      return model;
    } catch (e, stack) {
      Log.error('Gagal parsing Firebase: $data', e: e, st: stack);
      rethrow;
    }
  }

  /// Mengonversi `PelangganAktifModel` ke format Map untuk disimpan di SQLite.
  ///
  /// Semua kolom DateTime sekarang disimpan sebagai millisecondsSinceEpoch (INTEGER).
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'id_pelanggan': idPelanggan,
      'id_paket': idPaket,
      'id_transaksi': idTransaksi,
      'tanggal_mulai': tanggalMulai.millisecondsSinceEpoch, // INTEGER
      'tanggal_berakhir': tanggalBerakhir.millisecondsSinceEpoch, // INTEGER
      'status': status.name,
      'diperbarui': diperbarui?.millisecondsSinceEpoch, // INTEGER
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch, // INTEGER
    };
  }

  /// Mengonversi `PelangganAktifModel` ke format Map untuk disimpan di Firebase.
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

    Log.info('Data toFirebase untuk Pelanggan $id siap dikirim.');
    return data;
  }
}
