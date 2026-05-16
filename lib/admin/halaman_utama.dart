// path: lib/admin/halaman_utama.dart
// diubah: Mengganti IndexedStack dengan widget langsung untuk mengatasi konflik Hero.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:wifi/admin/halaman/tab/dompet.dart';
import 'package:wifi/admin/halaman/tab/lainnya.dart';
import 'package:wifi/admin/halaman/tab/pelanggan_aktif.dart';
import 'package:wifi/admin/halaman/tab/transaksi.dart';
import 'package:wifi/shared/data/services/pengecekan_waktu_sync_services.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/cek_langganan_kadaluarsa_service.dart';

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
  final PengecekanWaktuSyncService _syncService = PengecekanWaktuSyncService();
  bool _sedangSinkronisasi = false;

  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PelangganAktifPage(),
    const DompetPage(),
    const TransaksiPage(),
    const LainnyaPage(),
  ];

  void _onItemTapped(final int index) {
    Log.info(
      'Pengguna menekan bottom navigation index: $index.',
    );

    if (_selectedIndex == index) {
      Log.info(
        'Index yang ditekan sama dengan halaman aktif saat ini. Tidak ada perubahan state.',
      );
      return;
    }

    setState(() {
      Log.info(
        'Mengubah selected index dari $_selectedIndex menjadi $index.',
      );
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    Log.info(
      'Memulai inisialisasi halaman utama. Status offline: ${widget.isOffline}.',
    );
    WidgetsBinding.instance.addPostFrameCallback((final _) async {
      Log.info(
        'Frame pertama selesai dirender.',
      );
      _cekDanTampilkanPesanOffline();
      Log.info(
        'Menjalankan proses pengecekan langganan kadaluarsa.',
      );
      await CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();
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

  Future<void> _onKoneksiBerubah(final List<ConnectivityResult> hasil) async {
    final terkoneksi = hasil.contains(ConnectivityResult.mobile) ||
        hasil.contains(ConnectivityResult.wifi);
    if (terkoneksi) {
      Log.info(
        'Terdeteksi perubahan koneksi: KEMBALI ONLINE. Memicu sinkronisasi.',
      );
      await _sinkronisasiDataSaatOnline();
    } else {
      Log.warning('Terdeteksi perubahan koneksi: OFFLINE.');
    }
  }

  Future<void> _sinkronisasiDataSaatOnline() async {
    if (_sedangSinkronisasi) return;

    if (mounted) setState(() => _sedangSinkronisasi = true);
    try {
      await _syncService.jalankanPengecekanDanSinkronisasi();
    } finally {
      if (mounted) setState(() => _sedangSinkronisasi = false);
    }
  }

  void _cekDanTampilkanPesanOffline() {
    Log.info(
      'Memeriksa status koneksi aplikasi.',
    );
    if (widget.isOffline) {
      Log.warning(
        'Aplikasi berjalan dalam mode offline. Menampilkan snackbar peringatan.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda dalam mode offline. Data mungkin tidak terbaru.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      Log.info(
        'Snackbar offline berhasil ditampilkan.',
      );
    } else {
      Log.info(
        'Aplikasi berjalan dalam mode online.',
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun UI halaman utama dengan selected index: $_selectedIndex.',
    );
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle),
            label: 'Aktif',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Dompet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Lainnya',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha(179),
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
