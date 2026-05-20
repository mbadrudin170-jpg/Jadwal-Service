// path: lib/user/page/main_page.dart
// diubah: Menambahkan remove() splash screen untuk transisi mulus.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/penjadwal_notifikasi.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/user/page/profile_page.dart';
import 'package:wifi/user/page/settings_page_user.dart';
import 'package:wifi/user/page/subscription_history_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman utama aplikasi yang berfungsi sebagai container untuk navigasi bawah.
class MainPage extends StatefulWidget {
  final String userId;
  final LocalStorageService localStorageService;

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
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    // Menghilangkan splash screen di sini agar transisi mulus.
    FlutterNativeSplash.remove();
    _pages = [
      ProfilePage(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
      SubscriptionHistoryPage(
        userId: widget.userId,
      ),
      SettingsPageUser(
        userId: widget.userId,
        localStorageService: widget.localStorageService,
      ),
    ];
    Log.info(
        'MainPage diinisialisasi untuk pengguna dengan ID: ${widget.userId}');
    // Memanggil logika penjadwalan notifikasi dari file terpisah.
    unawaited(
        PenjadwalNotifikasi.aturNotifikasiLangganan(context, widget.userId));
  }

  void _onItemTapped(final int index) {
    Log.info('Item navigasi diketuk: index $index');
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun MainPage untuk indeks halaman: $_selectedIndex');

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(AppIcons.person), label: 'Profil'),
          BottomNavigationBarItem(
              icon: Icon(AppIcons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(AppIcons.settings), label: 'Pengaturan'),
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
