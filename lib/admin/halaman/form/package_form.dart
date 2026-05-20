// path: lib/admin/halaman/form/package_form.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/detail/package_detail.dart (PackageDetailPage)
//
// 📂 FILE INI MENGGUNAKAN:
//   - lib/shared/model/package_model.dart (PackageModel)
//   - lib/shared/operasi/package_operation.dart (PackageOperation)
//   - lib/shared/enum/duration_type_enum.dart (DurationType)
//   - lib/shared/utils/toast_util.dart (ToastUtil)
//   - lib/shared/debug/log.dart (Log)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/duration_type_enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/thousands_input_formatter.dart';

/// Halaman form untuk menambah atau mengedit paket.
class PackageForm extends StatefulWidget {
  /// Model paket yang akan diedit. Jika null, maka form akan membuat paket baru.
  final PackageModel? package;

  /// Operasi paket untuk berinteraksi dengan database.
  final PackageOperation? packageOperation;

  /// Konstruktor untuk PackageForm.
  const PackageForm({super.key, this.package, this.packageOperation});

  @override
  State<PackageForm> createState() => _PackageFormState();
}

class _PackageFormState extends State<PackageForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _rewardPointsController = TextEditingController();
  final _redemptionPointsController = TextEditingController();
  late final PackageOperation _packageOperation;

  final _nameFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _durationFocusNode = FocusNode();
  final _rewardPointsFocusNode = FocusNode();
  final _redemptionPointsFocusNode = FocusNode();

  DurationType _selectedType = DurationType.days;

  bool get _isEditMode => widget.package != null;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman PackageForm');
    Log.info('========================================');

    Log.info(
      'Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}, '
      '${_isEditMode ? "ID: ${widget.package!.id}, Nama: ${widget.package!.name}, Harga: ${widget.package!.price}, Durasi: ${widget.package!.duration} ${widget.package!.type.name}" : ""}',
    );

    Log.info(
      'Menginisialisasi PackageOperation. '
      'Menggunakan instance dari widget jika tersedia, jika tidak membuat instance baru.',
    );
    _packageOperation = widget.packageOperation ?? PackageOperation();
    Log.info(
      'PackageOperation berhasil diinisialisasi. '
      'Instance: ${_packageOperation.hashCode}, '
      'Sumber: ${widget.packageOperation != null ? "Dependency Injection" : "Instance Baru"}',
    );

    if (_isEditMode) {
      Log.info('MODE EDIT terdeteksi. Data paket yang akan diedit:');
      Log.info('  - ID: ${widget.package!.id}');
      Log.info('  - Nama: ${widget.package!.name}');
      Log.info('  - Harga: ${widget.package!.price}');
      Log.info('  - Durasi: ${widget.package!.duration}');
      Log.info('  - Tipe Durasi: ${widget.package!.type.name}');
      Log.info('  - Poin Hadiah: ${widget.package!.rewardPoints}');
      Log.info('  - Poin Penukaran: ${widget.package!.redemptionPoints}');
      Log.info('  - isPublic: ${widget.package!.isPublic}');
      Log.info('  - isDeleted: ${widget.package!.isDeleted}');
      Log.info('  - Diperbarui: ${widget.package!.updatedAt}');
      Log.info('  - Diarsipkan: ${widget.package!.archivedAt ?? "NULL"}');

      Log.info(
          'Mengisi TextEditingController dengan data dari paket yang diedit.');
      _nameController.text = widget.package!.name;
      Log.info('  - _nameController.text = "${widget.package!.name}"');

      _priceController.text = widget.package!.price.toString();
      Log.info('  - _priceController.text = "${widget.package!.price}"');

      _durationController.text = widget.package!.duration.toString();
      Log.info('  - _durationController.text = "${widget.package!.duration}"');

      _rewardPointsController.text = widget.package!.rewardPoints.toString();
      Log.info(
          '  - _rewardPointsController.text = "${widget.package!.rewardPoints}"');

      _redemptionPointsController.text =
          widget.package!.redemptionPoints.toString();
      Log.info(
          '  - _redemptionPointsController.text = "${widget.package!.redemptionPoints}"');

      _selectedType = widget.package!.type;
      Log.info('  - _selectedType = ${widget.package!.type.name}');

      _isPublic = widget.package!.isPublic;
      Log.info('  - _isPublic = ${widget.package!.isPublic}');
    } else {
      Log.info('MODE TAMBAH BARU terdeteksi.');
      Log.info('Form akan membuat paket baru dengan:');
      Log.info('  - ID: Akan digenerate otomatis oleh database');
      Log.info('  - isPublic default: true (paket aktif)');
      Log.info('  - Tipe Durasi default: hari');
      Log.info('  - isDeleted default: 0');
      Log.info('  - Diarsipkan default: NULL');
      Log.info('  - Diperbarui: Akan diisi otomatis');
    }

    Log.info(
        'Inisialisasi PackageForm selesai. Semua controller siap menerima input.');
  }

  Future<void> _saveForm() async {
    Log.info('========================================');
    Log.info('AKSI: Tombol Simpan Ditekan');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('========================================');

    Log.info('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      Log.info('Validasi form BERHASIL. Semua input valid.');

      Log.info('Data yang akan disimpan:');
      Log.info('  - Nama: "${_nameController.text}"');
      Log.info('  - Harga: ${_priceController.text}');
      Log.info('  - Durasi: ${_durationController.text}');
      Log.info('  - Tipe Durasi: ${_selectedType.name}');
      Log.info(
          '  - Poin Hadiah: ${_rewardPointsController.text.isNotEmpty ? _rewardPointsController.text : "0 (default)"}');
      Log.info(
          '  - Poin Penukaran: ${_redemptionPointsController.text.isNotEmpty ? _redemptionPointsController.text : "0 (default)"}');
      Log.info('  - isPublic: $_isPublic');
      Log.info(
          '  - ID: ${_isEditMode ? widget.package!.id : "Akan digenerate otomatis"}');

      Log.info('Membuat objek PackageModel baru dari data form.');
      final newPackage = PackageModel(
        id: _isEditMode ? widget.package!.id : null,
        name: _nameController.text,
        price: int.parse(_priceController.text.replaceAll('.', '')),
        duration: int.parse(_durationController.text),
        type: _selectedType,
        rewardPoints: int.tryParse(_rewardPointsController.text) ?? 0,
        redemptionPoints: int.tryParse(_redemptionPointsController.text) ?? 0,
        isPublic: _isPublic,
      );

      Log.info('Objek PackageModel berhasil dibuat:');
      Log.info('  - ID: ${newPackage.id}');
      Log.info('  - Nama: ${newPackage.name}');
      Log.info('  - Harga: ${newPackage.price}');
      Log.info('  - Durasi: ${newPackage.duration}');
      Log.info('  - Tipe: ${newPackage.type.name}');
      Log.info('  - Poin Hadiah: ${newPackage.rewardPoints}');
      Log.info('  - Poin Penukaran: ${newPackage.redemptionPoints}');
      Log.info('  - isPublic: ${newPackage.isPublic}');

      try {
        if (_isEditMode) {
          Log.info('========================================');
          Log.info('PROSES UPDATE PAKET (MODE EDIT)');
          Log.info('========================================');
          Log.info('Data sebelum update:');
          Log.info('  - Nama: ${widget.package!.name} -> ${newPackage.name}');
          Log.info(
              '  - Harga: ${widget.package!.price} -> ${newPackage.price}');
          Log.info(
              '  - Durasi: ${widget.package!.duration} -> ${newPackage.duration}');
          Log.info(
              '  - Tipe: ${widget.package!.type.name} -> ${newPackage.type.name}');
          Log.info(
              '  - Poin Hadiah: ${widget.package!.rewardPoints} -> ${newPackage.rewardPoints}');
          Log.info(
              '  - Poin Penukaran: ${widget.package!.redemptionPoints} -> ${newPackage.redemptionPoints}');
          Log.info(
              '  - isPublic: ${widget.package!.isPublic} -> ${newPackage.isPublic}');

          Log.info(
              'Memanggil _packageOperation.updatePackage() untuk menyimpan perubahan ke database.');
          await _packageOperation.updatePackage(newPackage);
          Log.info(
              'Update paket BERHASIL. Data paket telah diperbarui di database.');
        } else {
          Log.info('========================================');
          Log.info('PROSES TAMBAH PAKET BARU (MODE TAMBAH)');
          Log.info('========================================');

          Log.info(
              'Memanggil _packageOperation.createPackage() untuk menyimpan paket baru ke database.');
          await _packageOperation.createPackage(newPackage);
          Log.info('Paket baru BERHASIL disimpan ke database.');
        }

        if (!mounted) {
          Log.warning(
              'Widget sudah tidak mounted setelah operasi database berhasil. Tidak dapat menampilkan Toast atau melakukan Navigator.pop.');
          return;
        }

        Log.info('========================================');
        Log.info('PENYIMPANAN DATA PAKET BERHASIL');
        Log.info('========================================');

        ToastUtil.success(
          context,
          'Data paket berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
        );
        Log.info('Toast sukses telah ditampilkan.');

        Log.info(
            'Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.');
        Log.info(
            'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.');
        Navigator.pop(context, true);
        Log.info('Navigator.pop berhasil dijalankan.');
      } on DatabaseException catch (e, s) {
        Log.info('========================================');
        Log.info('ERROR DATABASE TERDETEKSI');
        Log.info('========================================');

        String errorMessage =
            'Gagal menyimpan paket. Terjadi kesalahan database.';
        Log.warning('Terjadi DatabaseException saat menyimpan paket.');
        Log.warning('Detail exception: ${e.toString()}');

        if (e.isUniqueConstraintError()) {
          errorMessage = 'Nama paket sudah ada. Harap gunakan nama lain.';
          Log.warning(
              'Penyebab: UNIQUE CONSTRAINT VIOLATION. Nama paket "${_nameController.text}" sudah ada di database. Pengguna harus menggunakan nama yang berbeda.');
        } else {
          Log.error(
              'DatabaseException tidak dikenal saat menyimpan paket. Kemungkinan penyebab: constraint violation lain, database corrupt, atau kesalahan struktur tabel.',
              e: e,
              st: s);
        }

        if (!mounted) {
          Log.warning(
              'Widget sudah tidak mounted setelah DatabaseException. Tidak dapat menampilkan Toast error.');
          return;
        }

        Log.info(
            'Menampilkan Toast error ke pengguna dengan pesan: "$errorMessage"');
        ToastUtil.error(context, errorMessage);
        Log.info('Toast error telah ditampilkan.');
      } on Exception catch (e, s) {
        Log.error(
            'Gagal menyimpan paket karena error tidak dikenal (Unknown Error). Terjadi kesalahan yang tidak terduga saat operasi ${_isEditMode ? "update" : "create"} paket.',
            e: e,
            st: s);

        if (!mounted) {
          Log.warning(
              'Widget sudah tidak mounted setelah Unknown Error. Tidak dapat menampilkan Toast error.');
          return;
        }

        Log.info('Menampilkan Toast error umum ke pengguna.');
        ToastUtil.error(context, 'Terjadi kesalahan: $e');
        Log.info('Toast error telah ditampilkan.');
      }
    } else {
      Log.warning('Validasi form GAGAL. Terdapat input yang tidak valid.');
      Log.warning('Kemungkinan penyebab:');
      Log.warning('  - Nama paket kosong');
      Log.warning('  - Harga kosong atau bukan angka');
      Log.warning('  - Durasi kosong atau bukan angka');
      Log.warning('  - Poin hadiah bukan angka');
      Log.warning('  - Poin penukaran bukan angka');
      Log.info('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(final BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI PackageForm');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Data form saat ini:');
    Log.info('  - Nama: "${_nameController.text}"');
    Log.info('  - Harga: "${_priceController.text}"');
    Log.info('  - Durasi: "${_durationController.text}"');
    Log.info('  - Tipe Durasi: ${_selectedType.name}');
    Log.info('  - Poin Hadiah: "${_rewardPointsController.text}"');
    Log.info('  - Poin Penukaran: "${_redemptionPointsController.text}"');
    Log.info('  - isPublic: $_isPublic');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Paket' : 'Tambah Paket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
                'NAVIGASI: Tombol Kembali ditekan. Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).');
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
              children: [
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Nama Paket'),
                  onChanged: (final value) {
                    Log.info(
                        'INPUT: Nama paket berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                  },
                  validator: (final value) {
                    Log.info(
                        'VALIDASI: Memvalidasi input nama paket. Nilai: "${value ?? "NULL"}"');
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Nama paket kosong.');
                      return 'Nama paket tidak boleh kosong';
                    }
                    Log.info('VALIDASI BERHASIL: Nama paket valid.');
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                ),
                const SizedBox(height: 12),
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
                  onChanged: (final value) {
                    Log.info(
                        'INPUT: Harga berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                  },
                  validator: (final value) {
                    Log.info(
                        'VALIDASI: Memvalidasi input harga. Nilai: "${value ?? "NULL"}"');
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Harga kosong.');
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value.replaceAll('.', '')) == null) {
                      Log.warning(
                          'VALIDASI GAGAL: Harga bukan angka yang valid. Nilai: "$value"');
                      return 'Harga harus berupa angka';
                    }
                    Log.info(
                        'VALIDASI BERHASIL: Harga valid = ${int.parse(value.replaceAll('.', ''))}');
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context).requestFocus(_durationFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durationController,
                  focusNode: _durationFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Durasi'),
                  keyboardType: TextInputType.number,
                  onChanged: (final value) {
                    Log.info(
                        'INPUT: Durasi berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                  },
                  validator: (final value) {
                    Log.info(
                        'VALIDASI: Memvalidasi input durasi. Nilai: "${value ?? "NULL"}"');
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Durasi kosong.');
                      return 'Durasi tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                          'VALIDASI GAGAL: Durasi bukan angka yang valid. Nilai: "$value"');
                      return 'Durasi harus berupa angka';
                    }
                    Log.info(
                        'VALIDASI BERHASIL: Durasi valid = ${int.parse(value)}');
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context).requestFocus(_rewardPointsFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rewardPointsController,
                  focusNode: _rewardPointsFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Poin Hadiah'),
                  keyboardType: TextInputType.number,
                  onChanged: (final value) {
                    Log.info(
                        'INPUT: Poin hadiah berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                  },
                  validator: (final value) {
                    Log.info(
                        'VALIDASI: Memvalidasi input poin hadiah. Nilai: "${value ?? "NULL"}"');
                    if (value == null || value.isEmpty) {
                      Log.info(
                          'VALIDASI: Poin hadiah kosong, dianggap valid (opsional). Default akan digunakan (0).');
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                          'VALIDASI GAGAL: Poin hadiah bukan angka yang valid. Nilai: "$value"');
                      return 'Poin hadiah harus angka';
                    }
                    Log.info(
                        'VALIDASI BERHASIL: Poin hadiah valid = ${int.parse(value)}');
                    return null;
                  },
                  onFieldSubmitted: (final _) {
                    FocusScope.of(context)
                        .requestFocus(_redemptionPointsFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _redemptionPointsController,
                  focusNode: _redemptionPointsFocusNode,
                  textInputAction: TextInputAction.done,
                  decoration:
                      const InputDecoration(labelText: 'Poin Penukaran'),
                  keyboardType: TextInputType.number,
                  onChanged: (final value) {
                    Log.info(
                        'INPUT: Poin penukaran berubah menjadi: "$value" (panjang: ${value.length} karakter)');
                  },
                  validator: (final value) {
                    Log.info(
                        'VALIDASI: Memvalidasi input poin penukaran. Nilai: "${value ?? "NULL"}"');
                    if (value == null || value.isEmpty) {
                      Log.info(
                          'VALIDASI: Poin penukaran kosong, dianggap valid (opsional). Default akan digunakan (0).');
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                          'VALIDASI GAGAL: Poin penukaran bukan angka yang valid. Nilai: "$value"');
                      return 'Poin penukaran harus angka';
                    }
                    Log.info(
                        'VALIDASI BERHASIL: Poin penukaran valid = ${int.parse(value)}');
                    return null;
                  },
                  onFieldSubmitted: (final _) async {
                    await _saveForm();
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DurationType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: DurationType.values.map((final DurationType type) {
                    return DropdownMenuItem<DurationType>(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (final DurationType? newValue) {
                    if (newValue != null) {
                      Log.info('DROPDOWN: Tipe durasi diubah.');
                      Log.info('  - Tipe Lama: ${_selectedType.displayName}');
                      Log.info('  - Tipe Baru: ${newValue.name}');
                      setState(() {
                        _selectedType = newValue;
                      });
                      Log.info(
                          'State _selectedType berhasil diperbarui ke: ${_selectedType.name}');
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Paket Aktif (Public)'),
                  subtitle: const Text('Jika OFF, paket tidak tampil ke user'),
                  value: _isPublic,
                  onChanged: (final value) {
                    Log.info('SWITCH: Status public diubah.');
                    Log.info('  - Status Lama: $_isPublic');
                    Log.info('  - Status Baru: $value');
                    Log.info(
                        '  - Efek: Paket akan ${value ? "TAMPIL" : "TIDAK TAMPIL"} ke pengguna.');
                    setState(() {
                      _isPublic = value;
                    });
                    Log.info(
                        'State _isPublic berhasil diperbarui ke: $_isPublic');
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Log.info('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    await _saveForm();
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
      ),
    );
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman PackageForm');
    Log.info('Membersihkan resource:');
    Log.info('  - Mendispose TextEditingController (_nameController)');
    Log.info('  - Mendispose TextEditingController (_priceController)');
    Log.info('  - Mendispose TextEditingController (_durationController)');
    Log.info('  - Mendispose TextEditingController (_rewardPointsController)');
    Log.info(
        '  - Mendispose TextEditingController (_redemptionPointsController)');
    Log.info('  - Mendispose FocusNode (_nameFocusNode)');
    Log.info('  - Mendispose FocusNode (_priceFocusNode)');
    Log.info('  - Mendispose FocusNode (_durationFocusNode)');
    Log.info('  - Mendispose FocusNode (_rewardPointsFocusNode)');
    Log.info('  - Mendispose FocusNode (_redemptionPointsFocusNode)');
    Log.info('========================================');

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

    Log.info('Semua resource berhasil dibersihkan.');
    super.dispose();
  }
}
