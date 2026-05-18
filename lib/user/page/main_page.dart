// path: lib/user/page/main_page.dart
// diubah: Logika penjadwalan notifikasi telah dipindahkan ke file terpisah.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/penjadwal_notifikasi.dart';
import 'package:wifi/user/page/profile_page.dart';
import 'package:wifi/user/page/settings_page_user.dart';
import 'package:wifi/user/page/subscription_history_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman utama aplikasi yang berfungsi sebagai container untuk navigasi bawah.
///
/// Menampilkan halaman berbeda berdasarkan item yang dipilih di BottomNavigationBar.
class MainPage extends StatefulWidget {
  /// ID unik pengguna yang sedang login.
  final String userId;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService localStorageService;

  /// Konstruktor untuk [MainPage].
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
        'MainPage diinisialisasi untuk pengguna dengan ID: ${widget.userId}');
    // Memanggil logika penjadwalan notifikasi dari file terpisah.
    unawaited(PenjadwalNotifikasi.aturNotifikasiLangganan(context, widget.userId));
  }

  void _onItemTapped(final int index) {
    Log.info('Item navigasi diketuk: index $index');
    setState(() {
      _selectedIndex = index;
      Log.info('Indeks halaman diubah menjadi: $_selectedIndex');
    });
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun MainPage untuk indeks halaman: $_selectedIndex');

    final List<Widget> pages = [
      ProfilePage(
          userId: widget.userId,
          localStorageService: widget.localStorageService),
      SubscriptionHistoryPage(userId: widget.userId),
      SettingsPageUser(
          userId: widget.userId,
          localStorageService: widget.localStorageService),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    Log.info('MainPage sedang di-dispose');
    super.dispose();
  }
}
