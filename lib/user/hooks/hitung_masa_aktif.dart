// path: lib/user/hooks/hitung_masa_aktif.dart
import 'dart:developer';
import 'package:wifi/user/core/app_colors.dart';

Map<String, dynamic> hitungStatusMasaAktif(DateTime tanggalBerakhir,
    {DateTime? sekarang}) {
  log(
    '[Kalkulasi Masa Aktif] ✅ Menghitung status untuk tanggal berakhir: $tanggalBerakhir',
    name: 'hitung_masa_aktif.dart',
  );

  final now = sekarang ?? DateTime.now();
  final selisih = tanggalBerakhir.difference(now);

  Map<String, dynamic> hasil;

  if (selisih.isNegative) {
    hasil = {'teks': 'Telah berakhir', 'warna': AppColors.error};
  } else {
    final sisaHari = selisih.inDays;
    final sisaJam = selisih.inHours;

    if (sisaHari < 1) {
      if (sisaJam > 0) {
        hasil = {'teks': 'Sisa $sisaJam jam', 'warna': AppColors.error};
      } else {
        final sisaMenit = selisih.inMinutes;
        hasil = {'teks': 'Sisa $sisaMenit menit', 'warna': AppColors.error};
      }
    } else if (sisaHari <= 7) {
      hasil = {'teks': 'Sisa $sisaHari hari', 'warna': AppColors.warning};
    } else {
      hasil = {'teks': 'Aktif', 'warna': AppColors.success};
    }
  }

  log(
    '[Kalkulasi Masa Aktif] ✅ Hasil kalkulasi: ${hasil['teks']}',
    name: 'hitung_masa_aktif.dart',
  );

  return hasil;
}
