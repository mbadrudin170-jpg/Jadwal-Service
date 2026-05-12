// path: lib/enum/status_pembayaran_enum.dart

import 'package:wifiname/debug/log.dart'; // diubah: Menggunakan Log kustom

// Enum untuk status pembayaran
enum StatusPembayaranEnum {
  lunas,
  belumLunas;

  String get displayName {
    Log.info('Mengakses getter displayName untuk enum StatusPembayaranEnum.');
    Log.info('Nilai enum saat ini: $this');

    switch (this) {
      case StatusPembayaranEnum.lunas:
        Log.info('Mengembalikan string "Lunas" untuk nilai lunas.');
        return 'Lunas';
      case StatusPembayaranEnum.belumLunas:
        Log.info('Mengembalikan string "Belum Lunas" untuk nilai belumLunas.');
        return 'Belum Lunas';
    }
  }
}
