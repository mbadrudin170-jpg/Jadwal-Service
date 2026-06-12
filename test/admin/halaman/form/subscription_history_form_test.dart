// path: test/admin/halaman/form/subscription_history_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_riwayat_aktivasi.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaction_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';

class MockTransactionOpFirebase extends Mock implements TransactionOpFirebase {}

class MockNotifikasiServis extends Mock implements NotifikasiServis {}

class MockKoneksiInternetService extends Mock
    implements KoneksiInternetService {}

void main() {
  late MockTransactionOpFirebase mockTransactionOperation;
  late MockNotifikasiServis mockNotifikasiServis;
  late MockKoneksiInternetService mockKoneksiInternetService;

  final transaction = TransactionModel(
    id: '1',
    date: DateTime.now(),
    description: 'Test Transaction',
    amount: 10000,
    type: TransactionType.income,
    walletId: 'wallet1',
    categoryId: 'category1',
    customerId: 'customer1',
    packageId: 'package1',
    paymentStatus: PaymentStatus.paid,
  );

  setUp(() {
    mockTransactionOperation = MockTransactionOpFirebase();
    mockNotifikasiServis = MockNotifikasiServis();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOperation),
        notifikasiServisProvider.overrideWithValue(mockNotifikasiServis),
        koneksiInternetServiceProvider
            .overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container,
      {required TransactionModel transaction}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: FromRiwayatAktivasi(transaksi: transaction),
      ),
    );
  }

  testWidgets('01. Tes tampilan awal form riwayat langganan', (tester) async {
    final container = makeProviderContainer();
    await tester
        .pumpWidget(createTestWidget(container, transaction: transaction));

    await tester.pumpAndSettle();

    expect(find.text('Edit Riwayat Langganan'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });
}
