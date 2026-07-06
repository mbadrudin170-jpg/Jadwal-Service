
// File: lib/fitur/app_role/role_util.dart

```dart
// path: lib/shared/utils/role_util.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/app_role/app_role_enum.dart';
import 'package:wifi/shared/debug/log.dart';

part 'role_util.g.dart';

@Riverpod(keepAlive: true)
AppRole appRole(Ref ref) {
  final akunState = ref.watch(pengelolaAkunProvider);
  final role = akunState.value?.akunSaatIni?.role ?? AppRole.user;
  Log.info('Role saat ini: ${role.name} (dari pengelolaAkunProvider)');
  return role;
}

class RoleUtil {
  static bool isAdmin(Ref ref) {
    final role = ref.watch(appRoleProvider);
    Log.info('Role saat ini: ${role.name}'); // ← lihat log ini
    return role == AppRole.admin;
  }

  static bool isUser(Ref ref) {
    return ref.watch(appRoleProvider) == AppRole.user;
  }

  static bool isInvestor(Ref ref) {
    return ref.watch(appRoleProvider) == AppRole.investor;
  }

  static bool hasRole(Ref ref, AppRole role) {
    return ref.watch(appRoleProvider) == role;
  }

  static Future<bool> isAdminAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role == AppRole.admin;
  }

  static Future<bool> isUserAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role == AppRole.user;
  }

  static Future<bool> hasRoleAsync(Ref ref, AppRole role) async {
    final currentRole = ref.watch(appRoleProvider);
    return currentRole == role;
  }

  static String getRoleName(Ref ref) {
    return ref.watch(appRoleProvider).name;
  }

  static Future<String> getRoleNameAsync(Ref ref) async {
    final role = ref.watch(appRoleProvider);
    return role.name;
  }
}

extension RoleExtension on WidgetRef {
  /// Mengecek apakah pengguna saat ini adalah admin.
  bool get isAdmin => watch(appRoleProvider) == AppRole.admin;

  /// Mengecek apakah pengguna saat ini adalah user.
  bool get isUser => watch(appRoleProvider) == AppRole.user;

  bool get isInvestor => watch(appRoleProvider) == AppRole.investor;

  /// Mengecek apakah pengguna saat ini memiliki role yang sama dengan [role].
  bool hasRole(AppRole role) => watch(appRoleProvider) == role;

  /// Mendapatkan role saat ini.
  AppRole get currentRole => watch(appRoleProvider);
}
```

// File: lib/fitur/settings/page/settings_page_u.dart

```dart
// path lib/fitur/settings/page/settings_page_u.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/admin/halaman/tes/halaman_tes.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/feedback/page/feedback_page.dart';
import 'package:wifi/fitur/info_perangkat/page/info_apk_page_user.dart';
import 'package:wifi/fitur/investor/page/portofolio.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/user/widget/theme_menu_widget.dart';

class SettingsPageU extends ConsumerWidget {
  const SettingsPageU({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: TSizes.p8),
        children: <Widget>[
          _SettingsMenuItem(
            icon: TIcons.theme,
            title: 'Tema Aplikasi',
            trailing: Consumer(
              builder: (context, ref, child) {
                final themeAsync = ref.watch(temaProvider);
                return themeAsync.when(
                  data: (themeMode) => ThemeMenuWidget(
                    currentThemeMode: themeMode,
                    onThemeSelected: (mode) {
                      unawaited(
                        ref.read(temaProvider.notifier).simpanModeTema(mode),
                      );
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const Icon(TIcons.error),
                );
              },
            ),
          ),
          _SettingsMenuItem(
            icon: TIcons.feedback,
            title: 'Kritik dan Saran',
            onTap: () async {
              Log.info('Navigasi ke halaman riwayat masukan.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          _SettingsMenuItem(
            icon: TIcons.infoOutlined,
            title: 'Info Aplikasi & Perangkat',
            onTap: () async {
              Log.info('Navigasi ke halaman info aplikasi.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const InfoApkPageUser(),
                ),
              );
            },
          ),

          if (ref.isInvestor)
            _SettingsMenuItem(
              icon: TIcons.money,
              title: 'Portofolio Saya',
              onTap: () async {
                Log.info('Navigasi ke halaman portofolio investor.');
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const HalamanPortofolio(),
                  ),
                );
              },
            ),

          // Hanya tampilkan tombol ini dalam mode debug
          if (kDebugMode)
            _SettingsMenuItem(
              icon: TIcons.science,
              title: 'Halaman Uji Fitur',
              onTap: () async {
                Log.info('Navigasi ke halaman tes fitur.');
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const HalamanTes(),
                  ),
                );
              },
            ),
          _SettingsMenuItem(
            icon: TIcons.logout,
            title: 'Ganti Akun/Keluar',
            isDestructive: true,
            onTap: () async {
              Log.info('Navigasi ke halaman daftar akun untuk ganti akun.');
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const DaftarAkunPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Widget kustom untuk item menu di halaman pengaturan.
class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(final BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : null;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: TextStyle(color: color)),
          trailing: trailing,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 4,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}
```

// File: lib/main/main_user/bootstrap_user.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/shared/constant/app_constants.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/user/app_user.dart';

Future<void> bootstrapUser({
  required FirebaseOptions firebaseOptions,
  required String logPrefix,
}) async {
  // Memastikan binding Flutter siap dan menahan native splash screen.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Log.info('Memuat variabel lingkungan dari file .env...');
  await dotenv.load();
  Log.info('Variabel lingkungan berhasil dimuat.');

  Log.info('Menginisialisasi Firebase...');
  await Firebase.initializeApp(options: firebaseOptions);

  Log.info('Inisialisasi Firebase selesai.');
  await SharedPreferences.getInstance();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  Log.info('Menginisialisasi Supabase...');
  final supabaseUrl = dotenv.env[AppConstants.supabaseUrlKey]!;
  final supabasePublishableKey =
      dotenv.env[AppConstants.supabasePublishableKey]!;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  Log.info('Inisialisasi Supabase selesai.');

  Log.info('Menginisialisasi workmanager');
  await LayananLatarBelakang.inisialisasi();

  Log.info('Menginisialisasi GmaMediationUnity');
  await GmaMediationUnity().setGDPRConsent(true);
  await GmaMediationUnity().setCCPAConsent(true);

  Log.info('Menginisialisasi MobileAds');
  await MobileAds.instance.initialize();
  Intl.defaultLocale = 'id_ID';

  Log.info(
    '$logPrefix Memulai aplikasi user. Menyerahkan kendali ke AppUser...',
  );

  // Native splash akan dihilangkan dari dalam SplashScreenUser.
  runApp(const ProviderScope(child: AppUser()));
}
```

// File: lib/user/page/main_page.dart

```dart
// path: lib/user/page/main_page.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/chating/chating_dashboard.dart';
import 'package:wifi/fitur/investor/page/portofolio.dart';
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
      if (kDebugMode) const ChatingDashboard() else const HalamanUjiKecepatan(),
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

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun MainPage untuk indeks halaman: $_indeksTerpilih');
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
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(TIcons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(TIcons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(TIcons.pesanan), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(TIcons.speed), label: 'Uji Speed'),
          BottomNavigationBarItem(
            icon: Icon(TIcons.settings),
            label: 'Pengaturan',
          ),
        ],
        currentIndex: _indeksTerpilih,
        onTap: _ketikaItemDiketuk,
      ),
    );
  }
}
```

// File: lib/user/page/splash_screen_user.dart

```dart
// path: lib/user/page/splash_screen_user.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/fitur/event/page/event_page_u.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/notifikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_firebase.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/page/update_apk_page_u.dart';
import 'package:wifi/fitur/versi_apk/service/layanan_cek_update_apk.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/future_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_provider.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';
import 'package:wifi/user/widget/ads/interstitial/id_interstitial_ads.dart';

/// Record yang berisi informasi tentang pembaruan aplikasi.
typedef InfoPembaruanRecord = ({
  bool isUpdateRequired,
  VersiApkModel? apkInfo,
  InfoPerangkatModel? packageInfo,
  ArsitekturApk? architecture,
});

class SplashScreenUser extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final LayananPenyimpananLokal penyimpananLokal;

  const SplashScreenUser({
    super.key,
    required this.prefs,
    required this.penyimpananLokal,
  });

  @override
  ConsumerState<SplashScreenUser> createState() => _SplashScreenUserState();
}

class _SplashScreenUserState extends ConsumerState<SplashScreenUser> {
  final SettingsOpFirebase _settingsOp = SettingsOpFirebase();
  final idUnitIklan = interstitialAdUnitIds[0];

  bool _terhubung = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inisialisasiAplikasi();
    });
  }

  Future<void> _inisialisasiAplikasi() async {
    try {
      Log.info('Memulai inisialisasi dari Splash Screen...');
      await _inisialisasiLayananOffline();

      _terhubung = await ref.read(koneksiInternetServiceProvider).cekInternet();
      if (_terhubung == false) {
        if (mounted) {
          ToastUtil.info(context, 'Anda sedang offline.');
        }
        FlutterNativeSplash.remove();
        await _navigasiKeHalamanBerikutnya();
        return;
      }

      // 1. Ambil seluruh data dari server secara paralel (bersamaan)
      final hasilInisialisasi = await futureWait([
        _periksaModePemeliharaan(),
        _periksaPembaruanAplikasi(),
        _cekEvent(),
      ]);
      final pengaturanPemeliharaan = hasilInisialisasi[0] as SettingsModel?;
      final infoPembaruan = hasilInisialisasi[1] as InfoPembaruanRecord?;
      final eventInfo = hasilInisialisasi[2] as EventModel?;
      if (!mounted) return;

      // 2. Tampilkan Event Terlebih Dahulu (Jika Ada)
      if (eventInfo != null) {
        Log.info('Menuju ke halaman event (Pelapis Splash Screen)');
        // Menunggu sampai masa countdown event selesai atau di-skip oleh user
        await Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (context) => EventPageU(event: eventInfo)),
        );
      } else {
        // Keselamatan Visual: Jika event kosong, hapus Native Splash sekarang!
        FlutterNativeSplash.remove();
      }

      if (!mounted) return;

      // 3. Validasi Sistem (Maintenance & Force Update) setelah Event ditutup
      if (pengaturanPemeliharaan != null) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => MaintenancePage(
              infoMaintenance: pengaturanPemeliharaan.infoMaintenance,
              onRefresh: _inisialisasiAplikasi,
              onExit: SystemNavigator.pop,
            ),
          ),
        );
        return;
      }

      if (infoPembaruan != null) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => UpdateApkPage(
              infoApk: infoPembaruan.apkInfo!,
              infoPaket: infoPembaruan.packageInfo!,
              arsitektur: infoPembaruan.architecture!,
            ),
          ),
        );
        return;
      }

      // 4. Masuk ke aplikasi utama jika semua aman
      await _navigasiKeHalamanBerikutnya();
    } catch (e, st) {
      Log.error('Error kritis saat inisialisasi', e: e, s: st);
      FlutterNativeSplash.remove(); // Atasi penahanan layar jika terjadi kendala/error
      if (mounted) {
        ToastUtil.error(context, 'Gagal terhubung ke server.');
      }
      await _navigasiKeHalamanBerikutnya();
    }
  }

  Future<void> _inisialisasiLayananOffline() async {
    await LayananNotifikasi().inisialisasiNotifikasi(
      iconName: 'ic_notification',
    );
    await LayananNotifikasi().mintaIzin();
    await initializeDateFormatting('id_ID');
  }

  Future<EventModel?> _cekEvent() async {
    final eventOpSupabase = ref.read(eventOpSupabaseProvider);
    return await eventOpSupabase.ambilEventAktif();
  }

  Future<InfoPembaruanRecord?> _periksaPembaruanAplikasi() async {
    if (!mounted) return null;
    final layananCekUpdateApk = LayananCekUpdateApk(
      prefs: widget.prefs,
      penyimpananLokal: widget.penyimpananLokal,
      context: context,
    );
    final infoUpdate = await layananCekUpdateApk.ambilInfoUpdate();
    if (infoUpdate.perluUpdate) {
      return (
        isUpdateRequired: infoUpdate.perluUpdate,
        apkInfo: infoUpdate.infoApk,
        packageInfo: infoUpdate.infoPaket,
        architecture: infoUpdate.arsitektur,
      );
    }
    return null;
  }

  Future<SettingsModel?> _periksaModePemeliharaan() async {
    try {
      final petaPengaturan = await _settingsOp.ambilPengaturan();
      final pengaturan = SettingsModel.fromFirebase(petaPengaturan);
      if (pengaturan.modeMaintenance) {
        return pengaturan;
      }
      return null;
    } catch (e, st) {
      Log.error('Gagal memeriksa mode pemeliharaan', e: e, s: st);
      return null;
    }
  }

  Future<void> _navigasiKeHalamanBerikutnya() async {
    if (!mounted) return;
    final pengelolaAkun = await ref.read(pengelolaAkunProvider.future);
    final akunAktif = pengelolaAkun.akunSaatIni;

    if (akunAktif != null) {
      if (_terhubung == true) {
        unawaited(() async {
          final layananAktivitasUser = await ref.read(
            layananAktivitasUserProvider.future,
          );
          await layananAktivitasUser.pingAktivitas(akunAktif.id);
        }());
      }
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const MainPage()),
      );
    } else {
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            gapH16,
            Text('Memuat aplikasi...'),
          ],
        ),
      ),
    );
  }
}
```
