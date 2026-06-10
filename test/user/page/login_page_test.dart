// path: test/user/page/login_page_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/akun/provider/akun_provider.dart';
import 'package:wifi/fitur/pelanggan/core/user_activity_service.dart';
import 'package:wifi/fitur/pelanggan/model/customer_model.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/providers/shared_providers.dart';
import 'package:wifi/shared/services/internet_connection_check.dart';
import 'package:wifi/user/page/login_page.dart';
import 'package:wifi/user/page/main_page.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/services/storage/layanan_penyimpanan_lokal.dart';

// Mock classes
class MockInternetConnectionService extends Mock
    implements InternetConnectionService {}

class MockPengelolaAkun extends Mock implements PengelolaAkun {}

class MockUserActivityService extends Mock implements UserActivityService {}

class MockLayananPenyimpananLokal extends Mock
    implements LayananPenyimpananLokal {}

class FakeCustomerModel extends Fake implements CustomerModel {}

void main() {
  late MockInternetConnectionService mockInternetConnectionService;
  late MockPengelolaAkun mockPengelolaAkun;
  late FakeFirebaseFirestore fakeFirestore;
  late MockUserActivityService mockUserActivityService;
  late MockLayananPenyimpananLokal mockLayananPenyimpananLokal;

  setUpAll(() {
    registerFallbackValue(FakeCustomerModel());
  });

  setUp(() {
    mockInternetConnectionService = MockInternetConnectionService();
    mockPengelolaAkun = MockPengelolaAkun();
    fakeFirestore = FakeFirebaseFirestore();
    mockUserActivityService = MockUserActivityService();
    mockLayananPenyimpananLokal = MockLayananPenyimpananLokal();

    when(() => mockInternetConnectionService.checkLocalConnection())
        .thenAnswer((_) async => true);
    when(() => mockPengelolaAkun.login(any())).thenAnswer((_) async {});
    when(() => mockUserActivityService.pingActivity(any(),
        force: any(named: 'force'))).thenAnswer((_) async {});
    when(() => mockLayananPenyimpananLokal.ambilDaftarAkun())
        .thenAnswer((_) async => []);
    when(() => mockPengelolaAkun.build())
        .thenAnswer((_) async => const AkunState());
  });

  Widget createTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        internetConnectionServiceProvider
            .overrideWithValue(mockInternetConnectionService),
        pengelolaAkunProvider.overrideWith((ref) => mockPengelolaAkun),
        firestoreProvider.overrideWithValue(fakeFirestore),
        userActivityServiceProvider
            .overrideWithValue(AsyncValue.data(mockUserActivityService)),
        localStorageServiceProvider
            .overrideWithValue(AsyncValue.data(mockLayananPenyimpananLokal)),
      ],
      child: MaterialApp(
        home: child,
        routes: {
          '/main': (_) => const MainPage(),
        },
      ),
    );
  }

  group('Pengujian Halaman Login', () {
    testWidgets('1. Tampilan Awal Halaman Login', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      expect(find.text('Silakan Masuk'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nomor Telepon'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Pilih dari Akun Tersimpan'),
          findsOneWidget);
      expect(find.text('Lupa Sandi?'), findsOneWidget);
    });

    testWidgets('2. Login Gagal - Form Kosong', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Akun tidak ditemukan'), findsOneWidget);
      expect(find.text('Nomor telepon dan password tidak boleh kosong.'),
          findsOneWidget);
    });

    testWidgets('3. Login Gagal - Akun Tidak Ditemukan', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Telepon'), '12345');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Akun tidak ditemukan'), findsOneWidget);
      expect(find.text('Nomor telepon atau password yang Anda masukkan salah.'),
          findsOneWidget);
    });

    testWidgets('4. Login Berhasil', (tester) async {
      final customerData = {
        ColumnNames.name: 'John Doe',
        ColumnNames.phone: '081234567890',
        ColumnNames.password: 'password123',
        ColumnNames.address: 'Some Address',
        ColumnNames.isDeleted: false,
      };

      await fakeFirestore
          .collection(TableNameValue.get(TableName.customer))
          .add(customerData);

      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Telepon'), '081234567890');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));

      await tester.pumpAndSettle();

      verify(() => mockPengelolaAkun.login(any(that: isA<CustomerModel>()))) .called(1);

      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('5. Visibilitas Password', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final textField =
          find.descendant(of: passwordField, matching: find.byType(TextField));

      expect(tester.widget<TextField>(textField).obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(tester.widget<TextField>(textField).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(tester.widget<TextField>(textField).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
