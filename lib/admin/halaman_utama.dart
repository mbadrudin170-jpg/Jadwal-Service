// path: lib/admin/halaman_utama.dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/fitur/background/layanan_latar_belakang.dart';
import 'package:wifi/fitur/dompet/page/dompet_page.dart';
import 'package:wifi/fitur/order/page/order_page.dart';
import 'package:wifi/fitur/pelanggan_aktif/page/pelanggan_aktif_page.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/fitur/statistik/page/statistik_page_a.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_a.dart';
import 'package:wifi/fitur/voucher/page/voucher.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/arsipkan_langganan_kadaluarsa_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:workmanager/workmanager.dart';

class HalamanUtama extends ConsumerStatefulWidget {
  const HalamanUtama({super.key, this.isOffline = false});

  final bool isOffline;

  @override
  ConsumerState<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends ConsumerState<HalamanUtama>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<HalamanUtama> {
  late StreamSubscription<List<ConnectivityResult>> _langgananKoneksi;
  late final LayananCekSinkronisasi _syncService;
  bool _sedangSync = false;
  int _tabDipilih = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Log.info('Aplikasi kembali ke foreground, memicu sinkronisasi.');
      unawaited(_syncJikaOnline());
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    Log.info('HalamanUtama initState. Offline: ${widget.isOffline}');

    _syncService = ref.read(layananCekSinkronisasiProvider);
    WidgetsBinding.instance.addObserver(this);

    // Subscribe to connectivity changes
    _langgananKoneksi = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initAwal());
    });
  }

  Future<void> _initAwal() async {
    await _prosesNotifAwal();
    await _jadwalkanSinkron();
    if (!mounted) return;
    _cekDanTampilkanPesanOffline();
    Log.info('Menjalankan pengecekan langganan kadaluarsa.');

    try {
      final expiredService = ref.read(arsipLanggananKadaluarsaServiceProvider);
      await expiredService.prosesArsipLanggananKadaluarsa();
      final initialConnection = await Connectivity().checkConnectivity();
      await _handleConnectivityChange(initialConnection);
    } catch (e, s) {
      Log.info('gagal arsip langganan kadaluarsa $e $s');
    }
  }

  @override
  void dispose() {
    Log.info('Menutup HalamanUtama');
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_langgananKoneksi.cancel());
    super.dispose();
  }

  void _onItemTapped(final int index) {
    setState(() {
      _tabDipilih = index;
    });
  }

  Future<void> _jadwalkanSinkron() async {
    await ref
        .read(workmanagerProvider)
        .registerPeriodicTask(
          '1',
          namaTugasSinkronisasi,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
        );
    Log.info('Tugas sinkronisasi periodik dijadwalkan.');
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final isOnline =
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    if (isOnline) {
      Log.info('Koneksi kembali online. Memicu sinkronisasi.');
      await _syncJikaOnline();
    } else {
      Log.warning('Koneksi terputus.');
    }
  }

  Future<void> _syncJikaOnline() async {
    if (_sedangSync) return;
    Log.info('Memulai sinkronisasi data.');
    if (mounted) setState(() => _sedangSync = true);
    try {
      await _syncService.jalankanCekSinkronisasi();
      Log.info('Sinkronisasi data selesai.');
    } catch (e, s) {
      Log.error('Gagal sinkronisasi data.', e: e, s: s);
    } finally {
      if (mounted) setState(() => _sedangSync = false);
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

  Future<void> _prosesNotifAwal() async {
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

  final _halamanTab = <Widget>[
    const PelangganAktifPage(),
    const DompetPage(),
    const TransaksiA(),
    const StatistikPageA(),
    if (kDebugMode) const Voucher() else const OrderPage(),
    const LainnyaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: IndexedStack(index: _tabDipilih, children: _halamanTab),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(TIcons.pelangganAktif),
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
          BottomNavigationBarItem(icon: Icon(TIcons.listAlt), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(TIcons.apps), label: 'Lainnya'),
        ],
        currentIndex: _tabDipilih,
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
