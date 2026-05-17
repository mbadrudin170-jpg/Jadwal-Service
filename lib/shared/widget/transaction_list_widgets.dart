// path: lib/shared/widget/transaction_list_widgets.dart
// Diperbarui: Aksi didelegasikan ke pemanggil melalui callback.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/wallet_operation.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Mengelompokkan daftar transaksi berdasarkan tanggal (tanpa jam).
Map<DateTime, List<TransactionModel>> groupTransactionsByDate(
  final List<TransactionModel> transactions,
) {
  final Map<DateTime, List<TransactionModel>> grouped = {};
  for (final t in transactions) {
    final date = DateTime(t.date.year, t.date.month, t.date.day);
    grouped[date] ??= [];
    grouped[date]!.add(t);
  }
  return grouped;
}

/// Membangun widget header untuk sebuah seksi transaksi berdasarkan tanggal.
Widget buildSectionHeader(final DateTime date, final double total) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FormatUtil.formatDateBasic(date),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          CurrencyFormat.formatCurrency(total),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: total >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
  );
}

/// Widget tile untuk menampilkan satu transaksi dalam daftar.
///
/// Widget ini bersifat pasif. Semua aksi (tap, edit, hapus) didelegasikan
/// ke pemanggil melalui parameter callback.
class TransactionTile extends StatefulWidget {
  /// Data transaksi yang ditampilkan.
  final TransactionModel transaction;

  /// Callback yang dipanggil saat item di-tap.
  final VoidCallback? onTap;

  /// Callback yang dipanggil saat tombol "Edit" ditekan.
  final VoidCallback? onEdit;

  /// Callback yang dipanggil saat tombol "Hapus" ditekan.
  final VoidCallback? onDelete;

  /// Membuat [TransactionTile].
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  // Operasi database tetap diperlukan untuk mengambil nama kategori dan dompet.
  final CategoryOperation _categoryOperation = CategoryOperation();
  final WalletOperation _walletOperation = WalletOperation();

  Future<String> _getCategoryName() async {
    try {
      final category = await _categoryOperation.getCategoryById(
        widget.transaction.categoryId,
      );
      return category.name;
    } on Exception {
      return 'Tidak ada kategori';
    }
  }

  Future<String> _getWalletName() async {
    try {
      final wallet = await _walletOperation.getWalletById(
        widget.transaction.walletId,
      );
      return wallet?.name ?? 'Tidak ada dompet';
    } on Exception {
      return 'Tidak ada dompet';
    }
  }

  @override
  Widget build(final BuildContext context) {
    final IconData iconData;
    final Color iconColor;
    if (widget.transaction.type == TransactionType.income) {
      iconData = Icons.arrow_downward;
      iconColor = Colors.green;
    } else {
      iconData = Icons.arrow_upward;
      iconColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        key: ValueKey(widget.transaction.id),
        onTap: widget.onTap,
        onLongPress: () {
          // Hanya tampilkan dialog jika ada aksi (onEdit atau onDelete).
          if (widget.onEdit == null && widget.onDelete == null) return;

          unawaited(
            showDialog<void>(
              context: context,
              builder: (final context) => AlertDialog(
                title: const Text('Opsi'),
                content: const Text(
                  'Apa yang ingin Anda lakukan dengan transaksi ini?',
                ),
                actions: [
                  if (widget.onEdit != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit!();
                      },
                      child: const Text('Edit'),
                    ),
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete!();
                      },
                      child: const Text('Hapus'),
                    ),
                ],
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: iconColor.withAlpha(25),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(widget.transaction.description),
        subtitle: FutureBuilder<List<String>>(
          future: Future.wait([_getCategoryName(), _getWalletName()]),
          builder: (final context, final snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }
            if (snapshot.hasError) {
              return const Text('Error memuat data');
            }
            final categoryName = snapshot.data?[0] ?? '-';
            final walletName = snapshot.data?[1] ?? '-';
            return Text('$categoryName | $walletName');
          },
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormat.formatCurrency(widget.transaction.amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: iconColor),
            ),
            Text(TimeFormat.formatHourMinute(widget.transaction.date)),
          ],
        ),
      ),
    );
  }
}

/// Membangun widget [TransactionTile] dengan parameter yang diberikan.
Widget buildTransactionItem(
  final BuildContext context,
  final TransactionModel transaction, {
  final VoidCallback? onTap,
  final VoidCallback? onEdit,
  final VoidCallback? onDelete,
}) {
  return TransactionTile(
    transaction: transaction,
    onTap: onTap,
    onEdit: onEdit,
    onDelete: onDelete,
  );
}
