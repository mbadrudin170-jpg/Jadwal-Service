// path: lib/admin/halaman/form/form_dompet.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/wallet_model.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/snackbar_util.dart';

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
      'Membuat state untuk WalletForm. '
      'Mode: ${isEditMode ? "EDIT (ID: ${widget.wallet!.id}, Nama: ${widget.wallet!.name}, Saldo: ${widget.wallet!.balance})" : "TAMBAH BARU"}',
    );

    Log.info('========================================');
    Log.info('LIFECYCLE: initState() - Halaman WalletForm');
    Log.info('========================================');

    Log.info('Membuat FocusNode untuk input nama dompet.');
    _namaFocusNode = FocusNode();
    Log.info('FocusNode berhasil dibuat: ${_namaFocusNode.hashCode}');

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
      'Inisialisasi WalletForm selesai. Siap menerima input dari pengguna.',
    );
  }

  @override
  void dispose() {
    Log.info('========================================');
    Log.info('LIFECYCLE: dispose() - Halaman WalletForm');
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
          Log.info('  - ID: ${widget.wallet!.id}');
          Log.info('  - Nama Lama: ${widget.wallet!.name}');
          Log.info('  - Nama Baru: ${_namaController.text}');
          Log.info(
            '  - Saldo Tetap: ${widget.wallet!.balance} (saldo tidak berubah)',
          );
          Log.info('  - Diperbarui: Akan diupdate ke DateTime.now()');

          Log.info(
            'Membuat objek WalletModel baru dengan data yang diperbarui.',
          );
          final updatedWallet = WalletModel(
            id: widget.wallet!.id,
            name: _namaController.text,
            balance: widget.wallet!.balance,
          );

          Log.info('Objek WalletModel berhasil dibuat:');
          Log.info('  - ID: ${updatedWallet.id}');
          Log.info('  - Nama: ${updatedWallet.name}');
          Log.info('  - Saldo: ${updatedWallet.balance}');
          Log.info('  - Diperbarui: ${updatedWallet.updatedAt}');

          Log.info(
            'Memanggil _walletOperation.updateWallet() untuk menyimpan perubahan ke database.',
          );
          await _walletOperation.updateWallet(updatedWallet);

          Log.info(
            'Update dompet BERHASIL. Data dompet telah diperbarui di database.',
          );
          Log.info(
            'Nama dompet berubah dari "${widget.wallet!.name}" menjadi "${_namaController.text}"',
          );

          if (!mounted) {
            Log.warning(
              'Widget sudah tidak mounted setelah update berhasil. '
              'Tidak dapat melakukan Navigator.pop atau menampilkan SnackBar.',
            );
            return;
          }

          Log.info('Menampilkan SnackBar sukses update dompet.');
          SnackBarUtil.info(context, 'Nama dompet berhasil diperbarui!');
          Log.info('SnackBar sukses update dompet telah ditampilkan.');

          Log.info(
            'Widget masih mounted. Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
          );
          Log.info(
            'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada perubahan data.',
          );
          Navigator.pop(context, true);
          Log.info('Navigator.pop berhasil dijalankan.');
        } else {
          Log.info('========================================');
          Log.info('PROSES TAMBAH DOMPET BARU (MODE TAMBAH)');
          Log.info('========================================');

          Log.info('Menggenerate UUID v4 untuk ID dompet baru.');
          final newId = const Uuid().v4();
          Log.info('UUID berhasil digenerate: $newId');

          Log.info('Membuat objek WalletModel baru dengan data:');
          Log.info('  - ID: $newId');
          Log.info('  - Nama: ${_namaController.text}');
          Log.info('  - Saldo Awal: 0.0');
          Log.info('  - Diperbarui: DateTime.now()');

          final newWallet = WalletModel(
            id: newId,
            name: _namaController.text,
            balance: 0.0,
            updatedAt: DateTime.now(),
          );

          Log.info('Objek WalletModel berhasil dibuat.');
          Log.info(
            'Memanggil _walletOperation.createWallet() untuk menyimpan dompet baru ke database.',
          );
          await _walletOperation.createWallet(newWallet);

          Log.info('Dompet baru BERHASIL disimpan ke database.');
          Log.info('Detail dompet yang disimpan:');
          Log.info('  - ID: ${newWallet.id}');
          Log.info('  - Nama: ${newWallet.name}');
          Log.info('  - Saldo: ${newWallet.balance}');
          Log.info('  - Diperbarui: ${newWallet.updatedAt}');

          if (!mounted) {
            Log.warning(
              'Widget sudah tidak mounted setelah create berhasil. '
              'Tidak dapat melakukan Navigator.pop atau menampilkan SnackBar.',
            );
            return;
          }

          Log.info('Menampilkan SnackBar sukses tambah dompet.');
          SnackBarUtil.success(context, 'Dompet baru berhasil ditambahkan!');
          Log.info('SnackBar sukses tambah dompet telah ditampilkan.');

          Log.info(
            'Widget masih mounted. Melakukan Navigator.pop(context, true) untuk kembali ke halaman sebelumnya.',
          );
          Log.info(
            'Nilai result true dikirim untuk memberitahu halaman sebelumnya bahwa ada data baru.',
          );
          Navigator.pop(context, true);
          Log.info('Navigator.pop berhasil dijalankan.');
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
        SnackBarUtil.error(context, 'Gagal menyimpan dompet: $e');
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
  Widget build(final BuildContext context) {
    Log.info('========================================');
    Log.info('LIFECYCLE: build() - Membangun UI WalletForm');
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
                onFieldSubmitted: (final _) async {
                  Log.info(
                    'INPUT: Field nama dompet disubmit melalui keyboard (TextInputAction.done).',
                  );
                  Log.info('Nilai yang disubmit: "${_namaController.text}"');
                  Log.info('Memanggil _simpanForm() secara otomatis.');
                  await _simpanForm();
                },
                onChanged: (final value) {
                  Log.info(
                    'INPUT: Nama dompet berubah menjadi: "$value" (panjang: ${value.length} karakter)',
                  );
                },
                validator: (final value) {
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
