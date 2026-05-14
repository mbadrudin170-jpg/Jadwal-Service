// path: lib/user/page/main_page.dart
// diubah: Mengganti penggunaan log dari dart:developer menjadi Log.info dari shared/debug/log.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/page/pengaturan_user.dart';
import 'package:wifi/user/page/profil_page.dart';
import 'package:wifi/user/page/riwayat_langganan_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman utama aplikasi yang berfungsi sebagai container untuk navigasi bawah.
///
/// Mengelola halaman-halaman utama seperti [ProfilPage], [RiwayatLanggananPage],
/// dan [PengaturanPageUser].
class MainPage extends StatefulWidget {
  /// ID pengguna yang sedang login.
  final String userId;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Membuat instance dari [MainPage].
  const MainPage({
    super.key,
    required this.userId,
    required this.localStorageService,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Log.info(
      '[Inisialisasi State] ✅ Memulai inisialisasi state untuk MainPage dengan userId: ${widget.userId}.',
    );
  }

  void _onItemTapped(final int index) {
    Log.info(
      '[Aksi Navigasi] ✅ Pengguna menekan item navigasi. Index baru: $index, Index sebelumnya: $_selectedIndex.',
    );
    setState(() {
      _selectedIndex = index;
      Log.info(
        '[Pembaruan State] ✅ State _selectedIndex berhasil diperbarui menjadi $index. UI akan di-rebuild.',
      );
    });
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      '[Pembangunan UI] ✅ Membangun UI untuk MainPage. Halaman yang ditampilkan saat ini adalah index: $_selectedIndex.',
    );

    final List<Widget> pages = [
      ProfilPage(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
      RiwayatLanggananPage(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
      PengaturanPageUser(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    Log.info(
      '[Pembersihan State] ✅ Membersihkan state MainPage saat widget dihancurkan.',
    );
    super.dispose();
  }
}
