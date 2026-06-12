// path: lib/user/page/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman untuk mengedit profil pengguna.
///
/// Memungkinkan pengguna untuk mengubah nama, nomor telepon, dan password mereka.
class EditProfilePage extends ConsumerStatefulWidget {
  /// Data pelanggan yang akan diedit.
  final CustomerModel customer;

  // /// ID unik pengguna yang sedang login.
  // final String userId;

  /// Membuat instance dari [EditProfilePage].
  const EditProfilePage({
    super.key,
    required this.customer,
    // required this.userId,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  final _internetConnectionService = KoneksiInternetService();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _passwordController = TextEditingController(text: widget.customer.password);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      final navigator = Navigator.of(context);

      try {
        final isOnline = await _internetConnectionService.cekInternet(ref);
        if (!isOnline) {
          if (mounted) {
            ToastUtil.info(
              context,
              'Cek koneksi internet Anda.',
            );
          }
          return;
        }

        final updatedCustomer = widget.customer.copyWith(
          name: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );
        final customerOpFirebase = ref.read(customerOpFirebaseProvider);
        await customerOpFirebase.perbaruiPelanggan(updatedCustomer);
        ref.invalidate(customerOpFirebaseProvider);
        if (!mounted) return;

        ToastUtil.success(context, 'Profil berhasil diperbarui.');

        navigator.pop(true);
      } on Exception catch (e, st) {
        Log.error(
          'Gagal menyimpan perubahan profil',
          e: e,
          st: st,
        );
        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan perubahan: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                validator: (final value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              gapH16,
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (final value) {
                  if (value == null || value.isEmpty) {
                    return 'No. HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
              gapH16,
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
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
                onPressed: _saveChanges,
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
