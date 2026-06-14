// path: test/user/page/subscription_history_user_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/user/page/subscription_history_user.dart';
import 'package:wifi/user/providers/user_providers.dart';

// Mocks
class MockTransactionOpFirebase extends Mock implements TransactionOpFirebase {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockTransactionOpFirebase mockTransactionOpFirebase;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockTransactionOpFirebase = MockTransactionOpFirebase();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  final transactions = [
    TransaksiModel(
      id: '1',
      idPelanggan: '1',
      idPaket: '1',
      tanggalMulai: DateTime(2023, 1, 1),
      tangglberakhir: DateTime(2023, 1, 31),
    ),
    TransaksiModel(
      id: '2',
      idPelanggan: '1',
      idPaket: '2',
      tanggalMulai: DateTime(2023, 2, 1),
      tangglberakhir: DateTime(2023, 2, 28),
    ),
  ];

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        transactionOpFirebaseProvider
            .overrideWithValue(mockTransactionOpFirebase),
        userIdProvider.overrideWith((ref) => Future.value('testUserId')),
      ],
      child: MaterialApp(
        home: const SubscriptionHistoryPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('SubscriptionHistoryPage', () {
    testWidgets('Test 01: should display loading indicator while fetching data',
        (WidgetTester tester) async {
      when(() => mockTransactionOpFirebase.getByCustomerId(any()))
          .thenAnswer((_) async => transactions);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Test 02: should display transaction history after fetching',
        (WidgetTester tester) async {
      when(() => mockTransactionOpFirebase.getByCustomerId(any()))
          .thenAnswer((_) async => transactions);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('Test 03: should display error message when fetching fails',
        (WidgetTester tester) async {
      when(() => mockTransactionOpFirebase.getByCustomerId(any()))
          .thenThrow(Exception('Failed to fetch data'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat: Exception: Failed to fetch data'),
          findsOneWidget);
    });

    testWidgets('Test 04: should sort transactions by end date descending',
        (WidgetTester tester) async {
      when(() => mockTransactionOpFirebase.getByCustomerId(any()))
          .thenAnswer((_) async => transactions);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tanggal Berakhir (Terbaru)'));
      await tester.pumpAndSettle();

      final firstTransaction = tester.firstWidget<Card>(find.byType(Card));
      final lastTransaction = tester.lastWidget<Card>(find.byType(Card));

      expect(firstTransaction.key, equals(const ValueKey('2')));
      expect(lastTransaction.key, equals(const ValueKey('1')));
    });
  });
}
