// path lib/fitur/voucher/page/voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/page/detail_voucher.dart';
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/widget/nama_paket_widget.dart';

class Voucher extends ConsumerWidget {
  const Voucher({super.key});

  void _navigasiKeDetail(BuildContext context, String idVoucher) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => DetailVoucher(idVoucher: idVoucher),
      ),
    );
  }

  void _navigasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const FormVoucher()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher')),
      body: voucherAsync.when(
        data: (state) {
          if (state.voucher.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.voucher.length,
                  itemBuilder: (context, index) {
                    final voucher = state.voucher[index];
                    return ListTile(
                      onTap: () => _navigasiKeDetail(context, voucher.id),
                      title: Text(voucher.voucher),
                      subtitle: NamaPaketWidget(idPaket: voucher.idPaket),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Text('$error'),
        loading: () => const Center(child: CircularProgressIndicator()),
        skipLoadingOnReload: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tambah_voucher',
        onPressed: () => _navigasiKeForm(context),
        child: const Icon(TIcons.add),
      ),
    );
  }
}
