// path: lib/shared/enum/transaction_type_enum.dart
// diperbaiki: Menambahkan dokumentasi untuk getter.

/// Enum untuk tipe-tipe transaksi.
enum TipeTransaksi {
  /// Untuk transaksi pemasukan.
  income,

  /// Untuk transaksi pengeluaran.
  expense,

  /// Untuk transaksi transfer.
  transfer;

  /// Mendapatkan nama tampilan (display name) dari tipe transaksi.
  String get displayName {
    switch (this) {
      case TipeTransaksi.income:
        return 'Pemasukan';
      case TipeTransaksi.expense:
        return 'Pengeluaran';
      case TipeTransaksi.transfer:
        return 'Transfer';
    }
  }
}
