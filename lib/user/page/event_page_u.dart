// path: lib/user/page/event_page_u.dart

import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';

/// Halaman untuk menampilkan pengumuman kepada pengguna.
/// Untuk sementara menggunakan data dummy.
class EventPageU extends StatefulWidget {
  const EventPageU({super.key});

  @override
  State<EventPageU> createState() => _EventPageUState();
}

class _EventPageUState extends State<EventPageU> {
  // Data dummy untuk pengumuman
  final String _dummyImageUrl =
      'https://i.ibb.co/L89Yf2S/dummy-announcement.jpg'; // Ganti dengan URL gambar dummy yang valid
  final bool _dummyIsActive = true;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informasi Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            gapH16,
            if (_dummyIsActive)
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _dummyImageUrl.isNotEmpty
                      ? Image.network(_dummyImageUrl,
                          fit: BoxFit.cover, // Diubah menjadi BoxFit.cover
                          errorBuilder: (final _, final __, final ___) =>
                              const Center(
                                  child:
                                      Text('Gagal memuat gambar pengumuman')))
                      : const Center(
                          child: Text('Tidak ada gambar pengumuman'))),
            if (!_dummyIsActive) // Tampilkan pesan jika tidak aktif
              const Center(
                child: Text('Saat ini tidak ada pengumuman aktif.'),
              ),
            gapH16,
            Text(
              _dummyIsActive
                  ? 'Pengumuman sedang aktif dan dapat dilihat.'
                  : 'Pengumuman sedang tidak aktif.',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (final context) => const ManageAnnouncementPage(),
            ),
          );
        },
        child: const Icon(TIcons.add),
      ),
    );
  }
}
