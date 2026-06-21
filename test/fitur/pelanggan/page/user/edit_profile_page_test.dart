// path: test/fitur/pelanggan/page/user/edit_profile_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/page/user/edit_profile_page.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';

import 'edit_profile_page_test.mocks.dart';

// Solusi Mutakhir: Gunakan Spy Class sungguhan alih-alih Mock berbasis Mockito 
// untuk menghindari isu Null Safety pada parameter Route<dynamic>
class SpyNavigatorObserver extends NavigatorObserver {
  bool didPopCalled = false;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    didPopCalled = true;
  }
}

@GenerateMocks([], customMocks: [
  MockSpec<PelangganOpFirebase>(),
  MockSpec<KoneksiInternetService>(),
])
void main() {
  late MockPelangganOpFirebase mockPelangganOp;
  late MockKoneksiInternetService mockKoneksiService;
  late SpyNavigatorObserver spyNavigatorObserver;

  final mockPelanggan = PelangganModel(
    id: 'user123',
    nama: 'Nama Awal',
    telepon: '08111',
    alamat: 'Jalan Utama No. 12',
    kataSandi: 'passAwal',
    macAddress: 'AA:BB:CC:DD:EE:FF',
  );

  setUp(() {
    mockPelangganOp = MockPelangganOpFirebase();
    mockKoneksiService = MockKoneksiInternetService();
    spyNavigatorObserver = SpyNavigatorObserver();
    
    // Default mock koneksi internet diatur ke true (online)
    when(mockKoneksiService.cekInternet()).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pelangganOpFirebaseProvider.overrideWithValue(mockPelangganOp),
        koneksiInternetServiceProvider.overrideWithValue(mockKoneksiService),
      ],
      child: MaterialApp(
        home: EditProfilePage(pelanggan: mockPelanggan),
        navigatorObservers: [spyNavigatorObserver],
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

      await tester.enterText(find.widgetWithText(TextField, 'Nama Lengkap'), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); 

      expect(find.text('Input tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan error jika password dikosongkan',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextField, 'Password'), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); 

      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('04. harus memanggil perbaruiPelanggan saat form valid dan online',
        (tester) async {
      when(mockPelangganOp.perbaruiPelanggan(any)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextField, 'Nama Lengkap'), 'Nama Baru');
      await tester.enterText(
          find.widgetWithText(TextField, 'Password'), 'passBaru');

      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); 
      await tester.pump(); 

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
      await tester.pump(); 
      await tester.pumpAndSettle(); 

      // Verifikasi yang bersih tanpa menggunakan macro matchers mockito yang rewel
      expect(spyNavigatorObserver.didPopCalled, isTrue);
    });

    testWidgets('06. harus menampilkan toast error saat gagal menyimpan',
        (tester) async {
      final exception = Exception('Firestore error');
      when(mockPelangganOp.perbaruiPelanggan(any)).thenThrow(exception);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIMPAN'));
      await tester.pump(); 
      await tester.pumpAndSettle(); 

      expect(find.textContaining('Gagal menyimpan perubahan'), findsOneWidget);
    });
  });
}