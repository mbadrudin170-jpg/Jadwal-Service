// path: test/admin/halaman/detail/subscription_history_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/subscription_history_detail.dart';
import 'package:wifi/admin/providers/detail_langganan_provider.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/shared/export/enum.dart';

import 'subscription_history_detail_test.mocks.dart';

@GenerateMocks([])
void main() {
  late ProviderContainer kontainer;
  final idTransaksi = 'trans-123';

  final mockCustomer = CustomerModel(
    id: 'cust-1',
    name: 'Budi Utomo',
    phone: '08123456789',
    address: 'Alamat Budi',
    password: 'password123',
  );

  final mockPackage = PackageModel(
    id: 'pack-1',
    name: 'Paket Bulanan',
    price: 100000,
    duration: 30,
    type: DurationType.day,
    rewardPoints: 10,
    redemptionPoints: 100,
  );

  final mockTransaction = TransactionModel(
    id: idTransaksi,
    customerId: 'cust-1',
    packageId: 'pack-1',
    amount: 100000,
    transactionDate: DateTime(2023, 10, 1),
    status: StatusOrder.completed,
    paymentStatus: PaymentStatus.paid,
    transactionType: TransactionType.subscription,
  );

  setUp(() {
    kontainer = ProviderContainer();
  });

  tearDown(() {
    kontainer.dispose();
  });

  testWidgets('1. Menampilkan indikator pemuatan saat status loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ambilDetailLanggananProvider(idTransaksi).overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
        ],
        child: MaterialApp(
          home: SubscriptionHistoryDetailPage(transactionId: idTransaksi),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('2. Menampilkan pesan error saat status error', (tester) async {
    final pesanError = 'Gagal memuat data';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ambilDetailLanggananProvider(idTransaksi).overrideWith(
            (ref) => AsyncValue.error(pesanError, StackTrace.current),
          ),
        ],
        child: MaterialApp(
          home: SubscriptionHistoryDetailPage(transactionId: idTransaksi),
        ),
      ),
    );

    expect(find.textContaining('Terjadi kesalahan'), findsOneWidget);
    expect(find.textContaining(pesanError), findsOneWidget);
  });

  testWidgets('3. Menampilkan detail langganan dengan lengkap saat data berhasil dimuat', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ambilDetailLanggananProvider(idTransaksi).overrideWith(
            (ref) => AsyncValue.data((
              transaction: mockTransaction,
              customer: mockCustomer,
              package: mockPackage,
              poinDidapat: 10,
            )),
          ),
        ],
        child: MaterialApp(
          home: SubscriptionHistoryDetailPage(transactionId: idTransaksi),
        ),
      ),
    );

    // Periksa AppBar
    expect(find.text('Detail Riwayat'), findsOneWidget);

    // Periksa informasi pelanggan
    expect(find.text('Budi Utomo'), findsOneWidget);
    expect(find.text('cust-1'), findsOneWidget);

    // Periksa informasi paket
    expect(find.text('Paket Bulanan'), findsOneWidget);
    expect(find.textContaining('100.000'), findsOneWidget);

    // Periksa informasi poin
    expect(find.text('10 Poin'), findsOneWidget);

    // Periksa status
    expect(find.text(StatusOrder.completed.displayName), findsOneWidget);
    expect(find.text(PaymentStatus.paid.displayName), findsOneWidget);
  });

  testWidgets('4. Memastikan tombol interaksi tersedia di halaman detail', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ambilDetailLanggananProvider(idTransaksi).overrideWith(
            (ref) => AsyncValue.data((
              transaction: mockTransaction,
              customer: mockCustomer,
              package: mockPackage,
              poinDidapat: 10,
            )),
          ),
        ],
        child: MaterialApp(
          home: SubscriptionHistoryDetailPage(transactionId: idTransaksi),
        ),
      ),
    );

    // Tombol Edit di AppBar
    expect(find.byIcon(Icons.edit), findsOneWidget);

    // Deteksi InkWell atau tombol navigasi ke detail pelanggan/paket
    expect(find.text('Budi Utomo'), findsOneWidget);
    expect(find.text('Paket Bulanan'), findsOneWidget);
  });
}