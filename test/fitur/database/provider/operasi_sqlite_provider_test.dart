
// path: test/fitur/database/provider/operasi_sqlite_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';

import 'operasi_sqlite_provider_test.mocks.dart';

@GenerateMocks([NotifikasiOpFirebase, Database])
void main() {
  group('operasiSqliteProvider', () {
    late MockNotifikasiOpFirebase mockNotifikasiOpFirebase;
    late MockDatabase mockDatabase;
    late ProviderContainer container;

    setUp(() {
      mockNotifikasiOpFirebase = MockNotifikasiOpFirebase();
      mockDatabase = MockDatabase();

      container = ProviderContainer(
        overrides: [
          sqliteDatabaseProvider.overrideWithValue(SqliteDatabase(mockDatabase)),
          // TODO: Mock the provider for NotifikasiOpFirebase
          // notifikasiOpFirebaseProvider.overrideWithValue(mockNotifikasiOpFirebase),
        ],
      );
    });

    test('01. should return an instance of OperasiSqlite', () {
      final operasiSqlite = container.read(operasiSqliteProvider);
      expect(operasiSqlite, isA<OperasiSqlite>());
    });
  });
}
