// path: lib/user/page/main_page.dart
// DITAMBAHKAN: Implementasi App Open Ad saat aplikasi kembali aktif.
// PERBAIKAN: Menunda inisialisasi berat untuk mencegah jank/lag saat startup.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/notifikasi/penjadwal_notifikasi.dart';
import 'package:wifi/shared/services/user_activity_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/user/page/profile_page.dart';
import 'package:wifi/user/page/settings_page_user.dart';
import 'package:wifi/user/page/subscription_history_user.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';
import 'package:wifi/user/widget/ads/app_open/app_lifecycle_reactor.dart';
import 'package:wifi/user/widget/ads/app_open/app_open_ad_service.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

/// Halaman utama aplikasi yang berfungsi sebagai container untuk navigasi bawah.
class MainPage extends StatefulWidget {
  /// ID unik pengguna yang sedang login.
  final String userId;

  /// Layanan untuk mengakses penyimpanan lokal.
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
  late final List<Widget> _pages;
  late final AppLifecycleReactor _appLifecycleReactor;
  final AppOpenAdService _appOpenAdService = AppOpenAdService();

  @override
  void initState() {
    super.initState();
    unawaited(
        PenjadwalNotifikasi.aturNotifikasiLangganan(context, widget.userId));
    unawaited(UserActivityService().pingActivity(widget.userId));
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

    // Inisialisasi AppLifecycleReactor untuk iklan. Konstruktornya ringan.
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdService: _appOpenAdService);
    _appLifecycleReactor.listenToAppStateChanges();

    Log.info(
        'MainPage diinisialisasi untuk pengguna dengan ID: ${widget.userId}');

    // Hapus splash screen agar UI dasar aplikasi terlihat.
    FlutterNativeSplash.remove();
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
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          BannerWaterfallWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(AppIcons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
