// path: lib/shared/theme/app_icons.dart
// diubah: Menambahkan ikon-ikon untuk navigasi utama admin.
import 'package:flutter/material.dart';

/// Kelas utilitas untuk mengelola ikon aplikasi secara terpusat.
///
/// Dengan mendefinisikan semua ikon di sini, kita memastikan konsistensi
/// dan kemudahan dalam mengganti ikon di masa mendatang. Cukup ubah di satu tempat.
///
/// Contoh Penggunaan:
/// ```
/// Icon(AppIcons.save)
/// ```
class AppIcons {
  // Mencegah class ini diinstansiasi.
  AppIcons._();

  // --- Navigasi & Aksi Umum ---
  /// Ikon untuk aksi tambah.
  static const IconData add = Icons.add;

  /// Ikon untuk aksi edit.
  static const IconData edit = Icons.edit;

  /// Ikon untuk aksi hapus.
  static const IconData delete = Icons.delete;

  /// Ikon untuk aksi simpan.
  static const IconData save = Icons.save;

  /// Ikon untuk aksi tutup.
  static const IconData close = Icons.close;

  /// Ikon untuk aksi pencarian.
  static const IconData search = Icons.search;

  /// Ikon untuk aksi kembali.
  static const IconData back = Icons.arrow_back;

  /// Ikon untuk panah atas.
  static const IconData arrowUp = Icons.arrow_upward;

  /// Ikon untuk panah bawah.
  static const IconData arrowDown = Icons.arrow_downward;

  /// Ikon untuk aksi filter.
  static const IconData filter = Icons.filter_list;

  /// Ikon untuk aksi urutkan.
  static const IconData sort = Icons.sort;

  /// Ikon untuk panah navigasi ke kanan.
  static const IconData chevronRight = Icons.chevron_right;

  /// Ikon untuk aksi salin.
  static const IconData copy = Icons.copy;

  /// Ikon untuk keluar atau logout.
  static const IconData logout = Icons.logout;

  // --- Menu Utama & Halaman ---
  /// Ikon untuk menu dasbor.
  static const IconData dashboard = Icons.dashboard;

  /// Ikon untuk menu pelanggan.
  static const IconData customers = Icons.group;

  /// Ikon untuk pelanggan aktif di navigasi utama.
  static const IconData activeCustomer = Icons.person_pin_circle;

  /// Ikon untuk menu transaksi.
  static const IconData transactions = Icons.swap_horiz;

  /// Ikon untuk struk atau riwayat panjang.
  static const IconData receiptLong = Icons.receipt_long;

  /// Ikon untuk dompet.
  static const IconData wallet = Icons.account_balance_wallet;

  /// Ikon untuk menu paket.
  static const IconData packages = Icons.inventory_2;

  /// Ikon untuk menu pengaturan.
  static const IconData settings = Icons.settings;

  /// Ikon untuk menu laporan atau statistik.
  static const IconData report = Icons.bar_chart;

  /// Ikon untuk menu "Lainnya".
  static const IconData apps = Icons.apps;

  // --- Entitas & Status ---
  /// Ikon generik untuk pengguna atau orang.
  static const IconData person = Icons.person;

  /// Ikon generik untuk pengguna (outline).
  static const IconData personOutlined = Icons.person_outline;

  /// Ikon untuk status pengguna aktif.
  static const IconData personActive = Icons.person_add_alt_1;

  /// Ikon untuk status pengguna kedaluwarsa.
  static const IconData personExpired = Icons.person_off;

  /// Ikon untuk kalender atau tanggal.
  static const IconData calendar = Icons.calendar_today;

  /// Ikon untuk rentang tanggal.
  static const IconData dateRange = Icons.date_range_outlined;

  /// Ikon untuk jam atau waktu.
  static const IconData clock = Icons.access_time;

  /// Ikon untuk jam pasir (menunjukkan durasi).
  static const IconData hourglass = Icons.hourglass_bottom;

  /// Ikon untuk status wifi aktif.
  static const IconData wifi = Icons.wifi;

  /// Ikon untuk status wifi tidak aktif.
  static const IconData noWifi = Icons.wifi_off;

  /// Ikon untuk mata uang atau harga.
  static const IconData money = Icons.attach_money;

  /// Ikon untuk poin.
  static const IconData points = Icons.stars;

  /// Ikon untuk menambah poin (riwayat).
  static const IconData pointsAdd = Icons.add_circle_outline;

  /// Ikon untuk mengurangi poin (riwayat).
  static const IconData pointsRemove = Icons.remove_circle_outline;

  /// Ikon untuk informasi.
  static const IconData info = Icons.info;

  /// Ikon untuk informasi (outline).
  static const IconData infoOutlined = Icons.info_outline;

  /// Ikon untuk peringatan.
  static const IconData warning = Icons.warning;

  /// Ikon untuk status sukses.
  static const IconData success = Icons.check_circle;

  /// Ikon untuk status sukses (outline).
  static const IconData successOutlined = Icons.check_circle_outline;

  /// Ikon untuk status error atau gagal.
  static const IconData error = Icons.error;

  /// Ikon untuk status error (outline).
  static const IconData errorOutlined = Icons.error_outline;

  /// Ikon untuk bantuan.
  static const IconData help = Icons.help;

  /// Ikon untuk kritik dan saran (feedback).
  static const IconData feedback = Icons.feedback_outlined;

  /// Ikon untuk hadiah atau penukaran.
  static const IconData gift = Icons.card_giftcard;

  /// Ikon untuk riwayat.
  static const IconData history = Icons.history;

  // --- Sinkronisasi & Data ---
  /// Ikon untuk aksi unggah (upload).
  static const IconData upload = Icons.upload;

  /// Ikon untuk aksi unduh (download).
  static const IconData download = Icons.download;

  /// Ikon untuk status sinkronisasi.
  static const IconData sync = Icons.sync;

  /// Ikon untuk masalah sinkronisasi.
  static const IconData syncAlert = Icons.sync_problem;

  /// Ikon untuk sinkronisasi nonaktif.
  static const IconData syncOff = Icons.sync_disabled;

  /// Ikon untuk cloud.
  static const IconData cloud = Icons.cloud;

  /// Ikon untuk unggah ke cloud.
  static const IconData cloudUpload = Icons.cloud_upload;

  /// Ikon untuk unduh dari cloud.
  static const IconData cloudDownload = Icons.cloud_download;

  // --- UI Lainnya ---
  /// Ikon untuk menampilkan (misal: password).
  static const IconData show = Icons.visibility;

  /// Ikon untuk menyembunyikan (misal: password).
  static const IconData hide = Icons.visibility_off;

  /// Ikon untuk menu pilihan tema.
  static const IconData theme = Icons.brightness_6_outlined;

  /// Ikon untuk tema terang.
  static const IconData themeLight = Icons.light_mode;

  /// Ikon untuk tema terang (outline).
  static const IconData themeLightOutlined = Icons.light_mode_outlined;

  /// Ikon untuk tema gelap.
  static const IconData themeDark = Icons.dark_mode;

  /// Ikon untuk tema gelap (outline).
  static const IconData themeDarkOutlined = Icons.dark_mode_outlined;

  /// Ikon untuk tema sistem/otomatis (di toolbar).
  static const IconData themeAuto = Icons.brightness_auto;

  /// Ikon untuk tema sistem/otomatis (di menu).
  static const IconData themeSystem = Icons.settings_brightness_outlined;
}
