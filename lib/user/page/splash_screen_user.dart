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
      final hasilInisialisasi = await Future.wait([
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
