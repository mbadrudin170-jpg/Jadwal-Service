// path: lib/fitur/paket/page/form_paket.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/enum/tipe_durasi_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/sinkronisasi/layanan_cek_sinkronisasi.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_angka.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';

/// Halaman form untuk menambah atau mengedit paket.
class FormPaket extends ConsumerStatefulWidget {
  /// Model paket yang akan diedit. Jika null, maka form akan membuat paket baru.
  final PaketModel? paket;

  /// Konstruktor untuk PackageForm.
  const FormPaket({super.key, this.paket});

  @override
  ConsumerState<FormPaket> createState() => _PackageFormState();
}

class _PackageFormState extends ConsumerState<FormPaket> {
  late final PaketOpSqlite _paketOpSqlite;
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _durasiController = TextEditingController();
  final _poinHadiahcontroller = TextEditingController();
  final _poinPenukaranController = TextEditingController();
  final _namsFocusNode = FocusNode();
  final _hargaFocusNode = FocusNode();
  final _durasiFocusNode = FocusNode();
  final _poinHadiahFocusNode = FocusNode();
  final _poinPenukaranFocusNode = FocusNode();

  TipeDurasiPaket _selectedType = TipeDurasiPaket.days;

  bool get _modeEdit => widget.paket != null;
  bool _publik = false;

  @override
  void initState() {
    super.initState();
    _paketOpSqlite = ref.read(paketOpSqliteProvider);
    if (_modeEdit) {
      _namaController.text = widget.paket!.nama;
      _hargaController.text = widget.paket!.harga.toString();
      _durasiController.text = widget.paket!.durasi.toString();
      _poinHadiahcontroller.text = widget.paket!.poinHadiah.toString();
      _poinPenukaranController.text = widget.paket!.poinPenukaran.toString();
      _selectedType = widget.paket!.tipe;
      _publik = widget.paket!.statusPublik;
    }
  }

  Future<void> _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      final paketBaru = PaketModel(
        id: _modeEdit ? widget.paket!.id : const Uuid().v4(),
        nama: _namaController.text,
        harga:
            int.tryParse(
              _hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        durasi: int.tryParse(_durasiController.text) ?? 0,
        tipe: _selectedType,
        poinHadiah: int.tryParse(_poinHadiahcontroller.text) ?? 0,
        poinPenukaran: int.tryParse(_poinPenukaranController.text) ?? 0,
        statusPublik: _publik,
        diperbaruiPada: DateTime.now(),
      );

      try {
        if (_modeEdit) {
          await _paketOpSqlite.perbaruiPaket(paketBaru);
        } else {
          await _paketOpSqlite.tambahPaket(paketBaru);
        }
        ref.invalidate(daftarPaketProvider);
        unawaited(
          ref.read(layananCekSinkronisasiProvider).jalankanCekSinkronisasi(),
        );
        if (!mounted) {
          return;
        }
        ToastUtil.success(
          context,
          'Data paket berhasil ${_modeEdit ? 'diperbarui' : 'disimpan'}!',
        );
        Navigator.pop(context);
      } on DatabaseException catch (e, s) {
        String pesanError =
            'Gagal menyimpan paket. Terjadi kesalahan database.';
        if (e.isUniqueConstraintError()) {
          pesanError = 'Nama paket sudah ada. Harap gunakan nama lain.';
        } else {
          Log.error(
            'DatabaseException tidak dikenal saat menyimpan paket. Kemungkinan penyebab: constraint violation lain, database corrupt, atau kesalahan struktur tabel.',
            e: e,
            s: s,
          );
        }

        if (!mounted) {
          return;
        }
        ToastUtil.error(context, pesanError);
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan paket karena error tidak dikenal (Unknown Error). Terjadi kesalahan yang tidak terduga saat operasi ${_modeEdit ? "update" : "create"} paket.',
          e: e,
          s: s,
        );

        if (!mounted) {
          return;
        }
        ToastUtil.error(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Paket' : 'Tambah Paket'),
        leading: IconButton(
          icon: const Icon(TIcons.back),
          onPressed: () {
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
              children: [
                InputTeks(
                  controller: _namaController,
                  focusNode: _namsFocusNode,
                  nextFocusNode: _hargaFocusNode,
                  label: 'Nama Paket',
                ),

                gapH12,
                InputAngka(
                  controller: _hargaController,
                  focusNode: _hargaFocusNode,
                  label: 'Harga',
                  nextFocusNode: _durasiFocusNode,
                ),
                gapH12,
                InputAngka(
                  controller: _durasiController,
                  focusNode: _durasiFocusNode,
                  label: 'Durasi',
                  nextFocusNode: _poinHadiahFocusNode,
                ),
                gapH12,
                InputAngka(
                  controller: _poinHadiahcontroller,
                  focusNode: _poinHadiahFocusNode,
                  nextFocusNode: _poinPenukaranFocusNode,
                  label: 'Poin Hadiah',
                ),

                gapH12,
                InputAngka(
                  controller: _poinPenukaranController,
                  focusNode: _poinPenukaranFocusNode,
                  nextFocusNode: _poinPenukaranFocusNode,
                  label: 'Poin Hadiah',
                  textInputAction: TextInputAction.done,
                ),

                gapH16,
                DropdownButtonFormField<TipeDurasiPaket>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: TipeDurasiPaket.values.map((
                    final TipeDurasiPaket type,
                  ) {
                    return DropdownMenuItem<TipeDurasiPaket>(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (final TipeDurasiPaket? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                ),
                gapH12,
                SwitchListTile(
                  title: const Text('Paket Aktif (Public)'),
                  subtitle: const Text('Jika OFF, paket tidak tampil ke user'),
                  value: _publik,
                  onChanged: (v) {
                    setState(() {
                      _publik = v;
                    });
                  },
                ),
                gapH20,
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            await _simpanForm();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Simpan'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _durasiController.dispose();
    _poinHadiahcontroller.dispose();
    _poinPenukaranController.dispose();
    _namsFocusNode.dispose();
    _hargaFocusNode.dispose();
    _durasiFocusNode.dispose();
    _poinHadiahFocusNode.dispose();
    _poinPenukaranFocusNode.dispose();
    super.dispose();
  }
}
