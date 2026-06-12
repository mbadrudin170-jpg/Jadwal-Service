// path: test/admin/halaman/detail/wallet_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/wallet_detail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/export/model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/transaction_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/dompet_provider.dart';
import 'package:wifi/admin/providers/transaction_provider.dart';

import 'wallet_detail_test.mocks.dart';

@GenerateMocks([TransactionOperation])
void main() {
  late MockTransactionOperation mockTransactionOp;

  setUp(() {
    mockTransactionOp = MockTransactionOperation();
  });

  final dompetDummy = WalletModel(
    id: 'w1',
    name: 'Kas Utama',
    balance: 500000,
  );

  final transaksiDummy = [
    TransactionModel(
      id: 't1',
      walletId: 'w1',
      amount: 100000,
      type: TransactionType.income,
      description: 'Pemasukan Internet',
      date: DateTime(2023, 10, 1),
      categoryId: 'c1',
      paymentStatus: PaymentStatus.paid,
    ),
    TransactionModel(
      id: 't2',
      walletId: 'w1',
      amount: 50000,
      type: TransactionType.expense,
      description: 'Beli Kabel',
      date: DateTime(2023, 10, 1),
      categoryId: 'c2',
      paymentStatus: PaymentStatus.paid,
    ),
  ];

  Widget buatWidgetUji(String walletId) {
    return ProviderScope(
      overrides: [
        transactionOperationProvider.overrideWithValue(mockTransactionOp),
        // Mocking the detail provider behavior
        ambilDetailDompetProvider(walletId).overrideWith((ref) async {
          final transactions = await mockTransactionOp.getTransactionsByWalletId(walletId);
          double income = 0;
          double expense = 0;
          for (var t in transactions) {
            if (t.type == TransactionType.income) income += t.amount;
            if (t.type == TransactionType.expense) expense += t.amount;
          }
          return (
            wallet: dompetDummy,
            transactions: transactions,
            totalIncome: income,
            totalExpense: expense,
          );
        }),
      ],
      child: MaterialApp(
        home: WalletDetailPage(walletId: walletId),
      ),
    );
  }

  testWidgets('1. Menampilkan status loading saat memuat data dompet', (tester) async {
    when(mockTransactionOp.getTransactionsByWalletId(any))
        .thenAnswer((_) => Future.delayed(const Duration(seconds: 1), () => []));

    await tester.pumpWidget(buatWidgetUji('w1'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('2. Menampilkan pesan error jika gagal memuat data dompet', (tester) async {
    when(mockTransactionOp.getTransactionsByWalletId(any))
        .thenThrow(Exception('Gagal database'));

    await tester.pumpWidget(buatWidgetUji('w1'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Terjadi kesalahan'), findsOneWidget);
  });

  testWidgets('3. Menampilkan ringkasan saldo dan daftar transaksi dengan benar', (tester) async {
    when(mockTransactionOp.getTransactionsByWalletId('w1'))
        .thenAnswer((_) async => transaksiDummy);

    await tester.pumpWidget(buatWidgetUji('w1'));
    await tester.pumpAndSettle();

    // Cek Nama Dompet di AppBar
    expect(find.text('Kas Utama'), findsWidgets);

    // Cek Ringkasan Saldo
    expect(find.textContaining('100.000'), findsOneWidget); // Income
    expect(find.textContaining('50.000'), findsOneWidget);  // Expense
    
    // Cek Daftar Transaksi
    expect(find.text('Pemasukan Internet'), findsOneWidget);
    expect(find.text('Beli Kabel'), findsOneWidget);
    
    // Cek Grouping Tanggal (Format lokal biasanya muncul)
    expect(find.textContaining('2023'), findsWidgets);
  });

  testWidgets('4. Aksi hapus transaksi memicu dialog konfirmasi', (tester) async {
    when(mockTransactionOp.getTransactionsByWalletId('w1'))
        .thenAnswer((_) async => transaksiDummy);

    await tester.pumpWidget(buatWidgetUji('w1'));
    await tester.pumpAndSettle();

    // Geser atau temukan tombol hapus (biasanya IconButton delete di list tile)
    final tombolHapus = find.byIcon(Icons.delete).first;
    await tester.tap(tombolHapus);
    await tester.pumpAndSettle();

    expect(find.text('Hapus Transaksi?'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });
}