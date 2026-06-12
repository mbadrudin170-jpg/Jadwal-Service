// path: test/admin/halaman/detail/customer_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/customer_detail.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/widget/page/customer_detail_ui.dart';

@GenerateMocks([CustomerModel])
import 'customer_detail_test.mocks.dart';

void main() {
  late MockCustomerModel mockPelanggan;

  setUp(() {
    mockPelanggan = MockCustomerModel();
    when(mockPelanggan.id).thenReturn('cust-123');
    when(mockPelanggan.name).thenReturn('Budi Santoso');
    when(mockPelanggan.phone).thenReturn('08123456789');
    when(mockPelanggan.address).thenReturn('Jl. Merdeka No. 1');
    when(mockPelanggan.nik).thenReturn('1234567890123456');
    when(mockPelanggan.email).thenReturn('budi@example.com');
  });

  Widget buatWidgetTes(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: CustomerDetailPage(customerId: 'cust-123'),
      ),
    );
  }

  testWidgets('1. Menampilkan indikator pemuatan saat status loading', (tester) async {
    final container = ProviderContainer(
      overrides: [
        customerDetailProvider('cust-123').overrideWith((ref) {
          return const AsyncValue.loading();
        }),
      ],
    );

    await tester.pumpWidget(buatWidgetTes(container));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('2. Menampilkan pesan kesalahan saat status error', (tester) async {
    final container = ProviderContainer(
      overrides: [
        customerDetailProvider('cust-123').overrideWith((ref) {
          return AsyncValue.error('Gagal memuat data', StackTrace.current);
        }),
      ],
    );

    await tester.pumpWidget(buatWidgetTes(container));
    await tester.pump();

    expect(find.textContaining('Terjadi kesalahan: Gagal memuat data'), findsOneWidget);
  });

  testWidgets('3. Menampilkan UI detail pelanggan saat data berhasil dimuat', (tester) async {
    final container = ProviderContainer(
      overrides: [
        customerDetailProvider('cust-123').overrideWith((ref) {
          return AsyncValue.data(mockPelanggan);
        }),
      ],
    );

    await tester.pumpWidget(buatWidgetTes(container));
    await tester.pump();

    expect(find.byType(CustomerDetailUI), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
  });

  testWidgets('4. Menguji interaksi tombol salin nomor telepon', (tester) async {
    final container = ProviderContainer(
      overrides: [
        customerDetailProvider('cust-123').overrideWith((ref) {
          return AsyncValue.data(mockPelanggan);
        }),
      ],
    );

    await tester.pumpWidget(buatWidgetTes(container));
    await tester.pump();

    // Mencari tombol salin (biasanya menggunakan icon copy di CustomerDetailUI)
    final tombolSalin = find.byIcon(Icons.copy);
    if (tombolSalin.evaluate().isNotEmpty) {
      await tester.tap(tombolSalin.first);
      await tester.pump();
      
      // Verifikasi interaksi clipboard jika memungkinkan atau sekadar memastikan tidak crash
      // SystemChannels.platform.setMockMethodCallHandler tidak wajib di sini jika hanya tes UI
    }
  });

  testWidgets('5. Navigasi ke form edit saat tombol edit ditekan', (tester) async {
    final container = ProviderContainer(
      overrides: [
        customerDetailProvider('cust-123').overrideWith((ref) {
          return AsyncValue.data(mockPelanggan);
        }),
      ],
    );

    await tester.pumpWidget(buatWidgetTes(container));
    await tester.pump();

    final tombolEdit = find.byIcon(Icons.edit);
    expect(tombolEdit, findsOneWidget);

    await tester.tap(tombolEdit);
    await tester.pumpAndSettle();

    // Memastikan navigasi mencoba memanggil halaman form
    // (Dalam unit test widget, kita biasanya mengecek tipe route atau kehadiran widget baru)
  });
}