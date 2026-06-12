// path: test/user/page/edit_profile_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/services/koneksi_internet_service.dart';
import 'package:wifi/user/page/edit_profile_page.dart';

// Mocks
class MockCustomerOpFirebase extends Mock implements CustomerOpFirebase {}

class MockKoneksiInternetService extends Mock
    implements KoneksiInternetService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeCustomerModel extends Fake implements PelangganModel {}

void main() {
  // Data dummy
  const customer = PelangganModel(
    id: 'user1',
    name: 'John Doe',
    phone: '081234567890',
    password: 'password123',
    email: 'john.doe@example.com',
  );

  late MockCustomerOpFirebase mockCustomerOpFirebase;
  late MockKoneksiInternetService mockKoneksiInternetService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeCustomerModel());
  });

  setUp(() {
    mockCustomerOpFirebase = MockCustomerOpFirebase();
    mockKoneksiInternetService = MockKoneksiInternetService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  // Widget wrapper
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        customerOpFirebaseProvider.overrideWithValue(mockCustomerOpFirebase),
      ],
      child: MaterialApp(
        home: EditProfilePage(
          customer: customer,
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Uji Halaman Edit Profil', () {
    testWidgets('Test 01: Render Awal dan Tampilkan Data Pelanggan',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifikasi judul AppBar
      expect(find.text('Edit Profil'), findsOneWidget);

      // Verifikasi data awal di TextFormFields
      expect(find.widgetWithText(TextFormField, 'John Doe'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, '081234567890'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'password123'), findsOneWidget);

      // Verifikasi tombol simpan
      expect(find.text('SIMPAN'), findsOneWidget);
    });

    testWidgets('Test 02: Tampilkan pesan error jika nama kosong',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Kosongkan field nama
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump();

      // Verifikasi pesan error
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Test 03: Tampilkan pesan error jika No. HP kosong',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump();

      expect(find.text('No. HP tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Test 04: Tampilkan pesan error jika password kosong',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(2), '');
      await tester.tap(find.text('SIMPAN'));
      await tester.pump();

      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Test 05: Toggle visibilitas password berfungsi',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Awalnya password tidak terlihat
      TextField passwordField = tester.widget(find.byType(TextFormField).at(2));
      expect(passwordField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tekan ikon untuk menampilkan password
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Password sekarang terlihat
      passwordField = tester.widget(find.byType(TextFormField).at(2));
      expect(passwordField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tekan lagi untuk menyembunyikan
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Password kembali tersembunyi
      passwordField = tester.widget(find.byType(TextFormField).at(2));
      expect(passwordField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Test 06: Simpan perubahan berhasil saat online',
        (tester) async {
      // Ganti `_internetConnectionService` dengan mock
      final pageState = tester.state<ConsumerState<EditProfilePage>>(
          find.byType(EditProfilePage)) as dynamic;
      pageState._internetConnectionService = mockKoneksiInternetService;

      // Stub
      when(() => mockKoneksiInternetService.cekInternet(any()))
          .thenAnswer((_) async => true);
      when(() => mockCustomerOpFirebase.updateCustomer(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockNavigatorObserver.didPop(any(), any())).thenAnswer((_) {});

      await tester.pumpWidget(createWidgetUnderTest());

      // Ubah data
      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');

      // Simpan
      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();

      // Verifikasi
      final captured =
          verify(() => mockCustomerOpFirebase.updateCustomer(captureAny()))
              .captured
              .single as PelangganModel;
      expect(captured.name, 'Jane Doe');

      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets(
        'Test 07: Tampilkan info saat mencoba simpan tanpa koneksi internet',
        (tester) async {
      final pageState = tester.state<ConsumerState<EditProfilePage>>(
          find.byType(EditProfilePage)) as dynamic;
      pageState._internetConnectionService = mockKoneksiInternetService;

      when(() => mockKoneksiInternetService.cekInternet(any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();

      // Verifikasi `updateCustomer` tidak dipanggil
      verifyNever(() => mockCustomerOpFirebase.updateCustomer(any()));
      // Verifikasi tidak ada navigasi pop
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });

    testWidgets('Test 08: Tangani error saat gagal menyimpan perubahan',
        (tester) async {
      final exception = Exception('Update failed');
      final pageState = tester.state<ConsumerState<EditProfilePage>>(
          find.byType(EditProfilePage)) as dynamic;
      pageState._internetConnectionService = mockKoneksiInternetService;

      when(() => mockKoneksiInternetService.cekInternet(any()))
          .thenAnswer((_) async => true);
      when(() => mockCustomerOpFirebase.updateCustomer(any()))
          .thenThrow(exception);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('SIMPAN'));
      await tester.pumpAndSettle();

      // Verifikasi `updateCustomer` dipanggil
      verify(() => mockCustomerOpFirebase.updateCustomer(any())).called(1);

      // Verifikasi tidak ada navigasi pop
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });

    testWidgets('Test 09: Pastikan controllers di-dispose', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final state =
          tester.state(find.byType(EditProfilePage)) as _EditProfilePageState;

      // Ambil controller sebelum di-dispose
      final nameController = state._nameController;
      final phoneController = state._phoneController;
      final passwordController = state._passwordController;

      // Dispose widget
      await tester.pumpWidget(Container());

      // Cek apakah controller sudah di-dispose (akan melempar error jika diakses)
      expect(() => nameController.text, throwsA(isA<FlutterError>()));
      expect(() => phoneController.text, throwsA(isA<FlutterError>()));
      expect(() => passwordController.text, throwsA(isA<FlutterError>()));
    });
  });
}
