// path: lib/shared/enum/table_name_enum.dart

/// Enum yang merepresentasikan nama-nama tabel dalam database.
/// Digunakan untuk sinkronisasi dan operasi terkait database lainnya.
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
  transaction,

  /// Tabel dompet.
  wallet,

  /// Tabel kritik dan saran.
  feedback,

  /// Tabel pesanan.
  order,

  /// Tabel versi APK pengguna.
  userApkVersion,

  /// Tabel pengaturan.
  setting,

  /// Tabel status unggah.
  uploadStatus,

  /// Tabel pesan.
  message,

  /// Tabel status aplikasi.
  appStatus,

  /// Tabel token FCM.
  fcmToken,

  /// Tabel notifikasi.
  notification,
}
