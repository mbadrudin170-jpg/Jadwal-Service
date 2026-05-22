// path: lib/tes_fitur/halaman_test.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

class TestNotificationPage extends StatefulWidget {
  const TestNotificationPage({super.key});

  @override
  _TestNotificationPageState createState() => _TestNotificationPageState();
}

class _TestNotificationPageState extends State<TestNotificationPage> {
  // Instance dari layanan notifikasi (singleton)
  final NotifikasiServis _notifikasiServis = NotifikasiServis();

  // Controller untuk input teks dari pengguna
  final TextEditingController _titleController =
      TextEditingController(text: 'Notifikasi Test');
  final TextEditingController _bodyController =
      TextEditingController(text: 'Ini adalah notifikasi test instan.');
  final TextEditingController _payloadController =
      TextEditingController(text: 'test_payload');

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    _titleController.dispose();
    _bodyController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  Future<void> _jadwalkanNotifikasi() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final payload = _payloadController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _tampilkanSnackbar('Judul dan isi tidak boleh kosong');
      return;
    }

    final jadwal = DateTime.now().add(const Duration(minutes: 1));
    Log.info('Menjadwalkan notifikasi untuk $jadwal');

    try {
      // Gunakan id unik (misal berdasarkan timestamp)
      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      await _notifikasiServis.jadwalNotifikasi(
        id: id,
        title: title,
        body: body,
        jadwal: jadwal,
        payload: payload.isNotEmpty ? payload : null,
      );
      _tampilkanSnackbar(
          'Notifikasi dijadwalkan pukul ${jadwal.hour}:${jadwal.minute}');
    } on Exception catch (e) {
      Log.error('Gagal menjadwalkan', e: e);
      _tampilkanSnackbar('Error: $e');
    }
  }
  /// Fungsi untuk menampilkan notifikasi langsung
  Future<void> _tampilkanNotifikasi() async {
    // Ambil nilai dari input pengguna
    final String title = _titleController.text.trim();
    final String body = _bodyController.text.trim();
    final String payload = _payloadController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _tampilkanSnackbar('Judul dan isi notifikasi tidak boleh kosong!');
      return;
    }

    Log.info('=== TEST: Mencoba menampilkan notifikasi langsung ===');
    Log.info('Judul: $title, Isi: $body, Payload: $payload');

    try {
      // Panggil method dari NotifikasiServis yang sudah Anda buat
      await _notifikasiServis.tampilkanNotifikasiLangsung(
        title: title,
        body: body,
        payload: payload.isNotEmpty ? payload : null,
      );
      _tampilkanSnackbar('Notifikasi berhasil dikirim!');
    } on Exception catch (e, st) {
      Log.error('=== TEST: Gagal menampilkan notifikasi ===', e: e, st: st);
      _tampilkanSnackbar('Gagal mengirim notifikasi: $e');
    }
  }

  void _tampilkanSnackbar(final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Uji Kirim Notifikasi Langsung',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Notifikasi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi Notifikasi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _payloadController,
              decoration: const InputDecoration(
                labelText: 'Data Payload (Opsional)',
                hintText: 'Contoh: order_123, promo_info, dll.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _jadwalkanNotifikasi,
              icon: const Icon(Icons.schedule),
              label: const Text('Jadwalkan Notifikasi (1 menit lagi)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            ElevatedButton.icon(
              onPressed: _tampilkanNotifikasi,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Kirim Notifikasi Sekarang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Tips Pengujian:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Kirim notifikasi dari halaman ini.\n'
                      '2. Notifikasi akan langsung muncul di panel notifikasi sistem.\n'
                      '3. Klik notifikasi tersebut, pastikan Snackbar "Dibuka dari notifikasi" muncul di halaman utama.\n'
                      '4. Tutup paksa aplikasi, lalu kirim notifikasi lagi, dan klik untuk menguji skenario terminated.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
