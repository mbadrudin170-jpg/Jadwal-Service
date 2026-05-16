/// Enum yang merepresentasikan nama-nama tabel dalam database.
/// Digunakan untuk sinkronisasi dan operasi terkait database lainnya.
enum TableName {
  /// Tabel kategori produk atau layanan.
  category,

  /// Tabel sub-kategori untuk pengelompokan yang lebih spesifik.
  subCategory,

  /// Tabel paket layanan atau produk.
  package,

  /// Tabel data pelanggan.
  customer,

  /// Tabel data pelanggan yang sedang aktif.
  activeCustomer,

  /// Tabel transaksi (diubah menjadi bentuk jamak agar konsisten).
  transactions,

  /// Tabel dompet digital atau saldo pengguna.
  wallet,

  /// Tabel masukan atau feedback dari pengguna.
  feedback,

  /// Tabel pesanan atau order.
  order,

  /// Tabel versi APK yang digunakan oleh pengguna.
  userApkVersion,

  /// Tabel pengaturan aplikasi.
  setting,

  /// Tabel status unggahan data.
  uploadStatus,

  /// Tabel pesan atau chat.
  message,

  /// Tabel status operasional aplikasi.
  appStatus,

  /// Tabel token Firebase Cloud Messaging untuk notifikasi.
  fcmToken,

  /// Tabel riwayat notifikasi.
  notification,
}
