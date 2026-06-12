
// path: test/admin/halaman/form/subscription_history_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/subscription_history_form.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/notfikasi/notifikasi_servis.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

class MockTransactionOperation extends Mock implements TransactionOperation {}
class MockNotifikasiServis extends Mock implements NotifikasiServis {}
class MockKoneksiInternetService extends Mock implements KoneksiInternetService {}

void main() {
  late MockTransactionOperation mockTransactionOperation;
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
    mockTransactionOperation = MockTransactionOperation();
    mockNotifikasiServis = MockNotifikasiServis();
    mockKoneksiInternetService = MockKoneksiInternetService();
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer(
      overrides: [
        transactionOperationProvider.overrideWithValue(mockTransactionOperation),
        notifikasiServisProvider.overrideWithValue(mockNotifikasiServis),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiInternetService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget createTestWidget(ProviderContainer container, {required TransactionModel transaction}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: SubscriptionHistoryForm(transaction: transaction),
      ),
    );
  }

  testWidgets('1. Tes tampilan awal form riwayat langganan', (tester) async {
    final container = makeProviderContainer();
    await tester.pumpWidget(createTestWidget(container, transaction: transaction));
    
    await tester.pumpAndSettle(); 

    expect(find.text('Edit Riwayat Langganan'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
  });
}
