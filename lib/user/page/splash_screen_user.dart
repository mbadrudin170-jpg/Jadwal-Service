// path: lib/user/page/splash_screen_user.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/info_perangkat/enum/arsitektur_apk.dart';
import 'package:wifi/fitur/info_perangkat/model/info_perangkat_model.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/settings/model/settings_model.dart';
import 'package:wifi/fitur/settings/operasi/settings_op_firebase.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/fitur/versi_apk/service/layanan_cek_update_apk.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/event/operasi/event_op_supabase.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/maintenance_page.dart';
import 'package:wifi/fitur/event/page/event_page_u.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/fitur/versi_apk/page/update_apk_page_u.dart';
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
  final idUnitIklan = IdInterstitialAds.interstitialAdUnitIds[0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      unawaited(_inisialisasiAplikasi());
    });
  }

  Future<void> _inisialisasiAplikasi() async {
    try {
      Log.info('Memulai inisialisasi dari Splash Screen...');
      await _inisialisasiLayananOffline();

      final terhubung = await ref
          .watch(koneksiInternetServiceProvider)
          .cekKoneksiLokal();

      if (terhubung) {
        await _lanjutkanInisialisasi();

        final eventInfo = await _cekEvent();
        if (eventInfo != null) {
          if (mounted) {
            Log.info('menuju ke halaman event');
            // Tampilkan halaman event di atas splash screen dan tunggu sampai selesai.
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => EventPageU(event: eventInfo),
              ),
            );
          }
        }

        // Setelah halaman event selesai, lanjutkan alur inisialisasi.
        await _continueInitialization();
      } else {
        if (mounted) {
          ToastUtil.info(context, 'Anda sedang offline.');
        }
        await _navigasiKeHalamanBerikutnya();
      }
    } on Exception catch (e, st) {
      Log.error('Error kritis saat inisialisasi', e: e, s: st);
      if (mounted) {
        ToastUtil.error(context, 'Gagal terhubung ke server.');
      }
      await _navigasiKeHalamanBerikutnya();
    }
  }

  Future<void> _continueInitialization() async {
    final pengaturanPemeliharaan = await _periksaModePemeliharaan();
    if (pengaturanPemeliharaan != null) {
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MaintenancePage(
              infoMaintenance: pengaturanPemeliharaan.infoMaintenance,
              onRefresh: _inisialisasiAplikasi,
              onExit: SystemNavigator.pop,
            ),
          ),
        ),
      );
      return;
    }

    final infoPembaruan = await _periksaPembaruanAplikasi();
    if (infoPembaruan != null) {
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => UpdateApkPage(
              infoApk: infoPembaruan.apkInfo!,
              infoPaket: infoPembaruan.packageInfo!,
              arsitektur: infoPembaruan.architecture!,
            ),
          ),
        ),
      );
      return;
    }
    await _navigasiKeHalamanBerikutnya();
  }

  Future<void> _inisialisasiLayananOffline() async {
    await LayananNotifikasi().inisialisasiNotifikasi(
      iconName: 'ic_notification',
    );
    await LayananNotifikasi().mintaIzin();
    await initializeDateFormatting('id_ID');
  }

  Future<void> _lanjutkanInisialisasi() async {
    try {
      await MobileAds.instance.initialize();
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } on Exception catch (e, st) {
      Log.error('Gagal inisialisasi layanan online', e: e, s: st);
    }
  }

  Future<EventModel?> _cekEvent() async {
    final eventOpSupabase = ref.read(eventOpSupabaseProvider);
    final infoEvent = await eventOpSupabase.ambilEventAktif();
    return infoEvent;
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
    } on Exception catch (e, st) {
      Log.error('Gagal memeriksa mode pemeliharaan', e: e, s: st);
      return null;
    }
  }

  Future<void> _navigasiKeHalamanBerikutnya() async {
    if (!mounted) return;
    final pengelolaAkun = await ref.read(pengelolaAkunProvider.future);
    final akunAktif = pengelolaAkun.akunSaatIni;

    if (akunAktif != null) {
      final terhubung = await ref
          .read(koneksiInternetServiceProvider)
          .cekKoneksiLokal();

      if (terhubung) {
        final layananAktivitasPengguna = await ref.read(
          layananAktivitasUserProvider.future,
        );
        unawaited(layananAktivitasPengguna.pingAktivitas(akunAktif.id));
      }
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        ),
      );
    } else {
      if (!mounted) return;
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        ),
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
