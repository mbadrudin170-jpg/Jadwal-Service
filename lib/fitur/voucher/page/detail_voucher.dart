import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart'; // tambahkan ini
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class DetailVoucher extends ConsumerWidget {
  final String idVoucher;
  const DetailVoucher({super.key, required this.idVoucher});

  void _naviagasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (contex) => FormVoucher(idVoucher: idVoucher),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Voucher'),
        actions: [
          IconButton(
            onPressed: () => _naviagasiKeForm(context),
            icon: const Icon(TIcons.edit),
          ),
        ],
      ),
      body: voucherAsync.when(
        data: (state) {
          final voucher = state.voucher.firstWhere(
            (v) => v.id == idVoucher,
            orElse: () => throw Exception('Voucher tidak ditemukan'),
          );

          return _buildDetail(context, voucher);
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // ⬇️ Perubahan: dynamic → VoucherModel
  Widget _buildDetail(BuildContext context, VoucherModel voucher) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            voucher.voucher,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Paket: '),
              NamaPaketWidget(idPaket: voucher.idPaket),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Status: '),
              Icon(
                voucher.terpakai ? Icons.check_circle : Icons.cancel,
                color: voucher.terpakai ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(voucher.terpakai ? 'Terpakai' : 'Belum Terpakai'),
            ],
          ),
          const SizedBox(height: 8),
          if (voucher.diperbaruiPada != null)
            Text(
              'Terakhir diperbarui: ${_formatDateTime(voucher.diperbaruiPada!)}',
              style: const TextStyle(color: Colors.grey),
            ),
          if (voucher.diarsipkanPada != null)
            Text(
              'Diarsipkan pada: ${_formatDateTime(voucher.diarsipkanPada!)}',
              style: const TextStyle(color: Colors.grey),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
