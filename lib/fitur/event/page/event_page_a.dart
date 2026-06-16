// path: lib/fitur/event/page/event_page_a.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/event/page/detail_event_a.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';

/// Menggunakan StreamProvider dengan proteksi siklus hidup
final announcementsStreamProvider = StreamProvider.autoDispose<List<EventModel>>((
  ref,
) {
  final operator = ref.watch(eventOpSupabaseProvider);

  // Mencegah provider langsung dihancurkan saat layar sedikit bergeser/rebuild
  final link = ref.keepAlive();

  // Pastikan stream ditutup bersih saat halaman BENAR-BENAR ditinggalkan (di-pop)
  ref.onDispose(() {
    Log.warning(
      'announcementsStreamProvider: Menutup stream dan membersihkan memori.',
    );
    link.close();
  });

  return operator.ambilRealtimeStream();
});

class EventPageA extends ConsumerWidget {
  const EventPageA({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Tonton state dari StreamProvider terbaru
    final announcementsAsync = ref.watch(announcementsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman Realtime')),
      // 3. RefreshIndicator sekarang opsional karena data sudah otomatis realtime.
      // Namun tetap dipertahankan jika pengguna ingin memaksa pembersihan cache/sinkronisasi ulang.
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(announcementsStreamProvider.future),
        child: announcementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            Log.error(
              'Error saat memuat pengumuman realtime: $error',
              e: error,
              s: stackTrace,
            );
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
              // Tambahkan physics AlwaysScrollableScrollPhysics agar RefreshIndicator
              // tetap berfungsi normal meskipun jumlah item sedikit.
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: announcements.length,
              itemBuilder: (final context, final index) {
                final announcement = announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: TSizes.p16),
                  child: ListTile(
                    leading: announcement.linkGambar.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              announcement.linkGambar,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, e, st) {
                                Log.error(
                                  'Gagal memuat gambar: ${announcement.linkGambar}',
                                  e: e,
                                  s: st,
                                );
                                return const Icon(TIcons.error);
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
                          'Dibuat: ${announcement.tanggalDibuat.toLocal().toString().split(' ')[0]}',
                        ),
                        gapH4,
                        Chip(
                          label: Text(
                            announcement.statusAktif ? 'Aktif' : 'Tidak Aktif',
                          ),
                          avatar: Icon(
                            announcement.statusAktif
                                ? TIcons.toggleOn
                                : TIcons.toggleOff,
                            size: 18,
                            color: announcement.statusAktif
                                ? Colors.green
                                : Colors.grey,
                          ),
                          backgroundColor: announcement.statusAktif
                              ? Colors.green.withValues(alpha: 0.08)
                              : Colors.grey.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ),
                    onTap: () {
                      Log.info('Menavigasi ke detail pengumuman.', {
                        'id': announcement.id,
                      });
                      unawaited(
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                DetailEventA(event: announcement),
                          ),
                        ),
                      );
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
          Log.info('Membuka halaman untuk mengelola pengumuman baru.');
          unawaited(
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ManageAnnouncementPage(),
              ),
            ),
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
