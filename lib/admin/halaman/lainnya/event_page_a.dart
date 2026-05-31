// path: lib/admin/halaman/lainnya/event_page_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_firebase.dart'; // Impor providernya
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/debug/log.dart'; // Impor Log

/// Halaman yang menampilkan daftar pengumuman (event) untuk pengguna.
///
/// Halaman ini mengambil data pengumuman dari Firebase menggunakan
/// [EventOpFirebase] dan menampilkannya dalam bentuk daftar.
class EventPageU extends ConsumerWidget {
  const EventPageU({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    // Menggunakan ref.watch untuk mendapatkan provider EventOpFirebase.
    // Widget akan otomatis rebuild jika data di provider berubah.
    // final eventOperator = ref.watch(eventOpFirebaseProvider); // Tidak digunakan, jadi hapus atau gunakan ref.read

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        actions: [
          // Jika ada fitur refresh, bisa ditambahkan di sini
          IconButton(
            icon: const Icon(TIcons.refresh),
            tooltip: 'Muat Ulang Pengumuman',
            onPressed: () {
              ref.invalidate(
                  eventOpFirebaseProvider); // Contoh cara refresh provider
            },
          ),
        ],
      ),
      body: FutureBuilder<List<EventModel>>(
        future: ref.read(eventOpFirebaseProvider).getAll(),
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Menampilkan pesan error jika terjadi kesalahan saat mengambil data.
          else if (snapshot.hasError) {
            // Log error untuk debugging
            Log.error('Error saat memuat pengumuman: ${snapshot.error}',
                e: snapshot.error,
                st: snapshot.stackTrace); // Pastikan stackTrace juga dicatat
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat pengumuman.', // Pesan yang lebih ramah pengguna
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // Menampilkan pesan jika tidak ada data pengumuman.
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada pengumuman.'),
            );
          }
          // Menampilkan daftar pengumuman jika data berhasil diambil.
          else {
            final announcements = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(TSizes.p16),
              itemCount: announcements.length,
              itemBuilder: (final context, final index) {
                final announcement = announcements[index];
                return Card(
                  margin: EdgeInsets.only(bottom: TSizes.p16),
                  child: ListTile(
                    // Menampilkan gambar jika URL valid
                    leading: announcement.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              announcement.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Log error gambar
                                Log.error(
                                    'Gagal memuat gambar: ${announcement.imageUrl}',
                                    e: error,
                                    st: stackTrace);
                                return const Icon(TIcons
                                    .error); // Ikon error jika gambar gagal dimuat
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : null, // Tidak menampilkan leading jika tidak ada URL gambar
                    title: Text(
                      // Menggunakan 'id' sebagai pengganti 'releaseNotes' yang tidak ada di EventModel
                      'ID: ${announcement.id.length > 50 ? '${announcement.id.substring(0, 50)}...' : announcement.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gapH8,
                        Text(
                            'Dibuat: ${announcement.createdAt.toLocal().toString().split(' ')[0]}'), // Tampilkan tanggal saja
                        if (announcement.isActive)
                          Chip(
                            label: const Text('Aktif'),
                            avatar: const Icon(TIcons.toggle_on, size: 18),
                            backgroundColor: Colors.green.withAlpha(16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                          )
                        else
                          Chip(
                            label: const Text('Tidak Aktif'),
                            avatar: const Icon(TIcons.toggle_off, size: 18),
                            // Kembali menggunakan withOpacity karena op() tidak valid
                            backgroundColor: Colors.grey.withAlpha(16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                          ),
                      ],
                    ),
                    onTap: () {
                      Log.info('Pengumuman ${announcement.id} diklik');
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Extension method untuk mencari elemen pertama dalam list yang memenuhi kondisi.
// Ini bisa diletakkan di file utilitas terpisah atau di sini jika hanya digunakan di sini.
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
