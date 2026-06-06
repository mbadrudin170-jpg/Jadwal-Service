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

extension CategoryTypeExtension on CategoryType {
  String get displayName {
    switch (this) {
      case CategoryType.income:
        return 'Pemasukan';
      case CategoryType.expense:
        return 'Pengeluaran';
      case CategoryType.transfer:
        return 'Transfer';
    }
  }
}
