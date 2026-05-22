// path: lib/shared/widget/transaction_list_widgets.dart
// Diperbarui: Aksi didelegasikan ke pemanggil melalui callback.
// Diperbaiki: Menambahkan logging pada lifecycle dan error handling di TransactionTile.
// Diperbaiki: Menggunakan Theme.of(context) untuk gaya teks yang konsisten.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wifi/shared/debug/log.dart';
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
  // Menggunakan Builder untuk mendapatkan context agar bisa mengakses Theme
  return Builder(builder: (final context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            FormatDate.formatDateCompact(date),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            CurrencyFormat.formatCurrency(total),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: total >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  });
}

/// Widget tile untuk menampilkan satu transaksi dalam daftar.
///
/// Widget ini bersifat pasif. Semua aksi (tap, edit, hapus) didelegasikan
/// ke pemanggil melalui parameter callback.
class TransactionTile extends StatefulWidget {
  /// Data transaksi yang akan ditampilkan.
  final TransactionModel transaction;

  /// Callback yang dipanggil saat item di-tap.
  final VoidCallback? onTap;

  /// Callback yang dipanggil saat tombol "Edit" ditekan.
  final VoidCallback? onEdit;

  /// Callback yang dipanggil saat tombol "Hapus" ditekan.
  final VoidCallback? onDelete;

  /// Membuat instance dari [TransactionTile].
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
  final CategoryOperation _categoryOperation = CategoryOperation();
  final WalletOperation _walletOperation = WalletOperation();

  @override
  void initState() {
    super.initState();
    Log.info(
        'TransactionTile initState for transaction ID: ${widget.transaction.id}');
  }

  @override
  void dispose() {
    Log.info(
        'TransactionTile dispose for transaction ID: ${widget.transaction.id}');
    super.dispose();
  }

  Future<String> _getCategoryName() async {
    try {
      final category = await _categoryOperation.getCategoryById(
        widget.transaction.categoryId,
      );
      return category.name;
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama kategori untuk ID: ${widget.transaction.categoryId}',
        e: e,
        st: st,
      );
      return 'Error Kategori';
    }
  }

  Future<String> _getWalletName() async {
    try {
      final wallet = await _walletOperation.getWalletById(
        widget.transaction.walletId,
      );
      return wallet?.name ?? 'Dompet Dihapus';
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama dompet untuk ID: ${widget.transaction.walletId}',
        e: e,
        st: st,
      );
      return 'Error Dompet';
    }
  }

  @override
  Widget build(final BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
              Log.error(
                'Error di FutureBuilder TransactionTile untuk ID: ${widget.transaction.id}',
                e: snapshot.error,
                st: snapshot.stackTrace,
              );
              return Text('Error memuat data',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.red));
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
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              TimeFormat.formatHourMinute(widget.transaction.date),
              style: textTheme.bodySmall,
            ),
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
