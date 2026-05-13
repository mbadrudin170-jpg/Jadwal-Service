// path: lib/admin/halaman/form/form_paket.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/paket_model.dart';
import 'package:wifi/shared/operasi/paket_operasi.dart';

/// Halaman form untuk menambah atau mengedit paket.
class FormPaket extends StatefulWidget {
  /// Model paket yang akan diedit. Jika null, maka form akan membuat paket baru.
  final PaketModel? paket;

  /// Operasi paket untuk berinteraksi dengan database.
  final PaketOperasi? paketOperasi;

  /// Konstruktor untuk FormPaket.
  const FormPaket({super.key, this.paket, this.paketOperasi});

  @override
  State<FormPaket> createState() => _FormPaketState();
}

class _FormPaketState extends State<FormPaket> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _durasiController = TextEditingController();
  final _poinHadiahController = TextEditingController();
  final _poinPenukaranController = TextEditingController();
  late final PaketOperasi _paketOperasi;

  // ditambah: FocusNode untuk setiap input field
  final _namaFocusNode = FocusNode();
  final _hargaFocusNode = FocusNode();
  final _durasiFocusNode = FocusNode();
  final _poinHadiahFocusNode = FocusNode();
  final _poinPenukaranFocusNode = FocusNode();

  TipeDurasi _selectedTipe = TipeDurasi.hari;

  bool get _isEditMode => widget.paket != null;
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman FormPaket');
    Log.info('========================================');

    // dihapus: Variabel lokal isEditMode tidak digunakan
    Log.info(
      'Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}, '
      '${_isEditMode ? "ID: ${widget.paket!.id}, Nama: ${widget.paket!.nama}, Harga: ${widget.paket!.harga}, Durasi: ${widget.paket!.durasi} ${widget.paket!.tipe.displayName}" : ""}',
    );

    Log.info(
      'Menginisialisasi PaketOperasi. '
      'Menggunakan instance dari widget jika tersedia, jika tidak membuat instance baru.',
    );
    _paketOperasi = widget.paketOperasi ?? PaketOperasi();
    Log.info(
      'PaketOperasi berhasil diinisialisasi. '
      'Instance: ${_paketOperasi.hashCode}, '
      'Sumber: ${widget.paketOperasi != null ? "Dependency Injection" : "Instance Baru"}',
    );

    if (_isEditMode) {
      Log.info('MODE EDIT terdeteksi. Data paket yang akan diedit:');
      Log.info('  - ID: ${widget.paket!.id}');
      Log.info('  - Nama: ${widget.paket!.nama}');
      Log.info('  - Harga: ${widget.paket!.harga}');
      Log.info('  - Durasi: ${widget.paket!.durasi}');
      Log.info('  - Tipe Durasi: ${widget.paket!.tipe.displayName}');
      Log.info('  - Poin Hadiah: ${widget.paket!.poinHadiah}');
      Log.info('  - Poin Penukaran: ${widget.paket!.poinPenukaran}');
      Log.info('  - isPublic: ${widget.paket!.isPublic}');
      Log.info('  - isDeleted: ${widget.paket!.isDeleted}');
      Log.info('  - Diperbarui: ${widget.paket!.diperbarui}');
      Log.info('  - Diarsipkan: ${widget.paket!.diarsipkan ?? "NULL"}');

      Log.info(
        'Mengisi TextEditingController dengan data dari paket yang diedit.',
      );
      _namaController.text = widget.paket!.nama;
      Log.info('  - _namaController.text = "${widget.paket!.nama}"');

      _hargaController.text = widget.paket!.harga.toString();
      Log.info('  - _hargaController.text = "${widget.paket!.harga}"');

      _durasiController.text = widget.paket!.durasi.toString();
      Log.info('  - _durasiController.text = "${widget.paket!.durasi}"');

      _poinHadiahController.text = widget.paket!.poinHadiah.toString();
      Log.info(
        '  - _poinHadiahController.text = "${widget.paket!.poinHadiah}"',
      );

      _poinPenukaranController.text = widget.paket!.poinPenukaran.toString();
      Log.info(
        '  - _poinPenukaranController.text = "${widget.paket!.poinPenukaran}"',
      );

      _selectedTipe = widget.paket!.tipe;
      Log.info('  - _selectedTipe = ${widget.paket!.tipe.displayName}');

      _isPublic = widget.paket!.isPublic;
      Log.info('  - _isPublic = ${widget.paket!.isPublic}');
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
      'Inisialisasi FormPaket selesai. Semua controller siap menerima input.',
    );
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
      Log.info('  - Nama: "${_namaController.text}"');
      Log.info('  - Harga: ${_hargaController.text}');
      Log.info('  - Durasi: ${_durasiController.text}');
      Log.info('  - Tipe Durasi: ${_selectedTipe.displayName}');
      Log.info(
        '  - Poin Hadiah: ${_poinHadiahController.text.isNotEmpty ? _poinHadiahController.text : "0 (default)"}',
      );
      Log.info(
        '  - Poin Penukaran: ${_poinPenukaranController.text.isNotEmpty ? _poinPenukaranController.text : "0 (default)"}',
      );
      Log.info('  - isPublic: $_isPublic');
      Log.info(
        '  - ID: ${_isEditMode ? widget.paket!.id : "Akan digenerate otomatis"}',
      );

      Log.info('Membuat objek PaketModel baru dari data form.');
      final newPaket = PaketModel(
        id: _isEditMode ? widget.paket!.id : null,
        nama: _namaController.text,
        harga: int.parse(_hargaController.text),
        durasi: int.parse(_durasiController.text),
        tipe: _selectedTipe,
        poinHadiah: int.tryParse(_poinHadiahController.text) ?? 0,
        poinPenukaran: int.tryParse(_poinPenukaranController.text) ?? 0,
        isPublic: _isPublic,
      );

      Log.info('Objek PaketModel berhasil dibuat:');
      Log.info('  - ID: ${newPaket.id}');
      Log.info('  - Nama: ${newPaket.nama}');
      Log.info('  - Harga: ${newPaket.harga}');
      Log.info('  - Durasi: ${newPaket.durasi}');
      Log.info('  - Tipe: ${newPaket.tipe.displayName}');
      Log.info('  - Poin Hadiah: ${newPaket.poinHadiah}');
      Log.info('  - Poin Penukaran: ${newPaket.poinPenukaran}');
      Log.info('  - isPublic: ${newPaket.isPublic}');

      try {
        if (_isEditMode) {
          Log.info('========================================');
          Log.info('PROSES UPDATE PAKET (MODE EDIT)');
          Log.info('========================================');
          Log.info('Data sebelum update:');
          Log.info('  - Nama: ${widget.paket!.nama} -> ${newPaket.nama}');
          Log.info('  - Harga: ${widget.paket!.harga} -> ${newPaket.harga}');
          Log.info('  - Durasi: ${widget.paket!.durasi} -> ${newPaket.durasi}');
          Log.info(
            '  - Tipe: ${widget.paket!.tipe.displayName} -> ${newPaket.tipe.displayName}',
          );
          Log.info(
            '  - Poin Hadiah: ${widget.paket!.poinHadiah} -> ${newPaket.poinHadiah}',
          );
          Log.info(
            '  - Poin Penukaran: ${widget.paket!.poinPenukaran} -> ${newPaket.poinPenukaran}',
          );
          Log.info(
            '  - isPublic: ${widget.paket!.isPublic} -> ${newPaket.isPublic}',
          );

          Log.info(
            'Memanggil _paketOperasi.updatePaket() untuk menyimpan perubahan ke database.',
          );
          await _paketOperasi.updatePaket(newPaket);
          Log.info(
            'Update paket BERHASIL. Data paket telah diperbarui di database.',
          );
        } else {
          Log.info('========================================');
          Log.info('PROSES TAMBAH PAKET BARU (MODE TAMBAH)');
          Log.info('========================================');

          Log.info(
            'Memanggil _paketOperasi.createPaket() untuk menyimpan paket baru ke database.',
          );
          await _paketOperasi.createPaket(newPaket);
          Log.info('Paket baru BERHASIL disimpan ke database.');
        }

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah operasi database berhasil. '
            'Tidak dapat menampilkan SnackBar atau melakukan Navigator.pop.',
          );
          return;
        }

        Log.info('========================================');
        Log.info('PENYIMPANAN DATA PAKET BERHASIL');
        Log.info('========================================');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // diperbaiki: Menghapus backslash yang salah
              'Data paket berhasil ${_isEditMode ? 'diperbarui' : 'disimpan'}!',
            ),
          ),
        );
        Log.info('SnackBar sukses telah ditampilkan.');

        Log.info(
          'Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
        );
        Log.info(
          'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.',
        );
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
            'Penyebab: UNIQUE CONSTRAINT VIOLATION. '
            'Nama paket "${_namaController.text}" sudah ada di database. '
            'Pengguna harus menggunakan nama yang berbeda.',
          );
        } else {
          Log.error(
            'DatabaseException tidak dikenal saat menyimpan paket. '
            'Kemungkinan penyebab: constraint violation lain, database corrupt, '
            'atau kesalahan struktur tabel.',
            e: e,
            st: s,
          );
        }

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah DatabaseException. '
            'Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        Log.info(
          'Menampilkan SnackBar error ke pengguna dengan pesan: "$errorMessage"',
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        Log.info('SnackBar error telah ditampilkan.');
      } catch (e, s) {
        Log.error(
          'Gagal menyimpan paket karena error tidak dikenal (Unknown Error). '
          'Terjadi kesalahan yang tidak terduga saat operasi ${_isEditMode ? "update" : "create"} paket. '
          'Kemungkinan penyebab: koneksi database gagal, memory overflow, '
          'atau exception dari sistem yang tidak tertangani.',
          e: e,
          st: s,
        );

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah Unknown Error. '
            'Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        Log.info('Menampilkan SnackBar error umum ke pengguna.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        Log.info('SnackBar error telah ditampilkan.');
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
  Widget build(BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI FormPaket');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Data form saat ini:');
    Log.info('  - Nama: "${_namaController.text}"');
    Log.info('  - Harga: "${_hargaController.text}"');
    Log.info('  - Durasi: "${_durasiController.text}"');
    Log.info('  - Tipe Durasi: ${_selectedTipe.displayName}');
    Log.info('  - Poin Hadiah: "${_poinHadiahController.text}"');
    Log.info('  - Poin Penukaran: "${_poinPenukaranController.text}"');
    Log.info('  - isPublic: $_isPublic');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Paket' : 'Tambah Paket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Log.info(
              'NAVIGASI: Tombol Kembali ditekan. '
              'Kembali ke halaman sebelumnya dengan result false (tidak ada perubahan).',
            );
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
                  controller: _namaController,
                  focusNode: _namaFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Nama Paket'),
                  onChanged: (value) {
                    Log.info(
                      'INPUT: Nama paket berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input nama paket. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Nama paket kosong.');
                      return 'Nama paket tidak boleh kosong';
                    }
                    Log.info('VALIDASI BERHASIL: Nama paket valid.');
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(context).requestFocus(_hargaFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hargaController,
                  focusNode: _hargaFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    Log.info(
                      'INPUT: Harga berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input harga. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Harga kosong.');
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                        'VALIDASI GAGAL: Harga bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Harga harus berupa angka';
                    }
                    Log.info(
                      'VALIDASI BERHASIL: Harga valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(context).requestFocus(_durasiFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _durasiController,
                  focusNode: _durasiFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Durasi'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    Log.info(
                      'INPUT: Durasi berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input durasi. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.warning('VALIDASI GAGAL: Durasi kosong.');
                      return 'Durasi tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                        'VALIDASI GAGAL: Durasi bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Durasi harus berupa angka';
                    }
                    Log.info(
                      'VALIDASI BERHASIL: Durasi valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(context).requestFocus(_poinHadiahFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poinHadiahController,
                  focusNode: _poinHadiahFocusNode, // ditambah: focusNode
                  textInputAction:
                      TextInputAction.next, // ditambah: textInputAction
                  decoration: const InputDecoration(labelText: 'Poin Hadiah'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    Log.info(
                      'INPUT: Poin hadiah berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input poin hadiah. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.info(
                        'VALIDASI: Poin hadiah kosong, dianggap valid (opsional). Default akan digunakan (0).',
                      );
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                        'VALIDASI GAGAL: Poin hadiah bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Poin hadiah harus angka';
                    }
                    Log.info(
                      'VALIDASI BERHASIL: Poin hadiah valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    FocusScope.of(
                      context,
                    ).requestFocus(_poinPenukaranFocusNode);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _poinPenukaranController,
                  focusNode: _poinPenukaranFocusNode, // ditambah: focusNode
                  textInputAction: TextInputAction
                      .done, // diubah: textInputAction menjadi done
                  decoration: const InputDecoration(
                    labelText: 'Poin Penukaran',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    Log.info(
                      'INPUT: Poin penukaran berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                    );
                  },
                  validator: (value) {
                    Log.info(
                      'VALIDASI: Memvalidasi input poin penukaran. Nilai: "${value ?? "NULL"}"',
                    );
                    if (value == null || value.isEmpty) {
                      Log.info(
                        'VALIDASI: Poin penukaran kosong, dianggap valid (opsional). Default akan digunakan (0).',
                      );
                      return null;
                    }
                    if (int.tryParse(value) == null) {
                      Log.warning(
                        'VALIDASI GAGAL: Poin penukaran bukan angka yang valid. Nilai: "$value"',
                      );
                      return 'Poin penukaran harus angka';
                    }
                    Log.info(
                      'VALIDASI BERHASIL: Poin penukaran valid = ${int.parse(value)}',
                    );
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    // ditambah: onFieldSubmitted
                    _saveForm(); // diubah: panggil _saveForm saat selesai
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TipeDurasi>(
                  initialValue: _selectedTipe,
                  decoration: const InputDecoration(labelText: 'Tipe Durasi'),
                  items: TipeDurasi.values.map((TipeDurasi tipe) {
                    return DropdownMenuItem<TipeDurasi>(
                      value: tipe,
                      child: Text(tipe.displayName),
                    );
                  }).toList(),
                  onChanged: (TipeDurasi? newValue) {
                    if (newValue != null) {
                      Log.info('DROPDOWN: Tipe durasi diubah.');
                      Log.info('  - Tipe Lama: ${_selectedTipe.displayName}');
                      Log.info('  - Tipe Baru: ${newValue.displayName}');
                      setState(() {
                        _selectedTipe = newValue;
                      });
                      Log.info(
                        'State _selectedTipe berhasil diperbarui ke: ${_selectedTipe.displayName}',
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Paket Aktif (Public)'),
                  subtitle: const Text('Jika OFF, paket tidak tampil ke user'),
                  value: _isPublic,
                  onChanged: (value) {
                    Log.info('SWITCH: Status public diubah.');
                    Log.info('  - Status Lama: $_isPublic');
                    Log.info('  - Status Baru: $value');
                    Log.info(
                      '  - Efek: Paket akan ${value ? "TAMPIL" : "TIDAK TAMPIL"} ke pengguna.',
                    );
                    setState(() {
                      _isPublic = value;
                    });
                    Log.info(
                      'State _isPublic berhasil diperbarui ke: $_isPublic',
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Log.info('AKSI: Tombol Simpan ditekan oleh pengguna.');
                    _saveForm();
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
    Log.info('LIFECYCLE: dispose() - Halaman FormPaket');
    Log.info('Membersihkan resource:');
    Log.info('  - Mendispose TextEditingController (_namaController)');
    Log.info('  - Mendispose TextEditingController (_hargaController)');
    Log.info('  - Mendispose TextEditingController (_durasiController)');
    Log.info('  - Mendispose TextEditingController (_poinHadiahController)');
    Log.info('  - Mendispose TextEditingController (_poinPenukaranController)');
    Log.info('  - Mendispose FocusNode (_namaFocusNode)');
    Log.info('  - Mendispose FocusNode (_hargaFocusNode)');
    Log.info('  - Mendispose FocusNode (_durasiFocusNode)');
    Log.info('  - Mendispose FocusNode (_poinHadiahFocusNode)');
    Log.info('  - Mendispose FocusNode (_poinPenukaranFocusNode)');
    Log.info('========================================');

    _namaController.dispose();
    _hargaController.dispose();
    _durasiController.dispose();
    _poinHadiahController.dispose();
    _poinPenukaranController.dispose();

    // ditambah: dispose FocusNode
    _namaFocusNode.dispose();
    _hargaFocusNode.dispose();
    _durasiFocusNode.dispose();
    _poinHadiahFocusNode.dispose();
    _poinPenukaranFocusNode.dispose();

    Log.info('Semua resource berhasil dibersihkan.');
    super.dispose();
  }
}
