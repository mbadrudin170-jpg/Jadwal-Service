// // path: test/user/page/daftar_akun_page_test.dart
// // Fitur: Pengujian Halaman Daftar Akun
// // Tujuan: Memastikan semua fungsionalitas di halaman daftar akun berjalan sesuai harapan.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wifi/shared/model/pelanggan_model.dart';
// import 'package:wifi/user/page/daftar_akun_page.dart';
// import 'package:wifi/user/services/storage/local_storage_service.dart';

// // 1. Anotasi untuk menghasilkan file mock
// @GenerateMocks([LocalStorageService])
// import 'daftar_akun_page_test.mocks.dart';

// void main() {
//   // 2. Siapkan instance mock
//   late MockLocalStorageService mockLocalStorageService;
//   late PelangganModel testPelanggan1;
//   late PelangganModel testPelanggan2;

//   setUp(() {
//     // Inisialisasi mock dan data dummy sebelum setiap test
//     mockLocalStorageService = MockLocalStorageService();
//     testPelanggan1 = PelangganModel(id: '1', nama: 'User Satu', email: 'user1@mail.com');
//     testPelanggan2 = PelangganModel(id: '2', nama: 'User Dua', email: 'user2@mail.com');

//     // Atur nilai default untuk SharedPreferences
//     SharedPreferences.setMockInitialValues({});
//   });

//   // Fungsi pembantu untuk membangun widget
//   Future<void> pumpWidget(WidgetTester tester) async {
//     await tester.pumpWidget(
//       MaterialApp(
//         home: DaftarAkunPage(
//           localStorageService: mockLocalStorageService,
//           mainPageBuilder: (userId, service) => Scaffold(
//             body: Center(child: Text('Main Page for $userId')),
//           ),
//         ),
//       ),
//     );
//   }

//   group('Pengujian Halaman Daftar Akun', () {
//     testWidgets('Harus menampilkan daftar akun saat data tersedia', (WidgetTester tester) async {
//       // 3. Atur perilaku mock
//       // Saat `ambilDaftarAkun` dipanggil, kembalikan daftar pelanggan dummy
//       when(mockLocalStorageService.ambilDaftarAkun())
//           .thenAnswer((_) async => [testPelanggan1, testPelanggan2]);

//       // 4. Bangun widget
//       await pumpWidget(tester);

//       // Tunggu widget selesai rendering
//       await tester.pumpAndSettle();

//       // 5. Verifikasi hasil
//       // Harapannya, ada dua ListTile yang muncul, masing-masing dengan nama pelanggan
//       expect(find.text('User Satu'), findsOneWidget);
//       expect(find.text('User Dua'), findsOneWidget);
//       expect(find.byType(ListTile), findsNWidgets(2));
//     });

//     testWidgets('Harus menampilkan pesan saat tidak ada riwayat login', (WidgetTester tester) async {
//       // Atur mock untuk mengembalikan list kosong
//       when(mockLocalStorageService.ambilDaftarAkun()).thenAnswer((_) async => []);

//       await pumpWidget(tester);
//       await tester.pumpAndSettle();

//       // Verifikasi bahwa pesan yang benar ditampilkan
//       expect(find.text('Belum ada riwayat login di perangkat ini.'), findsOneWidget);
//       expect(find.byType(ListTile), findsNothing);
//     });

//     testWidgets('Harus menavigasi ke halaman utama saat akun dipilih', (WidgetTester tester) async {
//       // Atur mock untuk daftar akun dan simpan akun
//       when(mockLocalStorageService.ambilDaftarAkun()).thenAnswer((_) async => [testPelanggan1]);
//       when(mockLocalStorageService.simpanAkun(any)).thenAnswer((_) async {});

//       await pumpWidget(tester);
//       await tester.pumpAndSettle();

//       // Tap pada akun pertama
//       await tester.tap(find.text('User Satu'));
//       await tester.pumpAndSettle(); // Tunggu transisi navigasi selesai

//       // Verifikasi bahwa kita sudah berada di halaman utama
//       expect(find.text('Main Page for 1'), findsOneWidget);
//     });
//   });
// }
