import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

Widget bangunRingkasanInfoKeuangan({
  required final BuildContext context,
  required final String label,
  required final double jumlah,
  final Color? color,
}) {
  Log.info(
    'Membangun widget FinancialSummaryInfo untuk label: "$label", amount: $jumlah',
  );

  final textColor = color ?? context.colorScheme.primary;

  return Column(
    children: [
      Text(
        label,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      gapH4,
      Text(
        FormatUang.formatMataUang(jumlah),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    ],
  );
}

class WidgetRingkasanKeuangan extends StatelessWidget {
  final double pemasukan;
  final double pengeluaran;
  final double total;
  final bool sedangLoading;
  final String? pesanError;
  final VoidCallback? onRefresh;

  const WidgetRingkasanKeuangan({
    super.key,
    required this.pemasukan,
    required this.pengeluaran,
    required this.total,
    this.sedangLoading = false,
    this.pesanError,
    this.onRefresh,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info(
      'Membangun FinancialSummaryWidget: income=$pemasukan, expense=$pengeluaran, total=$total, isLoading=$sedangLoading',
    );

    return Card(
      margin: const EdgeInsets.all(TSizes.p12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.p20),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (pesanError != null && pesanError!.isNotEmpty) {
      Log.warning(
        'Menampilkan error message di FinancialSummaryWidget: $pesanError',
      );
      return Column(
        children: [
          Icon(
            TIcons.errorOutlined,
            color: context.colorScheme.error,
            size: 40,
          ),
          gapH8,
          Text(
            pesanError!,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            gapH12,
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 36)),
            ),
          ],
        ],
      );
    }

    if (sedangLoading) {
      Log.info('Menampilkan loading indicator di FinancialSummaryWidget');
      return const Center(child: CircularProgressIndicator());
    }

    Log.info('Menampilkan data ringkasan keuangan di FinancialSummaryWidget');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        bangunRingkasanInfoKeuangan(
          context: context,
          label: 'Pemasukan',
          jumlah: pemasukan,
          color: const Color(
            0xFF4CAF50,
          ), // Gunakan konstanta atau pindahkan ke TColors.success
        ),
        bangunRingkasanInfoKeuangan(
          context: context,
          label: 'Pengeluaran',
          jumlah: pengeluaran.abs(),
          color: context.colorScheme.error,
        ),
        bangunRingkasanInfoKeuangan(
          context: context,
          label: 'Total',
          jumlah: total,
          color: context.colorScheme.primary,
        ),
      ],
    );
  }
}

extension EkstensiRingkasanKeuangan on BuildContext {
  void showFinancialSummarySnackbar({
    required final double pendapatan,
    required final double pengeluaran,
    required final double total,
  }) {
    Log.info(
      'Menampilkan snackbar ringkasan keuangan: income=$pendapatan, expense=$pengeluaran, total=$total',
    );

    final message =
        '📊 Ringkasan: ${FormatUang.formatMataUang(pendapatan)} | '
        '${FormatUang.formatMataUang(pengeluaran.abs())} | '
        '${FormatUang.formatMataUang(total)}';

    ToastUtil.info(this, message);
  }
}
