// path lib/fitur/pelanggan/page/user/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final PelangganModel pelanggan;

  const EditProfilePage({super.key, required this.pelanggan});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _teleponController;
  late TextEditingController _passwordController;
  final _koneksiInternetService = KoneksiInternetService();

  bool _passwordTerlihat = false;

  @override
  void initState() {
    super.initState();
    Log.info('EditProfilePage.initState - mulai inisialisasi controller.');
    _nameController = TextEditingController(text: widget.pelanggan.nama);
    _teleponController = TextEditingController(text: widget.pelanggan.telepon);
    _passwordController = TextEditingController(
      text: widget.pelanggan.kataSandi,
    );
    Log.info(
      'EditProfilePage.initState - data pelanggan dimuat: id=${widget.pelanggan.id}, nama=${widget.pelanggan.nama}, telepon=${widget.pelanggan.telepon}.',
    );
  }

  Future<void> _simpanForm() async {
    Log.info('SimpanForm dipanggil - validasi form dimulai.');
    if (_formKey.currentState?.validate() ?? false) {
      Log.info('Form valid - memproses penyimpanan perubahan profil.');
      final navigator = Navigator.of(context);

      try {
        Log.info('Memeriksa koneksi internet sebelum menyimpan perubahan.');
        final isOnline = await _koneksiInternetService.cekInternet(ref);
        Log.info('Hasil cek koneksi: isOnline=$isOnline');

        if (!isOnline) {
          if (mounted) {
            ToastUtil.info(context, 'Cek koneksi internet Anda.');
          }
          Log.info(
            'Proses simpan dibatalkan karena tidak ada koneksi internet.',
          );
          return;
        }

        final dataPelanggan = widget.pelanggan.copyWith(
          nama: _nameController.text,
          telepon: _teleponController.text,
          kataSandi: _passwordController.text,
        );

        Log.info(
          'Menyiapkan update pelanggan: id=${dataPelanggan.id}, nama=${dataPelanggan.nama}, telepon=${dataPelanggan.telepon}.',
        );

        final pelangganOpFirebase = ref.read(pelangganOpFirebaseProvider);
        Log.info(
          'Memanggil pelangganOpFirebase.perbaruiPelanggan untuk id=${dataPelanggan.id}.',
        );
        await pelangganOpFirebase.perbaruiPelanggan(dataPelanggan);
        Log.info('perbaruiPelanggan selesai untuk id=${dataPelanggan.id}.');

        ref.invalidate(pelangganOpFirebaseProvider);
        Log.info(
          'Provider pelangganOpFirebase di-invalidate agar data terbaru diambil.',
        );

        if (!mounted) {
          Log.info(
            'Widget tidak lagi mounted setelah update; tidak menampilkan toast atau menutup halaman.',
          );
          return;
        }

        ToastUtil.success(context, 'Profil berhasil diperbarui.');
        Log.info('Toast sukses ditampilkan, menutup halaman edit.');

        navigator.pop(context);
      } on Exception catch (e, st) {
        Log.error('Gagal menyimpan perubahan profil', e: e, s: st);
        if (!mounted) {
          Log.error(
            'Widget tidak mounted saat terjadi error: tidak menampilkan toast.',
          );
          return;
        }
        ToastUtil.error(context, 'Gagal menyimpan perubahan: $e');
      }
    } else {
      Log.info('Form tidak valid - pembatalan penyimpanan.');
    }
  }

  @override
  void dispose() {
    Log.info('EditProfilePage.dispose - membuang controller.');
    _nameController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('Membangun UI EditProfilePage.');
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              gapH16,
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No. HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
              gapH16,
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordTerlihat,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordTerlihat
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordTerlihat = !_passwordTerlihat;
                        Log.info(
                          'Toggle visibilitas password: $_passwordTerlihat',
                        );
                      });
                    },
                  ),
                ),
                validator: (final value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              gapH32,
              ElevatedButton(
                onPressed: _simpanForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'SIMPAN',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
