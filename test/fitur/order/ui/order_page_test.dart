// path: test/fitur/order/ui/order_page_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/order/page/order_page.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

// 1. Membuat mock class dengan Mocktail
class MockOrderOperation extends Mock implements OrderOperation {}

class MockOrderOpFirebase extends Mock implements OrderOpFirebase {}

class MockPackageOpFirebase extends Mock implements PaketOpFirebase {}

void main() {
  // 2. Deklarasi mock dan data
  late MockOrderOperation mockOrderOperation;
  late MockOrderOpFirebase mockOrderOpFirebase;
  late MockPackageOpFirebase mockPackageOpFirebase;

  final orderAdmin = OrderModel(
    id: 'order1',
    customerId: 'custAdmin',
    packageId: 'pkg1',
    date: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final orderUser = OrderModel(
    id: 'order2',
    customerId: 'custUser',
    packageId: 'pkg2',
    date: DateTime.now(),
    status: StatusOrderEnum.diproses,
    updatedAt: DateTime.now(),
  );

  final package1 = PackageModel(
      id: 'pkg1',
      name: 'Paket Admin',
      price: 5,
      duration: 4,
      type: DurationType.days);
  final package2 = PackageModel(
      id: 'pkg2',
      name: 'Paket User',
      price: 6,
      duration: 4,
      type: DurationType.minutes);

  // 3. Fungsi setUp untuk inisialisasi mock sebelum setiap tes
  setUp(() {
    mockOrderOperation = MockOrderOperation();
    mockOrderOpFirebase = MockOrderOpFirebase();
    mockPackageOpFirebase = MockPackageOpFirebase();

    registerFallbackValue(StatusOrderEnum.baru);

    // Stubs default
    when(() => mockPackageOpFirebase.getPackageById(any()))
        .thenAnswer((_) => Future.value(package1));
    when(() => mockOrderOpFirebase.getAllByUserId(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockOrderOperation.getAllActiveOrdersStream())
        .thenAnswer((_) => Stream.value([]));
    when(() => mockOrderOperation.getJumlahByStatus(any()))
        .thenAnswer((_) async => 0);
    when(() => mockOrderOpFirebase.countOrdersByStatus(any(), any()))
        .thenAnswer((_) async => 0);
    // Stub for softDelete to prevent timer leaks
    when(() => mockOrderOperation.softDelete(any())).thenAnswer((_) async => 1);
  });

  // 4. Widget tester wrapper
  Widget createTestableWidget({
    required Widget child,
    required AppRole appRole,
    String? userId,
  }) {
    return ProviderScope(
      overrides: [
        appRoleProvider.overrideWith((ref) => appRole),
        userIdProvider.overrideWithValue(AsyncValue.data(userId)),
        orderOperationProvider.overrideWith((ref) => mockOrderOperation),
        orderOpFirebaseProvider.overrideWith((ref) => mockOrderOpFirebase),
        packageOpFirebaseProvider.overrideWith((ref) => mockPackageOpFirebase),
      ],
      child: MaterialApp(
        home: Material(child: child),
      ),
    );
  }

  group('Pengujian Halaman Pesanan', () {
    testWidgets('1. Peran Admin: Menampilkan pesanan dari SQLite',
        (tester) async {
      when(() => mockOrderOperation.getAllActiveOrdersStream())
          .thenAnswer((_) => Stream.value([orderAdmin]));
      when(() => mockOrderOperation.getJumlahByStatus(StatusOrderEnum.baru))
          .thenAnswer((_) async => 1);
      when(() => mockPackageOpFirebase.getPackageById('pkg1'))
          .thenAnswer((_) => Future.value(package1));

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.admin,
        userId: 'admin1',
      ));

      await tester.pumpAndSettle();

      // Ubah filter untuk menampilkan pesanan 'Baru'
      final baruButton = find.text('Baru');
      await tester.ensureVisible(baruButton);
      await tester.pumpAndSettle();
      await tester.tap(baruButton);
      await tester.pumpAndSettle();

      // Verify that the package name is eventually displayed
      expect(find.text('Paket Admin'), findsOneWidget);
      expect(find.text('Status: baru'), findsOneWidget);
    });

    testWidgets('2. Peran User: Menampilkan pesanan dari Firebase',
        (tester) async {
      when(() => mockOrderOpFirebase.getAllByUserId(any()))
          .thenAnswer((_) => Stream.value([orderUser]));
      when(() => mockOrderOpFirebase.countOrdersByStatus(
          StatusOrderEnum.diproses, any())).thenAnswer((_) async => 1);
      when(() => mockPackageOpFirebase.getPackageById('pkg2'))
          .thenAnswer((_) => Future.value(package2));

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.user,
        userId: 'custUser',
      ));

      await tester.pumpAndSettle();

      // Ubah filter untuk menampilkan pesanan 'Diproses'
      final prosesButton = find.text('Diproses');
      await tester.ensureVisible(prosesButton);
      await tester.pumpAndSettle();
      await tester.tap(prosesButton);
      await tester.pumpAndSettle();

      expect(find.text('Paket User'), findsOneWidget);
      expect(find.text('Status: diproses'), findsOneWidget);
    });

    testWidgets('3. Interaksi Tombol Filter: Mengubah daftar yang ditampilkan',
        (tester) async {
      when(() => mockOrderOpFirebase.getAllByUserId(any()))
          .thenAnswer((_) => Stream.value([orderUser, orderAdmin]));
      when(() => mockOrderOpFirebase.countOrdersByStatus(
          StatusOrderEnum.baru, any())).thenAnswer((_) async => 1);
      when(() => mockOrderOpFirebase.countOrdersByStatus(
          StatusOrderEnum.diproses, any())).thenAnswer((_) async => 1);
      when(() => mockPackageOpFirebase.getPackageById('pkg1'))
          .thenAnswer((_) => Future.value(package1));
      when(() => mockPackageOpFirebase.getPackageById('pkg2'))
          .thenAnswer((_) => Future.value(package2));

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.user,
        userId: 'custUser',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada pesanan ditemukan.'), findsOneWidget);

      final baruButton = find.text('Baru');
      await tester.ensureVisible(baruButton);
      await tester.pumpAndSettle();
      await tester.tap(baruButton);
      await tester.pumpAndSettle();

      expect(find.text('Paket Admin'), findsOneWidget);
      expect(find.text('Paket User'), findsNothing);

      final prosesButton = find.text('Diproses');
      await tester.ensureVisible(prosesButton);
      await tester.pumpAndSettle();
      await tester.tap(prosesButton);
      await tester.pumpAndSettle();

      expect(find.text('Paket Admin'), findsNothing);
      expect(find.text('Paket User'), findsOneWidget);
    });

    testWidgets('4. Admin: Long-press memunculkan dialog opsi', (tester) async {
      when(() => mockOrderOperation.getAllActiveOrdersStream())
          .thenAnswer((_) => Stream.value([orderAdmin]));
      when(() => mockOrderOperation.getJumlahByStatus(any()))
          .thenAnswer((_) async => 1);
      when(() => mockPackageOpFirebase.getPackageById(any()))
          .thenAnswer((_) => Future.value(package1));

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.admin,
        userId: 'admin1',
      ));

      await tester.pumpAndSettle();

      final baruButton = find.text('Baru');
      await tester.ensureVisible(baruButton);
      await tester.pumpAndSettle();
      await tester.tap(baruButton);
      await tester.pumpAndSettle();

      final listTile = find.byType(ListTile);
      await tester.ensureVisible(listTile);
      await tester.pumpAndSettle();

      expect(listTile, findsOneWidget);
      await tester.longPress(listTile);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Ubah Status'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('5. Admin: Alur ubah status pesanan berhasil', (tester) async {
      when(() => mockOrderOperation.getAllActiveOrdersStream())
          .thenAnswer((_) => Stream.value([orderAdmin]));
      when(() => mockOrderOperation.getJumlahByStatus(any()))
          .thenAnswer((_) async => 1);
      when(() => mockPackageOpFirebase.getPackageById(any()))
          .thenAnswer((_) => Future.value(package1));
      when(() => mockOrderOperation.updateOrderStatus(any(), any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.admin,
        userId: 'admin1',
      ));

      await tester.pumpAndSettle();

      final baruButton = find.text('Baru');
      await tester.ensureVisible(baruButton);
      await tester.pumpAndSettle();
      await tester.tap(baruButton);
      await tester.pumpAndSettle();

      final listTile = find.byType(ListTile);
      await tester.ensureVisible(listTile);
      await tester.pumpAndSettle();
      expect(listTile, findsOneWidget);

      await tester.longPress(listTile);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ubah Status'));
      await tester.pumpAndSettle();

      // Finder lebih spesifik untuk text di dalam dialog
      final dialogSelesaiButton = find.descendant(
        of: find.byType(Dialog),
        matching: find.text(StatusOrderEnum.selesai.displayName),
      );

      expect(dialogSelesaiButton, findsOneWidget);

      await tester.tap(dialogSelesaiButton);
      await tester.pumpAndSettle();

      expect(find.text('Apakah Anda yakin ingin melanjutkan?'), findsOneWidget);

      await tester.tap(find.text('Iya'));
      await tester
          .pumpAndSettle(const Duration(seconds: 5)); // Allow time for toast

      verify(() => mockOrderOperation.updateOrderStatus(
          orderAdmin.id, StatusOrderEnum.selesai)).called(1);
    });

    testWidgets('6. User: Alur hapus pesanan berhasil', (tester) async {
      when(() => mockOrderOpFirebase.getAllByUserId(any()))
          .thenAnswer((_) => Stream.value([orderUser]));
      when(() => mockOrderOpFirebase.countOrdersByStatus(any(), any()))
          .thenAnswer((_) async => 1);
      when(() => mockPackageOpFirebase.getPackageById(any()))
          .thenAnswer((_) => Future.value(package2));
      when(() => mockOrderOpFirebase.softDeleteOrder(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.user,
        userId: 'custUser',
      ));

      await tester.pumpAndSettle();

      final prosesButton = find.text('Diproses');
      await tester.ensureVisible(prosesButton);
      await tester.pumpAndSettle();
      await tester.tap(prosesButton);
      await tester.pumpAndSettle();

      final listTile = find.byType(ListTile);
      await tester.ensureVisible(listTile);
      await tester.pumpAndSettle();
      expect(listTile, findsOneWidget);

      await tester.longPress(listTile);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Apakah Anda yakin ingin melanjutkan?'), findsOneWidget);

      await tester.tap(find.text('Iya'));
      await tester
          .pumpAndSettle(const Duration(seconds: 5)); // Allow time for toast

      verify(() => mockOrderOpFirebase.softDeleteOrder(orderUser.id)).called(1);
    });
  });
}
