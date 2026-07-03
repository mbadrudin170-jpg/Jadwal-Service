// path lib/fitur/voucher/page/voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
import 'package:wifi/fitur/voucher/voucher_provider.dart';
import 'package:wifi/shared/export/theme.dart';

class Voucher extends ConsumerWidget {
  const Voucher({super.key});

  void _naviagasiKeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const FormVoucher()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);
    final daftarPaket = ref.watch(paketProvider).value?.daftarPaket ?? [];

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
                    final namaPaket =
                        daftarPaket
                            .where((p) => p?.id == voucher.idPaket)
                            .map((p) => p?.nama)
                            .firstOrNull ??
                        'Paket tidak dtemukan';
                    return ListTile(
                      onTap: () => _naviagasiKeForm(context),
                      title: Text(voucher.voucher),
                      subtitle: Text(namaPaket),
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
        onPressed: () => _naviagasiKeForm(context),
        child: const Icon(TIcons.add),
      ),
    );
  }
}
