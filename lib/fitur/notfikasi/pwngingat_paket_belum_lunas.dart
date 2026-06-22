// path lib/fitur/notfikasi/pwngingat_paket_belum_lunas.dart

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart'; // Sesuaikan path Anda

class PengingatService {
  final LayananNotifikasi _notifServis = LayananNotifikasi();

  Future<void> cekDanTampilkanNotif() async {
    // 1. Cek apakah notifikasi sudah tampil hari ini
    final prefs = await SharedPreferences.getInstance();
    final String hariIni = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String terakhirNotif = prefs.getString('last_notif_date') ?? '';

    if (terakhirNotif == hariIni) {
      // Jika sudah tampil hari ini, hentikan proses
      return;
    }

    // 2. Cek data paket (sesuaikan dengan logic Anda)
    // Asumsi: Anda memiliki fungsi untuk mengambil daftar paket
    final daftarPaket = await _ambilDataPaketBelumLunas();

    if (daftarPaket.isNotEmpty) {
      // 3. Tampilkan Notifikasi
      await _notifServis.tampilkanNotifikasiLangsung(
        title: 'Pengingat Tagihan',
        body:
            'Anda memiliki ${daftarPaket.length} paket yang belum lunas. Segera lakukan pembayaran.',
      );

      // 4. Update flag di SharedPreferences agar tidak muncul lagi hari ini
      await prefs.setString('last_notif_date', hariIni);
    }
  }

  // Contoh fungsi dummy untuk mengambil data paket
  Future<List<dynamic>> _ambilDataPaketBelumLunas() async {
    // Implementasi logic database/provider Anda di sini
    // Contoh: return await ref.read(transaksiProvider.future).where((t) => !t.isLunas).toList();
    return [];
  }
}
