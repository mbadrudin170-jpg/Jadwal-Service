// path: lib/user/page/edit_profil_page.dart

import 'package:flutter/material.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/services/firestore_service.dart';
import 'package:wifi/user/core/app_colors.dart';

class EditProfilPage extends StatefulWidget {
  final PelangganModel pelanggan;
  final String userId;

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
  final FirestoreService _firestoreService = FirestoreService();

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
    if (_formKey.currentState!.validate()) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        Map<String, dynamic> dataUntukUpdate = {
          'nama': _namaController.text,
          'telepon': _teleponController.text,
          'password':
              _passwordController.text, // Tambahkan password ke data update
        };

        await _firestoreService.perbaruiProfil(widget.userId, dataUntukUpdate);

        if (!mounted) return;

        // Menampilkan SnackBar sebagai notifikasi sukses
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Langsung kembali ke halaman sebelumnya dengan hasil true
        navigator.pop(true);
      } catch (e) {
        if (!mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
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
  Widget build(BuildContext context) {
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
                validator: (value) {
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
                validator: (value) {
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
                validator: (value) {
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
                  backgroundColor: AppColors.primary,
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
