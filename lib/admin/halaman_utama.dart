// path: lib/admin/halaman_utama.dart
// TODO : menambahkan workmanager
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/admin/halaman/tab/active_customer_tab.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman/tab/statistik_page_a.dart';
import 'package:wifi/admin/halaman/tab/transaction_page_a.dart';
import 'package:wifi/admin/halaman/tab/wallet_page.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/background_service.dart';
import 'package:wifi/shared/services/expired_subscription_check_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:wifi/tes_fitur/halaman_test.dart';

// === INFORMASI DEPENDENCY ===
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/main/main_admin/admin_dev.dart (AdminDev)
//   - lib/main/main_admin/admin_prod.dart (AdminProd)
//   - lib/admin/app_admin.dart (AppAdmin)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/admin/halaman/tab/active_customer_tab.dart (ActiveCustomerPage)
//   - lib/admin/halaman/tab/wallet_page.dart (WalletPage)
//   - lib/admin/halaman/tab/transaction_page.dart (TransactionPage)
//   - lib/admin/halaman/tab/statistik_page_a.dart (StatistikPageA)
//   - lib/admin/halaman/tab/lainnya.dart (LainnyaPage)
//   - lib/shared/data/services/sync_check_service.dart (SyncCheckService)
//   - lib/shared/services/expired_subscription_check_service.dart (ExpiredSubscriptionCheckService)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (ToastUtil)
//   - lib/shared/theme/app_icons.dart (AppIcons)

/// Halaman utama aplikasi admin yang menampilkan navigasi tab.
class HalamanUtama extends StatefulWidget {
  /// Menandakan apakah aplikasi sedang berjalan dalam mode offline.
  ///
  /// Default-nya adalah `false` (mode online).
  final bool isOffline;

  /// Membuat instance [HalamanUtama].
  ///
  /// Parameter [isOffline] menentukan status koneksi awal halaman.
  const HalamanUtama({super.key, this.isOffline = false});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late StreamSubscription<List<ConnectivityResult>> _koneksiSubscription;
  late final SyncCheckService _syncService;
  bool _sedangSinkronisasi = false;

  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    Log.info(
      'Memulai inisialisasi halaman utama. Status offline: ${widget.isOffline}.',
    );

    // PERBAIKAN 1: Inisialisasi service
    _syncService = SyncCheckService();

    // PERBAIKAN 2: Menggunakan nama class yang benar dari file yang ada
    _widgetOptions = <Widget>[
      const ActiveCustomerPage(), // dari active_customer_tab.dart
      const WalletPage(), // dari wallet_page.dart
      const TransactionPage(), // dari transaction_page.dart
      const StatistikPageA(), // dari statistik_page_a.dart
      const LainnyaPage(), // dari lainnya.dart
      // const TestNotificationPage(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((final _) async {
      await _handleInitialNotification();
      await _scheduleSync(); // Jadwalkan tugas background
      Log.info('Frame pertama selesai dirender.');
      _cekDanTampilkanPesanOffline();
      Log.info('Menjalankan proses pengecekan langganan kadaluarsa.');
      // PERBAIKAN 3: Method yang benar adalah processExpiredSubscriptions
      await ExpiredSubscriptionCheckService().processExpiredSubscriptions();
      await _sinkronisasiDataSaatOnline();
    });
    _koneksiSubscription =
        Connectivity().onConnectivityChanged.listen(_onKoneksiBerubah);
  }

  @override
  Future<void> dispose() async {
    Log.info('Menutup HalamanUtama, membersihkan semua listener.');
    await _koneksiSubscription.cancel();
    super.dispose();
  }

  Future<void> _scheduleSync() async {
    await Workmanager().registerPeriodicTask(
      '1',
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    Log.info('Tugas sinkronisasi periodik dijadwalkan setiap 12 jam.');
  }

  void _onItemTapped(final int index) {
    Log.info('Pengguna menekan bottom navigation index: $index.');

    if (_selectedIndex == index) {
      Log.info(
          'Index yang ditekan sama dengan halaman aktif saat ini. Tidak ada perubahan state.');
      return;
    }

    setState(() {
      Log.info('Mengubah selected index dari $_selectedIndex menjadi $index.');
      _selectedIndex = index;
    });
  }

  Future<void> _onKoneksiBerubah(final List<ConnectivityResult> hasil) async {
    final terkoneksi = hasil.contains(ConnectivityResult.mobile) ||
        hasil.contains(ConnectivityResult.wifi);
    if (terkoneksi) {
      Log.info(
          'Terdeteksi perubahan koneksi: KEMBALI ONLINE. Memicu sinkronisasi.');
      await _sinkronisasiDataSaatOnline();
    } else {
      Log.warning('Terdeteksi perubahan koneksi: OFFLINE.');
    }
  }

  Future<void> _sinkronisasiDataSaatOnline() async {
    if (_sedangSinkronisasi) return;
    Log.info('Memulai sinkronisasi data.');
    if (mounted) setState(() => _sedangSinkronisasi = true);
    try {
      // PERBAIKAN 4: Method yang benar adalah runSyncCheck
      await _syncService.runSyncCheck();
      Log.info('Sinkronisasi data selesai.');
    } on Exception catch (e, s) {
      Log.error('Gagal sinkronisasi data.', e: e, st: s);
    } finally {
      if (mounted) setState(() => _sedangSinkronisasi = false);
    }
  }

  void _cekDanTampilkanPesanOffline() {
    Log.info('Memeriksa status koneksi aplikasi.');
    if (widget.isOffline) {
      Log.warning(
          'Aplikasi berjalan dalam mode offline. Menampilkan snackbar peringatan.');

      // PERBAIKAN 5: Menggunakan ToastUtil
      ToastUtil.warning(
        context,
        'Anda dalam mode offline. Data mungkin tidak terbaru.',
      );
      Log.info('Snackbar offline berhasil ditampilkan.');
    } else {
      Log.info('Aplikasi berjalan dalam mode online.');
    }
  }

  Future<void> _handleInitialNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString('initial_notification_payload');
    if (payload != null && payload.isNotEmpty) {
      // Hapus setelah dibaca agar tidak terulang
      await prefs.remove('initial_notification_payload');
      Log.info(
          'Aplikasi dibuka dari notifikasi (terminated) dengan payload: $payload');

      if (mounted) {
        // Tampilkan pesan atau navigasi sesuai payload
        ToastUtil.info(context, 'Dibuka dari notifikasi: $payload');

        // Contoh jika ingin navigasi ke halaman tertentu:
        // if (payload.startsWith('order_')) {
        //   final orderId = payload.split('_')[1];
        //   Navigator.pushNamed(context, '/detail_order', arguments: orderId);
        // }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
        'Membangun UI halaman utama dengan selected index: $_selectedIndex.');
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(AppIcons.activeCustomer),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.wallet),
            label: 'Dompet',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.receiptLong),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.report),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.apps),
            label: 'Lainnya',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withAlpha(179),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
