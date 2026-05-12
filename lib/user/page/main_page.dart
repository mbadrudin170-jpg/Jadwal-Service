// path: lib/user/page/main_page.dart
// diubah: Memperbaiki semua path impor yang salah dan menambahkan tab pengaturan.
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:wifi/user/page/home_page.dart';
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    log(
      '[Inisialisasi State] ✅ Memulai inisialisasi state untuk MainPage dengan userId: ${widget.userId}.',
      name: 'main_page.dart',
    );
    _pages = [
      ProfilPage(
          userId: widget.userId,
          localStorageService: widget.localStorageService),
      HomePage(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
      PengaturanPage(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
    ];
    log(
      '[Inisialisasi Halaman] ✅ Daftar halaman (pages) telah berhasil dibuat. Memulai pada tab index ke-$_selectedIndex.',
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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Transaksi',
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
