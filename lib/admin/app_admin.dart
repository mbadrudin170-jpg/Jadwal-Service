// path: lib/admin/app_admin.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/admin/halaman_utama.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_unduhan_awal.dart';
import 'package:wifi/fitur/transaksi/operasi_provider.dart/transaksi_provider.dart';
import 'package:wifi/shared/data/services/layanan_navigasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

/// Widget root untuk aplikasi admin WiFi.
///
/// Menunggu ketersediaan `SharedPreferences` asinkron sebelum melanjutkan
/// ke proses inisialisasi utama ([AppInitializer]). Jika gagal memuat,
/// menampilkan pesan error.
class AppAdmin extends ConsumerWidget {
  const AppAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    return prefsAsync.when(
      data: (prefs) => const AppInitializer(),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error memuat SharedPreferences: $err')),
        ),
      ),
    );
  }
}

/// Menangani inisialisasi awal aplikasi setelah `SharedPreferences` tersedia.
///
/// Menjalankan serangkaian tugas awal secara berurutan:
/// 1. Inisialisasi layanan latar belakang dan notifikasi.
/// 2. Memeriksa payload notifikasi yang meluncurkan aplikasi.
/// 3. Menginisialisasi format tanggal lokal (id_ID).
/// 4. Membuka database SQLite dan melakukan pengarsipan data kedaluwarsa.
/// 5. Jika perangkat online, menjalankan unduhan data awal dan pembersihan data arsip.
///
/// Menampilkan indikator loading hingga seluruh proses selesai, lalu meneruskan
/// ke [AppMaterial] dengan status koneksi yang sesuai.
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  /// Future yang menyimpan hasil inisialisasi, sekaligus status koneksi.
  late Future<bool> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeAndNavigate();
  }

  /// Menjalankan semua langkah inisialisasi dan mengembalikan status koneksi.
  ///
  /// Mengembalikan `true` jika perangkat online, `false` jika offline,
  /// atau saat terjadi error kritis.
  Future<bool> _initializeAndNavigate() async {
    final notifikasiServis = ref.read(layananNotifikasiProvider);
    final koneksiInternetService = ref.read(koneksiInternetServiceProvider);
    final sqliteDb = ref.read(sqliteDatabaseProvider);

    try {
      // 1. Inisialisasi layanan latar belakang dan notifikasi
      await LayananLatarBelakang.inisialisasi();
      await notifikasiServis.inisialisasiNotifikasi(
        iconName: 'ic_notification',
      );
      await notifikasiServis.mintaIzin();

      // 2. Tangani payload notifikasi yang mungkin membuka aplikasi
      final launchDetails = await notifikasiServis
          .getDetailPeluncuranNotifikasi();
      final prefs = ref.read(sharedPreferencesProvider).requireValue;
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          await prefs.setString('initial_notification_payload', payload);
        } else {
          await prefs.remove('initial_notification_payload');
        }
      } else {
        await prefs.remove('initial_notification_payload');
      }

      // 3. Format tanggal lokal
      await initializeDateFormatting('id_ID');

      // 4. Buka database dan arsipkan data kedaluwarsa
      await sqliteDb.database;
      final isOnline = await koneksiInternetService.cekInternet();
      if (isOnline) {
        Log.info('Perangkat online, melanjutkan dengan unduhan data awal.');
        unawaited(() async {
          try {
            final pelangganAktifOpSqlite = ref.read(
              pelangganAktifOpSqliteProvider,
            );
            await pelangganAktifOpSqlite.arsipkanLanggananKadaluarsa();
            final unduhanAwalService = ref.read(layananUnduhanAwalProvider);
            final adaDataBaru = await unduhanAwalService.jalankanUnduhanAwal();

            if (adaDataBaru) {
              ref.invalidate(pelangganProvider);
              ref.invalidate(paketProvider);
              ref.invalidate(transaksiProvider);
              ref.invalidate(dompetProvider);
              Log.info('Provider di-invalidate karena ada data baru.');
            }
            final dataPengaturan = await ref
                .read(settingsOpSqliteProvider)
                .ambilSettings();
            final waktuPenjadwalanHapusDataArsip =
                dataPengaturan.waktuOtomatisHapusDataArsip;

            final pembersihanDataOperasi = ref.read(
              pembersihanDataOperasiProvider,
            );
            await pembersihanDataOperasi.hapusPermanentDataYangDiarsip(
              waktuPenjadwalanHapusDataArsip: waktuPenjadwalanHapusDataArsip,
            );
          } catch (e, s) {
            Log.error(
              'Gagal menjalankan proses sinkronisasi background',
              e: e,
              s: s,
            );
          }
        }());
      } else {
        Log.warning(
          'Perangkat offline, melewati proses unduhan data awal dan pembersihan.',
        );
      }

      return isOnline;
    } catch (e, s) {
      Log.error('Error kritis selama inisialisasi sekunder.', e: e, s: s);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final isOffline = !(snapshot.data ?? false);
          if (snapshot.hasError) {
            Log.error(
              'Error pada FutureBuilder inisialisasi',
              e: snapshot.error,
            );
          }
          return AppMaterial(isOffline: isOffline);
        }
        // Tampilkan layar loading saat inisialisasi berlangsung
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

/// Widget yang membangun [MaterialApp] utama dengan tema dinamis
/// dan navigasi siap pakai.
///
/// Menerima parameter [isOffline] untuk diteruskan ke [HalamanUtama]
/// sehingga UI dapat menyesuaikan diri dengan status koneksi.
class AppMaterial extends ConsumerWidget {
  const AppMaterial({super.key, required this.isOffline});

  /// Apakah perangkat sedang offline.
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(layananNotifikasiProvider);
    ref.watch(pengontrolNotifikasiProvider);
    final temaAsync = ref.watch(temaProvider);
    return temaAsync.when(
      data: (themeMode) => ToastificationWrapper(
        child: MaterialApp(
          title: 'Admin Wifi',
          theme: AppTheme.modeTerang,
          darkTheme: AppTheme.modeGelap,
          themeMode: themeMode,
          home: HalamanUtama(isOffline: isOffline),
          navigatorKey: LayananNavigasi.navigatorKey,
        ),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Gagal memuat tema: $err'))),
      ),
    );
  }
}
