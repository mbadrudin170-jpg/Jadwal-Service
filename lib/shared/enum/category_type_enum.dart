// path: lib/shared/enum/category_type_enum.dart

/// Enum untuk mendefinisikan tipe-tipe kategori transaksi.
enum CategoryType {
  /// Mewakili transaksi yang menambah saldo (pemasukan).
  income,

  /// Mewakili transaksi yang mengurangi saldo (pengeluaran).
  expense,

  /// Mewakili transaksi transfer dana antar dompet.
  transfer,
}
