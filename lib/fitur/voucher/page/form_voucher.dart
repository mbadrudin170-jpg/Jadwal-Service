// lib/fitur/voucher/page/form_voucher.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
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

  // Simpan ID paket yang dipilih (bukan nama paket)
  String? _selectedPaketId;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _simpanForm() async {
    if (_menyimpan) return;
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _menyimpan = true);

      // Buat voucher baru (id kosong, nanti diisi Firestore)
      final voucherBaru = VoucherModel(
        id: const Uuid().v4(),
        voucher: _voucherController.text.trim(),
        idPaket: _selectedPaketId!,
        diperbaruiPada: DateTime.now(),
      );

      // Simpan via provider
      await ref.read(voucherProvider.notifier).tambah(voucherBaru);

      if (mounted) {
        ToastUtil.success(context, 'Voucher berhasil disimpan');
        Navigator.pop(context);
      }
    } on Exception catch (e, s) {
      Log.error('Error di simpanForm: $e', e: e, s: s);
      if (mounted) {
        ToastUtil.error(context, 'Gagal menyimpan data');
      }
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data paket dari provider
    final paketAsync = ref.watch(paketProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Voucher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Kode Voucher
              InputTeks(controller: _voucherController, label: 'Voucher'),
              const SizedBox(height: 16),
              paketAsync.when(
                data: (paketState) {
                  final daftarPaket = paketState.daftarPaket
                      .whereType<PaketModel>()
                      .toList();

                  if (daftarPaket.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Tidak ada paket tersedia'),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedPaketId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Paket',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih paket'),
                    items: daftarPaket.map((paket) {
                      return DropdownMenuItem<String>(
                        value: paket.id,
                        child: Text(paket.nama),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPaketId = value);
                    },
                    validator: (value) =>
                        value == null ? 'Paket wajib dipilih!' : null,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat paket: $e'),
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
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
