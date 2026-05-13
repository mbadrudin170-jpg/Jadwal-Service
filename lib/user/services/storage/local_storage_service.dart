// path: lib/user/services/storage/local_storage_service.dart
// diubah: Menggunakan toSqlite dan fromSqlite untuk konsistensi data.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart'; // diubah: menggunakan Log.dart untuk konsistensi

class LocalStorageService {
  final SharedPreferences prefs;

  LocalStorageService({required this.prefs}) {
    Log.info('[Inisialisasi Service] LocalStorageService dibuat.');
  }

  static const _kunciDaftarAkun = 'daftar_akun';
  static const _kunciPrefixModeTema = 'mode_tema_';
  static const _kunciUserId = 'userId';

  Future<void> simpanModeTema(ThemeMode mode) async {
    Log.info('[Simpan Tema] Menyimpan mode tema: $mode.');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      Log.warning(
          '[Simpan Tema] Pengguna belum login, penyimpanan mode tema dibatalkan.');
      return;
    }
    await prefs.setString('$_kunciPrefixModeTema$userId', mode.toString());
    Log.info(
        '[Simpan Tema] Mode tema berhasil disimpan untuk user ID: $userId.');
  }

  Future<ThemeMode> ambilModeTema() async {
    Log.info('[Ambil Tema] Mengambil mode tema.');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      Log.warning(
          '[Ambil Tema] Pengguna belum login, menggunakan ThemeMode.system.');
      return ThemeMode.system;
    }

    final modeString = prefs.getString('$_kunciPrefixModeTema$userId');
    if (modeString == null) {
      Log.warning(
          '[Ambil Tema] Mode tema tidak ditemukan untuk user ID: $userId, menggunakan ThemeMode.system.');
      return ThemeMode.system;
    }

    final themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () => ThemeMode.system);
    Log.info('[Ambil Tema] Mode tema ($themeMode) berhasil diambil.');
    return themeMode;
  }

  Future<void> simpanAkun(PelangganModel pelanggan) async {
    Log.info('[Simpan Akun] Menyimpan akun: ${pelanggan.nama}.');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    List<dynamic> daftar =
        daftarJson != null ? jsonDecode(daftarJson) as List<dynamic> : [];

    if (!daftar.any((p) => p['id'] == pelanggan.id)) {
      // diubah: Menggunakan toSqlite() untuk konsistensi
      daftar.add(pelanggan.toSqlite());
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftar));
      Log.info('[Simpan Akun] Akun ${pelanggan.nama} berhasil disimpan.');
    } else {
      Log.warning(
          '[Simpan Akun] Akun ${pelanggan.nama} sudah ada, tidak disimpan ulang.');
    }
  }

  Future<List<PelangganModel>> ambilDaftarAkun() async {
    Log.info('[Ambil Daftar Akun] Mengambil semua akun dari local storage.');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      Log.warning('[Ambil Daftar Akun] Tidak ada daftar akun ditemukan.');
      return [];
    }

    final List<dynamic> daftar = jsonDecode(daftarJson) as List<dynamic>;
    // diubah: Menggunakan fromSqlite() untuk deserialisasi
    final listAkun = daftar
        .cast<Map<String, dynamic>>()
        .map((json) => PelangganModel.fromSqlite(json))
        .toList();
    Log.info('[Ambil Daftar Akun] Berhasil mengambil ${listAkun.length} akun.');
    return listAkun;
  }

  Future<void> hapusAkun(String userId) async {
    Log.info('[Hapus Akun] Menghapus akun dengan ID: $userId.');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      Log.warning(
          '[Hapus Akun] Daftar akun tidak ditemukan, proses dibatalkan.');
      return;
    }

    List<dynamic> daftar = jsonDecode(daftarJson) as List<dynamic>;
    int jumlahSebelum = daftar.length;
    daftar.removeWhere((p) => p['id'] == userId);
    int jumlahSesudah = daftar.length;

    if (jumlahSebelum > jumlahSesudah) {
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftar));
      Log.info('[Hapus Akun] Akun dengan ID $userId berhasil dihapus.');
    } else {
      Log.warning(
          '[Hapus Akun] Akun dengan ID $userId tidak ditemukan untuk dihapus.');
    }
  }

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

  Future<void> hapusTokenLogin() async {
    Log.info('[Logout] Menghapus token login (userId).');
    await prefs.remove(_kunciUserId);
    Log.info('[Logout] Berhasil logout.');
  }

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

    final List<dynamic> daftar = jsonDecode(daftarJson) as List<dynamic>;
    try {
      final akunJson = daftar
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['id'] == userId);
      // diubah: Menggunakan fromSqlite() untuk deserialisasi
      final pelanggan = PelangganModel.fromSqlite(akunJson);
      Log.info(
          '[Ambil Akun Saat Ini] Akun ${pelanggan.nama} berhasil diambil.');
      return pelanggan;
    } catch (e) {
      Log.warning(
          '[Ambil Akun Saat Ini] Akun dengan ID $userId tidak ditemukan dalam daftar.');
      return null;
    }
  }
}
