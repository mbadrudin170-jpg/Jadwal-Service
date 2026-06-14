// path: lib/shared/enum/tipe_kategori.dart

/// Enum untuk mendefinisikan tipe-tipe kategori transaksi.
enum TipeKategori {
  /// Mewakili transaksi yang menambah saldo (pemasukan).
  income,

  /// Mewakili transaksi yang mengurangi saldo (pengeluaran).
  expense,

  /// Mewakili transaksi transfer dana antar dompet.
  transfer,
}

extension CategoryTypeExtension on TipeKategori {
  String get displayName {
    switch (this) {
      case TipeKategori.income:
        return 'Pemasukan';
      case TipeKategori.expense:
        return 'Pengeluaran';
      case TipeKategori.transfer:
        return 'Transfer';
    }
  }
}
