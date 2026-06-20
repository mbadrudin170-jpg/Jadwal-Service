// path: lib/user/page/login_page.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/data_dummy/halaman_data_dummy.dart';
import 'package:wifi/fitur/akun/page/daftar_akun_page.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/shared/widget/input/input_telepon.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _teleponFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _sedangLogin = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _showErrorAlert(String pesan) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Akun tidak ditemukan'),
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

  Future<void> _prosesLogin() async {
    final telepon = _teleponController.text.trim();
    final kataSandi = _passwordController.text.trim();

    // Validasi format
    if (telepon.isEmpty || kataSandi.isEmpty) {
      return;
    }
    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(telepon)) {
      await _showErrorAlert('Nomor telepon tidak valid (minimal 10 digit).');
      return;
    }

    if (_sedangLogin) return;
    setState(() => _sedangLogin = true);

    try {
      final internetService = ref.read(koneksiInternetServiceProvider);
      final isConnected = await internetService.cekInternet();
      if (!isConnected) {
        if (!mounted) return;
        ToastUtil.error(context, 'Tidak ada koneksi internet.');
        return;
      }

      // Proses login ke Firestore
      final firestore = ref.read(firestoreProvider);
      final querySnapshot = await firestore
          .collection(NamaTabel.pelanggan)
          .where(NamaKolom.telepon, isEqualTo: telepon)
          .where(NamaKolom.kataSandi, isEqualTo: kataSandi)
          .where(NamaKolom.dihapus, isEqualTo: false)
          .limit(1)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        await _showErrorAlert('Nomor telepon tidak terdaftar.');
        return;
      }

      // Verifikasi password (misal dengan hash)
      final userDoc = querySnapshot.docs.first;
      final pelanggan = PelangganModel.fromFirebase(userDoc.id, userDoc.data());
      await ref.read(pengelolaAkunProvider.notifier).login(pelanggan);

      // Navigasi
      if (!mounted) return;
      unawaited(
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainPage())),
      );

      // Tugas sekunder
      try {
        final layananAktivitasUser = await ref.read(
          layananAktivitasUserProvider.future,
        );
        layananAktivitasUser.pingAktivitas(pelanggan.id, paksa: true);
      } catch (e, s) {
        Log.error('Gagal ping activity', e: e, s: s);
      }
    } catch (e, s) {
      Log.error('Login error', e: e, s: s);
      if (mounted) {
        await _showErrorAlert('Terjadi kesalahan. Silakan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _sedangLogin = false);
    }
  }

  Future<void> _tanganiPilihAkunTersedia() async {
    if (_sedangLogin) return;
    final layananPenyimpananLokal = await ref.read(
      layananPenyimpananLokalProvider.future,
    );
    final akun = await layananPenyimpananLokal.ambilDaftarAkun();
    if (!mounted) return;

    if (akun.isEmpty) {
      ToastUtil.info(
        context,
        'Tidak ada akun yang tersimpan. Silakan login manual.',
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const DaftarAkunPage()),
      );
    }
  }

  @override
  void dispose() {
    _teleponController.dispose();
    _passwordController.dispose();
    _teleponFocusNode.dispose();
    _passwordFocusNode.dispose();
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              gapH32,
              InputTelepon(
                controller: _teleponController,
                label: 'Nomor Telepon',
                focusNode: _teleponFocusNode,
                nextFocusNode: _passwordFocusNode,
                prefixIcon: TIcons.phoneAndroid,
                keyboardType: TextInputType.phone,
                enabled: !_sedangLogin,
              ),
              gapH16,
              InputPassword(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                onSubmitted: (_) => _prosesLogin(),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: TColors.primaryColor.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: _sedangLogin
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (kDebugMode)
                      TextButton(
                        onPressed: () {
                          unawaited(
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => const HalamanDataDummy(),
                              ),
                            ),
                          );
                        },
                        child: const Text('Debug: Dummy'),
                      ),

                    TextButton(
                      onPressed: _sedangLogin
                          ? null
                          : () {
                              unawaited(
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      'Fitur Dalam Pengembangan',
                                    ),
                                    content: const Text(
                                      'Fitur ini sedang kami kerjakan.',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                      child: const Text('Lupa Sandi?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
