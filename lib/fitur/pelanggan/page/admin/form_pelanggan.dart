// path lib/fitur/pelanggan/page/admin/form_pelanggan.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/app_role/role_util.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_mac_address.dart';
import 'package:wifi/shared/widget/input/input_password.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';
import 'package:wifi/shared/widget/input/input_telepon.dart';

class FormPelanggan extends ConsumerStatefulWidget {
  final PelangganModel? pelanggan;

  const FormPelanggan({super.key, this.pelanggan});

  @override
  ConsumerState<FormPelanggan> createState() => _CustomerFormState();
}

class _CustomerFormState extends ConsumerState<FormPelanggan> {
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

  bool get _modeEdit => widget.pelanggan != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    Log.info(
      'Membuka form_pelanggan dalam mode: ${_modeEdit ? "Edit" : "Tambah"}.',
    );
    if (_modeEdit) {
      Log.info(
        'Mode Edit: Mempopulasikan form dengan data pelanggan ID: ${widget.pelanggan!.id}',
      );
      _namaController.text = widget.pelanggan!.nama;
      _teleponController.text = widget.pelanggan!.telepon;
      _alamatController.text = widget.pelanggan!.alamat;
      _passwordController.text = widget.pelanggan!.kataSandi;
      _macAddressController.text = widget.pelanggan!.macAddress;
    }
  }

  @override
  void dispose() {
    Log.info(
      'Menjalankan dispose di CustomerForm. Membersihkan semua controllers dan focus nodes.',
    );
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

  Future<void> _simpanPelanggan() async {
    if (_menyimpan) return;
    if (ref.isUser) {
      final isOnline = await ref
          .read(koneksiInternetServiceProvider)
          .cekInternet();
      if (!isOnline) {
        if (!mounted) return;
        ToastUtil.error(context, 'Cek koneksi internet Anda');
        return;
      }
    }
    final pelangganOp = ref.read(pelangganProvider.notifier);
    Log.info('Tombol "Simpan" ditekan.');
    if (!_formKey.currentState!.validate()) {
      Log.warning('Form tidak valid. Proses penyimpanan dibatalkan.');
      return;
    }
    try {
      Log.info('Form valid. Memulai proses penyimpanan.');
      setState(() => _menyimpan = true);
      final pelangganBaru = PelangganModel(
        id: _modeEdit ? widget.pelanggan!.id : const Uuid().v4(),
        nama: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
        alamat: _alamatController.text.trim(),
        kataSandi: _passwordController.text,
        macAddress: _macAddressController.text.trim().toUpperCase(),
      );
      Log.info(
        'Model Pelanggan yang akan disimpan: ${pelangganBaru.toFirebase()}',
      );

      if (_modeEdit) {
        Log.info(
          'Menjalankan operasi UPDATE untuk pelanggan ID: ${pelangganBaru.id}',
        );
        await pelangganOp.updatePelanggan(pelangganBaru);
      } else {
        Log.info(
          'Menjalankan operasi CREATE untuk pelanggan baru: ${pelangganBaru.nama}',
        );
        await pelangganOp.tambahPelanggan(pelangganBaru);
      }
      Log.info('jalankan sinkroniasi');
      if (mounted) {
        ToastUtil.success(context, 'Data pelanggan berhasil disimpan.');
      }
      if (mounted) {
        Navigator.pop(context);
      }
      if (ref.isAdmin) {
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
      }
    } catch (e, s) {
      Log.error('Gagal menyimpan data pelanggan ke database.', e: e, s: s);
      String userMessage = 'Gagal menyimpan data: $e';
      if (e.toString().contains('sudah ada')) {
        userMessage = 'Nomor telepon dan password sudah digunakan.';
      }
      if (mounted) {
        ToastUtil.error(context, userMessage);
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
        Log.info('Proses penyimpanan selesai. isSaving diatur ke false.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('Membangun UI CustomerForm. isSaving: $_menyimpan');
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
        leading: BackButton(
          onPressed: () {
            Log.info('Tombol "Back" ditekan. Kembali tanpa menyimpan.');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputTeks(
                  controller: _namaController,
                  focusNode: _namaFocusNode,
                  nextFocusNode: _teleponFocusNode,
                  label: 'Nama Pelanggan',
                  prefixIcon: TIcons.personOutlined,
                ),
                gapH16,
                InputTelepon(
                  controller: _teleponController,
                  focusNode: _teleponFocusNode,
                  nextFocusNode: _alamatFocusNode,
                ),
                gapH16,
                InputTeks(
                  controller: _alamatController,
                  focusNode: _alamatFocusNode,
                  nextFocusNode: _passwordFocusNode,
                  label: 'Alamat Lengkap',
                  prefixIcon: TIcons.home,
                ),
                gapH16,
                InputPassword(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  nextFocusNode: _macAddressFocusNode,
                ),
                gapH16,
                if (ref.isAdmin)
                  InputMacAddress(
                    controller: _macAddressController,
                    focusNode: _macAddressFocusNode,
                    onSubmitted: (_) => _simpanPelanggan(),
                    textInputAction: TextInputAction.done,
                  ),
                gapH32,
                ElevatedButton(
                  onPressed: _menyimpan ? null : _simpanPelanggan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('SIMPAN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
