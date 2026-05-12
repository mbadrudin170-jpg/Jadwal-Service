
import 'dart:math' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final FirebaseFirestore? firestore;
  final LocalStorageService? localStorageService;

  const LoginPage({super.key, this.firestore, this.localStorageService});

  @override
  Widget build(BuildContext context) {
    return _TampilanLogin(
      firestore: firestore,
      localStorageService: localStorageService,
    );
  }
}

class StatelessWidget {
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
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  bool _isLocalStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    _initializeLocalStorage();
  }

  Future<void> _initializeLocalStorage() async {
    if (widget.localStorageService != null) {
      _localStorageService = widget.localStorageService!;
      setState(() {
        _isLocalStorageInitialized = true;
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _localStorageService = LocalStorageService(prefs: prefs);
        _isLocalStorageInitialized = true;
      });
    }
  }

  void _tampilkanAlertError(String pesan) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Gagal Masuk"),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cek Kembali"),
          ),
        ],
      ),
    );
  }

  void _ubahVisibilitasPassword() {
    setState(() {
      _apakahPasswordTerlihat = !_apakahPasswordTerlihat;
    });
  }

  Future<void> _prosesLogin() async {
    if (!_isLocalStorageInitialized) {
      _tampilkanAlertError("Layanan penyimpanan lokal belum siap. Coba lagi.");
      return;
    }

    final navigator = Navigator.of(context);
    final telepon = _teleponController.text.trim();
    final password = _passwordController.text.trim();

    if (telepon.isEmpty || password.isEmpty) {
      _tampilkanAlertError("Nomor telepon dan password tidak boleh kosong.");
      return;
    }

    try {
      developer.log(
          "Mencoba login dengan telepon: '$telepon' dan password: '$password'",
          name: 'auth.attempt');

      final querySnapshot = await _firestore
          .collection('pelanggan')
          .where('telepon', isEqualTo: telepon)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      developer.log(
          "Query selesai. Ditemukan ${querySnapshot.docs.length} dokumen yang cocok.",
          name: 'auth.result');

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final uid = userDoc.id;

        final pelanggan = PelangganModel.fromFirestore(userDoc);

        await _localStorageService.simpanAkun(pelanggan);

        developer.log("Login Berhasil! ID User: $uid", name: 'auth.login');
        developer.log("Akun disimpan ke penyimpanan lokal.",
            name: 'auth.local_storage');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', uid);
        developer.log("ID Pengguna disimpan di SharedPreferences.",
            name: 'auth.session');

        await _pushNotificationService.simpanTokenPenggunaSaatIni();
        developer.log("Memulai penyimpanan FCM Token.", name: 'auth.fcm');

        navigator.pushReplacement(
          MaterialPageRoute(
              builder: (context) => MainPage(
                  userId: uid, localStorageService: _localStorageService)),
        );
      } else {
        _tampilkanAlertError(
            "Nomor telepon atau password yang Anda masukkan salah.");
      }
    } catch (e, s) {
      developer.log(
        "Terjadi kesalahan saat login.",
        name: 'auth.error',
        error: e,
        stackTrace: s,
      );
      _tampilkanAlertError(
          "Terjadi kesalahan koneksi ke server. Silakan coba lagi.");
    }
  }

  @override
  void dispose() {
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                onFieldSubmitted: (_) => _prosesLogin(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _prosesLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
                  developer.log("Tombol 'Lupa Sandi?' ditekan.",
                      name: 'ui.interaction');
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Fitur Dalam Pengembangan'),
                      content: const Text(
                          'Fitur ini sedang kami kerjakan dan akan segera tersedia.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        )
                      ],
                    ),
                  );
                },
                child: const Text('Lupa Sandi?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
