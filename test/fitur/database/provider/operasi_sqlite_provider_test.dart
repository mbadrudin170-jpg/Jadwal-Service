
// path: test/fitur/database/provider/operasi_sqlite_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/paket/operasi/paket_op_sqlite.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_op_sqlite.dart';

import 'operasi_sqlite_provider_test.mocks.dart';

@GenerateMocks([SqliteDatabase, BaseOpSqlite, Database])
void main() {
  group('paketOpSqliteProvider', () {
    late MockSqliteDatabase mockSqliteDatabase;
    late MockBaseOpSqlite mockBaseOpSqlite;
    late MockDatabase mockDatabase;
    late ProviderContainer container;

    setUp(() {
      mockSqliteDatabase = MockSqliteDatabase();
      mockBaseOpSqlite = MockBaseOpSqlite();
      mockDatabase = MockDatabase();

      when(mockSqliteDatabase.database).thenAnswer((_) async => mockDatabase);

      container = ProviderContainer(
        overrides: [
          sqliteDatabaseProvider.overrideWithValue(mockSqliteDatabase),
          baseOpSqliteProvider.overrideWithValue(mockBaseOpSqlite),
        ],
      );
    });

    test('01. should return an instance of PaketOpSqlite', () {
      final paketOpSqlite = container.read(paketOpSqliteProvider);
      expect(paketOpSqlite, isA<PaketOpSqlite>());
    });
  });
}
