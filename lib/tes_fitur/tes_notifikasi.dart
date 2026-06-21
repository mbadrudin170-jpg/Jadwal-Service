// path: lib/tes_fitur/tes_notifikasi.dart
import 'package:flutter/material.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';

/// Halaman untuk melakukan tes fungsionalitas notifikasi.
class TesNotifikasiPage extends StatefulWidget {
  const TesNotifikasiPage({super.key});

  @override
  State<TesNotifikasiPage> createState() => _TesNotifikasiPageState();
}

class _TesNotifikasiPageState extends State<TesNotifikasiPage> {
  final LayananNotifikasi _notifikasiServis = LayananNotifikasi();

  /// Menampilkan notifikasi sederhana secara langsung.
  Future<void> _tampilkanNotifikasiLangsung() async {
    Log.info('Tombol "Tampilkan Notifikasi Langsung" ditekan.');
    // PERBAIKAN: Tambahkan await karena ini adalah operasi async
    await _notifikasiServis.tampilkanNotifikasiLangsung(
      title: 'Tes Notifikasi Langsung',
      body: 'Ini adalah isi dari notifikasi yang ditampilkan langsung.',
      payload: 'direct_notification_payload',
    );
  }

  /// Menjadwalkan notifikasi untuk muncul dalam 5 detik.
  Future<void> _jadwalkanNotifikasi() async {
    Log.info('Tombol "Jadwalkan Notifikasi" ditekan.');
    final waktuJadwal = DateTime.now().add(const Duration(seconds: 5));

    // PERBAIKAN: Tambahkan await karena ini adalah operasi async
    await _notifikasiServis.jadwalNotifikasi(
      id: 2,
      judul: 'Tes Notifikasi Terjadwal',
      pesan: 'Notifikasi ini dijadwalkan untuk 5 detik dari sekarang.',
      payload: 'scheduled_notification_payload',
      jadwal: waktuJadwal,
    );

    // PERBAIKAN: Pemeriksaan `mounted` untuk keamanan `BuildContext`.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dijadwalkan untuk 5 detik dari sekarang.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Mengambil dan mencatat daftar notifikasi yang sedang menunggu (pending).
  Future<void> _cekNotifikasiTerjadwal() async {
    Log.info('Tombol "Cek Notifikasi Terjadwal" ditekan.');

    // PERBAIKAN: Ambil context SEBELUM AWAIT.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final daftarNotifikasi = await _notifikasiServis.plugin
        .pendingNotificationRequests();

    // PERBAIKAN: Pemeriksaan `mounted` setelah AWAIT.
    if (!mounted) return;

    if (daftarNotifikasi.isEmpty) {
      Log.info('Tidak ada notifikasi yang sedang terjadwal.');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Tidak ada notifikasi yang sedang terjadwal.'),
        ),
      );
    } else {
      Log.info('Ditemukan ${daftarNotifikasi.length} notifikasi terjadwal:');
      for (final notif in daftarNotifikasi) {
        Log.info(
          '- ID: ${notif.id}, Judul: ${notif.title}, Payload: ${notif.payload}',
        );
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Ditemukan ${daftarNotifikasi.length} notifikasi terjadwal. Cek log untuk detail.',
          ),
        ),
      );
    }
  }

  /// Membatalkan semua notifikasi yang telah dijadwalkan.
  Future<void> _batalkanSemuaNotifikasi() async {
    Log.info('Tombol "Batalkan Semua Notifikasi" ditekan.');
    // PERBAIKAN: Tambahkan await karena ini adalah operasi async
    await _notifikasiServis.batalSemuaNotifikasi();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi terjadwal telah dibatalkan.'),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Fitur Notifikasi')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _tampilkanNotifikasiLangsung,
                child: const Text('Tampilkan Notifikasi Langsung'),
              ),
              gapH16,
              ElevatedButton(
                onPressed: _jadwalkanNotifikasi,
                child: const Text('Jadwalkan Notifikasi (5 detik)'),
              ),
              gapH16,
              ElevatedButton(
                onPressed: _cekNotifikasiTerjadwal,
                child: const Text('Cek Notifikasi Terjadwal'),
              ),
              gapH16,
              ElevatedButton(
                onPressed: _batalkanSemuaNotifikasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Batalkan Semua Notifikasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
