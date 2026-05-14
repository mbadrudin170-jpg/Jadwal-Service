// path: lib/admin/halaman/form/form_dompet.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/dompet_model.dart';
import 'package:wifi/shared/operasi/dompet_operasi.dart';

/// Halaman form untuk menambah atau mengedit dompet.
class FormDompet extends StatefulWidget {
  /// Model dompet yang akan diedit. Jika null, maka form akan membuat dompet baru.
  final DompetModel? dompet;

  /// Konstruktor untuk FormDompet.
  const FormDompet({super.key, this.dompet});

  @override
  State<FormDompet> createState() => _FormDompetState();
}

class _FormDompetState extends State<FormDompet> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final DompetOperasi _dompetOperasi = DompetOperasi();

  late FocusNode _namaFocusNode;

  bool get _isEditMode => widget.dompet != null;

  @override
  void initState() {
    super.initState();
    final isEditMode = widget.dompet != null;
    Log.info(
      'Membuat state untuk FormDompet. '
      'Mode: ${isEditMode ? "EDIT (ID: ${widget.dompet!.id}, Nama: ${widget.dompet!.namaDompet}, Saldo: ${widget.dompet!.saldo})" : "TAMBAH BARU"}',
    );

    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman FormDompet');
    Log.info('========================================');

    Log.info('Membuat FocusNode untuk input nama dompet.');
    _namaFocusNode = FocusNode();
    Log.info('FocusNode berhasil dibuat: ${_namaFocusNode.hashCode}');

    if (_isEditMode) {
      Log.info('MODE EDIT terdeteksi. Data dompet yang akan diedit:');
      Log.info('  - ID: ${widget.dompet!.id}');
      Log.info('  - Nama Lama: ${widget.dompet!.namaDompet}');
      Log.info('  - Saldo: ${widget.dompet!.saldo}');
      Log.info('  - Diperbarui: ${widget.dompet!.diperbarui}');
      Log.info('  - isDeleted: ${widget.dompet!.isDeleted}');
      Log.info('  - Diarsipkan: ${widget.dompet!.diarsipkan ?? "NULL"}');

      Log.info(
        'Mengisi TextEditingController dengan nama dompet lama: "${widget.dompet!.namaDompet}"',
      );
      _namaController.text = widget.dompet!.namaDompet;
      Log.info(
        'TextEditingController berhasil diisi. Teks saat ini: "${_namaController.text}"',
      );
    } else {
      Log.info('MODE TAMBAH BARU terdeteksi.');
      Log.info('Form akan membuat dompet baru dengan:');
      Log.info('  - ID: Akan digenerate otomatis menggunakan UUID v4');
      Log.info('  - Nama: Dari input pengguna');
      Log.info('  - Saldo Awal: 0.0 (sesuai arsitektur baru)');
      Log.info('  - Diperbarui: DateTime.now()');
      Log.info('  - isDeleted: 0 (default)');
      Log.info('  - Diarsipkan: NULL (default)');
    }

    Log.info(
      'Inisialisasi FormDompet selesai. Siap menerima input dari pengguna.',
    );
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman FormDompet');
    Log.info('Membersihkan resource:');
    Log.info('  - Mendispose TextEditingController (_namaController)');
    Log.info('  - Mendispose FocusNode (_namaFocusNode)');
    Log.info('========================================');
    _namaController.dispose();
    _namaFocusNode.dispose();
    Log.info('Semua resource berhasil dibersihkan.');
    super.dispose();
  }

  Future<void> _simpanForm() async {
    Log.info('========================================');
    Log.info('AKSI: Tombol Simpan Ditekan');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('========================================');

    Log.info('Menghilangkan fokus dari input nama dompet.');
    _namaFocusNode.unfocus();
    Log.info('Fokus berhasil dihilangkan dari input.');

    Log.info('Memvalidasi form...');
    if (_formKey.currentState!.validate()) {
      Log.info('Validasi form BERHASIL. Semua input valid.');
      Log.info('Nama dompet yang akan disimpan: "${_namaController.text}"');

      try {
        if (_isEditMode) {
          Log.info('========================================');
          Log.info('PROSES UPDATE DOMPET (MODE EDIT)');
          Log.info('========================================');
          Log.info('Data dompet sebelum update:');
          Log.info('  - ID: ${widget.dompet!.id}');
          Log.info('  - Nama Lama: ${widget.dompet!.namaDompet}');
          Log.info('  - Nama Baru: ${_namaController.text}');
          Log.info(
            '  - Saldo Tetap: ${widget.dompet!.saldo} (saldo tidak berubah)',
          );
          Log.info('  - Diperbarui: Akan diupdate ke DateTime.now()');

          Log.info(
            'Membuat objek DompetModel baru dengan data yang diperbarui.',
          );
          final updatedDompet = DompetModel(
            id: widget.dompet!.id,
            namaDompet: _namaController.text,
            saldo: widget.dompet!.saldo,
            diperbarui: DateTime.now(),
          );

          Log.info('Objek DompetModel berhasil dibuat:');
          Log.info('  - ID: ${updatedDompet.id}');
          Log.info('  - Nama: ${updatedDompet.namaDompet}');
          Log.info('  - Saldo: ${updatedDompet.saldo}');
          Log.info('  - Diperbarui: ${updatedDompet.diperbarui}');

          Log.info(
            'Memanggil _dompetOperasi.updateDompet() untuk menyimpan perubahan ke database.',
          );
          await _dompetOperasi.updateDompet(updatedDompet);

          Log.info(
            'Update dompet BERHASIL. Data dompet telah diperbarui di database.',
          );
          Log.info(
            'Nama dompet berubah dari "${widget.dompet!.namaDompet}" menjadi "${_namaController.text}"',
          );

          if (!mounted) {
            Log.warning(
              'Widget sudah tidak mounted setelah update berhasil. '
              'Tidak dapat melakukan Navigator.pop atau menampilkan SnackBar.',
            );
            return;
          }

          Log.info(
            'Widget masih mounted. Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
          );
          Log.info(
            'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.',
          );
          Navigator.pop(context, true);
          Log.info('Navigator.pop berhasil dijalankan.');

          Log.info('Menampilkan SnackBar sukses update dompet.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama dompet berhasil diperbarui!'),
              backgroundColor: Colors.blue,
            ),
          );
          Log.info('SnackBar sukses update dompet telah ditampilkan.');
        } else {
          Log.info('========================================');
          Log.info('PROSES TAMBAH DOMPET BARU (MODE TAMBAH)');
          Log.info('========================================');

          Log.info('Menggenerate UUID v4 untuk ID dompet baru.');
          final newId = const Uuid().v4();
          Log.info('UUID berhasil digenerate: $newId');

          Log.info('Membuat objek DompetModel baru dengan data:');
          Log.info('  - ID: $newId');
          Log.info('  - Nama: ${_namaController.text}');
          Log.info('  - Saldo Awal: 0.0');
          Log.info('  - Diperbarui: DateTime.now()');

          final nuevoDompet = DompetModel(
            id: newId,
            namaDompet: _namaController.text,
            saldo: 0.0,
            diperbarui: DateTime.now(),
          );

          Log.info('Objek DompetModel berhasil dibuat.');
          Log.info(
            'Memanggil _dompetOperasi.createDompet() untuk menyimpan dompet baru ke database.',
          );
          await _dompetOperasi.createDompet(nuevoDompet);

          Log.info('Dompet baru BERHASIL disimpan ke database.');
          Log.info('Detail dompet yang disimpan:');
          Log.info('  - ID: ${nuevoDompet.id}');
          Log.info('  - Nama: ${nuevoDompet.namaDompet}');
          Log.info('  - Saldo: ${nuevoDompet.saldo}');
          Log.info('  - Diperbarui: ${nuevoDompet.diperbarui}');

          if (!mounted) {
            Log.warning(
              'Widget sudah tidak mounted setelah create berhasil. '
              'Tidak dapat melakukan Navigator.pop atau menampilkan SnackBar.',
            );
            return;
          }

          Log.info(
            'Widget masih mounted. Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
          );
          Log.info(
            'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada data baru.',
          );
          Navigator.pop(context, true);
          Log.info('Navigator.pop berhasil dijalankan.');

          Log.info('Menampilkan SnackBar sukses tambah dompet.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dompet baru berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Log.info('SnackBar sukses tambah dompet telah ditampilkan.');
        }
      } on Exception catch (e, s) {
        Log.error(
          'Gagal menyimpan dompet. '
          'Proses ${_isEditMode ? "update" : "create"} dompet mengalami kegagalan. '
          'Kemungkinan penyebab: koneksi database gagal, constraint violation, '
          'data tidak valid, atau terjadi error saat operasi database.',
          e: e,
          st: s,
        );

        if (!mounted) {
          Log.warning(
            'Widget sudah tidak mounted setelah error. Tidak dapat menampilkan SnackBar error.',
          );
          return;
        }

        Log.info(
          'Widget masih mounted. Menampilkan SnackBar error ke pengguna.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan dompet: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Log.info('SnackBar error telah ditampilkan.');
      }
    } else {
      Log.warning('Validasi form GAGAL. Terdapat input yang tidak valid.');
      Log.warning(
        'Kemungkinan penyebab: Nama dompet kosong atau tidak memenuhi kriteria validasi.',
      );
      Log.info('Form tidak akan disimpan sampai semua input valid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI FormDompet');
    Log.info('Mode: ${_isEditMode ? "EDIT" : "TAMBAH BARU"}');
    Log.info('Nama di controller: "${_namaController.text}"');
    Log.info('========================================');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Nama Dompet' : 'Tambah Dompet Baru'),
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
                onFieldSubmitted: (_) async {
                  Log.info(
                    'INPUT: Field nama dompet disubmit melalui keyboard (TextInputAction.done).',
                  );
                  Log.info('Nilai yang disubmit: "${_namaController.text}"');
                  Log.info('Memanggil _simpanForm() secara otomatis.');
                  await _simpanForm();
                },
                onChanged: (value) {
                  Log.info(
                    'INPUT: Nama dompet berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                  );
                },
                validator: (value) {
                  Log.info(
                    'VALIDASI: Memvalidasi input nama dompet. Nilai: "${value ?? "NULL"}"',
                  );
                  if (value == null || value.isEmpty) {
                    Log.warning('VALIDASI GAGAL: Nama dompet kosong.');
                    return 'Nama dompet tidak boleh kosong';
                  }
                  Log.info('VALIDASI BERHASIL: Nama dompet valid.');
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Log.info('AKSI: Tombol Simpan ditekan oleh pengguna.');
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
            ],
          ),
        ),
      ),
    );
  }
}
