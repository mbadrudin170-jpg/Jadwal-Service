// path: test/shared/operasi/status_unggah_operasi_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/operasi/upload_status_operasi.dart';

import 'status_unggah_operasi_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late StatusUnggahOperasi statusUnggahOperasi;
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    statusUnggahOperasi = StatusUnggahOperasi(dbHelper: mockDbHelper);
    when(mockDbHelper.database).thenAnswer((final _) async => mockDatabase);
  });

  group('setPerluUnggah', () {
    test('should insert true status correctly', () async {
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      ),).thenAnswer((final _) async => 1);

      await statusUnggahOperasi.setPerluUnggah(true);

      verify(mockDatabase.insert(
        'status_aplikasi',
        {'id': 'perlu_unggah', 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),).called(1);
    });

    test('should insert false status correctly', () async {
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      ),).thenAnswer((final _) async => 1);

      await statusUnggahOperasi.setPerluUnggah(false);

      verify(mockDatabase.insert(
        'status_aplikasi',
        {'id': 'perlu_unggah', 'value': '0'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),).called(1);
    });
  });

  group('getPerluUnggah', () {
    test('should return true when database value is 1', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs'),),)
          .thenAnswer((final _) async => [
                {'id': 'perlu_unggah', 'value': '1'},
              ],);

      final result = await statusUnggahOperasi.getPerluUnggah();

      expect(result, isTrue);
    });

    test('should return false when database value is 0', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs'),),)
          .thenAnswer((final _) async => [
                {'id': 'perlu_unggah', 'value': '0'},
              ],);

      final result = await statusUnggahOperasi.getPerluUnggah();

      expect(result, isFalse);
    });

    test('should return false when database is empty', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs'),),)
          .thenAnswer((final _) async => []);

      final result = await statusUnggahOperasi.getPerluUnggah();

      expect(result, isFalse);
    });
  });
}
