// path: lib/user/page/event_page_u.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';

// Menggunakan FutureProvider agar data di-cache dan tidak melakukan re-fetch terus-menerus
final activeAnnouncementsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final operator = ref.watch(eventOpSupabaseProvider);
  final allEvents = await operator.getAll();
  // Filter hanya pengumuman yang aktif untuk aplikasi pengguna
  return allEvents.where((e) => e.isActive).toList();
});

class EventPageU extends ConsumerWidget {
  const EventPageU({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final announcementsAsync = ref.watch(activeAnnouncementsProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: announcementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          Log.error('Error saat memuat pengumuman', e: error, st: stackTrace);
          return const Center(
              child: Text('Gagal memuat pengumuman.',
                  style: TextStyle(color: Colors.white)));
        },
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(child: Text('Tidak ada pengumuman aktif.'));
          }
          // Menggunakan PageView agar pengguna bisa menggeser (swipe) gambar full screen ke kanan/kiri
          return PageView.builder(
            itemCount: announcements.length,
            itemBuilder: (final context, final index) {
              final announcement = announcements[index];

              if (announcement.imageUrl.isEmpty) {
                return const Center(child: Text('Gambar tidak tersedia.'));
              }

              return Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    Colors.black, // Background hitam saat gambar sedang dimuat
                child: Image.network(
                  announcement.imageUrl,
                  // PENTING: BoxFit.cover membuat gambar memenuhi seluruh layar
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    Log.error(
                        'Gagal memuat gambar full screen: ${announcement.imageUrl}');
                    return const Center(
                      child: Icon(TIcons.error, color: Colors.white, size: 50),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
