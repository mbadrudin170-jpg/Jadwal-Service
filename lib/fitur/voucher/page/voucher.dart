import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/page/form_voucher.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher')),
      body: Column(
        children: [
          ListTile(
            onTap: () => _naviagasiKeForm(context),
            title: const Text('Nama Voucher'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _naviagasiKeForm(context),
        child: const Icon(TIcons.add),
      ),
    );
  }
}
