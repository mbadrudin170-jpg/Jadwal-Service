// path: test/admin/halaman/detail/customer_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/detail/detail_pelanggan.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/operasi_sqlite_provider/pelanggan_provider.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';

class MockCustomerModel extends Mock implements PelangganModel {}

void main() {
  late MockCustomerModel mockCustomer;

  setUp(() {
    mockCustomer = MockCustomerModel();
    when(() => mockCustomer.id).thenReturn('cust-123');
    when(() => mockCustomer.nama).thenReturn('Budi Santoso');
    when(() => mockCustomer.telepon).thenReturn('08123456789');
    when(() => mockCustomer.alamat).thenReturn('Jl. Merdeka No. 1');
    when(() => mockCustomer.kataSandi).thenReturn('password');
  });

  Widget createTestWidget(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: DetailPelanggan(idPelanggan: 'cust-123'),
      ),
    );
  }

  testWidgets('01. Menampilkan indikator pemuatan saat status loading',
      (tester) async {
    final overrides = [
      pelangganDetailProvider('cust-123')
          .overrideWith((ref) => const AsyncLoading()),
    ];

    await tester.pumpWidget(createTestWidget(overrides));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('02. Menampilkan pesan kesalahan saat status error',
      (tester) async {
    final overrides = [
      pelangganDetailProvider('cust-123').overrideWith(
          (ref) => AsyncError('Gagal memuat data', StackTrace.current)),
    ];

    await tester.pumpWidget(createTestWidget(overrides));
    await tester.pump();

    expect(find.text('Gagal memuat data: Gagal memuat data'), findsOneWidget);
  });

  testWidgets('03. Menampilkan UI detail pelanggan saat data berhasil dimuat',
      (tester) async {
    final overrides = [
      pelangganDetailProvider('cust-123').overrideWith((ref) =>
          AsyncData((pelanggan: mockCustomer, totalPoin: 100))),
    ];

    await tester.pumpWidget(createTestWidget(overrides));
    await tester.pumpAndSettle();

    expect(find.byType(CustomerDetailUI), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('100 Poin'), findsOneWidget);
  });

  testWidgets('04. Menampilkan pesan pelanggan tidak ditemukan jika data null',
      (tester) async {
    final overrides = [
      pelangganDetailProvider('cust-123').overrideWith(
          (ref) => const AsyncData((pelanggan: null, totalPoin: 0))),
    ];

    await tester.pumpWidget(createTestWidget(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Pelanggan tidak ditemukan'), findsOneWidget);
  });
}
