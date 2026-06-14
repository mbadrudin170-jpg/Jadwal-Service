// path: lib/admin/halaman/form/wallet_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/data/services/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Halaman form untuk menambah atau mengedit dompet.
class WalletForm extends ConsumerStatefulWidget {
  /// Model dompet yang akan diedit. Jika null, maka form akan membuat dompet baru.
  final DompetModel? wallet;

  /// Konstruktor untuk WalletForm.
  const WalletForm({super.key, this.wallet});

  @override
  ConsumerState<WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends ConsumerState<WalletForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  late final DompetOpSqlite _dompetOpSqlite;

  late FocusNode _namaFocusNode;

  bool get _isEditMode => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.wallet != null;
    Log.info('Membuat state WalletForm. '
        'Mode: ${isEditMode ? "EDIT (ID: ${widget.wallet!.id}, Nama: ${widget.wallet!.name}, Saldo: ${widget.wallet!.balance})" : "TAMBAH BARU"}');
    _dompetOpSqlite = ref.read(dompetOpSqliteProvider);

    Log.info('Membuat FocusNode untuk input nama dompet.');
    _namaFocusNode = FocusNode();

    if (_isEditMode) {
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

  Future<void> _simpanform() async {
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

          final dataToUdpate = DompetModel(
            id: widget.wallet!.id,
            name: _namaController.text,
            balance: widget.wallet!.balance,
          );

          await _dompetOpSqlite.updateDompet(dataToUdpate);
          Log.info('Update dompet berhasil.');
        } else {
          Log.info('Proses TAMBAH dompet baru');

          final id = const Uuid().v4();
          Log.info(
              'UUID baru: $id, Nama: ${_namaController.text}, Saldo awal: 0.0');

          final dataBaru = DompetModel(
            id: id,
            name: _namaController.text,
            balance: 0.0,
            updatedAt: DateTime.now(),
          );

          await _dompetOpSqlite.tambahDompet(dataBaru);
          Log.info('Dompet baru berhasil disimpan. ID: $id');
        }

        if (!mounted) return;

        final cekKoneksiLokal =
            await ref.read(koneksiInternetServiceProvider).cekKoneksiLokal();
        if (cekKoneksiLokal) {
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi();

          if (mounted) {
            ToastUtil.success(
                context, 'Dompet berhasil disimpan dan disinkronkan.');
          }
        } else {
          if (mounted) {
            ToastUtil.info(context,
                'Dompet disimpan lokal. Sinkronisasi akan dilakukan saat online.');
          }
        }
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e, s) {
        Log.error(
          'Gagal menyimpan dompet. Proses ${_isEditMode ? "update" : "create"} gagal.',
          e: e,
          s: s,
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
          icon: const Icon(TIcons.back),
          onPressed: () {
            Log.info('Tombol Kembali ditekan. Kembali tanpa perubahan.');
            Navigator.pop(context, false);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
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
                  prefixIcon: Icon(TIcons.wallet),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) async {
                  Log.info('Field nama disubmit. Memanggil simpan.');
                  await _simpanform();
                },
                onChanged: (value) {
                  Log.info(
                      'Nama dompet berubah: "$value" (${value.length} karakter)');
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    Log.warning('Validasi: Nama dompet kosong.');
                    return 'Nama dompet tidak boleh kosong';
                  }
                  return null;
                },
              ),
              gapH24,
              ElevatedButton(
                onPressed: () async {
                  Log.info('Tombol Simpan ditekan.');
                  await _simpanform();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, TSizes.p48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.p12),
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
