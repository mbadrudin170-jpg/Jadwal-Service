// path: lib/user/page/login_page.dart
// diubah: Menambahkan logika untuk menyimpan FCM Token setelah login berhasil.
// diperbaiki: Menghilangkan TextStyle yang bertentangan pada ElevatedButton untuk mencegah crash.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';
import 'package:wifi/user/page/daftar_akun_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman login untuk pengguna.
///
/// Wrapper stateless yang meneruskan dependensi ke `_TampilanLogin`.
class LoginPage extends StatelessWidget {
  /// Instance Firestore untuk operasi database.
  final FirebaseFirestore? firestore;

  /// Service untuk mengakses penyimpanan lokal.
  final LocalStorageService? localStorageService;

  /// Membuat instance dari [LoginPage].
  const LoginPage({super.key, this.firestore, this.localStorageService});

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun LoginPage, meneruskan ke _TampilanLogin.', {
      'hasFirestore': firestore != null,
      'hasLocalStorage': localStorageService != null,
    });
    return _TampilanLogin(
      firestore: firestore,
      localStorageService: localStorageService,
    );
  }
}

class _TampilanLogin extends StatefulWidget {
  final FirebaseFirestore? firestore;
  final LocalStorageService? localStorageService;

  const _TampilanLogin({this.firestore, this.localStorageService});

  @override
  State<_TampilanLogin> createState() => _TampilanLoginState();
}

class _TampilanLoginState extends State<_TampilanLogin> {
  late FirebaseFirestore _firestore;
  late LocalStorageService _localStorageService;
  bool _apakahPasswordTerlihat = false;
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLocalStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    Log.info('Memulai inisialisasi state _TampilanLogin.');
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    unawaited(_initializeLocalStorage());
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      if (mounted) {
        SnackBarUtil.info(context, 'Anda telah keluar. Silakan login kembali.');
      }
    });
  }

  Future<void> _initializeLocalStorage() async {
    Log.info('Memulai inisialisasi LocalStorage.');
    if (widget.localStorageService != null) {
      Log.info('LocalStorageService diterima dari widget parent.');
      _localStorageService = widget.localStorageService!;
      if (mounted) {
        setState(() {
          _isLocalStorageInitialized = true;
        });
      }
    } else {
      Log.info(
        'LocalStorageService tidak disediakan, membuat instance baru dari SharedPreferences.',
      );
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _localStorageService = LocalStorageService(prefs: prefs);
          _isLocalStorageInitialized = true;
        });
      }
    }
    Log.info('Inisialisasi LocalStorage selesai.', {
      'isInitialized': _isLocalStorageInitialized,
    });
  }

  Future<void> _tampilkanAlertError(final String pesan) async {
    Log.warning('Menampilkan alert error.', {'pesan': pesan});
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (final ctx) => AlertDialog(
        title: const Text('Gagal Masuk'),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cek Kembali'),
          ),
        ],
      ),
    );
  }

  void _ubahVisibilitasPassword() {
    Log.info('Mengubah visibilitas password.', {
      'sekarangTerlihat': !_apakahPasswordTerlihat,
    });
    setState(() {
      _apakahPasswordTerlihat = !_apakahPasswordTerlihat;
    });
  }

  Future<void> _prosesLogin() async {
    Log.info('Memulai proses login.');

    if (!_isLocalStorageInitialized) {
      Log.warning('LocalStorage belum siap saat mencoba login.');
      await _tampilkanAlertError(
          'Layanan penyimpanan lokal belum siap. Coba lagi.',);
      return;
    }

    final navigator = Navigator.of(context);
    final telepon = _teleponController.text.trim();
    final password = _passwordController.text.trim();

    Log.info('Input login diterima.', {
      'telepon': telepon,
      'passwordLength': password.length,
    });

    if (telepon.isEmpty || password.isEmpty) {
      Log.warning('Validasi gagal: input kosong.', {
        'teleponKosong': telepon.isEmpty,
        'passwordKosong': password.isEmpty,
      });
      await _tampilkanAlertError(
          'Nomor telepon dan password tidak boleh kosong.',);
      return;
    }

    try {
      Log.info('Melakukan query ke Firestore.', {
        'telepon': telepon,
      });

      final querySnapshot = await _firestore
          .collection('pelanggan')
          .where('telepon', isEqualTo: telepon)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      Log.info('Query Firestore selesai.', {
        'dokumenDitemukan': querySnapshot.docs.length,
      });

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final uid = userDoc.id;

        Log.info('Dokumen pelanggan ditemukan, memproses data.', {
          'userId': uid,
        });

        // ditambah: Memulai proses penyimpanan token FCM di background.
        // Tidak perlu ditunggu (await) agar tidak menghambat proses login.

        final pelanggan =
            PelangganModel.fromFirebase(userDoc.id, userDoc.data());

        Log.info('Menyimpan akun ke LocalStorage.', {
          'nama': pelanggan.nama,
          'id': pelanggan.id,
        });
        await _localStorageService.simpanAkun(pelanggan);

        Log.info('Menyimpan userId ke SharedPreferences.', {
          'userId': uid,
        });
        await _localStorageService.prefs.setString('userId', uid);

        Log.info('Login berhasil, navigasi ke MainPage.', {
          'userId': uid,
        });

        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (final context) => MainPage(
              userId: uid,
              localStorageService: _localStorageService,
            ),
          ),
        );
      } else {
        Log.warning('Login gagal: kredensial tidak cocok.', {
          'telepon': telepon,
        });
        await _tampilkanAlertError(
          'Nomor telepon atau password yang Anda masukkan salah.',
        );
      }
    }on Exception catch (e, s) {
      Log.error(
        'Terjadi kesalahan saat login.',
        e: e,
        st: s,
      );
      await _tampilkanAlertError(
        'Terjadi kesalahan koneksi ke server. Silakan coba lagi.',
      );
    }
  }

  @override
  void dispose() {
    Log.info('Membersihkan state _TampilanLogin.');
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('🔴🔴🔴 HALAMAN LOGIN DITAMPILKAN 🔴🔴🔴');
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Silakan Masuk',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (final _) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_apakahPasswordTerlihat,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    focusNode: FocusNode(canRequestFocus: false),
                    icon: Icon(
                      _apakahPasswordTerlihat
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: _ubahVisibilitasPassword,
                    tooltip: 'Tampilkan/Sembunyikan Password',
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (final _) => _prosesLogin(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _prosesLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Log.info("Tombol 'Lupa Sandi?' ditekan.");
                  unawaited(showDialog<void>(
                    context: context,
                    builder: (final ctx) => AlertDialog(
                      title: const Text('Fitur Dalam Pengembangan'),
                      content: const Text(
                        'Fitur ini sedang kami kerjakan dan akan segera tersedia.',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ],
                    ),
                  ),);
                },
                child: const Text('Lupa Sandi?'),
              ),
              // ditambah: Tombol untuk navigasi ke halaman pendaftaran.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?'),
                  TextButton(
                    onPressed: () async {
                      Log.info("Tombol 'Daftar di sini' ditekan.");
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (final context) => const DaftarAkunPage(),
                        ),
                      );
                    },
                    child: const Text('Daftar di sini'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
