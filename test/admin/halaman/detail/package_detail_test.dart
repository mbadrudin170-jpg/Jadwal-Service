// path: test/admin/halaman/detail/package_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_paket.dart';
import 'package:wifi/admin/halaman/form/form_paket.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/export/enum.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late PaketModel testPackage;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    testPackage = PaketModel(
      id: 'pkg-1',
      name: 'Paket Super Cepat',
      price: 100000,
      duration: 30,
      durationType: DurationType.days,
      rewardPoints: 50,
      isPublic: true,
    );
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: DetailPaketPage(paket: testPackage),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  testWidgets('01. Menampilkan informasi detail paket dengan benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Detail Paket'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);
    expect(find.text('30 Hari'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('Ya'), findsOneWidget);
  });

  testWidgets('02. Menavigasi ke FormPaket saat tombol edit ditekan',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final editButton = find.byIcon(Icons.edit);
    expect(editButton, findsOneWidget);

    await tester.tap(editButton);
    await tester.pumpAndSettle();

    verify(() => mockNavigatorObserver.didPush(any(), any()));
    expect(find.byType(FormPaket), findsOneWidget);
  });
}
