// path: lib/shared/enum/table_name_enum.dart

/// Enum untuk daftar nama tabel dalam database.
enum TableName {
  /// Tabel kategori.
  category,

  /// Tabel sub-kategori.
  subCategory,

  /// Tabel paket.
  package,

  /// Tabel pelanggan.
  customer,

  /// Tabel pelanggan aktif.
  activeCustomer,

  /// Tabel transaksi.
  transactions,

  /// Tabel dompet.
  wallet,

  /// Tabel kritik dan saran.
  feedback,

  /// Tabel pesanan pelanggan.
  customerOrder,

  /// Tabel versi APK pengguna.
  userApkVersion,

  /// Tabel pengaturan.
  settings,

  /// Tabel status unggah.
  uploadStatus,

  /// Tabel pesan.
  message,

  /// Tabel token FCM.
  fcmToken,

  /// Tabel notifikasi.
  notification,

  /// Tabel status global.
  statusGlobal,

  /// Tabel pengumuman (event).
  events,
  notifikasi,
}
