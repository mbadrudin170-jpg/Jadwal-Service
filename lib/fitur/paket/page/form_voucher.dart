import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';

class FormVoucher extends ConsumerStatefulWidget {
  const FormVoucher({super.key});

  @override
  ConsumerState<FormVoucher> createState() => _FormVoucherState();
}

class _FormVoucherState extends ConsumerState<FormVoucher> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Bersihkan resource di sini jika diperlukan.
    // Contoh: _repository.dispose(); atau _subscription.cancel();
    super.dispose();
  }

Future<void> _simpanForm() async {
  try {
    // Logika asinkron
  } on Exception catch (e, s) {
    Log.error('Error di simpanForm: $e', e: e, s: s);
    // Error handling opsional
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FormVoucher')),
      body: Container(),
    );
  }
}
