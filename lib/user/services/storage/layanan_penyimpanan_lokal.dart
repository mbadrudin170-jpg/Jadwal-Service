// path: lib/user/services/storage/layanan_penyimpanan_lokal.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';

class LayananPenyimpananLokal {
  final SharedPreferences prefs;

  LayananPenyimpananLokal({required this.prefs}) {
    Log.info('[Inisialisasi Service] LayananPenyimpananLokal dibuat.');
  }

  static const _kunciDaftarAkun = 'daftar_akun';
  static const _kunciAwalanModeTema = 'mode_tema_';
  static const _kunciIdPengguna = 'userId';

  Future<void> simpanModeTema(ThemeMode mode) async {
    Log.info('[Simpan Tema] Menyimpan mode tema: $mode.');
    await prefs.setString(_kunciAwalanModeTema, mode.toString());
    Log.info('[Simpan Tema] Mode tema berhasil disimpan secara global.');
  }

  Future<ThemeMode> ambilModeTema() async {
    try {
      Log.info('[Ambil Tema] Mengambil mode tema global dari penyimpanan.');
      final modeString = prefs.getString(_kunciAwalanModeTema);
      final themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () {
          Log.warning(
            '[Ambil Tema] Tema global tidak ada atau tidak valid. Fallback ke tema sistem.',
          );
          return ThemeMode.light;
        },
      );

      Log.info('[Ambil Tema] Mode tema ($themeMode) berhasil diambil.');
      return themeMode;
    } catch (e, st) {
      Log.error('[Ambil Tema] Gagal mengambil mode tema.', e: e, s: st);
      return ThemeMode.system;
    }
  }

  Future<void> simpanAkun(PelangganModel pelanggan) async {
    Log.info(
      '[Simpan Akun] Menyimpan atau memperbarui akun: ${pelanggan.nama}.',
    );
    final daftarAkunJson = prefs.getString(_kunciDaftarAkun);
    final List<dynamic> daftarAkun;
    if (daftarAkunJson != null) {
      daftarAkun = jsonDecode(daftarAkunJson) as List<dynamic>;
    } else {
      daftarAkun = [];
    }

    final indeksAkunYangAda = daftarAkun
        .cast<Map<String, dynamic>>()
        .indexWhere((p) => p['id'] == pelanggan.id);

    if (indeksAkunYangAda != -1) {
      daftarAkun[indeksAkunYangAda] = pelanggan.toSqlite();
      Log.info('[Simpan Akun] Akun ${pelanggan.nama} berhasil diperbarui.');
    } else {
      daftarAkun.add(pelanggan.toSqlite());
      Log.info('[Simpan Akun] Akun ${pelanggan.nama} berhasil ditambahkan.');
    }

    await prefs.setString(_kunciDaftarAkun, jsonEncode(daftarAkun));
  }

  Future<void> simpanAkunSaatIni(PelangganModel pelanggan) async {
    Log.info(
      '[Simpan Akun Aktif] Mengatur ${pelanggan.nama} sebagai akun aktif.',
    );
    await hapusTokenLogin();
    await prefs.setString(_kunciIdPengguna, pelanggan.id);
    await simpanAkun(pelanggan);
    Log.info(
      '[Simpan Akun Aktif] Akun ${pelanggan.nama} berhasil diatur sebagai akun aktif.',
    );
  }

  Future<List<PelangganModel>> ambilDaftarAkun() async {
    Log.info(
      '[Ambil Daftar Akun] Mengambil semua akun dari penyimpanan lokal.',
    );
    final daftarAkunJson = prefs.getString(_kunciDaftarAkun);
    if (daftarAkunJson == null) {
      Log.warning('[Ambil Daftar Akun] Tidak ada daftar akun ditemukan.');
      return [];
    }
    final daftarAkun = jsonDecode(daftarAkunJson) as List<dynamic>;
    final listAkun = daftarAkun
        .cast<Map<String, dynamic>>()
        .map(PelangganModel.fromSqlite)
        .toList();
    Log.info('[Ambil Daftar Akun] Berhasil mengambil ${listAkun.length} akun.');
    return listAkun;
  }

  Future<void> hapusAkun(String idPengguna) async {
    Log.info('[Hapus Akun] Menghapus akun dengan ID: $idPengguna.');
    final daftarAkunJson = prefs.getString(_kunciDaftarAkun);
    if (daftarAkunJson == null) {
      Log.warning(
        '[Hapus Akun] Daftar akun tidak ditemukan, proses dibatalkan.',
      );
      return;
    }

    final daftarAkun = jsonDecode(daftarAkunJson) as List<dynamic>;
    final hitungSebelum = daftarAkun.length;
    daftarAkun.removeWhere(
      (p) => (p as Map<String, dynamic>)['id'] == idPengguna,
    );
    final hitungSesudah = daftarAkun.length;
    if (hitungSebelum > hitungSesudah) {
      await prefs.setString(_kunciDaftarAkun, jsonEncode(daftarAkun));
      Log.info('[Hapus Akun] Akun dengan ID $idPengguna berhasil dihapus.');
    } else {
      Log.warning(
        '[Hapus Akun] Akun dengan ID $idPengguna tidak ditemukan untuk dihapus.',
      );
    }
  }

  Future<void> hapusAkunSaatIni() async {
    Log.info('[Hapus Akun Saat Ini] Menghapus akun yang sedang login.');
    final idPengguna = prefs.getString(_kunciIdPengguna);
    if (idPengguna == null) {
      Log.warning('[Hapus Akun Saat Ini] Tidak ada pengguna yang login.');
      return;
    }
    await hapusAkun(idPengguna);
    await prefs.remove(_kunciIdPengguna);
    Log.info('[Hapus Akun Saat Ini] Akun yang login berhasil dihapus.');
  }

  Future<void> hapusTokenLogin() async {
    Log.info('[Logout] Menghapus token login (idPengguna).');
    await prefs.remove(_kunciIdPengguna);
    Log.info('[Logout] Berhasil logout.');
  }

  Future<PelangganModel?> ambilAkunLogin() async {
    Log.info('[Ambil Akun Saat Ini] Mengambil akun yang sedang login.');
    final idPengguna = prefs.getString(_kunciIdPengguna);
    if (idPengguna == null) {
      Log.warning('[Ambil Akun Saat Ini] Tidak ada pengguna yang login.');
      return null;
    }

    final daftarAkunJson = prefs.getString(_kunciDaftarAkun);
    if (daftarAkunJson == null) {
      Log.warning('[Ambil Akun Saat Ini] Daftar akun kosong.');
      return null;
    }

    final daftarAkun = jsonDecode(daftarAkunJson) as List<dynamic>;
    try {
      final akunJson = daftarAkun.cast<Map<String, dynamic>>().firstWhere(
        (p) => p['id'] == idPengguna,
        orElse: () => {},
      );
      if (akunJson.isEmpty) {
        Log.warning(
          '[Ambil Akun Saat Ini] Akun dengan ID $idPengguna tidak ada di daftar riwayat lokal.',
        );
        return null;
      }
      final pelanggan = PelangganModel.fromSqlite(akunJson);
      Log.info(
        '[Ambil Akun Saat Ini] Akun ${pelanggan.nama} berhasil diambil.',
      );
      return pelanggan;
    } catch (e, st) {
      Log.warning(
        '[Ambil Akun Saat Ini] Akun dengan ID $idPengguna tidak ditemukan dalam daftar.',
        {e, st},
      );
      return null;
    }
  }

  Future<void> hapusSemuaData() async {
    Log.info('[Hapus Semua Data] Menghapus semua data dari SharedPreferences.');
    await prefs.clear();
    Log.info('[Hapus Semua Data] Semua data berhasil dihapus.');
  }
}
