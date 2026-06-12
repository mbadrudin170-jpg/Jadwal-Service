// path: test/user/page/transaction_detail_u_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/enum/payment_status_enum.dart';
import 'package:wifi/shared/enum/transaction_type_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/model/transaction_model.dart';
import 'package:wifi/user/page/transaction_detail_u.dart';

void main() {
  final transaction = TransaksiModel(
    id: '1',
    customerId: '1',
    packageId: '1',
    date: DateTime(2023, 1, 1),
    description: 'Test Transaction',
    amount: 100000,
    type: TransactionType.purchase,
    paymentStatus: PaymentStatus.paid,
    startDate: DateTime(2023, 1, 1),
    endDate: DateTime(2023, 1, 31),
    earnedPoints: 10,
    usedPoints: 0,
  );

  final package = PaketModel(
    id: '1',
    name: 'Test Package',
    price: 100000,
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: TransactionDetailPage(
        transaction: transaction,
        package: package,
      ),
    );
  }

  group('TransactionDetailPage', () {
    testWidgets('Test 01: should display transaction details',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Detail Transaksi'), findsOneWidget);
      expect(find.text('Test Transaction'), findsOneWidget);
      expect(find.text('100.000'), findsOneWidget);
      expect(find.text('Purchase'), findsOneWidget);
      expect(find.text('Test Package'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });
}
