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

  /// Tabel pesanan atau customer_order.
  customerOrder,

  /// Tabel versi APK yang digunakan oleh pengguna.
  userApkVersion,

  /// Tabel pengaturan aplikasi.
  settings,

  /// Tabel status unggahan data.
  uploadStatus,

  /// Tabel pesan atau chat.
  message,

  /// Tabel status sinkronisasi global.
  status,

  /// Tabel token Firebase Cloud Messaging untuk notifikasi.
  fcmToken,

  /// Tabel riwayat notifikasi.
  notification,
}
