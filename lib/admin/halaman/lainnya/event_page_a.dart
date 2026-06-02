// path: lib/admin/halaman/lainnya/event_page_a.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';

/// Provider untuk mengambil daftar pengumuman secara asinkron.
final announcementsFutureProvider = FutureProvider.autoDispose((ref) async {
  final operator = ref.watch(eventOpSupabaseProvider);
  return await operator.getAll();
});

class EventPageA extends ConsumerWidget {
  const EventPageA({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    // Tonton state dari FutureProvider
    final announcementsAsync = ref.watch(announcementsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(announcementsFutureProvider.future),
        child: announcementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            Log.error('Error saat memuat pengumuman: $error',
                e: error, st: stackTrace);
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(TSizes.p16),
                child: Text(
                  'Gagal memuat pengumuman.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          data: (announcements) {
            if (announcements.isEmpty) {
              return const Center(child: Text('Belum ada pengumuman.'));
            }

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
                      'ID: ${announcement.id.length > 30 ? '${announcement.id.substring(0, 30)}...' : announcement.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        gapH8,
                        Text(
                            'Dibuat: ${announcement.createdAt.toLocal().toString().split(' ')[0]}'),
                        gapH4,
                        Chip(
                          label: Text(
                              announcement.isActive ? 'Aktif' : 'Tidak Aktif'),
                          avatar: Icon(
                            announcement.isActive
                                ? TIcons.toggleOn
                                : TIcons.toggleOff,
                            size: 18,
                            color: announcement.isActive
                                ? Colors.green
                                : Colors.grey,
                          ),
                          backgroundColor: announcement.isActive
                              ? Colors.green.withValues(alpha: 0.08)
                              : Colors.grey.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
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
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ManageAnnouncementPage()),
          );
        },
        child: const Icon(TIcons.add),
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
