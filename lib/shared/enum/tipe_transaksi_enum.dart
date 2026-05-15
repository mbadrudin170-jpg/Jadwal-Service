// path: lib/shared/enum/tipe_transaksi_enum.dart
// diubah: Mengganti nama enum menjadi TipeTransaksiEnum dan menambahkan dokumentasi.

import 'package:hive/hive.dart';

part 'tipe_transaksi_enum.g.dart';

/// Enum untuk tipe-tipe transaksi.
@HiveType(typeId: 1)
enum TipeTransaksiEnum {
  /// Untuk transaksi pemasukan.
  @HiveField(0)
  pemasukan,

  /// Untuk transaksi pengeluaran.
  @HiveField(1)
  pengeluaran,

  /// Untuk transaksi transfer.
  @HiveField(2)
  transfer,
}
