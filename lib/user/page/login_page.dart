// path: lib/user/page/login_page.dart
// diubah: Mengganti SnackBarUtil menjadi ToastUtil dan menambahkan pencatatan waktu login.
// PERBAIKAN: Menghapus toast otomatis di initState untuk mencegah notifikasi ganda.
// FITUR: Menambahkan pengecekan koneksi internet sebelum login.
// FITUR: Menambahkan tombol untuk memilih akun yang sudah tersimpan.
// PERBAIKAN: Mencegah navigasi ke halaman list akun jika tidak ada akun tersimpan.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/customer_model.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/services/user_activity_service.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/user/page/account_list_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/services/storage/local_storage_service.dart';

/// Halaman login untuk pengguna.
class LoginPage extends StatelessWidget {
  /// Instance Firestore untuk akses database.
  final FirebaseFirestore? firestore;

  /// Layanan untuk penyimpanan data lokal.
  final LocalStorageService? localStorageService;

  /// Konstruktor untuk [LoginPage].
  const LoginPage({super.key, this.firestore, this.localStorageService});

  @override
  Widget build(final BuildContext context) {
    return _LoginView(
      firestore: firestore,
      localStorageService: localStorageService,
    );
  }
}

class _LoginView extends StatefulWidget {
  final FirebaseFirestore? firestore;
  final LocalStorageService? localStorageService;

  const _LoginView({this.firestore, this.localStorageService});

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late FirebaseFirestore _firestore;
  late LocalStorageService _localStorageService;
  final UserActivityService _activityService = UserActivityService();
  final InternetConnectionService _internetService =
      InternetConnectionService();
  bool _isPasswordVisible = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLocalStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
    unawaited(_initializeLocalStorage());
  }

  Future<void> _initializeLocalStorage() async {
    if (widget.localStorageService != null) {
      _localStorageService = widget.localStorageService!;
      if (mounted) setState(() => _isLocalStorageInitialized = true);
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _localStorageService = LocalStorageService(prefs: prefs);
          _isLocalStorageInitialized = true;
        });
      }
    }
  }

  Future<void> _showErrorAlert(final String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (final ctx) => AlertDialog(
        title: const Text('Gagal Masuk'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cek Kembali'),
          ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  Future<void> _processLogin() async {
    final isConnected = await _internetService.isInternetAvailable();
    if (!mounted) return;

    if (!isConnected) {
      ToastUtil.error(
          context, 'Tidak ada koneksi internet. Periksa jaringan Anda.');
      return;
    }

    if (!_isLocalStorageInitialized) {
      await _showErrorAlert('Layanan penyimpanan lokal belum siap. Coba lagi.');
      return;
    }

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      await _showErrorAlert('Nomor telepon dan password tidak boleh kosong.');
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection(TableNameValue.get(TableName.customer))
          .where(ColumnNames.phone, isEqualTo: phone)
          .where(ColumnNames.password, isEqualTo: password)
          .where(ColumnNames.isDeleted, isEqualTo: false)
          .limit(1)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final customer = CustomerModel.fromFirebase(userDoc.id, userDoc.data());
        Log.info('Pengguna berhasil login: ${customer.name}');

        unawaited(_activityService.pingActivity(customer.id, force: true));
        Log.info('memperbarui last aktif user ', {customer.id});
        await _localStorageService.saveAccount(customer);
        Log.info('Menyimpan id akun ke memori lokal');
        await _localStorageService.prefs.setString('userId', customer.id);

        if (!mounted) return;

        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (final context) => MainPage(
              userId: customer.id,
              localStorageService: _localStorageService,
            ),
          ),
        );
      } else {
        await _showErrorAlert(
            'Nomor telepon atau password yang Anda masukkan salah.');
      }
    } on Exception catch (e, s) {
      Log.error('Terjadi kesalahan saat login.', e: e, st: s);
      if (!mounted) return;
      await _showErrorAlert(
          'Terjadi kesalahan koneksi ke server. Silakan coba lagi.');
    }
  }

  // DITAMBAHKAN: Logika untuk menangani pemilihan akun yang ada.
  Future<void> _handleChooseExistingAccount() async {
    if (!_isLocalStorageInitialized) {
      if (mounted) {
        ToastUtil.warning(context, 'Penyimpanan data lokal belum siap.');
      }
      return;
    }

    final accounts = await _localStorageService.getAccountList();
    if (!mounted) return;

    if (accounts.isEmpty) {
      ToastUtil.info(
          context, 'Tidak ada akun yang tersimpan. Silakan login manual.');
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (final context) => const AccountListPage(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
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
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (final _) => _processLogin(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _processLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Atau',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Pilih dari Akun Tersimpan'),
                // diubah: Memanggil fungsi baru dengan logika pengecekan.
                onPressed: _handleChooseExistingAccount,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                child: TextButton(
                  onPressed: () {
                    unawaited(showDialog<void>(
                      context: context,
                      builder: (final ctx) => AlertDialog(
                        title: const Text('Fitur Dalam Pengembangan'),
                        content: const Text('Fitur ini sedang kami kerjakan.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ));
                  },
                  child: const Text('Lupa Sandi?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
