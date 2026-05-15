// path: lib/shared/model/pelanggan_model.dart
// diubah: Memperbaiki toFirebase agar tidak selalu mengirim ServerTimestamp.
// diubah: Mengganti nama fungsi helper internal dan menyesuaikan konversi tanggal untuk SQLite.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

/// Model yang merepresentasikan data seorang pelanggan.
class PelangganModel implements MemilikiId {
  /// ID unik dari pelanggan, biasanya dihasilkan oleh UUID.
  @override
  final String id;

  /// Nama lengkap pelanggan.
  final String nama;

  /// Nomor telepon pelanggan.
  final String telepon;

  /// Alamat tempat tinggal pelanggan.
  final String alamat;

  /// Kata sandi pelanggan untuk login.
  final String password;

  /// Alamat MAC perangkat pelanggan, bersifat opsional.
  final String macAddress;

  /// Penanda apakah pelanggan ini telah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu terakhir data pelanggan ini diperbarui.
  final DateTime? diperbarui;

  /// Waktu kapan data pelanggan ini diarsipkan.
  final DateTime? diarsipkan;

  /// Konstruktor untuk membuat instance [PelangganModel].
  ///
  /// Jika [id] tidak disediakan, ID baru akan dibuat menggunakan UUID v4.
  PelangganModel({
    final String? id,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.diperbarui,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari instance [PelangganModel] dengan beberapa nilai yang diubah.
  PelangganModel copyWith({
    final String? id,
    final String? nama,
    final String? telepon,
    final String? alamat,
    final String? password,
    final String? macAddress,
    final bool? isDeleted,
    final DateTime? diperbarui,
    final DateTime? diarsipkan,
  }) {
    return PelangganModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      telepon: telepon ?? this.telepon,
      alamat: alamat ?? this.alamat,
      password: password ?? this.password,
      macAddress: macAddress ?? this.macAddress,
      isDeleted: isDeleted ?? this.isDeleted,
      diperbarui: diperbarui ?? this.diperbarui,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  /// Mengonversi instance [PelangganModel] menjadi Map JSON.
  /// Kata sandi disembunyikan untuk keamanan.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': '[TERSEMBUNYI]',
      'macAddress': macAddress,
      'isDeleted': isDeleted,
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  /// Helper untuk mengubah nilai dinamis menjadi DateTime.
  static DateTime? parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// Helper untuk mengubah nilai dinamis menjadi boolean dengan aman.
  static bool parseBool(final dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Factory constructor untuk membuat [PelangganModel] dari data SQLite (Map).
  factory PelangganModel.fromSqlite(final Map<String, dynamic> map) {
    return PelangganModel(
      id: map['id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      telepon: map['telepon'] as String? ?? '',
      alamat: map['alamat'] as String? ?? '',
      password: map['password'] as String? ?? '',
      macAddress: map['mac_address'] as String? ?? '',
      isDeleted: parseBool(map['isDeleted']),
      diperbarui: parseDateTime(map['diperbarui']),
      diarsipkan: parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengubah instance [PelangganModel] menjadi Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'isDeleted': isDeleted ? 1 : 0,
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor untuk membuat [PelangganModel] dari data Firebase.
  factory PelangganModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return PelangganModel(
      id: id,
      nama: data['nama'] as String? ?? '',
      telepon: data['telepon'] as String? ?? '',
      alamat: data['alamat'] as String? ?? '',
      password: data['password'] as String? ?? '',
      macAddress: data['mac_address'] as String? ?? '',
      isDeleted: parseBool(data['isDeleted']),
      diperbarui: parseDateTime(data['diperbarui']),
      diarsipkan: parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengubah instance [PelangganModel] menjadi Map untuk disimpan di Firebase.
  /// ID tidak disertakan karena digunakan sebagai ID dokumen.
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'isDeleted': isDeleted,
      'diperbarui': diperbarui != null
          ? Timestamp.fromDate(diperbarui!)
          : FieldValue.serverTimestamp(),
      'diarsipkan': diarsipkan != null ? Timestamp.fromDate(diarsipkan!) : null,
    };
    return data;
  }
}
