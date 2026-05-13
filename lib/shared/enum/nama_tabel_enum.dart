// path: lib/shared/enum/nama_tabel_enum.dart
// diubah: Menambahkan dokumentasi lengkap dan memperbaiki path file.

/// Enum yang mendefinisikan nama-nama tabel yang digunakan dalam database,
/// baik lokal (SQLite) maupun remote (Firebase).
///
/// Ini membantu menghindari kesalahan pengetikan dan menjaga konsistensi.
enum NamaTabel {
  /// Tabel untuk menyimpan data dompet atau sumber dana.
  dompet,

  /// Tabel untuk menyimpan kategori transaksi (pemasukan/pengeluaran).
  kategori,

  /// Tabel untuk menyimpan feedback kritik dan saran dari pengguna.
  kritikSaran,

  /// Tabel untuk menyimpan data paket langganan yang tersedia.
  paket,

  /// Tabel untuk menyimpan data pelanggan yang sedang aktif berlangganan.
  pelangganAktif,

  /// Tabel utama untuk menyimpan data semua pelanggan.
  pelanggan,

  /// Tabel untuk menyimpan pesanan atau permintaan layanan.
  pesanan,

  /// Tabel utama untuk mencatat semua transaksi keuangan.
  transaksi,

  /// Tabel untuk menyimpan sub-kategori dari sebuah kategori utama.
  subKategori,

  /// Tabel untuk menyimpan informasi versi APK yang digunakan oleh pengguna.
  versiApkUser,

  /// Tabel untuk menyimpan berbagai pengaturan aplikasi.
  pengaturan,

  /// Tabel untuk melacak status sinkronisasi data ke server.
  statusUnggah,

  /// Nilai default jika nama tabel tidak diketahui atau tidak relevan.
  unknown,
}
