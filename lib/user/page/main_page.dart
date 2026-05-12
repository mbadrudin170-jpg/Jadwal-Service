// path: lib/user/page/main_page.dart
// diubah: Memindahkan inisialisasi _pages ke dalam method build untuk mengatasi RangeError.
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wifi/user/page/riwayat_langganan_user.dart';
import 'package:wifi/user/page/pengaturan_user.dart';
import 'package:wifi/user/page/profil_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

class MainPage extends StatefulWidget {
  final String userId;
  final LocalStorageService localStorageService;

  const MainPage(
      {super.key, required this.userId, required this.localStorageService});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    log(
      '[Inisialisasi State] ✅ Memulai inisialisasi state untuk MainPage dengan userId: ${widget.userId}.',
      name: 'main_page.dart',
    );
  }

  void _onItemTapped(int index) {
    log(
      '[Aksi Navigasi] ✅ Pengguna menekan item navigasi. Index baru: $index, Index sebelumnya: $_selectedIndex.',
      name: 'main_page.dart',
    );
    setState(() {
      _selectedIndex = index;
      log(
        '[Pembaruan State] ✅ State _selectedIndex berhasil diperbarui menjadi $index. UI akan di-rebuild.',
        name: 'main_page.dart',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    log(
      '[Pembangunan UI] ✅ Membangun UI untuk MainPage. Halaman yang ditampilkan saat ini adalah index: $_selectedIndex.',
      name: 'main_page.dart',
    );

    final List<Widget> pages = [
      ProfilPage(
          userId: widget.userId,
          localStorageService: widget.localStorageService),
      RiwayatLanggananPage(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
      PengaturanPage(
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
    log(
      '[Pembersihan State] ✅ Membersihkan state MainPage saat widget dihancurkan.',
      name: 'main_page.dart',
    );
    super.dispose();
  }
}
