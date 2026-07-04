// path: lib/fitur/voucher/page/detail_voucher.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/enum/tipe_voucher.dart';
import 'package:wifi/fitur/voucher/model/voucher_model.dart'; // tambahkan ini
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/fitur/paket/widget/nama_paket_widget.dart';

class DetailVoucher extends ConsumerWidget {
  final String idVoucher;
  const DetailVoucher({super.key, required this.idVoucher});

  void _navigasiKeForm(BuildContext context) {
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
            onPressed: () => _navigasiKeForm(context),
            icon: const Icon(TIcons.edit),
          ),
        ],
      ),
      body: voucherAsync.when(
        data: (state) {
          final voucher = state.voucher.firstWhereOrNull(
            (v) => v.id == idVoucher,
          );
          if (voucher == null) {
            return const Center(child: Text('Voucher tidak ditemukan'));
          }
          return _buildDetail(context, voucher);
        },
        error: (error, _) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, VoucherModel voucher) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  voucher.voucher,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.blue),
                const SizedBox(width: 8),
                NamaPaketWidget(idPaket: voucher.idPaket),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(voucher.terpakai ? 'Terpakai' : 'Belum Terpakai'),
              backgroundColor: voucher.terpakai
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
            const SizedBox(height: 12),
            if (voucher.tipeVoucher.isNotEmpty)
              Chip(
                avatar: Icon(
                  voucher.tipeVoucher == TipeVoucher.satu.name
                      ? Icons.phone_android
                      : Icons.devices,
                  size: 18,
                ),
                label: Text(
                  voucher.tipeVoucher == TipeVoucher.satu.name
                      ? 'Satu Perangkat'
                      : 'Beberapa Perangkat',
                ),
                backgroundColor: Colors.blue.shade50,
              ),
            const SizedBox(height: 12),
            if (voucher.diperbaruiPada != null)
              Row(
                children: [
                  const Icon(Icons.update, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Terakhir diperbarui: ${_formatDateTime(voucher.diperbaruiPada!)}',
                  ),
                ],
              ),
            if (voucher.diarsipkanPada != null)
              Row(
                children: [
                  const Icon(Icons.archive, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Diarsipkan pada: ${_formatDateTime(voucher.diarsipkanPada!)}',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
