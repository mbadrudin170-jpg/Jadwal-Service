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

/// Extension untuk mendapatkan representasi String yang mudah dibaca dari [CategoryType].
extension CategoryTypeExtension on CategoryType {
  /// Mengembalikan nama tampilan dalam bahasa Indonesia.
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
