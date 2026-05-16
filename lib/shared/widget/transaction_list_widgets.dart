// path: lib/shared/widget/transaction_list_widgets.dart
// digunakan oleh: lib/admin/halaman/detail/wallet_detail.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/category_operation.dart';
import 'package:wifi/shared/operasi/transaction_operation.dart';
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
class TransactionTile extends StatefulWidget {
  /// Data transaksi yang ditampilkan.
  final TransactionModel transaction;

  /// Callback saat data berubah (setelah edit/hapus).
  final VoidCallback onDataChanged;

  /// Operasi transaksi untuk aksi arsipkan.
  final TransactionOperation transactionOperation;

  /// Membuat [TransactionTile].
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDataChanged,
    required this.transactionOperation,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
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

  Future<void> _archiveTransaction() async {
    await widget.transactionOperation.archiveTransaction(widget.transaction.id);
    widget.onDataChanged();
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
        onTap: () {
          // TODO: Navigate to transaction detail when available
          Log.info('Tap transaksi: ${widget.transaction.id}');
        },
        onLongPress: () {
          unawaited(
            showDialog<void>(
              context: context,
              builder: (final context) => AlertDialog(
                title: const Text('Opsi'),
                content: const Text(
                  'Apa yang ingin Anda lakukan dengan transaksi ini?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to transaction form when available
                    },
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _archiveTransaction();
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
  final TransactionModel transaction,
  final VoidCallback onDataChanged,
  final TransactionOperation transactionOperation,
) {
  return TransactionTile(
    transaction: transaction,
    onDataChanged: onDataChanged,
    transactionOperation: transactionOperation,
  );
}
