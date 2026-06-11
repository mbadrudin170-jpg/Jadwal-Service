// path: lib/user/page/login_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _sedangLogin = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _showErrorAlert(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akun tidak ditemukan'),
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

  Future<void> _prosesLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      await _showErrorAlert('Nomor telepon dan password tidak boleh kosong.');
      return;
    }

    if (_sedangLogin) return;
    setState(() => _sedangLogin = true);

    try {
      final internetService = ref.read(koneksiInternetServiceProvider);
      final isConnected = await internetService.cekInternet(ref);
      if (!mounted) return;
      if (!isConnected) {
        ToastUtil.error(
            context, 'Tidak ada koneksi internet. Periksa jaringan Anda.');
        return;
      }
      final firestore = ref.read(firestoreProvider);
      final querySnapshot = await firestore
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

        // 1. Simpan sesi (kritis)
        await ref.read(pengelolaAkunProvider.notifier).login(customer);
        Log.info('menyimpan token login pada saat login untuk ${customer.id}');

        // 2. Langsung navigasi (kritis untuk UX)
        if (!mounted) return;
        unawaited(Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (final context) => const MainPage(),
          ),
        ));

        // 3. Lakukan tugas sekunder setelah navigasi berhasil
        // Kesalahan di sini tidak akan mengganggu pengguna
        try {
          final activityService =
              await ref.read(userActivityServiceProvider.future);
          activityService.pingActivity(customer.id, force: true);
          Log.info(
              'memperbarui last aktif user setelah login berhasil ${customer.id}');
        } catch (e, s) {
          // Hanya catat error ini untuk debug, jangan tampilkan ke pengguna
          Log.error('Gagal ping activity setelah login', e: e, st: s);
        }

        return; // Selesai
      } else {
        setState(() => _sedangLogin = false);
        await _showErrorAlert(
            'Nomor telepon atau password yang Anda masukkan salah.');
      }
    } catch (e, s) {
      Log.error('Terjadi kesalahan saat login.', e: e, st: s);
      if (mounted) setState(() => _sedangLogin = false);
      if (!mounted) return;
      await _showErrorAlert(
          'Terjadi kesalahan koneksi ke server. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _sedangLogin = false);
      }
    }
  }

  Future<void> _tanganiPilihAkunTersedia() async {
    if (_sedangLogin) return;
    final layananPenyimpananLokal =
        await ref.read(localStorageServiceProvider.future);
    final akun = await layananPenyimpananLokal.ambilDaftarAkun();
    if (!mounted) return;

    if (akun.isEmpty) {
      ToastUtil.info(
          context, 'Tidak ada akun yang tersimpan. Silakan login manual.');
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const DaftarAkunPage(),
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
              gapH32,
              InputAngka(
                controller: _phoneController,
                label: 'Nomor Telepon',
                prefixIcon: TIcons.phoneAndroid,
                enabled: !_sedangLogin,
              ),
              gapH16,
              InputPassword(
                controller: _passwordController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Password tidak boleh kosong'
                    : null,
                onFieldSubmitted: (p0) => _prosesLogin(),
                textInputAction: TextInputAction.done,
                enabled: !_sedangLogin,
              ),
              gapH24,
              ElevatedButton(
                onPressed: _sedangLogin ? null : _prosesLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor:
                      TColors.primaryColor.withValues(alpha: 0.5),
                ),
                child: _sedangLogin
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Login'),
              ),
              gapH16,
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
              gapH16,
              OutlinedButton.icon(
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Pilih dari Akun Tersimpan'),
                onPressed: _sedangLogin ? null : _tanganiPilihAkunTersedia,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              gapH8,
              Align(
                child: TextButton(
                  onPressed: _sedangLogin
                      ? null
                      : () {
                          unawaited(showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Fitur Dalam Pengembangan'),
                              content:
                                  const Text('Fitur ini sedang kami kerjakan.'),
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
