// path: lib/shared/widget/financial_summary_widget.dart
//
// 📂 FILE INI DIGUNAKAN OLEH:
//   - lib/admin/halaman/tab/wallet_page.dart (WalletPage)
//   - lib/admin/halaman/detail/wallet_detail.dart (WalletDetail)
//   - lib/user/halaman/user_wallet_page.dart (jika ada)
//
// 📂 FILE INI MENGGUNAKAN:
//   - package:flutter/material.dart (Widget)
//   - package:intl/intl.dart (format mata uang)
//   - lib/shared/debug/log.dart (Log)
//   - lib/shared/utils/snackbar_util.dart (ToastUtil)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/utils/format_util.dart';
import 'package:wifi/shared/utils/toast_util.dart';

/// Membuat widget info ringkasan keuangan (label + amount) dengan warna tertentu.
///
/// Parameter:
/// - [context]: BuildContext untuk mengakses tema
/// - [label]: Label yang akan ditampilkan (contoh: 'Pemasukan', 'Pengeluaran')
/// - [amount]: Nilai nominal yang akan ditampilkan dalam format mata uang
/// - [color]: Warna untuk teks amount (opsional, default mengikuti tema)
///
/// Mengembalikan widget Column yang berisi label dan amount terformat.
Widget buildFinancialSummaryInfo({
  required final BuildContext context,
  required final String label,
  required final double amount,
  final Color? color,
}) {
  Log.info(
      'Membangun widget FinancialSummaryInfo untuk label: "$label", amount: $amount');

  final textColor = color ?? Theme.of(context).colorScheme.primary;

  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      const SizedBox(height: 4),
      Text(
        CurrencyFormat.formatCurrency(amount),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    ],
  );
}

/// Widget ringkasan keuangan lengkap dengan 3 item (pemasukan, pengeluaran, total).
///
/// Parameter:
/// - [income]: Jumlah pemasukan
/// - [expense]: Jumlah pengeluaran
/// - [total]: Total saldo
/// - [isLoading]: Status loading (menampilkan progress indicator)
/// - [errorMessage]: Pesan error jika gagal memuat (opsional)
///
/// Mengembalikan widget Card yang berisi 3 kolom info keuangan.
class FinancialSummaryWidget extends StatelessWidget {
  /// Jumlah pemasukan
  final double income;

  /// Jumlah pengeluaran
  final double expense;

  /// Total saldo
  final double total;

  /// Status loading (menampilkan CircularProgressIndicator)
  final bool isLoading;

  /// Pesan error (ditampilkan jika tidak null)
  final String? errorMessage;

  /// Callback saat tombol refresh ditekan
  final VoidCallback? onRefresh;

  /// Konstruktor untuk FinancialSummaryWidget.
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
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(final BuildContext context) {
    // Jika ada error message, tampilkan pesan error dengan tombol refresh
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      Log.warning(
          'Menampilkan error message di FinancialSummaryWidget: $errorMessage');
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: TextStyle(color: Colors.red[400]),
            textAlign: TextAlign.center,
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 12),
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

    // Jika loading, tampilkan progress indicator
    if (isLoading) {
      Log.info('Menampilkan loading indicator di FinancialSummaryWidget');
      return const Center(child: CircularProgressIndicator());
    }

    // Tampilkan data ringkasan keuangan
    Log.info('Menampilkan data ringkasan keuangan di FinancialSummaryWidget');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildFinancialSummaryInfo(
          context: context,
          label: 'Pemasukan',
          amount: income,
          color: Colors.green,
        ),
        buildFinancialSummaryInfo(
          context: context,
          label: 'Pengeluaran',
          amount: expense.abs(), // Tampilkan sebagai angka positif
          color: Colors.red,
        ),
        buildFinancialSummaryInfo(
          context: context,
          label: 'Total',
          amount: total,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

/// Extension method untuk memudahkan pembuatan FinancialSummaryWidget.
extension FinancialSummaryExtension on BuildContext {
  /// Menampilkan snackbar info ringkasan keuangan.
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

    // diperbaiki: Menggunakan ToastUtil sesuai aturan.
    ToastUtil.info(this, message);
  }
}
