// path: lib/model/pelanggan_model.dart
// diubah: Logika Firebase disesuaikan dengan standar Timestamp.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PelangganModel {
  final String id;
  final String nama;
  final String telepon;
  final String alamat;
  final String password;
  final String macAddress;

  final bool isDeleted;
  final DateTime? diperbarui;
  final DateTime? diarsipkan;

  PelangganModel({
    String? id,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.password,
    this.macAddress = '',
    this.isDeleted = false,
    this.diperbarui,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  // =========================
  // COPY WITH
  // =========================
  PelangganModel copyWith({
    String? id,
    String? nama,
    String? telepon,
    String? alamat,
    String? password,
    String? macAddress,
    bool? isDeleted,
    DateTime? diperbarui,
    DateTime? diarsipkan,
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

  // =========================
  // JSON SERIALIZATION (FOR LOGGING)
  // ditambahkan: karena butuh serialisasi untuk logging
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': '[TERSEMBUNYI]', // Keamanan: Jangan log password
      'macAddress': macAddress,
      'isDeleted': isDeleted,
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // =========================
  // PARSER UTIL
  // =========================

  // diubah: Menambahkan penanganan untuk tipe data Timestamp dari Firebase.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  // =========================
  // SQLITE
  // =========================

  factory PelangganModel.fromSqlite(Map<String, dynamic> map) {
    return PelangganModel(
      id: map['id'] ?? '',
      nama: map['nama'] ?? '',
      telepon: map['telepon'] ?? '',
      alamat: map['alamat'] ?? '',
      password: map['password'] ?? '',
      macAddress: map['mac_address'] ?? '',
      isDeleted: _parseBool(map['isDeleted']),
      diperbarui: _parseDateTime(map['diperbarui']),
      diarsipkan: _parseDateTime(map['diarsipkan']),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'isDeleted': isDeleted ? 1 : 0,
      'diperbarui': diperbarui?.toIso8601String(),
      'diarsipkan': diarsipkan?.toIso8601String(),
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory PelangganModel.fromFirebase(String id, Map<String, dynamic> data) {
    return PelangganModel(
      id: id,
      nama: data['nama'] ?? '',
      telepon: data['telepon'] ?? '',
      alamat: data['alamat'] ?? '',
      password: data['password'] ?? '',
      macAddress: data['mac_address'] ?? '',
      isDeleted: _parseBool(data['isDeleted']),
      diperbarui: _parseDateTime(data['diperbarui']),
      diarsipkan: _parseDateTime(data['diarsipkan']),
    );
  }

  // diubah: Menggunakan FieldValue.serverTimestamp() dan menyertakan ID.
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'password': password,
      'mac_address': macAddress,
      'isDeleted': isDeleted,
      'diperbarui': FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }
    return data;
  }
}
