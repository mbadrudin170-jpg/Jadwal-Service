// path: lib/admin/halaman/lainnya/event_page_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_firebase.dart';

class EventPageU extends ConsumerWidget {
  const EventPageU({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        actions: [
          IconButton(
            icon: const Icon(TIcons.refresh),
            tooltip: 'Muat Ulang Pengumuman',
            onPressed: () {
              ref.invalidate(eventOpFirebaseProvider);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<EventModel>>(
        future: ref.read(eventOpFirebaseProvider).getAll(),
        builder: (final context, final snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Log.error('Error saat memuat pengumuman: ${snapshot.error}',
                e: snapshot.error, st: snapshot.stackTrace);
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat pengumuman.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada pengumuman.'),
            );
          } else {
            final announcements = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(TSizes.p16),
              itemCount: announcements.length,
              itemBuilder: (final context, final index) {
                final announcement = announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: TSizes.p16),
                  child: ListTile(
                    leading: announcement.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              announcement.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                Log.error(
                                    'Gagal memuat gambar: ${announcement.imageUrl}',
                                    e: error,
                                    st: stackTrace);
                                return const Icon(TIcons.error);
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
                        : null,
                    title: Text(
                      'ID: ${announcement.id.length > 50 ? '${announcement.id.substring(0, 50)}...' : announcement.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gapH8,
                        Text(
                            'Dibuat: ${announcement.createdAt.toLocal().toString().split(' ')[0]}'),
                        if (announcement.isActive)
                          Chip(
                            label: const Text('Aktif'),
                            avatar: const Icon(TIcons.toggleOn, size: 18),
                            backgroundColor: Colors.green.withAlpha(16),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          )
                        else
                          Chip(
                            label: const Text('Tidak Aktif'),
                            avatar: const Icon(TIcons.toggleOff, size: 18),
                            backgroundColor: Colors.grey.withAlpha(16),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                      ],
                    ),
                    onTap: () {
                      try {
                        Log.info('Pengumuman ${announcement.id} diklik');
                        // Navigasi atau aksi lainnya
                      } catch (e, st) {
                        Log.error('Error saat menangani klik pengumuman', e: e, st: st);
                      }
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
