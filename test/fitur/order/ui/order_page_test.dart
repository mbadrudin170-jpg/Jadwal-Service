// path: test/fitur/order/ui/order_page_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/operasi/order_op_firebase.dart';
import 'package:wifi/fitur/order/ui/order_page.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/package_op_firebase.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/order_operation.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';

import 'order_page_test.mocks.dart';

// 1. Membuat mock class
@GenerateMocks([OrderOperation, OrderOpFirebase, PackageOpFirebase])
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

  final package1 = PackageModel(id: 'pkg1', name: 'Paket Admin', price: 5, duration: 4, type: DurationType.days);
  final package2 = PackageModel(id: 'pkg2', name: 'Paket User', price: 6, duration: 4, type: DurationType.minutes);

  // 3. Fungsi setUp untuk inisialisasi mock sebelum setiap tes
  setUp(() {
    mockOrderOperation = MockOrderOperation();
    mockOrderOpFirebase = MockOrderOpFirebase();
    mockPackageOpFirebase = MockPackageOpFirebase();
  });

  // 4. Widget tester wrapper untuk menyediakan ProviderScope
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
        home: child,
      ),
    );
  }

  group('Pengujian Halaman Pesanan', () {
    testWidgets('1. Peran Admin: Menampilkan pesanan dari SQLite',
        (tester) async {
      // Atur stub untuk admin
      when(mockOrderOperation.getAllActiveOrdersStream())
          .thenAnswer((_) => Stream.value([orderAdmin]));
      when(mockOrderOperation.getJumlahByStatus(any))
          .thenAnswer((_) async => 1);
      when(mockPackageOpFirebase.getPackageById('pkg1'))
          .thenAnswer((_) async => package1);

      // Pump widget
      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.admin,
        userId: 'admin1',
      ));

      // Tunggu stream dan future builder selesai
      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.text('Paket Admin'), findsOneWidget);
      expect(find.text('Status: baru'), findsOneWidget);
    });

    testWidgets('2. Peran User: Menampilkan pesanan dari Firebase',
        (tester) async {
      // Atur stub untuk user
      when(mockOrderOpFirebase.getAllByUserId(any))
          .thenAnswer((_) => Stream.value([orderUser]));
      when(mockOrderOpFirebase.countOrdersByStatus(any, any))
          .thenAnswer((_) async => 1);
      when(mockPackageOpFirebase.getPackageById('pkg2'))
          .thenAnswer((_) async => package2);

      // Pump widget
      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.user,
        userId: 'custUser',
      ));

      // Tunggu stream dan future builder selesai
      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.text('Paket User'), findsOneWidget);
      expect(find.text('Status: diproses'), findsOneWidget);
    });

    testWidgets('3. Interaksi Tombol Filter: Mengubah daftar yang ditampilkan',
        (tester) async {
      // Atur stub dengan dua pesanan berbeda status
      when(mockOrderOpFirebase.getAllByUserId(any))
          .thenAnswer((_) => Stream.value([orderUser, orderAdmin]));
      when(mockOrderOpFirebase.countOrdersByStatus(any, any))
          .thenAnswer((_) async => 1);
      when(mockPackageOpFirebase.getPackageById(any))
          .thenAnswer((_) async => package1);

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.user,
        userId: 'custUser',
      ));

      await tester.pumpAndSettle();

      // Awalnya, filter 'Selesai' aktif, jadi tidak ada yang tampil
      expect(find.text('Belum ada pesanan ditemukan.'), findsOneWidget);

      // Tekan filter 'Baru'
      await tester.tap(find.text('Baru'));
      await tester.pumpAndSettle();

      // Verifikasi hanya pesanan 'Baru' yang tampil
      expect(find.text('Paket Admin'), findsOneWidget);
      expect(find.text('Paket User'), findsNothing);

      // Tekan filter 'Diproses'
      await tester.tap(find.text('Diproses'));
      await tester.pumpAndSettle();

      // Verifikasi hanya pesanan 'Diproses' yang tampil
      expect(find.text('Paket Admin'), findsNothing);
      expect(find.text('Paket User'), findsOneWidget);
    });

    testWidgets('4. Admin: Long-press memunculkan dialog opsi', (tester) async {
      // Atur stub
      when(mockOrderOperation.getAllActiveOrdersStream())
          .thenAnswer((_) => Stream.value([orderAdmin]));
      when(mockOrderOperation.getJumlahByStatus(any))
          .thenAnswer((_) async => 1);
      when(mockPackageOpFirebase.getPackageById(any))
          .thenAnswer((_) async => package1);

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.admin,
        userId: 'admin1',
      ));
      await tester.pumpAndSettle();

      // Lakukan long-press
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Verifikasi dialog muncul
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Ubah Status'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('5. Admin: Alur ubah status pesanan berhasil', (tester) async {
      // Atur stub
      when(mockOrderOperation.getAllActiveOrdersStream())
          .thenAnswer((_) => Stream.value([orderAdmin]));
      when(mockOrderOperation.getJumlahByStatus(any))
          .thenAnswer((_) async => 1);
      when(mockPackageOpFirebase.getPackageById(any))
          .thenAnswer((_) async => package1);
      when(mockOrderOperation.updateOrderStatus(any, any))
          .thenAnswer((_) async {
        return;
      });

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.admin,
        userId: 'admin1',
      ));
      await tester.pumpAndSettle();

      // 1. Buka dialog opsi
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // 2. Tekan 'Ubah Status'
      await tester.tap(find.text('Ubah Status'));
      await tester.pumpAndSettle();

      // Verifikasi dialog ubah status muncul
      expect(find.text(StatusOrderEnum.selesai.displayName), findsOneWidget);

      // 3. Tekan status 'Selesai'
      await tester.tap(find.text(StatusOrderEnum.selesai.displayName));
      await tester.pumpAndSettle();

      // Verifikasi dialog konfirmasi muncul
      expect(find.text('Apakah Anda yakin ingin melanjutkan?'), findsOneWidget);

      // 4. Tekan 'Iya'
      await tester.tap(find.text('Iya'));
      await tester.pumpAndSettle();

      // 5. Verifikasi pemanggilan method
      verify(mockOrderOperation.updateOrderStatus(
              orderAdmin.id, StatusOrderEnum.selesai))
          .called(1);
    });

    testWidgets('6. User: Alur hapus pesanan berhasil', (tester) async {
      // Atur stub
      when(mockOrderOpFirebase.getAllByUserId(any))
          .thenAnswer((_) => Stream.value([orderUser]));
      when(mockOrderOpFirebase.countOrdersByStatus(any, any))
          .thenAnswer((_) async => 1);
      when(mockPackageOpFirebase.getPackageById(any))
          .thenAnswer((_) async => package2);
      when(mockOrderOpFirebase.softDeleteOrder(any)).thenAnswer((_) async {
        return;
      });

      await tester.pumpWidget(createTestableWidget(
        child: const OrderPage(),
        appRole: AppRole.user,
        userId: 'custUser',
      ));
      await tester.pumpAndSettle();

      // 1. Buka dialog opsi
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // 2. Tekan 'Hapus'
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Verifikasi dialog konfirmasi muncul
      expect(find.text('Apakah Anda yakin ingin melanjutkan?'), findsOneWidget);

      // 3. Tekan 'Iya'
      await tester.tap(find.text('Iya'));
      await tester.pumpAndSettle();

      // 4. Verifikasi pemanggilan method
      verify(mockOrderOpFirebase.softDeleteOrder(orderUser.id)).called(1);
    });
  });
}
