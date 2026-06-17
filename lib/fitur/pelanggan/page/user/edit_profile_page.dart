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
    _nameController = TextEditingController(text: widget.pelanggan.nama);
    _teleponController = TextEditingController(text: widget.pelanggan.telepon);
    _passwordController = TextEditingController(
      text: widget.pelanggan.kataSandi,
    );
  }

  Future<void> _simpanForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final navigator = Navigator.of(context);

      try {
        final isOnline = await _koneksiInternetService.cekInternet(ref);
        if (!isOnline) {
          if (mounted) {
            ToastUtil.info(context, 'Cek koneksi internet Anda.');
          }
          return;
        }

        final dataPelanggan = widget.pelanggan.copyWith(
          nama: _nameController.text,
          telepon: _teleponController.text,
          kataSandi: _passwordController.text,
        );
        final pelangganOpFirebase = ref.read(pelangganOpFirebaseProvider);
        await pelangganOpFirebase.perbaruiPelanggan(dataPelanggan);
        ref.invalidate(pelangganOpFirebaseProvider);
        if (!mounted) return;

        ToastUtil.success(context, 'Profil berhasil diperbarui.');

        navigator.pop(context);
      } on Exception catch (e, st) {
        Log.error('Gagal menyimpan perubahan profil', e: e, s: st);
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan perubahan: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
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
