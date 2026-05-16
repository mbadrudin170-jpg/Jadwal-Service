// path: lib/shared/enum/status_pembayaran_enum.dart
// diubah: Menghapus referensi ke Hive dan mempertahankan getter displayName.

import 'package:wifi/shared/debug/log.dart';

/// Enum untuk status pembayaran transaksi.
enum StatusPembayaranEnum {
  /// Pembayaran sudah lunas.
  lunas,

  /// Pembayaran belum lunas.
  belumLunas,

  /// Pembayaran tertunda atau menunggu konfirmasi.
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
