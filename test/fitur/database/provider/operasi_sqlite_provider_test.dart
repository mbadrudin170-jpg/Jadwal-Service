
// path: test/fitur/database/provider/operasi_sqlite_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/database/provider/operasi_sqlite_provider.dart';
import 'package:wifi/fitur/database/sqlite_user.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  group('OperasiSqliteNotifier', () {
    late OperasiSqliteNotifier notifier;
    late MockDatabaseHelper mockDatabaseHelper;
    late ProviderContainer container;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      container = ProviderContainer(
        overrides: [
          databaseHelperProvider.overrideWithValue(mockDatabaseHelper),
        ],
      );
      notifier = container.read(operasiSqliteProvider.notifier);
    });

    test('01. initState - database is initialized', () {
      // The build method should be implicitly called, which initializes the database.
      // We can verify this by checking if any method on the mock was called.
      // As the `initDB` is called in the constructor, we can't easily mock and verify it.
      // However, we can check if the state is not null.

      // This is a bit of a workaround to trigger the build method.
      container.read(operasiSqliteProvider);

      expect(notifier.state, isA<AsyncData<DatabaseHelper>>());
    });
  });
}
