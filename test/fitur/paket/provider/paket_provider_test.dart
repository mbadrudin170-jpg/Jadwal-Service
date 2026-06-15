
// path: test/fitur/paket/provider/paket_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/lainnya/paket.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/model/paket_model.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/fitur/paket/provider/paket_provider.dart';

class MockPaketOpSqlite extends Mock implements PaketOpSqlite {}

void main() {
  late MockPaketOpSqlite mockPaketOpSqlite;
  late ProviderContainer container;

  final tPaket1 = PaketModel(
    id: '1',
    name: 'Paket 1',
    harga: 10000,
    durasi: 30,
    isActive: true,
  );
  final tPaket2 = PaketModel(
    id: '2',
    name: 'Paket 2',
    harga: 20000,
    durasi: 60,
    isActive: true,
  );

  setUp(() {
    mockPaketOpSqlite = MockPaketOpSqlite();
    container = ProviderContainer(
      overrides: [
        paketOpSqliteProvider.overrideWithValue(mockPaketOpSqlite),
      ],
    );
  });

  group('daftarPaket Provider', () {
    test('01. harus mengembalikan daftar paket aktif', () async {
      when(() => mockPaketOpSqlite.ambilBerdasarkanAktif())
          .thenAnswer((_) async => [tPaket1, tPaket2]);

      final result = await container.read(daftarPaketProvider.future);

      expect(result, [tPaket1, tPaket2]);
      verify(() => mockPaketOpSqlite.ambilBerdasarkanAktif()).called(1);
    });
  });

  group('UrutanPaketState Provider', () {
    test('02. harus memiliki nilai awal durasiTerpendek', () {
      final result = container.read(urutanPaketStateProvider);
      expect(result, UrutanPaket.durasiTerpendek);
    });

    test('03. harus dapat mengubah urutan', () {
      container
          .read(urutanPaketStateProvider.notifier)
          .ubahUrutan(UrutanPaket.hargaTertinggi);
      final result = container.read(urutanPaketStateProvider);
      expect(result, UrutanPaket.hargaTertinggi);
    });
  });
}
