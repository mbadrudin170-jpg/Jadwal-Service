// path lib/fitur/voucher/page/detail_voucher.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/fitur/voucher/provider/voucher_provider.dart';

class DetailVoucher extends ConsumerWidget {
  const DetailVoucher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voucherAsync = ref.watch(voucherProvider);
    return Container();
  }
}
