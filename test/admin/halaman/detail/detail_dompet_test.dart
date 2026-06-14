// path: test/admin/halaman/detail/detail_dompet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_dompet.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/provider/transaksi_provider.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/dompet_provider.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransactionOperation {}

void main() {
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockTransaksiOpsqlite mockTransactionOperation;
  late DompetModel testWallet;

  setUp(() {
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockTransactionOperation = MockTransaksiOpsqlite();
    testWallet = DompetModel(
      id: '1',
      nama: 'Test Wallet',
      saldo: 1000,
    );
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        dompetOpSqliteProvider.overrideWithValue(mockDompetOpSqlite),
        transaksiOpSqliteProvider.overrideWithValue(mockTransactionOperation),
      ],
      child: MaterialApp(
        home: DetailDompet(
          dompet: testWallet,
        ),
      ),
    );
  }

  testWidgets('01. harus menampilkan nama dan saldo dompet',
      (tester) async {
    when(() => mockDompetOpSqlite.ambilBerdasarkanId(any()))
        .thenAnswer((_) async => testWallet);
    when(() => mockTransactionOperation.ambilBerdasarkanIdDompet(any()))
        .thenAnswer((_) async => []);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Test Wallet'), findsOneWidget);
    expect(find.textContaining('1000'), findsWidgets);
  });
}
