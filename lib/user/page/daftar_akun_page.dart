// path: lib/user/page/daftar_akun_page.dart
// diubah: Memperbaiki unawaited future.

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/user/page/login_page.dart';
import 'main_page.dart';
import '../services/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/theme/app_colors.dart';

typedef MainPageBuilder = Widget Function(
    String userId, LocalStorageService localStorageService);

class DaftarAkunPage extends StatefulWidget {
  final LocalStorageService? localStorageService;
  final MainPageBuilder? mainPageBuilder;

  const DaftarAkunPage(
      {super.key, this.localStorageService, this.mainPageBuilder});

  @override
  State<DaftarAkunPage> createState() => _DaftarAkunPageState();
}

class _DaftarAkunPageState extends State<DaftarAkunPage> {
  late Future<List<PelangganModel>> _futureDaftarAkun;
  late LocalStorageService _localStorageService;
  bool _isLocalStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocalStorage();
  }

  Future<void> _initializeLocalStorage() async {
    if (widget.localStorageService != null) {
      _localStorageService = widget.localStorageService!;
      if (mounted) {
        setState(() {
          _isLocalStorageInitialized = true;
        });
      }
      _muatDaftarAkun();
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _localStorageService = LocalStorageService(prefs: prefs);
          _isLocalStorageInitialized = true;
        });
        _muatDaftarAkun();
      }
    }
  }

  void _muatDaftarAkun() {
    if (_isLocalStorageInitialized) {
      if (mounted) {
        setState(() {
          _futureDaftarAkun = _localStorageService.ambilDaftarAkun();
        });
      }
    }
  }

  void _pilihAkun(PelangganModel pelanggan) {
    if (!_isLocalStorageInitialized) return;
    final navigator = Navigator.of(context);
    _localStorageService.simpanAkun(pelanggan).then((_) {
      if (!mounted) return;
      final page = widget.mainPageBuilder != null
          ? widget.mainPageBuilder!(pelanggan.id, _localStorageService)
          : MainPage(
              userId: pelanggan.id, localStorageService: _localStorageService);

      navigator.pushReplacement(MaterialPageRoute(builder: (context) => page));
    });
  }

  void _tampilkanDialogHapus(BuildContext context, PelangganModel pelanggan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Akun'),
          content: Text('Anda yakin ingin menghapus akun ${pelanggan.nama}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () async {
                // Ambil navigator dan context SEBELUM await
                final dialogNavigator = Navigator.of(dialogContext);
                final pageContext = context;

                if (!_isLocalStorageInitialized) return;
                final akunSaatIni =
                    await _localStorageService.ambilAkunSaatIni();

                // Cek apakah widget masih ada di tree SEBELUM menggunakan context
                if (!dialogContext.mounted) return; // ✅
                if (akunSaatIni?.id == pelanggan.id) {
                  dialogNavigator.pop(); // Tutup dialog pertama

                  // Tampilkan dialog konfirmasi
                  await showDialog(
                    context: pageContext,
                    builder: (BuildContext confirmDialogContext) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: const Text(
                            'Ini adalah akun yang sedang Anda gunakan. Anda akan keluar dan perlu login kembali. Lanjutkan?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Batal'),
                            onPressed: () =>
                                Navigator.of(confirmDialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text(
                              'Hapus & Keluar',
                              style: TextStyle(color: AppColors.errorColor),
                            ),
                            onPressed: () async {
                              // 1. Ambil navigator SEBELUM await
                              final navigator = Navigator.of(
                                  context); // Gunakan context halaman, bukan dialog

                              await _localStorageService
                                  .hapusAkun(pelanggan.id);
                              await _localStorageService.hapusAkunSaatIni();

                              // 2. Cek apakah halaman utama masih ada di screen
                              if (!context.mounted) return;

                              // 3. Eksekusi navigasi
                              await navigator.pushNamedAndRemoveUntil(
                                  '/login', (route) => false);
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Logika asli jika bukan akun yang sedang login
                  await _localStorageService.hapusAkun(pelanggan.id);
                  dialogNavigator.pop();
                  _muatDaftarAkun(); // Refresh daftar setelah hapus
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _tampilkanDialogKeluar(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Pilih metode keluar:'),
        actions: [
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              if (!_isLocalStorageInitialized) return;
              final akun = await _localStorageService.ambilAkunSaatIni();
              if (akun != null) {
                await _localStorageService.hapusAkun(akun.id);
              }
              await _localStorageService.hapusAkunSaatIni();
              await navigator.pushNamedAndRemoveUntil(
                  '/login', (route) => false);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.errorColor.withAlpha(25),
              foregroundColor: AppColors.textOnDark,
            ),
            child: const Text(
              'Keluar/Hapus Akun',
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.errorColor.withAlpha(25),
              foregroundColor: AppColors.textOnDark,
            ),
            onPressed: () async {
              final pageNavigator = Navigator.of(context);
              Navigator.of(dialogContext).pop();

              if (!_isLocalStorageInitialized) return;

              await _localStorageService.hapusTokenLogin();
              Log.info('Token login berhasil dihapus');

              if (!context.mounted) return;

              // Ganti dengan ini untuk memastikan semua route dihapus
              await pageNavigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLocalStorageInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pilih Akun Tersimpan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<PelangganModel>>(
              future: _futureDaftarAkun, // Perbaikan salah ketik di sini
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final daftar = snapshot.data ?? [];
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (daftar.isEmpty) {
                  return const Center(
                      child: Text('Belum ada riwayat login di perangkat ini.'));
                }
                return ListView.builder(
                  itemCount: daftar.length,
                  itemBuilder: (context, index) {
                    final p = daftar[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(p.nama.isNotEmpty ? p.nama[0] : '')),
                        title: Text(p.nama),
                        onTap: () => _pilihAkun(p),
                        onLongPress: () => _tampilkanDialogHapus(context, p),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _tampilkanDialogKeluar(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.errorColor.withAlpha(200), // Lebih solid
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
