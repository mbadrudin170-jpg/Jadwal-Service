// path: test/shared/operasi/category_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/admin/data/sqlite.dart';
import 'package:wifi/shared/enum/tipe_kategori.dart';
import 'package:wifi/fitur/kategori/model/kategori_model.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/base_operation.dart';
import 'package:wifi/shared/operasi/sqlite_operasi/kategori_op_sqlite.dart';

import 'category_operation_test.mocks.dart';

@GenerateMocks([
  SqliteDatabase,
  Database,
  BaseOpSqlite,
])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late MockBaseOperation mockBaseOperation;
  late KategoriOpSqlite categoryOperation;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    mockBaseOperation = MockBaseOperation();
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    categoryOperation = KategoriOpSqlite(
      sqlitedb: mockDbHelper,
      baseOpSqlite: mockBaseOperation,
    );
  });

  group('CategoryOperation', () {
    final tCategory = KategoriModel(
      id: '1',
      nama: 'Test Category',
      tipe: TipeKategori.expense,
    );
    final tCategoryMap = tCategory.toSqlite();

    test('createCategory should insert a new category and return it', () async {
      when(mockBaseOperation.sisipkan(any, any)).thenAnswer((_) async => 1);

      final result = await categoryOperation.tambahKategori(tCategory);

      expect(result.id, tCategory.id);
      verify(mockBaseOperation.sisipkan(any, any)).called(1);
    });

    test('getCategories should return a list of categories', () async {
      when(mockDatabase.query(any, where: anyNamed('where')))
          .thenAnswer((_) async => [tCategoryMap]);

      final result = await categoryOperation.ambilSemua();

      expect(result, isA<List<KategoriModel>>());
      expect(result.first.id, tCategory.id);
    });

    test('getCategoryById should return a category', () async {
      when(mockDatabase.query(any,
              where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [tCategoryMap]);

      final result = await categoryOperation.ambilKategoriBerdasarkanId('1');

      expect(result, isA<KategoriModel>());
      expect(result.id, tCategory.id);
    });

    test('updateCategory should update an existing category', () async {
      when(mockBaseOperation.update(any, any, any)).thenAnswer((_) async {});

      await categoryOperation.updateKategori(tCategory);

      verify(mockBaseOperation.update(any, any, any)).called(1);
    });

    test('deleteCategory should delete a category', () async {
      when(mockBaseOperation.delete(any, any)).thenAnswer((_) async {});

      await categoryOperation.deleteCategory('1');

      verify(mockBaseOperation.delete(any, '1')).called(1);
    });

    test('softDelete should soft delete a category', () async {
      when(mockBaseOperation.hapusSementara(any, any)).thenAnswer((_) async {});

      await categoryOperation.softDelete('1');

      verify(mockBaseOperation.hapusSementara(any, '1')).called(1);
    });
  });
}
