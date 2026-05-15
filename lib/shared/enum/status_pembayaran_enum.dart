// path: lib/shared/enum/status_pembayaran_enum.dart
// diubah: Menambahkan anotasi Hive dan mempertahankan getter displayName.

import 'package:hive/hive.dart';
import 'package:wifi/shared/debug/log.dart';

part 'status_pembayaran_enum.g.dart';

/// Enum untuk status pembayaran transaksi.
@HiveType(typeId: 2) // ID tipe unik, 0 & 1 sudah dipakai.
enum StatusPembayaranEnum {
  /// Pembayaran sudah lunas.
  @HiveField(0)
  lunas,

  /// Pembayaran belum lunas.
  @HiveField(1)
  belumLunas,

  /// Pembayaran tertunda atau menunggu konfirmasi.
  @HiveField(2)
  pending;

  /// Nama tampilan untuk status pembayaran.
  String get displayName {
    Log.info('Mengakses getter displayName untuk enum StatusPembayaran.');
    Log.info('Nilai enum saat ini: $this');

    switch (this) {
      case StatusPembayaranEnum.lunas:
        Log.info('Mengembalikan string "Lunas" untuk nilai lunas.');
        return 'Lunas';
      case StatusPembayaranEnum.belumLunas:
        Log.info('Mengembalikan string "Belum Lunas" untuk nilai belumLunas.');
        return 'Belum Lunas';
      case StatusPembayaranEnum.pending:
        Log.info('Mengembalikan string "Pending" untuk nilai pending.');
        return 'Pending';
    }
  }
}
