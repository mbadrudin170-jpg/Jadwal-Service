// path: lib/user/page/edit_profil_page.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

/// Halaman untuk mengedit profil pengguna.
///
/// Memungkinkan pengguna untuk mengubah nama, nomor telepon, dan password mereka.
class EditProfilPage extends StatefulWidget {
  /// Data pelanggan yang akan diedit.
  final PelangganModel pelanggan;

  /// ID unik pengguna yang sedang login.
  final String userId;

  /// Membuat instance dari [EditProfilPage].
  const EditProfilPage({
    super.key,
    required this.pelanggan,
    required this.userId,
  });

  @override
  State<EditProfilPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _teleponController;
  late TextEditingController _passwordController; // Controller untuk password
  final _pelangganOpFirebase = PelangganOpFirebase();

  bool _apakahPasswordTerlihat = false; // State untuk visibilitas password

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.pelanggan.nama);
    _teleponController = TextEditingController(text: widget.pelanggan.telepon);
    _passwordController = TextEditingController(
      text: widget.pelanggan.password,
    );
  }

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState?.validate() ?? false) {
      final navigator = Navigator.of(context);

      try {
        // Gunakan copyWith untuk membuat instance baru dengan data yang diperbarui
        final pelangganYangDiperbarui = widget.pelanggan.copyWith(
          nama: _namaController.text,
          telepon: _teleponController.text,
          password: _passwordController.text,
        );

        await _pelangganOpFirebase.perbaruiPelanggan(pelangganYangDiperbarui);

        if (!mounted) return;

        // Gunakan SnackBarUtil untuk notifikasi sukses
        SnackBarUtil.success(context, 'Profil berhasil diperbarui.');

        // Langsung kembali ke halaman sebelumnya dengan hasil true
        navigator.pop(true);
      } on Exception catch (e, st) {
        Log.error(
          'Gagal menyimpan perubahan profil',
          e: e,
          st: st,
        );
        if (!mounted) return;
        SnackBarUtil.error(context, 'Gagal menyimpan perubahan: $e');
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _passwordController.dispose(); // Jangan lupa dispose controller password
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
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (final value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (final value) {
                  if (value == null || value.isEmpty) {
                    return 'No. HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Form Field untuk Password
              TextFormField(
                controller: _passwordController,
                obscureText:
                    !_apakahPasswordTerlihat, // Sembunyikan atau tampilkan teks
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Ganti ikon berdasarkan state visibilitas
                      _apakahPasswordTerlihat
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      // Ubah state untuk toggle visibilitas password
                      setState(() {
                        _apakahPasswordTerlihat = !_apakahPasswordTerlihat;
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
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
