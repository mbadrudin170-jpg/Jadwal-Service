// path: lib/admin/halaman/form/wallet_form.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/data/services/sync_check_service.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman form untuk menambah atau mengedit dompet.
class WalletForm extends StatefulWidget {
  /// Model dompet yang akan diedit. Jika null, maka form akan membuat dompet baru.
  final WalletModel? wallet;

  /// Konstruktor untuk WalletForm.
  const WalletForm({super.key, this.wallet});

  @override
  State<WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends State<WalletForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final WalletOperation _walletOperation = WalletOperation();

  late FocusNode _namaFocusNode;

  bool get _isEditMode => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.wallet != null;
    Log.info(
      'Membuat state WalletForm. '
      'Mode: ${isEditMode ? "EDIT (ID: ${widget.wallet!.id}, Nama: ${widget.wallet!.name}, Saldo: ${widget.wallet!.balance})" : "TAMBAH BARU"}',
    );

    Log.info('Membuat FocusNode untuk input nama dompet.');
    _namaFocusNode = FocusNode();

    if (_isEditMode) {
      Log.info('MODE EDIT terdeteksi. Data dompet yang akan diedit:');
      Log.info('  - ID: ${widget.wallet!.id}');
      Log.info('  - Nama Lama: ${widget.wallet!.name}');
      Log.info('  - Saldo: ${widget.wallet!.balance}');
      Log.info('  - Diperbarui: ${widget.wallet!.updatedAt}');
      Log.info('  - isDeleted: ${widget.wallet!.isDeleted}');
      Log.info('  - Diarsipkan: ${widget.wallet!.archivedAt ?? "NULL"}');

      Log.info(
        'Mengisi TextEditingController dengan nama dompet lama: "${widget.wallet!.name}"',
      );
      _namaController.text = widget.wallet!.name;
    } else {
      Log.info('MODE TAMBAH BARU terdeteksi.');
      Log.info('Form akan membuat dompet baru dengan:');
      Log.info('  - ID: Akan digenerate otomatis menggunakan UUID v4');
      Log.info('  - Nama: Dari input pengguna');
      Log.info('  - Saldo Awal: 0.0');
      Log.info('  - Diperbarui: DateTime.now()');
      Log.info('  - isDeleted: 0 (default)');
      Log.info('  - Diarsipkan: NULL (default)');
    }

    Log.info('Inisialisasi WalletForm selesai.');
  }

  @override
  void dispose() {
    Log.info('Dispose WalletForm. Membersihkan resource.');
    _namaController.dispose();
    _namaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveform() async {
    Log.info(
      'Tombol Simpan ditekan. Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}',
    );

    _namaFocusNode.unfocus();

    if (_formKey.currentState!.validate()) {
      Log.info('Validasi form berhasil. Nama: "${_namaController.text}"');

      try {
        if (_isEditMode) {
          Log.info('Proses UPDATE dompet ID: ${widget.wallet!.id}');
          Log.info(
            'Nama Lama: "${widget.wallet!.name}", Nama Baru: "${_namaController.text}"',
          );
          Log.info('Saldo tetap: ${widget.wallet!.balance}');

          final updatedWallet = WalletModel(
            id: widget.wallet!.id,
            name: _namaController.text,
            balance: widget.wallet!.balance,
          );

          await _walletOperation.updateWallet(updatedWallet);
          Log.info('Update dompet berhasil.');
        } else {
          Log.info('Proses TAMBAH dompet baru');

          final newId = const Uuid().v4();
          Log.info(
              'UUID baru: $newId, Nama: ${_namaController.text}, Saldo awal: 0.0');

          final newWallet = WalletModel(
            id: newId,
            name: _namaController.text,
            balance: 0.0,
            updatedAt: DateTime.now(),
          );

          await _walletOperation.createWallet(newWallet);
          Log.info('Dompet baru berhasil disimpan. ID: $newId');
        }

        if (!mounted) return;

        final hasConnection = await InternetConnectionService().checkConnection();
        if (hasConnection) {
          await SyncCheckService().runSyncCheck();
          if (mounted) {
            ToastUtil.success(context, 'Dompet berhasil disimpan dan disinkronkan.');
          }
        } else {
          if (mounted) {
            ToastUtil.info(context, 'Dompet disimpan lokal. Sinkronisasi akan dilakukan saat online.');
          }
        }

        Navigator.pop(context, true);
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan dompet. Proses ${_isEditMode ? "update" : "create"} gagal.',
          e: e,
          st: s,
        );

        if (!mounted) return;
        ToastUtil.error(context, 'Gagal menyimpan dompet: $e');
      }
    } else {
      Log.warning('Validasi form gagal. Nama dompet kosong atau tidak valid.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Build WalletForm. Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}, Nama: "${_namaController.text}"',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Nama Dompet' : 'Tambah Dompet Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info('Tombol Kembali ditekan. Kembali tanpa perubahan.');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                focusNode: _namaFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Nama Dompet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (final _) async {
                  Log.info('Field nama disubmit. Memanggil simpan.');
                  await _saveform();
                },
                onChanged: (final value) {
                  Log.info(
                      'Nama dompet berubah: "$value" (${value.length} karakter)');
                },
                validator: (final value) {
                  if (value == null || value.isEmpty) {
                    Log.warning('Validasi: Nama dompet kosong.');
                    return 'Nama dompet tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Log.info('Tombol Simpan ditekan.');
                  await _saveform();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
