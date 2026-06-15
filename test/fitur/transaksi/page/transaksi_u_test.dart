
// path: test/fitur/transaksi/page/transaksi_u_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/page/detail_transaksi_u.dart';
import 'package:wifi/fitur/transaksi/page/transaksi_u.dart';
import 'package:wifi/shared/operasi/firebase_operasi/customer_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/paeket_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/transaksi_op_firebase.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/providers/user_providers.dart';
import 'package:wifi/user/widget/ads/interstitial/interstitial_ad_service.dart';

// Mocks
class MockCustomerOpFirebase extends Mock implements CustomerOpFirebase {}
class MockPaketOpFirebase extends Mock implements PaketOpFirebase {}
class MockTransaksiOpFirebase extends Mock implements TransaksiOpFirebase {}
class MockInterstitialAdService extends Mock implements InterstitialAdService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  // Data Mocks
  final mockUser = PelangganModel(id: 'user1', nama: 'User Test');
  final mockTx1 = TransaksiModel(
      id: 'tx1',
      idPelanggan: 'user1',
      deskripsi: 'Lunas, berakhir nanti',
      tanggalBerakhir: DateTime.now().add(const Duration(days: 5)),
      statusPembayaran: StatusPembayaran.paid);
  final mockTx2 = TransaksiModel(
      id: 'tx2',
      idPelanggan: 'user1',
      deskripsi: 'Belum lunas, berakhir dulu',
      tanggalBerakhir: DateTime.now().subtract(const Duration(days: 5)),
      statusPembayaran: StatusPembayaran.unpaid);

  late MockCustomerOpFirebase mockCustomerOp;
  late MockPaketOpFirebase mockPaketOp;
  late MockTransaksiOpFirebase mockTransaksiOp;
  late MockInterstitialAdService mockAdService;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  setUp(() {
    mockCustomerOp = MockCustomerOpFirebase();
    mockPaketOp = MockPaketOpFirebase();
    mockTransaksiOp = MockTransaksiOpFirebase();
    mockAdService = MockInterstitialAdService();
    mockNavigatorObserver = MockNavigatorObserver();

    when(() => mockCustomerOp.getById(any())).thenAnswer((_) async => mockUser);
    when(() => mockCustomerOp.getStreamPelanggan(any())).thenAnswer((_) => Stream.value(mockUser));
    when(() => mockTransaksiOp.ambilBerdasarkanIdPelanggan(any())).thenAnswer((_) async => [mockTx1, mockTx2]);
    when(() => mockAdService.show()).thenAnswer((_) async {});
    when(() => mockPaketOp.ambilBerdasarkanId(any())).thenAnswer((_) async => PaketModel(id: 'p1', nama: 'Paket'));

    container = ProviderContainer(
      overrides: [
        userIdProvider.overrideWith((ref) => Future.value('user1')),
        pelangganOpFirebaseProvider.overrideWithValue(mockCustomerOp),
        paketOpFirebaseProvider.overrideWithValue(mockPaketOp),
        interstitialAdServiceProvider.overrideWithValue(mockAdService),
      ],
    );
  });

   Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: const TransaksiU(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('Rendering State', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat memuat pelanggan', (tester) async {
      final completer = Completer<PelangganModel?>();
      when(() => mockCustomerOp.getStreamPelanggan(any())).thenAnswer((_) => completer.stream);
      
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      completer.complete(mockUser);
      await tester.pumpAndSettle();
    });

    testWidgets('03. harus menampilkan "Data pelanggan tidak ditemukan." jika tidak ada pelanggan', (tester) async {
      when(() => mockCustomerOp.getStreamPelanggan(any())).thenAnswer((_) => Stream.value(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.text('Data pelanggan tidak ditemukan.'), findsOneWidget);
    });

    testWidgets('05. harus menampilkan "Tidak ada riwayat." jika transaksi kosong', (tester) async {
       when(() => mockTransaksiOp.ambilBerdasarkanIdPelanggan(any())).thenAnswer((_) async => []);
       await tester.pumpWidget(createWidgetUnderTest());
       await tester.pumpAndSettle();
       expect(find.text('Tidak ada riwayat.'), findsOneWidget);
    });
  });

  group('Fungsionalitas Pengurutan', () {
     testWidgets('07. harus menampilkan PopupMenuButton untuk pengurutan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('08. harus mengurutkan berdasarkan "Tanggal Berakhir (Terbaru)" secara default', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      final listTiles = tester.widgetList<Card>(find.byType(Card));
      final firstKey = listTiles.first.key as ValueKey<String>;
      expect(firstKey.value, 'tx1'); // Berakhir nanti
    });

    testWidgets('09. harus mengurutkan ulang saat "Tanggal Berakhir (Terlama)" dipilih', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tanggal Berakhir (Terlama)'));
      await tester.pumpAndSettle();

      final listTiles = tester.widgetList<Card>(find.byType(Card));
      final firstKey = listTiles.first.key as ValueKey<String>;
      expect(firstKey.value, 'tx2'); // Berakhir dulu
    });
  });

  group('Interaksi & Navigasi', () {
    testWidgets('12. harus navigasi ke DetailTransaksiU saat item di-tap', (tester) async {
      when(() => mockNavigatorObserver.didPush(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tx1')));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPush(any(that: isA<MaterialPageRoute>()), any()));
      expect(find.byType(DetailTransaksiU), findsOneWidget);
    });

    testWidgets('13. harus menampilkan iklan sebelum dan sesudah navigasi ke detail', (tester) async {
      when(() => mockNavigatorObserver.didPush(any(), any())).thenAnswer((invocation) {
          final route = invocation.positionalArguments[0] as MaterialPageRoute;
          Future.delayed(Duration.zero, () => route.navigator?.pop());
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tx1')));
      await tester.pumpAndSettle();

      verify(() => mockAdService.show()).called(2);
    });
  });
}

