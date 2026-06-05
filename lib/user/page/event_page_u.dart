// path: lib/user/page/event_page_u.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class EventPageU extends ConsumerStatefulWidget {
  const EventPageU({super.key});

  @override
  ConsumerState<EventPageU> createState() => _EventPageUState();
}

class _EventPageUState extends ConsumerState<EventPageU> {
  // Controller untuk mengontrol halaman pada PageView
  final PageController _pageController = PageController();
  // Timer untuk perpindahan otomatis
  Timer? _timer;
  // Durasi setiap halaman ditampilkan
  final Duration _pageDuration = const Duration(seconds: 5);
  // Indeks halaman saat ini
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Sembunyikan UI sistem untuk pengalaman fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Kembalikan UI sistem saat halaman ditutup
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Hentikan timer dan hapus controller untuk mencegah memory leak
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk memulai atau mereset timer
  void _startTimer(int totalPages) {
    _timer?.cancel(); // Batalkan timer yang ada jika ada
    _timer = Timer.periodic(_pageDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // Jika bukan halaman terakhir, pindah ke halaman berikutnya
      if (_currentPage < totalPages - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        // Jika sudah di halaman terakhir, tutup halaman event
        timer.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  // Fungsi untuk menangani aksi tap pada layar
  void _handleTap(TapDownDetails details, int totalPages) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Jika tap di sepertiga kanan layar, pindah ke halaman berikutnya
    if (details.globalPosition.dx > screenWidth * 2 / 3) {
      if (_currentPage < totalPages - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        Navigator.of(context).pop();
      }
    } 
    // Jika tap di sepertiga kiri layar, kembali ke halaman sebelumnya
    else if (details.globalPosition.dx < screenWidth / 3) {
      if (_currentPage > 0) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }
    // Reset timer setiap kali ada interaksi tap
    _startTimer(totalPages);
  }

  @override
  Widget build(final BuildContext context) {
    final announcementsAsync = ref.watch(activeAnnouncementsProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: announcementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          Log.error('Error saat memuat pengumuman', e: error, st: stackTrace);
          return const Center(
            child: Text(
              'Gagal memuat pengumuman.',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
        data: (announcements) {
          if (announcements.isEmpty) {
            // Jika tidak ada pengumuman, langsung tutup halaman
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
            return const SizedBox.shrink();
          }

          // Mulai timer jika belum berjalan
          if (_timer == null) {
            _startTimer(announcements.length);
          }

          return GestureDetector(
            onTapDown: (details) => _handleTap(details, announcements.length),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: announcements.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    // Reset timer setiap kali pengguna swipe manual
                    _startTimer(announcements.length);
                  },
                  itemBuilder: (final context, final index) {
                    final announcement = announcements[index];

                    if (announcement.imageUrl.isEmpty) {
                      return const Center(child: Text('Gambar tidak tersedia.'));
                    }

                    return Image.network(
                      announcement.imageUrl,
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
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    );
                  },
                ),
                // Tombol kembali
                Positioned(
                  top: 40,
                  left: 16,
                  child: Material(
                    color: Colors.black.withOpacity(0.3),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
