// path: test/fitur/dompet/page/wallet_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/dompet/page/dompet_page.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/shared/model/dompet_model.dart';

// Mock kelas yang diperlukan
class MockWalletNotifier extends Mock implements WalletNotifier {}

class FakeWalletState extends Fake implements DompetState {
  @override
  final List<DompetModel> wallets;
  @override
  final double totalSaldoPositif;
  @override
  final double totalSaldoNegatif;
  @override
  final double totalSaldo;

  FakeWalletState({
    required this.wallets,
    required this.totalSaldoPositif,
    required this.totalSaldoNegatif,
    required this.totalSaldo,
  });
}

void main() {
  late ProviderContainer container;
  late List<DompetModel> dummyWallets;

  setUp(() {
    registerFallbackValue(FakeWalletState(
      wallets: [],
      totalSaldoPositif: 0,
      totalSaldoNegatif: 0,
      totalSaldo: 0,
    ));
    dummyWallets = [
      DompetModel(id: '1', name: 'Dompet Utama', balance: 100000),
      DompetModel(id: '2', name: 'Dompet Cadangan', balance: -50000),
    ];
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('WalletPage', () {
    testWidgets('1. Menampilkan indikator loading saat provider loading',
        (tester) async {
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith(
            (ref) => AsyncValue<List<DompetModel>>.loading(),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('2. Menampilkan pesan error saat provider error',
        (tester) async {
      final errorMessage = 'Gagal memuat data';
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith(
            (ref) => AsyncValue.error(errorMessage, StackTrace.current),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      expect(find.textContaining(errorMessage), findsOneWidget);
    });

    testWidgets(
        '3. Menampilkan pesan "Tidak ada dompet ditemukan" saat data kosong',
        (tester) async {
      final emptyState = AsyncValue.data(DompetState(
        wallets: [],
        totalSaldoPositif: 0,
        totalSaldoNegatif: 0,
        totalSaldo: 0,
      ));
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith((ref) => emptyState),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      expect(find.text('Tidak ada dompet ditemukan.'), findsOneWidget);
    });

    testWidgets('4. Menampilkan daftar dompet dengan benar saat ada data',
        (tester) async {
      final walletState = DompetState(
        wallets: dummyWallets,
        totalSaldoPositif: 100000,
        totalSaldoNegatif: -50000,
        totalSaldo: 50000,
      );
      final dataState = AsyncValue.data(walletState);
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith((ref) => dataState),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      expect(find.byType(FinancialSummaryWidget), findsOneWidget);
      expect(find.byType(WalletCard), findsNWidgets(2));
      expect(find.text('Dompet Utama'), findsOneWidget);
      expect(find.text('Dompet Cadangan'), findsOneWidget);
    });

    testWidgets('5. Tap pada WalletCard menavigasi ke halaman detail',
        (tester) async {
      final walletState = DompetState(
        wallets: dummyWallets,
        totalSaldoPositif: 100000,
        totalSaldoNegatif: -50000,
        totalSaldo: 50000,
      );
      final dataState = AsyncValue.data(walletState);
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith((ref) => dataState),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      final walletCard = find.byWidgetPredicate(
        (widget) => widget is WalletCard && widget.wallet.id == '1',
      );
      await tester.tap(walletCard);
      await tester.pumpAndSettle();
      // Test tidak error
    });

    testWidgets('6. Long press pada WalletCard menampilkan dialog arsip',
        (tester) async {
      final walletState = DompetState(
        wallets: dummyWallets,
        totalSaldoPositif: 100000,
        totalSaldoNegatif: -50000,
        totalSaldo: 50000,
      );
      final dataState = AsyncValue.data(walletState);
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith((ref) => dataState),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      final walletCard = find.byWidgetPredicate(
        (widget) => widget is WalletCard && widget.wallet.id == '1',
      );
      await tester.longPress(walletCard);
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi Arsip'), findsOneWidget);
      expect(find.textContaining('arsipkan dompet "Dompet Utama"'),
          findsOneWidget);
    });

    testWidgets('7. Tombol hapus semua di AppBar menampilkan dialog konfirmasi',
        (tester) async {
      final walletState = DompetState(
        wallets: dummyWallets,
        totalSaldoPositif: 100000,
        totalSaldoNegatif: -50000,
        totalSaldo: 50000,
      );
      final dataState = AsyncValue.data(walletState);
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith((ref) => dataState),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      final deleteButton = find.byIcon(TIcons.delete);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('Konfirmasi'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin menghapus semua dompet?'),
          findsOneWidget);
    });

    testWidgets('8. Tombol FAB menavigasi ke halaman form tambah dompet',
        (tester) async {
      final walletState = DompetState(
        wallets: dummyWallets,
        totalSaldoPositif: 100000,
        totalSaldoNegatif: -50000,
        totalSaldo: 50000,
      );
      final dataState = AsyncValue.data(walletState);
      container = ProviderContainer(
        overrides: [
          walletProvider.overrideWith((ref) => dataState),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            parent: container,
            child: const DompetPage(),
          ),
        ),
      );
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();
    });
  });

  group('WalletCard', () {
    testWidgets(
        '9. WalletCard menampilkan nama dan saldo dengan format mata uang',
        (tester) async {
      final wallet = DompetModel(id: '1', name: 'Dompet Test', balance: 75000);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );
      expect(find.text('Dompet Test'), findsOneWidget);
      expect(find.textContaining('Rp 75.000'), findsOneWidget);
    });

    testWidgets('10. Saldo negatif menggunakan warna error', (tester) async {
      final wallet =
          DompetModel(id: '1', name: 'Dompet Utang', balance: -25000);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.textContaining('Rp -25.000'));
      expect(
          textWidget.style?.color, equals(ThemeData.light().colorScheme.error));
    });

    testWidgets('11. WalletCard memanggil onTap saat diklik', (tester) async {
      bool tapped = false;
      final wallet = DompetModel(id: '1', name: 'Dompet Test', balance: 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              onTap: () => tapped = true,
              onLongPress: () {},
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WalletCard));
      expect(tapped, true);
    });

    testWidgets('12. WalletCard memanggil onLongPress saat long press',
        (tester) async {
      bool longPressed = false;
      final wallet = DompetModel(id: '1', name: 'Dompet Test', balance: 0);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalletCard(
              wallet: wallet,
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );
      await tester.longPress(find.byType(WalletCard));
      expect(longPressed, true);
    });
  });
}
