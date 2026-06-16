// path: test/fitur/order/ui/order_page_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/order/model/order_model.dart';
import 'package:wifi/fitur/order/page/order_page.dart';
import 'package:wifi/fitur/order/provider/order_provider_gabungan.dart';
import 'package:wifi/shared/enum/app_role_enum.dart';
import 'package:wifi/shared/enum/status_order_enum.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';

// 1. Mock classes
class MockOrderGabungan extends AutoDisposeAsyncNotifier<OrderState>
    with Mock
    implements OrderGabungan {}

class MockPackageOpFirebase extends Mock implements PaketOpFirebase {}

void main() {
  // 2. Data dummy
  final orderBaru = OrderModel(
    id: 'order1',
    idPelanggan: 'cust1',
    idPaket: 'pkg1',
    status: StatusOrderEnum.baru,
    tanggal: DateTime.now(),
    diperbaruiPada: DateTime.now(),
  );

  final orderDiproses = OrderModel(
    id: 'order2',
    idPelanggan: 'cust1',
    idPaket: 'pkg2',
    status: StatusOrderEnum.diproses,
    tanggal: DateTime.now(),
    diperbaruiPada: DateTime.now(),
  );

  final paket1 = PaketModel(
      id: 'pkg1',
      nama: 'Paket Baru',
      harga: 10000,
      durasi: 1,
      tipe: TipeDurasiPaket.days);
  final paket2 = PaketModel(
      id: 'pkg2',
      nama: 'Paket Diproses',
      harga: 20000,
      durasi: 2,
      tipe: TipeDurasiPaket.days);

  late MockPackageOpFirebase mockPackageOpFirebase;

  setUp(() {
    mockPackageOpFirebase = MockPackageOpFirebase();
    when(() => mockPackageOpFirebase.ambilBerdasarkanId('pkg1'))
        .thenAnswer((_) async => paket1);
    when(() => mockPackageOpFirebase.ambilBerdasarkanId('pkg2'))
        .thenAnswer((_) async => paket2);
  });

  // 3. Widget tester wrapper
  Widget createTestableWidget({
    required AppRole appRole,
    required AsyncValue<OrderState> orderState,
  }) {
    return ProviderScope(
      overrides: [
        appRoleProvider.overrideWithValue(appRole),
        orderProvider.overrideWith((ref) => orderState),
        packageOpFirebaseProvider.overrideWithValue(mockPackageOpFirebase),
        // Mock provider lain jika diperlukan oleh widget `PackageNameWidget`
      ],
      child: const MaterialApp(home: OrderPage()),
    );
  }

  group('Pengujian Halaman Pesanan', () {
    testWidgets(
        '01. Harusnya menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      await tester.pumpWidget(createTestableWidget(
        appRole: AppRole.admin,
        orderState: const AsyncValue.loading(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. Harusnya menampilkan pesan error saat terjadi kesalahan',
        (tester) async {
      final error = Exception('Gagal memuat pesanan');
      await tester.pumpWidget(createTestableWidget(
        appRole: AppRole.admin,
        orderState: AsyncValue.error(error, StackTrace.current),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Terjadi kesalahan'), findsOneWidget);
    });

    testWidgets(
        '03. Harusnya menampilkan "Belum ada pesanan" jika tidak ada data',
        (tester) async {
      await tester.pumpWidget(createTestableWidget(
        appRole: AppRole.admin,
        orderState: const AsyncValue.data(OrderState(orders: [])),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Belum ada pesanan ditemukan.'), findsOneWidget);
    });

    testWidgets(
        '04. Harusnya menampilkan pesanan dan bisa difilter berdasarkan status',
        (tester) async {
      final initialState = OrderState(orders: [orderBaru, orderDiproses]);

      await tester.pumpWidget(createTestableWidget(
        appRole: AppRole.admin,
        orderState: AsyncValue.data(initialState),
      ));

      await tester.pumpAndSettle();

      // Awalnya filter 'Selesai' aktif, jadi harusnya tidak ada pesanan
      expect(find.text('Belum ada pesanan ditemukan.'), findsOneWidget);

      // Klik filter 'Baru'
      await tester.tap(find.text('Baru'));
      await tester.pumpAndSettle();

      expect(find.text('Paket Baru'), findsOneWidget);
      expect(find.text('Paket Diproses'), findsNothing);

      // Klik filter 'Diproses'
      await tester.tap(find.text('Diproses'));
      await tester.pumpAndSettle();

      expect(find.text('Paket Baru'), findsNothing);
      expect(find.text('Paket Diproses'), findsOneWidget);
    });

    testWidgets('05. Admin: Long-press memunculkan dialog opsi',
        (tester) async {
      final initialState = OrderState(orders: [orderBaru]);

      await tester.pumpWidget(createTestableWidget(
        appRole: AppRole.admin,
        orderState: AsyncValue.data(initialState),
      ));

      await tester.pumpAndSettle();

      // Klik filter 'Baru' agar item muncul
      await tester.tap(find.text('Baru'));
      await tester.pumpAndSettle();

      final listTile = find.byType(ListTile);
      expect(listTile, findsOneWidget);

      await tester.longPress(listTile);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Ubah Status'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });
  });
}
