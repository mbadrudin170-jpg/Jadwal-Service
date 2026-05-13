// path: lib/admin/halaman/form/form_pelanggan.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart'; // diubah: Menggunakan Log kustom
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/operasi/pelanggan_operasi.dart';

/// Halaman form untuk menambah atau mengedit data pelanggan.
class FormPelanggan extends StatefulWidget {
  /// Model pelanggan yang akan diedit. Jika null, maka form dalam mode tambah baru.
  final PelangganModel? pelanggan;

  /// Konstruktor untuk FormPelanggan.
  const FormPelanggan({super.key, this.pelanggan});

  @override
  State<FormPelanggan> createState() => _FormPelangganState();
}

class _FormPelangganState extends State<FormPelanggan> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _macAddressController = TextEditingController();

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _alamatFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _macAddressFocusNode = FocusNode();

  bool get _isEditMode => widget.pelanggan != null;
  bool _isPasswordVisible = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Log.info(
        'Membuka FormPelanggan dalam mode: ${_isEditMode ? "Edit" : "Tambah"}.');
    if (_isEditMode) {
      Log.info(
          'Mode Edit: Mempopulasikan form dengan data pelanggan ID: ${widget.pelanggan!.id}');
      _namaController.text = widget.pelanggan!.nama;
      _teleponController.text = widget.pelanggan!.telepon;
      _alamatController.text = widget.pelanggan!.alamat;
      _passwordController.text = widget.pelanggan!.password;
      _macAddressController.text = widget.pelanggan!.macAddress;
    }
  }

  @override
  void dispose() {
    Log.info(
        'Menjalankan dispose di FormPelanggan. Membersihkan semua controllers dan focus nodes.');
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _macAddressController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _alamatFocusNode.dispose();
    _passwordFocusNode.dispose();
    _macAddressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanForm() async {
    Log.info('Tombol "Simpan" ditekan.');
    if (_formKey.currentState!.validate()) {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _isSaving = true);

      final newPelanggan = PelangganModel(
        id: _isEditMode ? widget.pelanggan!.id : const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        password: _passwordController.text, // No trim for password
        macAddress: _macAddressController.text.trim().toUpperCase(),
        diperbarui: DateTime.now(),
      );

      Log.info('Model Pelanggan yang akan disimpan: ${newPelanggan.toJson()}');

      try {
        if (!_isEditMode) {
          Log.info(
              'Menjalankan operasi CREATE untuk pelanggan baru: ${newPelanggan.nama}');
          await PelangganOperasi().createPelanggan(newPelanggan);
        } else {
          Log.info(
              'Menjalankan operasi UPDATE untuk pelanggan ID: ${newPelanggan.id}');
          await PelangganOperasi().updatePelanggan(newPelanggan);
        }

        if (mounted) {
          Log.info(
              'Penyimpanan berhasil. Menutup form dan kembali dengan hasil true.');
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data pelanggan berhasil disimpan.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e, s) {
        Log.error('Gagal menyimpan data pelanggan ke database.', e: e, st: s);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
          Log.info('Proses penyimpanan selesai. isSaving diatur ke false.');
        }
      }
    } else {
      Log.warning('Form tidak valid. Proses penyimpanan dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI FormPelanggan. isSaving: $_isSaving');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Pelanggan' : 'Tambah Pelanggan',
        ),
        leading: BackButton(
          onPressed: () {
            Log.info('Tombol "Back" ditekan. Kembali tanpa menyimpan.');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  label: 'Nama Pelanggan',
                  icon: Icons.person_outline,
                  nextFocus: _teleponFocusNode,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  label: 'Nomor Telepon (WhatsApp)',
                  icon: Icons.phone_android_outlined,
                  keyboard: TextInputType.phone,
                  nextFocus: _alamatFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Telepon tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  label: 'Alamat Lengkap',
                  icon: Icons.home_outlined,
                  nextFocus: _passwordFocusNode,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Alamat tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        Log.info('Visibilitas password diubah.');
                        setState(
                            () => _isPasswordVisible = !_isPasswordVisible);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_macAddressFocusNode),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _macAddressController,
                  focusNode: _macAddressFocusNode,
                  label: 'MAC Address',
                  icon: Icons.router_outlined,
                  hint: 'XX:XX:XX:XX:XX:XX',
                  action: TextInputAction.done,
                  onSubmitted: (_) => _macAddressFocusNode.unfocus(),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'MAC Address tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _simpanForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'SIMPAN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    FocusNode? nextFocus,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboard,
      textInputAction: action,
      onFieldSubmitted: (v) {
        if (nextFocus != null) FocusScope.of(context).requestFocus(nextFocus);
        if (onSubmitted != null) onSubmitted(v);
      },
      validator: validator,
    );
  }
}
