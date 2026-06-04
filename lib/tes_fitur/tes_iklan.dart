// path: lib/tes_fitur/tes_iklan.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_servis.dart';

class TestNotificationPage extends StatefulWidget {
  const TestNotificationPage({super.key});

  @override
  State<TestNotificationPage> createState() => _TestNotificationPageState();
}

class _TestNotificationPageState extends State<TestNotificationPage> {
  final NotifikasiServis _notifikasiServis = NotifikasiServis();

  // [DIPERBAIKI] Gunakan ID notifikasi yang konstan untuk pengujian
  static const int _testNotificationId = 99;

  final TextEditingController _titleController =
      TextEditingController(text: 'Notifikasi Uji Coba');
  final TextEditingController _bodyController =
      TextEditingController(text: 'Ini adalah isi dari notifikasi.');
  final TextEditingController _payloadController =
      TextEditingController(text: 'test_payload_123');

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  // [DIPERBAIKI] Menggunakan 'perbaruiJadwalNotifikasi' untuk keandalan
  Future<void> _jadwalkanNotifikasi() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final payload = _payloadController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _tampilkanSnackbar('Judul dan isi tidak boleh kosong');
      return;
    }

    // Jadwalkan untuk 10 detik dari sekarang agar lebih cepat diuji
    final jadwal = DateTime.now().add(const Duration(seconds: 10));

    try {
      await _notifikasiServis.perbaruiJadwalNotifikasi(
        id: _testNotificationId, // Gunakan ID konstan
        title: title,
        body: body,
        jadwal: jadwal,
        payload: payload.isNotEmpty ? payload : null,
      );
      _tampilkanSnackbar(
          'Notifikasi dijadwalkan ulang pukul \${jadwal.hour}:\${jadwal.minute}:\${jadwal.second}');
    } on Exception catch (e) {
      Log.error('Gagal memperbarui jadwal notifikasi', e: e);
      _tampilkanSnackbar('Error: \$e');
    }
  }

  Future<void> _tampilkanNotifikasi() async {
    final String title = _titleController.text.trim();
    final String body = _bodyController.text.trim();
    final String payload = _payloadController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      _tampilkanSnackbar('Judul dan isi notifikasi tidak boleh kosong!');
      return;
    }

    try {
      await _notifikasiServis.tampilkanNotifikasiLangsung(
        title: title,
        body: body,
        payload: payload.isNotEmpty ? payload : null,
      );
      _tampilkanSnackbar('Notifikasi berhasil dikirim!');
    } on Exception catch (e, st) {
      Log.error('=== TEST: Gagal menampilkan notifikasi ===', e: e, st: st);
      _tampilkanSnackbar('Gagal mengirim notifikasi: \$e');
    }
  }

  void _tampilkanSnackbar(final String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Uji Kirim Notifikasi',
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
                // [DIPERBAIKI] Label diubah untuk mencerminkan jadwal baru
                label: const Text('Jadwalkan Notifikasi (10 detik)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _tampilkanNotifikasi,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Kirim Notifikasi Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol untuk membatalkan semua notifikasi
              ElevatedButton.icon(
                onPressed: () async {
                  await _notifikasiServis.batalSemuaNotifikasi();
                  _tampilkanSnackbar('Semua notifikasi telah dibatalkan.');
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Batalkan Semua Notifikasi'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                        '1. Kirim notifikasi dari halaman ini.\\n'
                        '2. Notifikasi akan langsung muncul di panel notifikasi sistem.\\n'
                        '3. Klik notifikasi tersebut, pastikan Snackbar "Dibuka dari notifikasi" muncul di halaman utama.\\n'
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
      ),
    );
  }
}
