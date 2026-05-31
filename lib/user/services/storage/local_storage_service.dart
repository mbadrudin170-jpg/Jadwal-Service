// path: lib/user/services/storage/local_storage_service.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - Digunakan oleh halaman user untuk menyimpan data lokal.
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/customer_model.dart (CustomerModel)
//   - lib/shared/debug/log.dart (Log)

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/customer_model.dart';

class LocalStorageService {
  /// Instance dari [SharedPreferences] yang digunakan untuk penyimpanan.
  final SharedPreferences prefs;

  /// Membuat instance dari [LocalStorageService].
  LocalStorageService({required this.prefs}) {
    Log.info('[Inisialisasi Service] LocalStorageService dibuat.');
  }

  static const _accountListKey = 'daftar_akun';
  static const _themeModePrefixKey = 'mode_tema_';
  static const _userIdKey = 'userId';

  /// Menyimpan mode tema ([ThemeMode]) yang dipilih pengguna.
  ///
  /// Mode tema disimpan berdasarkan `userId` untuk personalisasi jika ada.
  /// Jika tidak, akan disimpan secara global (untuk admin app).
  Future<void> saveThemeMode(final ThemeMode mode) async {
    Log.info('[Simpan Tema] Menyimpan mode tema: $mode.');
    await prefs.setString(_themeModePrefixKey, mode.toString());
    Log.info('[Simpan Tema] Mode tema berhasil disimpan secara global.');
  }

// Versi yang lebih bersih dan ringkas
  Future<ThemeMode> getThemeMode() async {
    try {
      Log.info('[Ambil Tema] Mengambil mode tema global dari penyimpanan.');
      // Inisialisasi SharedPreferences di dalam try-catch
      final prefs = await SharedPreferences.getInstance();

      // Langsung ambil string mode tema global
      final modeString = prefs.getString(_themeModePrefixKey);

      // Gunakan satu blok untuk validasi (menangani null dan string tidak valid)
      final themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == modeString,
        orElse: () {
          // Beri log jika fallback terjadi
          Log.warning(
            '[Ambil Tema] Tema global tidak ada atau tidak valid. Fallback ke tema sistem.',
          );
          return ThemeMode.system;
        },
      );

      Log.info('[Ambil Tema] Mode tema ($themeMode) berhasil diambil.');
      return themeMode;
    } catch (e, st) {
      Log.error('[Ambil Tema] Gagal mengambil mode tema.', e: e, st: st);
      return ThemeMode.system; // Fallback jika ada error lain
    }
  }

  ///
  /// Jika akun sudah ada, datanya akan diperbarui.
  /// Jika belum, akun baru akan ditambahkan ke daftar.
  Future<void> saveAccount(final CustomerModel customer) async {
    Log.info(
        '[Simpan Akun] Menyimpan atau memperbarui akun: ${customer.name}.');
    final accountListJson = prefs.getString(_accountListKey);
    final List<dynamic> accountList = accountListJson != null
        ? jsonDecode(accountListJson) as List<dynamic>
        : [];

    final existingAccountIndex = accountList
        .cast<Map<String, dynamic>>()
        .indexWhere((final p) => p['id'] == customer.id);

    if (existingAccountIndex != -1) {
      // Akun sudah ada, perbarui datanya
      accountList[existingAccountIndex] = customer.toSqlite();
      Log.info('[Simpan Akun] Akun ${customer.name} berhasil diperbarui.');
    } else {
      // Akun belum ada, tambahkan baru
      accountList.add(customer.toSqlite());
      Log.info('[Simpan Akun] Akun ${customer.name} berhasil ditambahkan.');
    }

    await prefs.setString(_accountListKey, jsonEncode(accountList));
  }

  ///
  /// Metode ini juga akan memperbarui daftar akun yang ada dengan data terbaru dari
  /// customer yang dipilih, serta menyetel token ID pengguna yang aktif.
  Future<void> saveCurrentAccount(final CustomerModel customer) async {
    Log.info(
        '[Simpan Akun Aktif] Mengatur ${customer.name} sebagai akun aktif.');
    // Setel token ID pengguna yang aktif
    await prefs.setString(_userIdKey, customer.id);
    // Simpan atau perbarui detail akun di daftar riwayat
    await saveAccount(customer);
    Log.info(
      '[Simpan Akun Aktif] Akun ${customer.name} berhasil diatur sebagai akun aktif.',
    );
  }

  /// Mengambil daftar semua akun pelanggan yang tersimpan secara lokal.
  Future<List<CustomerModel>> getAccountList() async {
    Log.info('[Ambil Daftar Akun] Mengambil semua akun dari local storage.');
    final accountListJson = prefs.getString(_accountListKey);
    if (accountListJson == null) {
      Log.warning('[Ambil Daftar Akun] Tidak ada daftar akun ditemukan.');
      return [];
    }

    final List<dynamic> accountList =
        jsonDecode(accountListJson) as List<dynamic>;
    final listAccount = accountList
        .cast<Map<String, dynamic>>()
        .map(CustomerModel.fromSqlite)
        .toList();
    Log.info(
        '[Ambil Daftar Akun] Berhasil mengambil ${listAccount.length} akun.');
    return listAccount;
  }

  /// Menghapus akun pelanggan dari daftar berdasarkan `userId`.
  Future<void> deleteAccount(final String userId) async {
    Log.info('[Hapus Akun] Menghapus akun dengan ID: $userId.');
    final accountListJson = prefs.getString(_accountListKey);
    if (accountListJson == null) {
      Log.warning(
        '[Hapus Akun] Daftar akun tidak ditemukan, proses dibatalkan.',
      );
      return;
    }

    final List<dynamic> accountList =
        jsonDecode(accountListJson) as List<dynamic>;
    final int countBefore = accountList.length;
    accountList.removeWhere((p) => (p as Map<String, dynamic>)['id'] == userId);
    final int countAfter = accountList.length;
    if (countBefore > countAfter) {
      await prefs.setString(_accountListKey, jsonEncode(accountList));
      Log.info('[Hapus Akun] Akun dengan ID $userId berhasil dihapus.');
    } else {
      Log.warning(
        '[Hapus Akun] Akun dengan ID $userId tidak ditemukan untuk dihapus.',
      );
    }
  }

  /// Menghapus akun yang saat ini sedang login.
  Future<void> deleteCurrentAccount() async {
    Log.info('[Hapus Akun Saat Ini] Menghapus akun yang sedang login.');
    final userId = prefs.getString(_userIdKey);
    if (userId == null) {
      Log.warning('[Hapus Akun Saat Ini] Tidak ada pengguna yang login.');
      return;
    }
    await deleteAccount(userId);
    await prefs.remove(_userIdKey);
    Log.info('[Hapus Akun Saat Ini] Akun yang login berhasil dihapus.');
  }

  /// Menghapus token (userId) yang menandakan status login.
  Future<void> deleteLoginToken() async {
    Log.info('[Logout] Menghapus token login (userId).');
    await prefs.remove(_userIdKey);
    Log.info('[Logout] Berhasil logout.');
  }

  /// Mengambil data [CustomerModel] untuk akun yang saat ini sedang login.
  Future<CustomerModel?> getCurrentAccount() async {
    Log.info('[Ambil Akun Saat Ini] Mengambil akun yang sedang login.');
    final userId = prefs.getString(_userIdKey);
    if (userId == null) {
      Log.warning('[Ambil Akun Saat Ini] Tidak ada pengguna yang login.');
      return null;
    }

    final accountListJson = prefs.getString(_accountListKey);
    if (accountListJson == null) {
      Log.warning('[Ambil Akun Saat Ini] Daftar akun kosong.');
      return null;
    }

    final List<dynamic> accountList =
        jsonDecode(accountListJson) as List<dynamic>;
    try {
      final Map<String, dynamic> accountJson = accountList
          .cast<Map<String, dynamic>>()
          .firstWhere((final p) => p['id'] == userId);
      final customer = CustomerModel.fromSqlite(accountJson);
      Log.info(
        '[Ambil Akun Saat Ini] Akun ${customer.name} berhasil diambil.',
      );
      return customer;
    } on Exception {
      Log.warning(
        '[Ambil Akun Saat Ini] Akun dengan ID $userId tidak ditemukan dalam daftar.',
      );
      return null;
    }
  }
}
