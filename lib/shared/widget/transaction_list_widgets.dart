// path: lib/shared/widget/transaction_list_widgets.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/shared/export/theme.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/category_operation.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/shared/utils/format_util.dart';

/// Mengelompokkan daftar transaksi berdasarkan tanggal (tanpa jam).
Map<DateTime, List<TransaksiModel>> groupTransactionsByDate(
  final List<TransaksiModel> transactions,
) {
  final Map<DateTime, List<TransaksiModel>> grouped = {};
  for (final t in transactions) {
    final date = DateTime(t.date.year, t.date.month, t.date.day);
    grouped[date] ??= [];
    grouped[date]!.add(t);
  }
  return grouped;
}

/// Membangun widget header untuk sebuah seksi transaksi berdasarkan tanggal.
Widget buildSectionHeader(final DateTime date, final double total) {
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
class TransactionTile extends ConsumerStatefulWidget {
  final TransaksiModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends ConsumerState<TransactionTile> {
  late final CategoryOperation _categoryOperation;
  late final DompetOpSqlite _walletOperation;

  @override
  void initState() {
    super.initState();
    _categoryOperation = ref.read(categoryOperationProvider);
    _walletOperation = ref.read(walletOperationProvider);
    Log.info('TransactionTile initState for ID: ${widget.transaction.id}');
  }

  @override
  void dispose() {
    Log.info('TransactionTile dispose for ID: ${widget.transaction.id}');
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
        s: st,
      );
      return 'Error Kategori';
    }
  }

  Future<String> _getWalletName() async {
    try {
      final wallet = await _walletOperation.getById(
        widget.transaction.walletId,
      );
      return wallet?.name ?? 'Dompet Dihapus';
    } on Exception catch (e, st) {
      Log.error(
        'Gagal mendapatkan nama dompet untuk ID: ${widget.transaction.walletId}',
        e: e,
        s: st,
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
                s: snapshot.stackTrace,
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
            gapH4,
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
  final TransaksiModel transaction, {
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
