// path: lib/admin/halaman/form/form_paket.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_Sqlite.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/thousands_input_formatter.dart';

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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _rewardPointsController = TextEditingController();
  final _redemptionPointsController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();
  final _rewardPointsFocusNode = FocusNode();
  final _redemptionPointsFocusNode = FocusNode();

  DurationType _selectedType = DurationType.days;

  bool get _modeEdit => widget.paket != null;
  bool _publik = false;

  @override
  void initState() {
    super.initState();
    _paketOpSqlite = ref.read(paketOpSqliteProvider);
    if (_modeEdit) {
      _nameController.text = widget.paket!.nama;
      _priceController.text = widget.paket!.harga.toString();
      _durationController.text = widget.paket!.durasi.toString();
      _rewardPointsController.text = widget.paket!.poinHadiah.toString();
      _redemptionPointsController.text = widget.paket!.poinPenukaran.toString();
      _selectedType = widget.paket!.tipe;
      _publik = widget.paket!.statusPublik;
    }
  }

  Future<void> _simpanForm() async {
    if (_formKey.currentState!.validate()) {
      final paketBaru = PaketModel(
          id: _modeEdit ? widget.paket!.id : null,
          nama: _nameController.text,
          harga: int.tryParse(
                  _priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
              0,
          durasi: int.tryParse(_durationController.text) ?? 0,
          tipe: _selectedType,
          poinHadiah: int.tryParse(_rewardPointsController.text) ?? 0,
          poinPenukaran: int.tryParse(_redemptionPointsController.text) ?? 0,
          statusPublik: _publik,
          diperbaruiPada: DateTime.now().toUtc());

      try {
        if (_modeEdit) {
          await _paketOpSqlite.perbaruiPaket(paketBaru);
        } else {
          await _paketOpSqlite.tambahPaket(paketBaru);
        }
        ref.invalidate(daftarPaketProvider);
        if (!mounted) {
          return;
        }
        ToastUtil.success(
          context,
          'Data paket berhasil ${_modeEdit ? 'diperbarui' : 'disimpan'}!',
        );
        Navigator.pop(context, true);
      } on DatabaseException catch (e, s) {
        String errorMessage =
            'Gagal menyimpan paket. Terjadi kesalahan database.';
        if (e.isUniqueConstraintError()) {
          errorMessage = 'Nama paket sudah ada. Harap gunakan nama lain.';
        } else {
          Log.error(
              'DatabaseException tidak dikenal saat menyimpan paket. Kemungkinan penyebab: constraint violation lain, database corrupt, atau kesalahan struktur tabel.',
              e: e,
              s: s);
        }

        if (!mounted) {
          return;
        }
        ToastUtil.error(context, errorMessage);
      } on Exception catch (e, s) {
        Log.error(
            'Gagal menyimpan paket karena error tidak dikenal (Unknown Error). Terjadi kesalahan yang tidak terduga saat operasi ${_modeEdit ? "update" : "create"} paket.',
            e: e,
            s: s);

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
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nama Paket'),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Nama paket tidak boleh kosong';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                ),
                gapH12,
                TextFormField(
                  controller: _priceController,
                  focusNode: _priceFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsAndNegativeInputFormatter(),
                  ],
                  validator: (final value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                        null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context).requestFocus(_durationFocusNode);
                  },
                ),
                gapH12,
                TextFormField(
                  controller: _durationController,
                  focusNode: _durationFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Durasi'),
                  keyboardType: TextInputType.number,
                  validator: (final value) {
                    if (value == null || value.isEmpty) {
                      return 'Durasi tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Durasi harus berupa angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context).requestFocus(_rewardPointsFocusNode);
                  },
                ),
                gapH12,
                TextFormField(
                  controller: _rewardPointsController,
                  focusNode: _rewardPointsFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Poin Hadiah'),
                  keyboardType: TextInputType.number,
                  validator: (final value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      return 'Poin hadiah harus angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context)
                        .requestFocus(_redemptionPointsFocusNode);
                  },
                ),
                gapH12,
                TextFormField(
                  controller: _redemptionPointsController,
                  focusNode: _redemptionPointsFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration:
                      const InputDecoration(labelText: 'Poin Penukaran'),
                  keyboardType: TextInputType.number,
                  validator: (final value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      return 'Poin penukaran harus angka';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                gapH16,
                DropdownButtonFormField<DurationType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: DurationType.values.map((final DurationType type) {
                    return DropdownMenuItem<DurationType>(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (final DurationType? newValue) {
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
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _rewardPointsController.dispose();
    _redemptionPointsController.dispose();
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _durationFocusNode.dispose();
    _rewardPointsFocusNode.dispose();
    _redemptionPointsFocusNode.dispose();
    super.dispose();
  }
}
