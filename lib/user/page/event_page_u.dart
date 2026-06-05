// path: lib/user/page/event_page_u.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/event_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/event_op_supabase.dart';

final activeAnnouncementProvider =
    FutureProvider.autoDispose<EventModel?>((ref) async {
  final operator = ref.watch(eventOpSupabaseProvider);
  return operator.getActive();
});

class EventPageU extends ConsumerStatefulWidget {
  // DIHAPUS: Tidak perlu lagi callback onDone.
  const EventPageU({super.key});

  @override
  ConsumerState<EventPageU> createState() => _EventPageUState();
}

class _EventPageUState extends ConsumerState<EventPageU> {
  Timer? _timer;
  final Duration _pageDuration = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(_pageDuration, () {
      // Setelah durasi selesai, tutup halaman ini.
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(final BuildContext context) {
    final announcementAsync = ref.watch(activeAnnouncementProvider);
    return Scaffold(
      body: announcementAsync.when(
        loading: Container.new,
        error: (e, st) {
          Log.error('Error saat memuat pengumuman', e: e, st: st);
          // Jika error, langsung tutup halaman ini.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        },
        data: (data) {
          if (data == null) {
            // Jika tidak ada pengumuman, langsung tutup halaman ini.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop();
            });
            return const SizedBox.shrink();
          }

          // Mulai timer HANYA setelah data siap.
          if (_timer == null) {
            _startTimer();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              if (data.imageUrl.isNotEmpty)
                Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Jika gambar gagal dimuat, langsung tutup halaman ini.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) Navigator.of(context).pop();
                    });
                    return const SizedBox.shrink();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                )
              else
                // Jika URL gambar kosong, langsung tutup halaman ini.
                const Center(child: Text('Gambar tidak tersedia.')),
              Positioned(
                top: 40,
                left: 16,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _timer?.cancel(); // Hentikan timer jika ditutup manual
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
