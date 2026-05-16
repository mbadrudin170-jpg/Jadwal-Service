// path: lib/shared/enum/payment_status_enum.dart

/// Enum untuk status pembayaran transaksi atau tagihan.
enum PaymentStatus {
  /// Status lunas, pembayaran telah diselesaikan.
  paid,

  /// Status belum lunas, pembayaran masih tertunda.
  unpaid,

  /// Status jatuh tempo, pembayaran sudah melewati batas waktu.
  overdue,
}
