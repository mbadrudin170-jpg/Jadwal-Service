import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

Widget buildFinancialSummaryInfo({
  required final BuildContext context,
  required final String label,
  required final double amount,
  final Color? color,
}) {
  Log.info(
      'Membangun widget FinancialSummaryInfo untuk label: "$label", amount: $amount');

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
        CurrencyFormat.formatCurrency(amount),
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    ],
  );
}

class FinancialSummaryWidget extends StatelessWidget {
  final double income;
  final double expense;
  final double total;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  const FinancialSummaryWidget({
    super.key,
    required this.income,
    required this.expense,
    required this.total,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  Widget build(final BuildContext context) {
    Log.info(
        'Membangun FinancialSummaryWidget: income=$income, expense=$expense, total=$total, isLoading=$isLoading');

    return Card(
      margin: const EdgeInsets.all(TSizes.p12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.p20),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(final BuildContext context) {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      Log.warning(
          'Menampilkan error message di FinancialSummaryWidget: $errorMessage');
      return Column(
        children: [
          Icon(
            TIcons.errorOutlined,
            color: context.colorScheme.error,
            size: 40,
          ),
          gapH8,
          Text(
            errorMessage!,
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
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 36),
              ),
            ),
          ],
        ],
      );
    }

    if (isLoading) {
      Log.info('Menampilkan loading indicator di FinancialSummaryWidget');
      return const Center(child: CircularProgressIndicator());
    }

    Log.info('Menampilkan data ringkasan keuangan di FinancialSummaryWidget');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildFinancialSummaryInfo(
          context: context,
          label: 'Pemasukan',
          amount: income,
          color: const Color(
              0xFF4CAF50), // Gunakan konstanta atau pindahkan ke TColors.success
        ),
        buildFinancialSummaryInfo(
          context: context,
          label: 'Pengeluaran',
          amount: expense.abs(),
          color: context.colorScheme.error,
        ),
        buildFinancialSummaryInfo(
          context: context,
          label: 'Total',
          amount: total,
          color: context.colorScheme.primary,
        ),
      ],
    );
  }
}

extension FinancialSummaryExtension on BuildContext {
  void showFinancialSummarySnackbar({
    required final double income,
    required final double expense,
    required final double total,
  }) {
    Log.info(
        'Menampilkan snackbar ringkasan keuangan: income=$income, expense=$expense, total=$total');

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final message = '📊 Ringkasan: ${currencyFormat.format(income)} | '
        '${currencyFormat.format(expense.abs())} | '
        '${currencyFormat.format(total)}';

    ToastUtil.info(this, message);
  }
}
