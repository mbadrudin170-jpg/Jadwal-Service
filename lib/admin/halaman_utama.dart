// path: lib/admin/halaman_utama.dart
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

class HalamanUtama extends StatefulWidget {
  final bool isOffline;

  const HalamanUtama({super.key, this.isOffline = false});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama>
    with WidgetsBindingObserver {
  // ditambah: Listener untuk memantau perubahan koneksi internet.
  late StreamSubscription<List<ConnectivityResult>> _koneksiSubscription;
  // diubah: Menggunakan satu service orkestrasi utama.
  final PengecekanWaktuSyncService _syncService = PengecekanWaktuSyncService();
  // diubah: Penanda untuk mencegah sinkronisasi ganda.
  bool _sedangSinkronisasi = false;

  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const PelangganAktifPage(),
    const DompetPage(),
    const TransaksiPage(),
    const LainnyaPage(),
  ];

  void _onItemTapped(int index) {
    Log.info(
      'Pengguna menekan bottom navigation index: $index.',
    );

    if (_selectedIndex == index) {
      Log.info(
        // diubah: dari warning ke info karena ini bukan kondisi error
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

    // ditambah: Daftarkan observer untuk memantau siklus hidup aplikasi (resume, pause).
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Log.info(
        'Frame pertama selesai dirender.',
      );

      _cekDanTampilkanPesanOffline();

      Log.info(
        'Menjalankan proses pengecekan langganan kadaluarsa.',
      );
      CekLanggananKadaluarsaService().prosesLanggananKadaluarsa();

      // ditambah: Memulai sinkronisasi data pertama kali saat halaman dimuat.
      _sinkronisasiDataSaatOnline();
    });

    // ditambah: Mulai mendengarkan perubahan status konektivitas.
    _koneksiSubscription =
        Connectivity().onConnectivityChanged.listen(_onKoneksiBerubah);
  }

  @override
  void dispose() {
    Log.info('Menutup HalamanUtama, membersihkan semua listener.');
    // ditambah: Hentikan pemantauan siklus hidup aplikasi.
    WidgetsBinding.instance.removeObserver(this);
    // ditambah: Hentikan pemantauan koneksi untuk mencegah memory leak.
    _koneksiSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ditambah: Logika ini akan berjalan setiap kali state aplikasi berubah.
    if (state == AppLifecycleState.resumed) {
      Log.info('Aplikasi kembali aktif (resumed), memicu sinkronisasi data.');
      // ditambah: Saat pengguna kembali ke aplikasi, panggil sinkronisasi untuk memastikan data terbaru.
      _sinkronisasiDataSaatOnline();
    }
  }

  // ditambah: Callback yang akan dieksekusi setiap kali status koneksi berubah.
  void _onKoneksiBerubah(List<ConnectivityResult> hasil) {
    final terkoneksi = hasil.contains(ConnectivityResult.mobile) ||
        hasil.contains(ConnectivityResult.wifi);
    if (terkoneksi) {
      Log.info(
          'Terdeteksi perubahan koneksi: KEMBALI ONLINE. Memicu sinkronisasi.');
      _sinkronisasiDataSaatOnline();
    } else {
      Log.warning('Terdeteksi perubahan koneksi: OFFLINE.');
    }
  }

  // ditambah: Metode utama untuk orkestrasi proses sinkronisasi.
  Future<void> _sinkronisasiDataSaatOnline() async {
    if (_sedangSinkronisasi) return;

    if (mounted) setState(() => _sedangSinkronisasi = true);
    try {
      // diubah: Memanggil satu fungsi orkestrasi utama yang sudah ada.
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
  Widget build(BuildContext context) {
    Log.info(
      'Membangun UI halaman utama dengan selected index: $_selectedIndex.',
    );

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
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
