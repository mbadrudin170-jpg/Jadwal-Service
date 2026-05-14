// path: lib/user/services/storage/local_storage_service.dart
// diubah: Menggunakan toSqlite dan fromSqlite untuk konsistensi data.
// diubah: Menambahkan tipe eksplisit untuk menghindari `avoid_dynamic_calls`.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart'; // diubah: menggunakan Log.dart untuk konsistensi
import 'package:wifi/shared/model/pelanggan_model.dart';

/// Service untuk mengelola penyimpanan data lokal menggunakan [SharedPreferences].
///
/// Menyediakan fungsi untuk menyimpan dan mengambil data seperti tema aplikasi,
/// daftar akun, dan status login pengguna.
class LocalStorageService {
  /// Instance dari [SharedPreferences] yang digunakan untuk penyimpanan.
  final SharedPreferences prefs;

  /// Membuat instance dari [LocalStorageService].
  LocalStorageService({required this.prefs}) {
    Log.info('[Inisialisasi Service] LocalStorageService dibuat.');
  }

  static const _kunciDaftarAkun = 'daftar_akun';
  static const _kunciPrefixModeTema = 'mode_tema_';
  static const _kunciUserId = 'userId';

  /// Menyimpan mode tema ([ThemeMode]) yang dipilih pengguna.
  ///
  /// Mode tema disimpan berdasarkan `userId` untuk personalisasi.
  Future<void> simpanModeTema(final ThemeMode mode) async {
    Log.info('[Simpan Tema] Menyimpan mode tema: $mode.');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      Log.warning(
        '[Simpan Tema] Pengguna belum login, penyimpanan mode tema dibatalkan.',
      );
      return;
    }
    await prefs.setString('$_kunciPrefixModeTema$userId', mode.toString());
    Log.info(
      '[Simpan Tema] Mode tema berhasil disimpan untuk user ID: $userId.',
    );
  }

  /// Mengambil mode tema yang disimpan untuk pengguna yang sedang login.
  ///
  /// Mengembalikan [ThemeMode.system] jika tidak ada pengguna yang login atau
  /// tidak ada mode tema yang disimpan.
  Future<ThemeMode> ambilModeTema() async {
    Log.info('[Ambil Tema] Mengambil mode tema.');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      Log.warning(
        '[Ambil Tema] Pengguna belum login, menggunakan ThemeMode.system.',
      );
      return ThemeMode.system;
    }

    final modeString = prefs.getString('$_kunciPrefixModeTema$userId');
    if (modeString == null) {
      Log.warning(
        '[Ambil Tema] Mode tema tidak ditemukan untuk user ID: $userId, menggunakan ThemeMode.system.',
      );
      return ThemeMode.system;
    }

    final themeMode = ThemeMode.values.firstWhere(
      (final e) => e.toString() == modeString,
      orElse: () => ThemeMode.system,
    );
    Log.info('[Ambil Tema] Mode tema ($themeMode) berhasil diambil.');
    return themeMode;
  }

  /// Menyimpan akun pelanggan ke dalam daftar akun di penyimpanan lokal.
  Future<void> simpanAkun(final PelangganModel pelanggan) async {
    Log.info('[Simpan Akun] Menyimpan akun: ${pelanggan.nama}.');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    // ditambah: Tipe eksplisit untuk menghindari dynamic calls.
    final List<dynamic> daftar =
        daftarJson != null ? jsonDecode(daftarJson) as List<dynamic> : [];

    // ditambah: Tipe eksplisit untuk menghindari dynamic calls.
    if (!daftar.cast<Map<String, dynamic>>().any((final p) => p['id'] == pelanggan.id)) {
      // diubah: Menggunakan toSqlite() untuk konsistensi
      daftar.add(pelanggan.toSqlite());
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftar));
      Log.info('[Simpan Akun] Akun ${pelanggan.nama} berhasil disimpan.');
    } else {
      Log.warning(
        '[Simpan Akun] Akun ${pelanggan.nama} sudah ada, tidak disimpan ulang.',
      );
    }
  }

  /// Mengambil daftar semua akun pelanggan yang tersimpan secara lokal.
  Future<List<PelangganModel>> ambilDaftarAkun() async {
    Log.info('[Ambil Daftar Akun] Mengambil semua akun dari local storage.');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      Log.warning('[Ambil Daftar Akun] Tidak ada daftar akun ditemukan.');
      return [];
    }

    // ditambah: Tipe eksplisit untuk menghindari dynamic calls.
    final List<dynamic> daftar = jsonDecode(daftarJson) as List<dynamic>;
    // diubah: Menggunakan fromSqlite() untuk deserialisasi
    final listAkun = daftar
        .cast<Map<String, dynamic>>()
        .map(PelangganModel.fromSqlite)
        .toList();
    Log.info('[Ambil Daftar Akun] Berhasil mengambil ${listAkun.length} akun.');
    return listAkun;
  }

  /// Menghapus akun pelanggan dari daftar berdasarkan `userId`.
  Future<void> hapusAkun(final String userId) async {
    Log.info('[Hapus Akun] Menghapus akun dengan ID: $userId.');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      Log.warning(
        '[Hapus Akun] Daftar akun tidak ditemukan, proses dibatalkan.',
      );
      return;
    }

    // ditambah: Tipe eksplisit untuk menghindari dynamic calls.
    final List<dynamic> daftar = jsonDecode(daftarJson) as List<dynamic>;
    final int jumlahSebelum = daftar.length;
    daftar.removeWhere((final p) => (p as Map<String, dynamic>)['id'] == userId);
    final int jumlahSesudah = daftar.length;

    if (jumlahSebelum > jumlahSesudah) {
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftar));
      Log.info('[Hapus Akun] Akun dengan ID $userId berhasil dihapus.');
    } else {
      Log.warning(
        '[Hapus Akun] Akun dengan ID $userId tidak ditemukan untuk dihapus.',
      );
    }
  }

  /// Menghapus akun yang saat ini sedang login.
  Future<void> hapusAkunSaatIni() async {
    Log.info('[Hapus Akun Saat Ini] Menghapus akun yang sedang login.');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      Log.warning('[Hapus Akun Saat Ini] Tidak ada pengguna yang login.');
      return;
    }
    await hapusAkun(userId);
    await prefs.remove(_kunciUserId); // Juga hapus userId yang menandakan login
    Log.info('[Hapus Akun Saat Ini] Akun yang login berhasil dihapus.');
  }

  /// Menghapus token (userId) yang menandakan status login.
  Future<void> hapusTokenLogin() async {
    Log.info('[Logout] Menghapus token login (userId).');
    await prefs.remove(_kunciUserId);
    Log.info('[Logout] Berhasil logout.');
  }

  /// Mengambil data [PelangganModel] untuk akun yang saat ini sedang login.
  Future<PelangganModel?> ambilAkunSaatIni() async {
    Log.info('[Ambil Akun Saat Ini] Mengambil akun yang sedang login.');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      Log.warning('[Ambil Akun Saat Ini] Tidak ada pengguna yang login.');
      return null;
    }

    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      Log.warning('[Ambil Akun Saat Ini] Daftar akun kosong.');
      return null;
    }

    // ditambah: Tipe eksplisit untuk menghindari dynamic calls.
    final List<dynamic> daftar = jsonDecode(daftarJson) as List<dynamic>;
    try {
      // ditambah: Tipe eksplisit untuk menghindari dynamic calls.
      final Map<String, dynamic> akunJson = daftar
          .cast<Map<String, dynamic>>()
          .firstWhere((final p) => p['id'] == userId);
      // diubah: Menggunakan fromSqlite() untuk deserialisasi
      final pelanggan = PelangganModel.fromSqlite(akunJson);
      Log.info(
        '[Ambil Akun Saat Ini] Akun ${pelanggan.nama} berhasil diambil.',
      );
      return pelanggan;
    } on Exception {
      Log.warning(
        '[Ambil Akun Saat Ini] Akun dengan ID $userId tidak ditemukan dalam daftar.',
      );
      return null;
    }
  }
}
