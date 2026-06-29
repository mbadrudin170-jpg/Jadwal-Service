// path: lib/fitur/dompet/page/form_dompet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';

/// Halaman form untuk menambah atau mengedit dompet.
class FormDompet extends ConsumerStatefulWidget {
  /// Model dompet yang akan diedit. Jika null, maka form akan membuat dompet baru.
  final DompetModel? dompet;

  /// Konstruktor untuk WalletForm.
  const FormDompet({super.key, this.dompet});

  @override
  ConsumerState<FormDompet> createState() => _WalletFormState();
}

class _WalletFormState extends ConsumerState<FormDompet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  late final DompetOpSqlite _dompetOpSqlite;
  late FocusNode _namaFocusNode;
  bool get _modeEdit => widget.dompet != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _dompetOpSqlite = ref.read(dompetOpSqliteProvider);
    _namaFocusNode = FocusNode();
    if (_modeEdit) {
      _namaController.text = widget.dompet!.nama;
    }
  }

  @override
  void dispose() {
    Log.info('Dispose WalletForm. Membersihkan resource.');
    _namaController.dispose();
    _namaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _simpanform() async {
    if (_menyimpan) return;
    try {
      _menyimpan = true;
      _namaFocusNode.unfocus();
      if (!_formKey.currentState!.validate()) {
        return;
      }
      Log.info('Validasi form berhasil. Nama: "${_namaController.text}"');

      if (_modeEdit) {
        Log.info('Proses UPDATE dompet ID: ${widget.dompet!.id}');
        Log.info(
          'Nama Lama: "${widget.dompet!.nama}", Nama Baru: "${_namaController.text}"',
        );
        Log.info('Saldo tetap: ${widget.dompet!.saldo}');
        final dataBaru = DompetModel(
          id: widget.dompet!.id,
          nama: _namaController.text,
          saldo: widget.dompet!.saldo,
        );
        await _dompetOpSqlite.updateDompet(dataBaru);
        ref.invalidate(detailDompetProvider(widget.dompet!.id));
      } else {
        final dataBaru = DompetModel(
          id: const Uuid().v4(),
          nama: _namaController.text,
        );
        await _dompetOpSqlite.tambahDompet(dataBaru);
      }
      ref.invalidate(dompetProvider);
      unawaited(
        ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
      );
      if (!mounted) return;
      ToastUtil.success(context, 'Dompet berhasil disimpan.');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, s) {
      Log.error(
        'Gagal menyimpan dompet. Proses ${_modeEdit ? "update" : "create"} gagal.',
        e: e,
        s: s,
      );
      if (!mounted) return;
      ToastUtil.error(context, 'Gagal menyimpan dompet: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Build WalletForm. Mode: ${_modeEdit ? "EDIT" : "TAMBAH BARU"}, Nama: "${_namaController.text}"',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Nama Dompet' : 'Tambah Dompet Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.p16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputTeks(
                controller: _namaController,
                focusNode: _namaFocusNode,
                label: 'Nama Dompet',
                textInputAction: TextInputAction.done,
                prefixIcon: TIcons.wallet,
                onSubmitted: (_) async {
                  await _simpanform();
                },
              ),
              // TextFormField(
              //   controller: _namaController,
              //   focusNode: _namaFocusNode,
              //   decoration: const InputDecoration(
              //     labelText: 'Nama Dompet',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(TIcons.wallet),
              //   ),
              //   textInputAction: TextInputAction.done,
              //   onFieldSubmitted: (_) async {
              //     Log.info('Field nama disubmit. Memanggil simpan.');
              //     await _simpanform();
              //   },
              //   onChanged: (value) {
              //     Log.info(
              //       'Nama dompet berubah: "$value" (${value.length} karakter)',
              //     );
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       Log.warning('Validasi: Nama dompet kosong.');
              //       return 'Nama dompet tidak boleh kosong';
              //     }
              //     return null;
              //   },
              // ),
              gapH24,
              ElevatedButton(
                onPressed: _menyimpan
                    ? null
                    : () async {
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
