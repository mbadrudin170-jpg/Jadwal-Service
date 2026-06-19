// path: test/fitur/pelanggan/page/user/edit_profile_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/user/edit_profile_page.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';

import 'edit_profile_page_test.mocks.dart';

// Mock Navigator
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

@GenerateMocks([PelangganOpFirebase, KoneksiInternetService])
void main() {
  late MockPelangganOpFirebase mockPelangganOp;
  late MockKoneksiInternetService mockKoneksiService;
  late MockNavigatorObserver mockNavigatorObserver;

  final mockPelanggan = PelangganModel(
    id: 'user123',
    nama: 'Nama Awal',
    telepon: '08111',
    kataSandi: 'passAwal',
    macAddress: 'AA:BB:CC:DD:EE:FF',
  );

  setUp(() {
    mockPelangganOp = MockPelangganOpFirebase();
    mockKoneksiService = MockKoneksiInternetService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pelangganOpFirebaseProvider.overrideWithValue(mockPelangganOp),
        // Kita tidak bisa langsung override service, jadi kita akan mock panggilannya
      ],
      child: MaterialApp(
        home: EditProfilePage(pelanggan: mockPelanggan),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('EditProfilePage Tests', () {
    testWidgets('01. harus menampilkan data awal pelanggan dengan benar',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nama Awal'), findsOneWidget);
      expect(find.text('08111'), findsOneWidget);
      expect(find.text('passAwal'), findsOneWidget);
    });

    testWidgets('02. harus menampilkan error jika nama dikosongkan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Nama Awal'), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); // Rebuild untuk menampilkan pesan error

      expect(find.text('Input tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan error jika password dikosongkan',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'passAwal'), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); // Rebuild untuk menampilkan pesan error

      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('04. harus memanggil perbaruiPelanggan saat form valid dan online',
        (tester) async {
      // Mocking KoneksiInternetService behavior is complex as it's instantiated directly.
      // For this test, we assume an online state and verify the firebase call.
      when(mockPelangganOp.perbaruiPelanggan(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Edit data
      await tester.enterText(
          find.widgetWithText(TextField, 'Nama Awal'), 'Nama Baru');
      await tester.enterText(
          find.widgetWithText(TextField, 'passAwal'), 'passBaru');

      // Simpan
      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); // Show loading
      await tester.pump(); // Process async gap

      // Verifikasi bahwa perbaruiPelanggan dipanggil dengan data yang benar
      final updatedPelanggan = mockPelanggan.copyWith(
        nama: 'Nama Baru',
        kataSandi: 'passBaru',
      );
      verify(mockPelangganOp.perbaruiPelanggan(updatedPelanggan)).called(1);
    });

    testWidgets('05. harus memanggil Navigator.pop setelah berhasil menyimpan',
        (tester) async {
      when(mockPelangganOp.perbaruiPelanggan(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); // show loading
      await tester.pumpAndSettle(); // finish async operations

      verify(mockNavigatorObserver.didPop(any, any)).called(1);
    });

    testWidgets('06. harus menampilkan toast error saat gagal menyimpan',
        (tester) async {
      final exception = Exception('Firestore error');
      when(mockPelangganOp.perbaruiPelanggan(any)).thenThrow(exception);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); // show loading
      await tester.pumpAndSettle(); // finish async operations

      // Verifikasi Toast
      expect(find.textContaining('Gagal menyimpan perubahan'), findsOneWidget);
    });
  });
}
