
// path: test/fitur/database/provider/operasi_sqlite_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';
import 'package:wifi/shared/services/notifikasi/notifikasi_service.dart';
import 'package:wifi/shared/providers/shared_providers.dart';


class MockDatabase extends Mock implements Database {}
class MockBaseOpSqlite extends Mock implements BaseOpSqlite {}
class MockNotifikasiService extends Mock implements LayananNotifikasi {}

void main() {
  group('Operation Providers', () {
    late ProviderContainer container;
    late MockDatabase mockDatabase;
    late MockBaseOpSqlite mockBaseOpSqlite;
    late MockNotifikasiService mockNotifikasiService;

    setUp(() {
      mockDatabase = MockDatabase();
      mockBaseOpSqlite = MockBaseOpSqlite();
      mockNotifikasiService = MockNotifikasiService();

      container = ProviderContainer(
        overrides: [
          sqliteDatabaseProvider.overrideWithValue(mockDatabase),
          baseOpSqliteProvider.overrideWithValue(mockBaseOpSqlite),
          layananNotifikasiProvider.overrideWithValue(mockNotifikasiService),
        ],
      );
    });

    test('01. paketOpSqliteProvider should return PaketOpSqlite', () {
      final result = container.read(paketOpSqliteProvider);
      expect(result, isA<PaketOpSqlite>());
    });

    // Add similar tests for all other providers
    // ...
  });
}
