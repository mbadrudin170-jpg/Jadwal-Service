// path: test/admin/halaman/detail/package_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/export/enum.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late PackageModel testPackage;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    testPackage = PackageModel(
      id: 'pkg-1',
      name: 'Paket Super Cepat',
      price: 100000,
      duration: 30,
      type: DurationType.days,
      rewardPoints: 50,
      redemptionPoints: 500,
      isPublic: true,
    );
    mockNavigatorObserver = MockNavigatorObserver();
    registerFallbackValue(FakeRoute());
  });

  Widget createTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: PackageDetailPage(paket: testPackage),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  testWidgets('01. Menampilkan informasi detail paket dengan benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Paket Super Cepat'), findsOneWidget);
    expect(find.text('Rp100.000'), findsOneWidget);
    expect(find.text('30 hari'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('Tersedia di Aplikasi'), findsOneWidget);
  });

  testWidgets('02. Menavigasi ke PackageForm saat tombol edit ditekan',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final editButton = find.byIcon(Icons.edit);
    expect(editButton, findsOneWidget);

    await tester.tap(editButton);
    await tester.pumpAndSettle();

    verify(() => mockNavigatorObserver.didPush(any(), any()));
    expect(find.byType(PackageForm), findsOneWidget);
  });
}
