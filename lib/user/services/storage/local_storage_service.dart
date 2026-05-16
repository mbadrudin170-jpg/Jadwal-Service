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

  static const _accountListKey = 'daftar_akun';
  static const _themeModePrefixKey = 'mode_tema_';
  static const _userIdKey = 'userId';

  /// Menyimpan mode tema ([ThemeMode]) yang dipilih pengguna.
  ///
  /// Mode tema disimpan berdasarkan `userId` untuk personalisasi.
  Future<void> saveThemeMode(final ThemeMode mode) async {
    Log.info('[Simpan Tema] Menyimpan mode tema: $mode.');
    final userId = prefs.getString(_userIdKey);
    if (userId == null) {
      Log.warning(
        '[Simpan Tema] Pengguna belum login, penyimpanan mode tema dibatalkan.',
      );
      return;
    }
    await prefs.setString('$_themeModePrefixKey$userId', mode.toString());
    Log.info(
      '[Simpan Tema] Mode tema berhasil disimpan untuk user ID: $userId.',
    );
  }

  /// Mengambil mode tema yang disimpan untuk pengguna yang sedang login.
  ///
  /// Mengembalikan [ThemeMode.system] jika tidak ada pengguna yang login atau
  /// tidak ada mode tema yang disimpan.
  Future<ThemeMode> getThemeMode() async {
    Log.info('[Ambil Tema] Mengambil mode tema.');
    final userId = prefs.getString(_userIdKey);
    if (userId == null) {
      Log.warning(
        '[Ambil Tema] Pengguna belum login, menggunakan ThemeMode.system.',
      );
      return ThemeMode.system;
    }

    final modeString = prefs.getString('$_themeModePrefixKey$userId');
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
  Future<void> saveAccount(final CustomerModel customer) async {
    Log.info('[Simpan Akun] Menyimpan akun: ${customer.name}.');
    final accountListJson = prefs.getString(_accountListKey);
    final List<dynamic> accountList = accountListJson != null
        ? jsonDecode(accountListJson) as List<dynamic>
        : [];

    if (!accountList
        .cast<Map<String, dynamic>>()
        .any((final p) => p['id'] == customer.id)) {
      accountList.add(customer.toSqlite());
      await prefs.setString(_accountListKey, jsonEncode(accountList));
      Log.info('[Simpan Akun] Akun ${customer.name} berhasil disimpan.');
    } else {
      Log.warning(
        '[Simpan Akun] Akun ${customer.name} sudah ada, tidak disimpan ulang.',
      );
    }
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
    accountList
        .removeWhere((final p) => (p as Map<String, dynamic>)['id'] == userId);
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
