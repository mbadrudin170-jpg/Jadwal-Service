// path: lib/shared/enum/payment_status_enum.dart

/// Enum untuk status pembayaran transaksi atau tagihan.
enum PaymentStatus {
  /// Status lunas, pembayaran telah diselesaikan.
  paid,

  /// Status belum lunas, pembayaran masih tertunda.
  unpaid,

  /// Status jatuh tempo, pembayaran sudah melewati batas waktu.
  overdue;

  /// Mengembalikan nama tampilan (display name) untuk setiap status pembayaran.
  String get displayName {
    switch (this) {
      case PaymentStatus.paid:
        return 'Lunas';
      case PaymentStatus.unpaid:
        return 'Belum Lunas';
      case PaymentStatus.overdue:
        return 'Jatuh Tempo';
    }
  }
}
