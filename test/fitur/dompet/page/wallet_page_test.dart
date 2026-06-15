// path: test/fitur/dompet/page/wallet_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/dompet/page/dompet_page.dart';
import 'package:wifi/fitur/dompet/provider/dompet_provider.dart';
import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/widget/financial_summary_widget.dart';

// Mocking Dompet notifier dan state
class MockDompet extends AutoDisposeAsyncNotifier<DompetState>
    with Mock
    implements Dompet {}

void main() {
  late ProviderContainer container;
  late List<DompetModel> dummyWallets;
  late DompetState dummyState;

  setUp(() {
    dummyWallets = [
      DompetModel(id: '1', nama: 'Dompet Utama', saldo: 100000),
      DompetModel(id: '2', nama: 'Dompet Cadangan', saldo: -50000),
    ];

    dummyState = DompetState(
      wallets: dummyWallets,
      totalSaldoPositif: 100000,
      totalSaldoNegatif: 50000,
      totalSaldo: 50000,
    );
  });

  // Helper untuk membuat ProviderContainer dengan override yang diperlukan
  ProviderContainer createContainer(AsyncValue<DompetState> state) {
    return ProviderContainer(overrides: [
      dompetProvider.overrideWith((ref) => state),
    ]);
  }

  testWidgets('01. Menampilkan indikator loading saat provider loading',
      (tester) async {
    container = createContainer(const AsyncValue.loading());

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(home: DompetPage()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('02. Menampilkan pesan error saat provider error', (tester) async {
    final error = Exception('Gagal memuat');
    container = createContainer(AsyncValue.error(error, StackTrace.current));

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(home: DompetPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Terjadi kesalahan: Exception: Gagal memuat'),
        findsOneWidget);
  });

  testWidgets(
      '03. Menampilkan pesan "Tidak ada dompet ditemukan" saat data kosong',
      (tester) async {
    final emptyState = DompetState(
      wallets: const [],
      totalSaldoPositif: 0,
      totalSaldoNegatif: 0,
      totalSaldo: 0,
    );
    container = createContainer(AsyncValue.data(emptyState));

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(home: DompetPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada dompet ditemukan.'), findsOneWidget);
  });

  testWidgets('04. Menampilkan daftar dompet dengan benar saat ada data',
      (tester) async {
    container = createContainer(AsyncValue.data(dummyState));

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(home: DompetPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FinancialSummaryWidget), findsOneWidget);
    expect(find.byType(WalletCard), findsNWidgets(2));
    expect(find.text('Dompet Utama'), findsOneWidget);
    expect(find.text('Dompet Cadangan'), findsOneWidget);
  });

  testWidgets('05. Tap pada WalletCard menavigasi ke halaman detail',
      (tester) async {
    container = createContainer(AsyncValue.data(dummyState));
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(home: const DompetPage(), observers: [mockObserver]),
      ),
    );
    await tester.pumpAndSettle();

    final walletCard = find.byType(WalletCard).first;
    await tester.tap(walletCard);
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any()));
  });

  testWidgets('06. Long press pada WalletCard menampilkan dialog arsip',
      (tester) async {
    container = createContainer(AsyncValue.data(dummyState));

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(home: DompetPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(WalletCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Arsip'), findsOneWidget);
    expect(find.textContaining('arsipkan dompet "Dompet Utama"'),
        findsOneWidget);
  });

  testWidgets('07. Tombol hapus semua di AppBar menampilkan dialog konfirmasi',
      (tester) async {
    container = createContainer(AsyncValue.data(dummyState));

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(home: DompetPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AppIcons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi'), findsOneWidget);
    expect(
        find.text(
            'Apakah Anda yakin ingin menghapus semua dompet? Aksi ini tidak dapat diurungkan.'),
        findsOneWidget);
  });

  testWidgets('08. Tombol FAB menavigasi ke halaman form tambah dompet',
      (tester) async {
    container = createContainer(AsyncValue.data(dummyState));
    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(home: const DompetPage(), observers: [mockObserver]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any()));
  });
}

// Mock untuk NavigatorObserver
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
