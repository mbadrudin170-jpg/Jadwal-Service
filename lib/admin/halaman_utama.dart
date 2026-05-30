// path: lib/admin/halaman_utama.dart
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

class HalamanUtama extends StatefulWidget {
  final bool isOffline;

  const HalamanUtama({super.key, this.isOffline = false});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama>
    with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _koneksiSubscription;
  late final SyncCheckService _syncService;
  bool _sedangSinkronisasi = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    Log.info('HalamanUtama initState. Offline: ${widget.isOffline}');

    _syncService = SyncCheckService();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((final _) {
      _initAsync();
    });

    _koneksiSubscription = Connectivity().onConnectivityChanged.listen(
          _onKoneksiBerubah,
        );
  }

  Future<void> _initAsync() async {
    await _handleInitialNotification();
    await _scheduleSync();
    Log.info('Frame pertama selesai dirender.');
    if (!mounted) return;
    _cekDanTampilkanPesanOffline();
    Log.info('Menjalankan pengecekan langganan kadaluarsa.');
    await ExpiredSubscriptionCheckService().processExpiredSubscriptions();
    await _sinkronisasiDataSaatOnline();
  }

  @override
  void dispose() {
    Log.info('Menutup HalamanUtama');
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_koneksiSubscription.cancel());
    super.dispose();
  }

  void _onItemTapped(final int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _scheduleSync() async {
    await Workmanager().registerPeriodicTask(
      '1',
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
    Log.info('Tugas sinkronisasi periodik dijadwalkan.');
  }

  Future<void> _onKoneksiBerubah(final List<ConnectivityResult> hasil) async {
    final terkoneksi = hasil.contains(ConnectivityResult.mobile) ||
        hasil.contains(ConnectivityResult.wifi);
    if (terkoneksi) {
      Log.info('Koneksi kembali online. Memicu sinkronisasi.');
      await _sinkronisasiDataSaatOnline();
    } else {
      Log.warning('Koneksi terputus.');
    }
  }

  Future<void> _sinkronisasiDataSaatOnline() async {
    if (_sedangSinkronisasi) return;
    Log.info('Memulai sinkronisasi data.');
    if (mounted) setState(() => _sedangSinkronisasi = true);
    try {
      await _syncService.runSyncCheck();
      Log.info('Sinkronisasi data selesai. Memberi sinyal refresh.');
    } on Exception catch (e, s) {
      Log.error('Gagal sinkronisasi data.', e: e, st: s);
    } finally {
      if (mounted) setState(() => _sedangSinkronisasi = false);
    }
  }

  void _cekDanTampilkanPesanOffline() {
    if (widget.isOffline) {
      Log.warning('Aplikasi dalam mode offline. Menampilkan pesan.');
      ToastUtil.warning(
        context,
        'Anda dalam mode offline. Data mungkin tidak terbaru.',
      );
    }
  }

  Future<void> _handleInitialNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString('initial_notification_payload');
    if (payload != null && payload.isNotEmpty) {
      await prefs.remove('initial_notification_payload');
      Log.info('Aplikasi dibuka dari notifikasi dengan payload: $payload');
      if (mounted) {
        ToastUtil.info(context, 'Dibuka dari notifikasi: $payload');
      }
    }
  }

  final _widgetOptions = <Widget>[
    const ActiveCustomerPage(),
    const WalletPage(),
    const TransactionPage(),
    const StatistikPageA(),
    const LainnyaPage(),
  ];

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(TIcons.activeCustomer),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(icon: Icon(TIcons.wallet), label: 'Dompet'),
          BottomNavigationBarItem(
            icon: Icon(TIcons.receiptLong),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(TIcons.report),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(icon: Icon(TIcons.apps), label: 'Lainnya'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha(179),
        showUnselectedLabels: true,
      ),
    );
  }
}
