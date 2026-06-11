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

// Mocks
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

    // Stubbing default behaviors
    when(() => mockInternetConnectionService.checkLocalConnection())
        .thenAnswer((_) async => true);
    // Stub pemanggilan login
    when(() => mockPengelolaAkun.login(any())).thenAnswer((_) async {});
    when(() => mockLayananPenyimpananLokal.ambilDaftarAkun())
        .thenAnswer((_) async => []);
    when(() => mockUserActivityService.pingActivity(any(),
        force: any(named: 'force'))).thenAnswer((_) async {});
  });

  // Helper untuk membuat widget dalam ProviderScope dengan override
  Widget createTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        internetConnectionServiceProvider
            .overrideWithValue(mockInternetConnectionService),
        pengelolaAkunProvider.overrideWith(() => mockPengelolaAkun),
        firestoreProvider.overrideWithValue(fakeFirestore),
        userActivityServiceProvider
        
            .overrideWithValue(AsyncValue.data(mockUserActivityService)),
        localStorageServiceProvider
            .overrideWithValue(AsyncValue.data(mockLayananPenyimpananLokal)),
      ],
      child: MaterialApp(
        home: child,
        // Sediakan route untuk navigasi
        routes: {
          '/main': (context) => const MainPage(),
        },
      ),
    );
  }

  group('Pengujian Halaman Login', () {
    testWidgets('1. Tampilan Awal Halaman Login', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      expect(find.text('Silakan Masuk'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Nomor Telepon'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
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
          find.widgetWithText(TextFormField, 'Nomor Telepon'), 'salah');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'salah');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Akun tidak ditemukan'), findsOneWidget);
      expect(find.text('Nomor telepon atau password yang Anda masukkan salah.'),
          findsOneWidget);
    });

    testWidgets('4. Login Berhasil', (tester) async {
      // Siapkan data palsu di FakeFirestore
      final customerData = {
        ColumnNames.id: 'customer123',
        ColumnNames.name: 'Pengguna Sukses',
        ColumnNames.phone: '08123456789',
        ColumnNames.password: 'password123',
        ColumnNames.address: 'Jalan Sukses No. 1',
        ColumnNames.isDeleted: false,
        ColumnNames.createdAt: DateTime.now().toIso8601String(),
        ColumnNames.lastActiveAt: DateTime.now().toIso8601String(),
        // Sesuaikan dengan semua field yang dibutuhkan oleh fromFirebase
        'latitude': 0.0,
        'longitude': 0.0,
        'email': 'test@example.com',
        'registrationDate': DateTime.now().toIso8601String(),
        'status': 'Aktif',
        'notes': '',
        'ktpImageUrl': '',
        'houseImageUrl': '',
        'subscriptionEndDate': null,
        'point': 0,
        'updatedAt': DateTime.now().toIso8601String(),
        'createdBy': '',
        'updatedBy': '',
      };

      await fakeFirestore
          .collection(TableNameValue.get(TableName.customer))
          .doc('customer123')
          .set(customerData);

      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      // Masukkan data yang benar
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nomor Telepon'), '08123456789');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');

      // Tekan tombol login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));

      // pumpAndSettle untuk menunggu semua proses selesai (termasuk navigasi)
      await tester.pumpAndSettle();

      // Verifikasi bahwa login dipanggil SATU KALI
      verify(() => mockPengelolaAkun.login(any(that: isA<CustomerModel>()))).called(1);

      // Verifikasi bahwa halaman utama ditampilkan
      expect(find.byType(MainPage), findsOneWidget,
          reason: 'Seharusnya navigasi ke MainPage setelah login berhasil');
    });

    testWidgets('5. Visibilitas Password', (tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final textField =
          find.descendant(of: passwordField, matching: find.byType(TextField));

      // Awalnya password tidak terlihat
      expect(tester.widget<TextField>(textField).obscureText, isTrue);

      // Klik ikon untuk menampilkan password
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Password seharusnya terlihat
      expect(tester.widget<TextField>(textField).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Klik ikon untuk menyembunyikan password kembali
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Password seharusnya tidak terlihat lagi
      expect(tester.widget<TextField>(textField).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
