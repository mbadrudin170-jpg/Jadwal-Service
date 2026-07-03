// path lib/fitur/voucher/page/form_voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/toast_util.dart';
import 'package:wifi/shared/widget/input/input_teks.dart';

class FormVoucher extends ConsumerStatefulWidget {
  const FormVoucher({super.key});

  @override
  ConsumerState<FormVoucher> createState() => _FormVoucherState();
}

class _FormVoucherState extends ConsumerState<FormVoucher> {
  final TextEditingController _voucherController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _menyimpan = false;

  // 1. PERBAIKAN: Deklarasikan variabel state di sini
  String? _selectedValue;

  // Contoh daftar paket, silakan sesuaikan isinya nanti
  final List<String> _daftarPaket = [
    'Paket 1 Jam',
    'Paket 1 Hari',
    'Paket 1 Minggu',
    'Paket 1 Bulan',
  ];

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _simpanForm() async {
    if (_menyimpan) return;
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() {
        _menyimpan = true;
      });

      // Logika asinkron simpan data ke Firebase/API ditaruh di sini nanti
    } on Exception catch (e, s) {
      Log.error('Error di simpanForm: $e', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan data');
      }
    } finally {
      if (mounted) {
        setState(() {
          _menyimpan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Voucher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Memberikan ruang di tepi layar
        child: Form(
          key: _formKey,
          child: ListView(
            // Menggunakan ListView agar aman dari overflow saat keyboard muncul
            children: [
              InputTeks(controller: _voucherController, label: 'Voucher'),

              const SizedBox(
                height: 16,
              ), // Memberikan jarak vertikal antar-inputan

              DropdownButtonFormField<String>(
                value: _selectedValue,
                decoration: const InputDecoration(
                  labelText: 'Pilih Paket',
                  border:
                      OutlineInputBorder(), // Membuat border kotak yang rapi
                ),
                hint: const Text('Pilih paket'),
                items: _daftarPaket.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Paket wajib dipilih!' : null,
              ),

              const SizedBox(height: 24), // Jarak sebelum tombol simpan

              ElevatedButton(
                onPressed: _menyimpan ? null : _simpanForm,
                child: _menyimpan
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
