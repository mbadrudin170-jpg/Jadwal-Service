// path: lib/user/page/main_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/investasi/page/portofolio.dart';
import 'package:wifi/fitur/notifikasi/pengingat_paket_belum_lunas.dart';
import 'package:wifi/fitur/notifikasi/penjadwal_notifikasi.dart';
import 'package:wifi/fitur/order/page/order_page.dart';
import 'package:wifi/fitur/settings/page/settings_page_u.dart';
import 'package:wifi/fitur/speedtest/page/uji_kecepatan_page.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_u.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/user/page/profile_page.dart';
import 'package:wifi/user/providers/user_provider.dart';
import 'package:wifi/user/widget/ads/app_open/app_lifecycle_reactor.dart';
import 'package:wifi/user/widget/ads/app_open/app_open_ad_service.dart';
import 'package:wifi/user/widget/ads/banner/banner_ads_widget.dart';

/// Halaman utama aplikasi yang berfungsi sebagai container untuk navigasi bawah.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _indeksTerpilih = 0;
  late final List<Widget> _daftarHalaman;
  late final AppLifecycleReactor _reaktorSiklusHidup;
  final LayananIklanBukaAplikasi _layananIklanBukaAplikasi =
      LayananIklanBukaAplikasi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await ref.read(userIdProvider.future);
      if (userId != null) {
        final notifikasiServis = ref.read(layananNotifikasiProvider);
        unawaited(
          PenjadwalNotifikasi.aturNotifikasiLangganan(notifikasiServis, userId),
        );
        final layananAktivitasUser = await ref.read(
          layananAktivitasUserProvider.future,
        );
        unawaited(layananAktivitasUser.pingAktivitas(userId));
        final pengingatService = ref.read(pengingatServiceProvider);
        unawaited(pengingatService.cekDanTampilkanPengingatTagihan());
      }
    });
    final halamanDasar = <Widget>[
      const ProfilePage(),
      const TransaksiU(),
      const OrderPage(),
    ];
    final halamanTambahan = <Widget>[
      if (ref.isInvestor) const HalamanPortofolio(),
      if (!ref.isInvestor) const HalamanUjiKecepatan(),
      const SettingsPageU(),
    ];
    _daftarHalaman = [...halamanDasar, ...halamanTambahan];
    _reaktorSiklusHidup = AppLifecycleReactor(
      appOpenAdService: _layananIklanBukaAplikasi,
    );
    _reaktorSiklusHidup.listenToAppStateChanges();
    FlutterNativeSplash.remove();
  }

  void _ketikaItemDiketuk(int index) {
    Log.info('Item navigasi diketuk: index $index');
    if (_indeksTerpilih == index) {
      return;
    }
    setState(() {
      _indeksTerpilih = index;
    });
  }
  // path: lib/user/page/main_page.dart

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun MainPage untuk indeks halaman: $_indeksTerpilih');

    // ✅ Buat daftar item navigasi secara dinamis
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(TIcons.person), label: 'Profil'),
      const BottomNavigationBarItem(
        icon: Icon(TIcons.history),
        label: 'Riwayat',
      ),
      const BottomNavigationBarItem(
        icon: Icon(TIcons.pesanan),
        label: 'Pesanan',
      ),
      // ✅ Tambahkan item Portofolio jika investor
      if (ref.isInvestor)
        const BottomNavigationBarItem(
          icon: Icon(TIcons.money),
          label: 'Portofolio',
        ),
      const BottomNavigationBarItem(
        icon: Icon(TIcons.speed),
        label: 'Uji Speed',
      ),
      const BottomNavigationBarItem(
        icon: Icon(TIcons.settings),
        label: 'Pengaturan',
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _indeksTerpilih,
              children: _daftarHalaman,
            ),
          ),
          const BannerAdsWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: navItems, // ✅ Gunakan navItems dinamis
        currentIndex: _indeksTerpilih,
        onTap: _ketikaItemDiketuk,
      ),
    );
  }
}
