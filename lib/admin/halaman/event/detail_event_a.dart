// path: lib/admin/halaman/event/detail_event_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/common/text.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';

class DetailEventA extends ConsumerWidget {
  final EventModel event;
  const DetailEventA({super.key, required this.event});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final futureEvent = ref.watch(eventOpSupabaseProvider).getById(event.id);
    return Scaffold(
      appBar: AppBar(
        title: const TeksJudulSedang('Detail Pengumuman'),
      ),
      body: FutureBuilder<EventModel?>(
        future: futureEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error('Error fetching event detail',
                e: snapshot.error, s: snapshot.stackTrace);
            return const Center(child: Text('Gagal memuat data.'));
          }

          final detailedEvent = snapshot.data;

          if (detailedEvent == null) {
            return const Center(child: Text('Pengumuman tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detailedEvent.linkGambar.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      detailedEvent.linkGambar,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, st) {
                        Log.error(
                            'Gagal memuat gambar detail: ${detailedEvent.linkGambar}',
                            e: e,
                            s: st);
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(TIcons.error, size: 50),
                        );
                      },
                    ),
                  ),
                gapH16,
                Row(
                  children: [
                    Chip(
                      label: Text(
                          detailedEvent.statusAktif ? 'Aktif' : 'Tidak Aktif'),
                      backgroundColor: detailedEvent.statusAktif
                          ? Colors.green.withAlpha(25) // Menggunakan withAlpha
                          : Colors.grey.withAlpha(25), // Menggunakan withAlpha
                      labelStyle: TextStyle(
                        color: detailedEvent.statusAktif
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dibuat: ${detailedEvent.tanggalDibuat.toLocal().toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                gapH16,
                const Text(
                  'ID Pengumuman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(detailedEvent.id,
                    style: Theme.of(context).textTheme.bodyMedium),
                gapH16,
                const Text(
                  'Deskripsi / Konten',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                gapH8,
                Text(
                  'Detail informasi untuk pengumuman ini dapat dikelola melalui menu manajemen.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: ElevatedButton.icon(
          onPressed: () {
            // Logika untuk edit bisa ditambahkan di sini
            Log.info('Tombol edit untuk ${event.id} ditekan');
          },
          icon: const Icon(TIcons.edit),
          label: const Text('Edit Pengumuman'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}
