// path: lib/user/page/main_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/notfikasi/penjadwal_notifikasi.dart';
import 'package:wifi/fitur/order/ui/user/order_page.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/user/page/profile_page.dart';
import 'package:wifi/user/page/settings_page_user.dart';
import 'package:wifi/user/page/subscription_history_user.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/widget/ads/app_open/app_lifecycle_reactor.dart';
import 'package:wifi/user/widget/ads/app_open/app_open_ad_service.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

/// Halaman utama aplikasi yang berfungsi sebagai container untuk navigasi bawah.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late final AppLifecycleReactor _appLifecycleReactor;
  final AppOpenAdService _appOpenAdService = AppOpenAdService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await ref.read(userIdProvider.future);
      if (userId != null) {
        final notifikasiServis = ref.read(notifikasiServisProvider);
        PenjadwalNotifikasi.aturNotifikasiLangganan(
          notifikasiServis,
          userId,
        );

        final userActivityService =
            await ref.read(userActivityServiceProvider.future);
        await userActivityService.pingActivity(userId);
      }
    });

    _pages = [
      const ProfilePage(),
      const SubscriptionHistoryPage(),
      const OrderPage(),
      const SettingsPageUser(),
    ];
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdService: _appOpenAdService);
    _appLifecycleReactor.listenToAppStateChanges();
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
          const BannerAdsWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(TIcons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(TIcons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(TIcons.pesanan),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(TIcons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
