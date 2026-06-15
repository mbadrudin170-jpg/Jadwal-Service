// path: lib/fitur/transaksi/enum/status_pembayaran.dart

/// Enum untuk status pembayaran transaksi atau tagihan.
enum StatusPembayaran {
  /// Status lunas, pembayaran telah diselesaikan.
  paid,

  /// Status belum lunas, pembayaran masih tertunda.
  unpaid;

  /// Mengembalikan nama tampilan (display name) untuk setiap status pembayaran.
  String get displayName {
    switch (this) {
      case StatusPembayaran.paid:
        return 'Lunas';
      case StatusPembayaran.unpaid:
        return 'Belum Lunas';
    }
  }
}
