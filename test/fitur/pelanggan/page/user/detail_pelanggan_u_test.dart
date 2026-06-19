// path: test/fitur/pelanggan/page/user/detail_pelanggan_u_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan_u.dart';
import 'package:wifi/fitur/pelanggan/widget/detail_pelanggan_ui.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_firebase.dart';
import 'package:wifi/user/providers/ad_providers.dart';
import 'package:wifi/user/services/interstitial_ad_service.dart';

import 'detail_pelanggan_u_test.mocks.dart';

@GenerateMocks([
  PelangganOpFirebase,
  TransaksiOpFirebase,
  InterstitialAdService,
])
void main() {
  late MockPelangganOpFirebase mockPelangganOp;
  late MockTransaksiOpFirebase mockTransaksiOp;
  late MockInterstitialAdService mockInterstitialAd;

  final mockPelanggan = PelangganModel(
    id: 'user123',
    nama: 'Pelanggan Uji',
    telepon: '089876543210',
    alamat: 'Jalan Uji Coba No. 1',
    kataSandi: 'password',
    macAddress: 'AA:BB:CC:DD:EE:FF',
  );

  setUp(() {
    mockPelangganOp = MockPelangganOpFirebase();
    mockTransaksiOp = MockTransaksiOpFirebase();
    mockInterstitialAd = MockInterstitialAdService();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        pelangganOpFirebaseProvider.overrideWithValue(mockPelangganOp),
        transaksiOpFirebaseProvider.overrideWithValue(mockTransaksiOp),
        interstitialAdServiceProvider.overrideWithValue(mockInterstitialAd),
      ],
      child: const MaterialApp(
        home: DetailPelangganU(userId: 'user123'),
      ),
    );
  }

  group('DetailPelangganU Widget Tests', () {
    testWidgets('01. harus menampilkan loading indicator saat data dimuat',
        (tester) async {
      // Arrange
      when(mockPelangganOp.ambilBerdasarkanId('user123'))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return mockPelanggan;
      });
      when(mockTransaksiOp.ambilTotalPoin('user123')).thenAnswer((_) async => 150);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Memuat Profil...'), findsOneWidget);

      // Fast-forward time
      await tester.pumpAndSettle();
    });

    testWidgets('02. harus menampilkan pesan error jika data gagal dimuat',
        (tester) async {
      // Arrange
      final exception = Exception('Firestore error');
      when(mockPelangganOp.ambilBerdasarkanId('user123')).thenThrow(exception);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Tunggu future selesai

      // Assert
      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Gagal memuat data'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan DetailPelangganUI saat data berhasil dimuat',
        (tester) async {
      // Arrange
      when(mockPelangganOp.ambilBerdasarkanId('user123'))
          .thenAnswer((_) async => mockPelanggan);
      when(mockTransaksiOp.ambilTotalPoin('user123')).thenAnswer((_) async => 150);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DetailPelangganUI), findsOneWidget);
      expect(find.text('Pelanggan Uji'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('04. harus menavigasi ke halaman edit dan menampilkan iklan',
        (tester) async {
      // Arrange
      when(mockPelangganOp.ambilBerdasarkanId('user123'))
          .thenAnswer((_) async => mockPelanggan);
      when(mockTransaksiOp.ambilTotalPoin('user123')).thenAnswer((_) async => 150);
      when(mockInterstitialAd.show()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      // IconButton edit ada di dalam DetailPelangganUI
      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Assert
      verify(mockInterstitialAd.show()).called(2); // Sebelum dan sesudah push
    });
  });
}
