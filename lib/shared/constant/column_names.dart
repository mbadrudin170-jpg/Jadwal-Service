
// path: lib/shared/constant/column_names.dart
// Berkas ini berisi daftar nama kolom database untuk konsistensi di seluruh aplikasi.

// TODO: Lengkapi semua nama kolom dari setiap tabel di sqlite.dart.

/// Kelas abstrak yang berisi konstanta untuk nama kolom database.
abstract final class ColumnNames {
  /// Nama kolom untuk ID unik.
  static const String id = 'id';

  /// Nama kolom untuk status hapus (soft delete).
  static const String isDeleted = 'is_deleted';

  /// Nama kolom untuk waktu pembaruan terakhir.
  static const String updatedAt = 'updated_at';

  /// Nama kolom untuk waktu pengarsipan.
  static const String archivedAt = 'archived_at';

  /// Nama kolom untuk nama (misalnya, nama kategori, nama dompet).
  static const String name = 'name';

  /// Nama kolom untuk saldo dompet.
  static const String balance = 'balance';

  /// Nama kolom untuk deskripsi atau keterangan.
  static const String description = 'description';

  /// Nama kolom untuk jumlah transaksi.
  static const String amount = 'amount';

  /// Nama kolom untuk tanggal.
  static const String date = 'date';

  /// Nama kolom untuk tipe (misalnya, tipe transaksi, tipe kategori).
  static const String type = 'type';

  /// Nama kolom untuk ID dompet.
  static const String walletId = 'wallet_id';

  /// Nama kolom untuk ID kategori.
  static const String categoryId = 'category_id';

  /// Nama kolom untuk ID sub-kategori.
  static const String subCategoryId = 'sub_category_id';

  /// Nama kolom untuk ID pelanggan.
  static const String customerId = 'customer_id';

  /// Nama kolom untuk ID paket.
  static const String packageId = 'package_id';
  
  /// Nama kolom untuk ID transaksi.
  static const String transactionId = 'transaction_id';

  /// Nama kolom untuk ID dompet tujuan (untuk transfer).
  static const String destinationWalletId = 'destination_wallet_id';

  /// Nama kolom untuk poin yang diperoleh.
  static const String earnedPoints = 'earned_points';

  /// Nama kolom untuk poin yang digunakan.
  static const String usedPoints = 'used_points';

  /// Nama kolom untuk status pembayaran.
  static const String paymentStatus = 'payment_status';

  /// Nama kolom untuk durasi paket.
  static const String packageDuration = 'package_duration';

  /// Nama kolom untuk tipe durasi (misalnya, hari, bulan).
  static const String durationType = 'duration_type';

  /// Nama kolom untuk tanggal mulai.
  static const String startDate = 'start_date';

  /// Nama kolom untuk tanggal berakhir.
  static const String endDate = 'end_date';

  /// Nama kolom untuk status aktivasi paket.
  static const String isActivated = 'is_activated';

  /// Nama kolom untuk harga.
  static const String price = 'price';

  /// Nama kolom untuk durasi.
  static const String duration = 'duration';

  /// Nama kolom untuk poin hadiah.
  static const String rewardPoints = 'reward_points';

  /// Nama kolom untuk poin penukaran.
  static const String redemptionPoints = 'redemption_points';

  /// Nama kolom untuk status publik (apakah paket dapat dilihat publik).
  static const String isPublic = 'is_public';

  /// Nama kolom untuk nomor telepon.
  static const String phone = 'phone';

  /// Nama kolom untuk alamat.
  static const String address = 'address';

  /// Nama kolom untuk kata sandi.
  static const String password = 'password';

  /// Nama kolom untuk alamat MAC.
  static const String macAddress = 'mac_address';

  /// Nama kolom untuk status umum.
  static const String status = 'status';

  /// Nama kolom untuk isi (misalnya, isi kritik dan saran).
  static const String content = 'content';

  /// Nama kolom untuk ID pengguna.
  static const String userId = 'user_id';

  /// Nama kolom untuk catatan rilis.
  static const String releaseNotes = 'release_notes';

  /// Nama kolom untuk nomor build terbaru.
  static const String latestBuildNumber = 'latest_build_number';

  /// Nama kolom untuk tautan unduhan.
  static const String downloadLink = 'download_link';

  /// Nama kolom untuk versi terbaru.
  static const String latestVersion = 'latest_version';

  /// Nama kolom untuk status pembaruan paksa.
  static const String forceUpdate = 'force_update';

  /// Nama kolom untuk tautan tutorial YouTube.
  static const String youtubeTutorial = 'youtube_tutorial';

  /// Nama kolom untuk interval sinkronisasi otomatis.
  static const String autoSyncInterval = 'auto_sync_interval';

  /// Nama kolom untuk interval penghapusan arsip otomatis (dalam hari).
  static const String autoDeleteArchiveDays = 'auto_delete_archive_days';

  /// Nama kolom untuk mode pemeliharaan.
  static const String maintenanceMode = 'maintenance_mode';

  /// Nama kolom untuk informasi pemeliharaan.
  static const String maintenanceInfo = 'maintenance_info';

  /// Nama kolom untuk nama tabel.
  static const String tableName = 'table_name';

  /// Nama kolom untuk daftar ID.
  static const String ids = 'ids';

  /// Nama kolom untuk nilai generik.
  static const String value = 'value';
}
