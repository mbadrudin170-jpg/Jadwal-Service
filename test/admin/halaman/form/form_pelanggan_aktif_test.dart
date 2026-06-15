// path: test/admin/halaman/form/form_pelanggan_aktif_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/form/form_pelanggan_aktif.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan_aktif/model/pelanggan_aktif_model.dart';
import 'package:wifi/fitur/dompet/model/dompet_model.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/fitur/pelanggan/operasi/pelanggan_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/dompet_op_sqlite.dart';
import 'package:wifi/fitur/kategori/operasi/kategori_op_sqlite.dart';
import 'package:wifi/fitur/pelanggan_aktif/operasi/pelanggan_aktif_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/notifikasi_op_sqlite.dart';

// Mocks
class MockPelangganOpSqlite extends Mock implements PelangganOpSqlite {}

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

class MockTransaksiOpsqlite extends Mock implements TransactionOperation {}

class MockDompetOpSqlite extends Mock implements DompetOpSqlite {}

class MockKategoriOpSqlite extends Mock implements KategoriOpSqlite {}

class MockPelangganAktifOpSqlite extends Mock
    implements PelangganAktifOpSqlite {}

class MockNotifikasiOpSqlite extends Mock implements NotifikasiOpSqlite {}

void main() {
  late MockPelangganOpSqlite mockPelangganOpSqlite;
  late MockPaketOpSqlite mockPaketOpSqlite;
  late MockTransaksiOpsqlite mockTransaksiOpsqlite;
  late MockDompetOpSqlite mockDompetOpSqlite;
  late MockKategoriOpSqlite mockKategoriOpSqlite;
  late MockPelangganAktifOpSqlite mockPelangganAktifOpSqlite;
  late MockNotifikasiOpSqlite mockNotifikasiOpSqlite;

  setUp(() {
    mockPelangganOpSqlite = MockPelangganOpSqlite();
    mockPaketOpSqlite = MockPaketOpSqlite();
    mockTransaksiOpsqlite = MockTransaksiOpsqlite();
    mockDompetOpSqlite = MockDompetOpSqlite();
    mockKategoriOpSqlite = MockKategoriOpSqlite();
    mockPelangganAktifOpSqlite = MockPelangganAktifOpSqlite();
    mockNotifikasiOpSqlite = MockNotifikasiOpSqlite();
  });

  Widget createWidgetUnderTest({PelangganAktifModel? activeCustomer}) {
    return ProviderScope(
      overrides: [
        pelangganOpSqliteProvider.overrideWithValue(mockPelangganOpSqlite),
        paketOpSqliteProvider.overrideWithValue(mockPaketOpSqlite),
        transaksiOpSqliteProvider.overrideWithValue(mockTransaksiOpsqlite),
        dompetOpSqliteProvider.overrideWithValue(mockDompetOpSqlite),
        kategoriOpSqliteProvider.overrideWithValue(mockKategoriOpSqlite),
        pelangganAktifOpSqliteProvider
            .overrideWithValue(mockPelangganAktifOpSqlite),
        notifikasiOpSqliteProvider.overrideWithValue(mockNotifikasiOpSqlite),
      ],
      child: MaterialApp(
        home: FormPelangganAktif(pelangganAktif: activeCustomer),
      ),
    );
  }

  testWidgets('01. should show loading indicator and then the form',
      (tester) async {
    when(() => mockPelangganOpSqlite.ambilSemuaPelanggan())
        .thenAnswer((_) async => <PelangganModel>[]);
    when(() => mockPaketOpSqlite.ambilSemuaPaket())
        .thenAnswer((_) async => <PaketModel>[]);
    when(() => mockDompetOpSqlite.ambilSemuaDompet())
        .thenAnswer((_) async => <DompetModel>[]);
    when(() => mockKategoriOpSqlite.ambilSemuaKategori())
        .thenAnswer((_) async => <KategoriModel>[]);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(Form), findsOneWidget);
  });
}
