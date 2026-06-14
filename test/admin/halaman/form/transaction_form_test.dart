// path: test/admin/halaman/form/transaction_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/transaksi/page/form_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/shared/model/kategori_model.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/dompet_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/kategori_op_firebase.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class MockDompetOpFirebase extends Mock implements DompetOpFirebase {}

class MockKategoriOpFirebase extends Mock implements KategoriOpFirebase {}

class MockTransactionOpFirebase extends Mock implements TransaksiOpFirebase {}

void main() {
  late MockDompetOpFirebase mockDompetOpFirebase;
  late MockKategoriOpFirebase mockKategoriOpFirebase;
  late MockTransactionOpFirebase mockTransactionOpFirebase;
  late TransaksiModel testTransaction;

  setUp(() {
    mockDompetOpFirebase = MockDompetOpFirebase();
    mockKategoriOpFirebase = MockKategoriOpFirebase();
    mockTransactionOpFirebase = MockTransactionOpFirebase();
    testTransaction = TransaksiModel(
      id: '1',
      deskripsi: 'Test Transaction',
      jumlah: 1000,
      tanggal: DateTime.now(),
      tipe: TipeTransaksi.income,
      idDompet: '1',
      idKategori: '1',
    );
  });

  Widget createTestWidget({TransaksiModel? transaction}) {
    return ProviderScope(
      overrides: [
        dompetOpFirebaseProvider.overrideWithValue(mockDompetOpFirebase),
        kategoriOpFirebaseProvider.overrideWithValue(mockKategoriOpFirebase),
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOpFirebase),
      ],
      child: MaterialApp(
        home: FormTransaksi(transaksi: transaction),
      ),
    );
  }

  testWidgets('01. FormTransaksiPage should display add form correctly',
      (tester) async {
    when(() => mockDompetOpFirebase.ambilSemuaDompet())
        .thenAnswer((_) async => []);
    when(() => mockKategoriOpFirebase.ambilSemuaKategori())
        .thenAnswer((_) async => []);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
    expect(find.text('Tambah Transaksi'), findsOneWidget);
  });

  testWidgets('02. FormTransaksiPage should display edit form correctly',
      (tester) async {
    when(() => mockDompetOpFirebase.ambilSemuaDompet())
        .thenAnswer((_) async => [
              DompetModel(id: '1', nama: 'Test Wallet', saldo: 0),
            ]);
    when(() => mockKategoriOpFirebase.ambilSemuaKategori())
        .thenAnswer((_) async => [
              KategoriModel(
                  id: '1', name: 'Test Category', type: TipeKategori.income),
            ]);
    await tester.pumpWidget(createTestWidget(transaction: testTransaction));
    await tester.pumpAndSettle();
    expect(find.text('Edit Transaksi'), findsOneWidget);
    expect(find.text('Test Transaction'), findsOneWidget);
    expect(find.text('1000.0'), findsOneWidget);
  });
}
