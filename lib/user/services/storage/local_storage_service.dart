// path: lib/user/services/storage/local_storage_service.dart
// diubah: Menggunakan toSqlite dan fromSqlite untuk konsistensi data.
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';

class LocalStorageService {
  final SharedPreferences prefs;

  LocalStorageService({required this.prefs}) {
    log('[Inisialisasi Service] ✅ LocalStorageService dibuat.',
        name: 'local_storage_service.dart');
  }

  static const _kunciDaftarAkun = 'daftar_akun';
  static const _kunciPrefixModeTema = 'mode_tema_';
  static const _kunciUserId = 'userId';

  Future<void> simpanModeTema(ThemeMode mode) async {
    log('[Simpan Tema] ⚙️ Menyimpan mode tema: $mode.',
        name: 'local_storage_service.dart');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      log('[Simpan Tema] 🤷 Pengguna belum login, penyimpanan mode tema dibatalkan.',
          name: 'local_storage_service.dart');
      return;
    }
    await prefs.setString('$_kunciPrefixModeTema$userId', mode.toString());
    log('[Simpan Tema] ✅ Mode tema berhasil disimpan untuk user ID: $userId.',
        name: 'local_storage_service.dart');
  }

  Future<ThemeMode> ambilModeTema() async {
    log('[Ambil Tema] ⚙️ Mengambil mode tema.',
        name: 'local_storage_service.dart');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      log('[Ambil Tema] 🤷 Pengguna belum login, menggunakan ThemeMode.system.',
          name: 'local_storage_service.dart');
      return ThemeMode.system;
    }

    final modeString = prefs.getString('$_kunciPrefixModeTema$userId');
    if (modeString == null) {
      log('[Ambil Tema] 🤷 Mode tema tidak ditemukan untuk user ID: $userId, menggunakan ThemeMode.system.',
          name: 'local_storage_service.dart');
      return ThemeMode.system;
    }

    final themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () => ThemeMode.system);
    log('[Ambil Tema] ✅ Mode tema ($themeMode) berhasil diambil.',
        name: 'local_storage_service.dart');
    return themeMode;
  }

  Future<void> simpanAkun(PelangganModel pelanggan) async {
    log('[Simpan Akun] ⚙️ Menyimpan akun: ${pelanggan.nama}.',
        name: 'local_storage_service.dart');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    List<dynamic> daftar = daftarJson != null ? jsonDecode(daftarJson) : [];

    if (!daftar.any((p) => p['id'] == pelanggan.id)) {
      // diubah: Menggunakan toSqlite() untuk konsistensi
      daftar.add(pelanggan.toSqlite());
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftar));
      log('[Simpan Akun] ✅ Akun ${pelanggan.nama} berhasil disimpan.',
          name: 'local_storage_service.dart');
    } else {
      log('[Simpan Akun] 🤷 Akun ${pelanggan.nama} sudah ada, tidak disimpan ulang.',
          name: 'local_storage_service.dart');
    }
  }

  Future<List<PelangganModel>> ambilDaftarAkun() async {
    log('[Ambil Daftar Akun] ⚙️ Mengambil semua akun dari local storage.',
        name: 'local_storage_service.dart');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      log('[Ambil Daftar Akun] 🤷 Tidak ada daftar akun ditemukan.',
          name: 'local_storage_service.dart');
      return [];
    }

    final List<dynamic> daftar = jsonDecode(daftarJson);
    // diubah: Menggunakan fromSqlite() untuk deserialisasi
    final listAkun =
        daftar.map((json) => PelangganModel.fromSqlite(json)).toList();
    log('[Ambil Daftar Akun] ✅ Berhasil mengambil ${listAkun.length} akun.',
        name: 'local_storage_service.dart');
    return listAkun;
  }

  Future<void> hapusAkun(String userId) async {
    log('[Hapus Akun] 🗑️ Menghapus akun dengan ID: $userId.',
        name: 'local_storage_service.dart');
    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      log('[Hapus Akun] 🤷 Daftar akun tidak ditemukan, proses dibatalkan.',
          name: 'local_storage_service.dart');
      return;
    }

    List<dynamic> daftar = jsonDecode(daftarJson);
    int jumlahSebelum = daftar.length;
    daftar.removeWhere((p) => p['id'] == userId);
    int jumlahSesudah = daftar.length;

    if (jumlahSebelum > jumlahSesudah) {
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftar));
      log('[Hapus Akun] ✅ Akun dengan ID $userId berhasil dihapus.',
          name: 'local_storage_service.dart');
    } else {
      log('[Hapus Akun] 🤷 Akun dengan ID $userId tidak ditemukan untuk dihapus.',
          name: 'local_storage_service.dart');
    }
  }

  Future<void> hapusAkunSaatIni() async {
    log('[Hapus Akun Saat Ini] 🗑️ Menghapus akun yang sedang login.',
        name: 'local_storage_service.dart');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      log('[Hapus Akun Saat Ini] 🤷 Tidak ada pengguna yang login.',
          name: 'local_storage_service.dart');
      return;
    }
    await hapusAkun(userId);
    await prefs.remove(_kunciUserId); // Juga hapus userId yang menandakan login
    log('[Hapus Akun Saat Ini] ✅ Akun yang login berhasil dihapus.',
        name: 'local_storage_service.dart');
  }

  Future<void> hapusTokenLogin() async {
    log('[Logout] 🔑 Menghapus token login (userId).',
        name: 'local_storage_service.dart');
    await prefs.remove(_kunciUserId);
    log('[Logout] ✅ Berhasil logout.', name: 'local_storage_service.dart');
  }

  Future<PelangganModel?> ambilAkunSaatIni() async {
    log('[Ambil Akun Saat Ini] ⚙️ Mengambil akun yang sedang login.',
        name: 'local_storage_service.dart');
    final userId = prefs.getString(_kunciUserId);
    if (userId == null) {
      log('[Ambil Akun Saat Ini] 🤷 Tidak ada pengguna yang login.',
          name: 'local_storage_service.dart');
      return null;
    }

    final daftarJson = prefs.getString(_kunciDaftarAkun);
    if (daftarJson == null) {
      log('[Ambil Akun Saat Ini] 🤷 Daftar akun kosong.',
          name: 'local_storage_service.dart');
      return null;
    }

    final List<dynamic> daftar = jsonDecode(daftarJson);
    try {
      final akunJson = daftar
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['id'] == userId);
      // diubah: Menggunakan fromSqlite() untuk deserialisasi
      final pelanggan = PelangganModel.fromSqlite(akunJson);
      log('[Ambil Akun Saat Ini] ✅ Akun ${pelanggan.nama} berhasil diambil.',
          name: 'local_storage_service.dart');
      return pelanggan;
    } catch (e) {
      log('[Ambil Akun Saat Ini] 🤷 Akun dengan ID $userId tidak ditemukan dalam daftar.',
          name: 'local_storage_service.dart');
      return null;
    }
  }
}
