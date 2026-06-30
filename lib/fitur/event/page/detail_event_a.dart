// path: lib/fitur/event/page/detail_event_a.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/form_event.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';

class DetailEventA extends ConsumerWidget {
  final EventModel event;
  const DetailEventA({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureEvent = ref
        .watch(eventOpSupabaseProvider)
        .ambilBerdasarkanId(event.id);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: FutureBuilder<EventModel?>(
        future: futureEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            Log.error(
              'Error fetching event detail',
              e: snapshot.error,
              s: snapshot.stackTrace,
            );
            return const Center(child: Text('Gagal memuat data.'));
          }

          final detailEvent = snapshot.data;

          if (detailEvent == null) {
            return const Center(child: Text('Pengumuman tidak ditemukan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detailEvent.linkGambar.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: CachedNetworkImage(
                      imageUrl: detailEvent.linkGambar,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, e) {
                        Log.error(
                          'Gagal memuat gambar detail: ${detailEvent.linkGambar}',
                          e: e,
                        );
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
                        detailEvent.statusAktif ? 'Aktif' : 'Tidak Aktif',
                      ),
                      backgroundColor: detailEvent.statusAktif
                          ? Colors.green.withAlpha(25) // Menggunakan withAlpha
                          : Colors.grey.withAlpha(25), // Menggunakan withAlpha
                      labelStyle: TextStyle(
                        color: detailEvent.statusAktif
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dibuat: ${FormatTanggal.formatSingkat(event.tanggalDibuat)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                gapH16,
                const Text(
                  'ID Pengumuman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  detailEvent.id,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                gapH16,
                const Text(
                  'Deskripsi / Konten',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (context) => FormEvent(event: event)),
            );
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
