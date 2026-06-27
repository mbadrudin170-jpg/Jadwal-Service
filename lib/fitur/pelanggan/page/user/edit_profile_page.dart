// path lib/fitur/pelanggan/page/user/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_global.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/input/input_telepon.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final PelangganModel pelanggan;
  const EditProfilePage({super.key, required this.pelanggan});
  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _teleponController;
  late TextEditingController _passwordController;

  final _namaFocusNode = FocusNode();
  final _teleponFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info('EditProfilePage.initState - mulai inisialisasi controller.');
    _namaController = TextEditingController(text: widget.pelanggan.nama);
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
        final isOnline = await ref
            .read(koneksiInternetServiceProvider)
            .cekInternet();
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
          nama: _namaController.text,
          telepon: _teleponController.text,
          kataSandi: _passwordController.text,
        );

        Log.info(
          'Menyiapkan update pelanggan: id=${dataPelanggan.id}, nama=${dataPelanggan.nama}, telepon=${dataPelanggan.telepon}.',
        );

        final pelangganOp = ref.read(pelangganOpGlobalProvider);
        await pelangganOp.updatePelanggan(dataPelanggan);
        Log.info('perbaruiPelanggan selesai untuk id=${dataPelanggan.id}.');
        if (!mounted) {
          Log.info(
            'Widget tidak lagi mounted setelah update; tidak menampilkan toast atau menutup halaman.',
          );                      
          return;
        }
        ToastUtil.success(context, 'Profil berhasil diperbarui.');
        Log.info('Toast sukses ditampilkan, mmenutup halaman edit.');
        navigator.pop(context);
      } catch (e, st) {
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
    _namaController.dispose();
    _teleponController.dispose();
    _passwordController.dispose();
    _namaFocusNode.dispose();
    _teleponFocusNode.dispose();
    _passwordFocusNode.dispose();
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
              InputTeks(
                focusNode: _namaFocusNode,
                controller: _namaController,
                nextFocusNode: _teleponFocusNode,
                label: 'Nama Lengkap',
                prefixIcon: TIcons.person,
              ),
              gapH16,
              InputTelepon(
                controller: _teleponController,
                focusNode: _teleponFocusNode,
                nextFocusNode: _passwordFocusNode,
              ),

              gapH16,
              InputPassword(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done,
              ),
              gapH32,
              ElevatedButton(
                onPressed: _menyimpan
                    ? null
                    : () async {
                        setState(() => _menyimpan = true);
                        try {
                          await _simpanForm();
                        } finally {
                          if (mounted) setState(() => _menyimpan = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _menyimpan
                    ? const CircularProgressIndicator()
                    : const Text(
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
