// path: test/shared/operasi/package_operation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/operasi/package_operation.dart';
import 'package:wifi/shared/operasi/base_operation.dart';

import 'base_operation_test.mocks.dart';

void main() {
  late MockDatabase mockDatabase;
  late BaseOperation<PackageModel> baseOperation;
  late PackageOperation packageOperation;

  setUp(() {
    mockDatabase = MockDatabase();
    baseOperation = BaseOperation<PackageModel>(mockDatabase, 'packages');
    packageOperation = PackageOperation(baseOperation);
  });

  group('PackageOperation Tests', () {
    final tPackage = PackageModel(
      id: '1',
      name: 'Basic Plan',
      price: 150000,
      duration: 30,
    );

    test('getPackages should return a list of packages', () async {
      when(baseOperation.getAll()).thenAnswer((_) async => [tPackage.toMap()]);

      final result = await packageOperation.getPackages();

      expect(result, isA<List<PackageModel>>());
      expect(result.length, 1);
      expect(result.first.id, tPackage.id);
      verify(baseOperation.getAll()).called(1);
    });

    test('getPackageById should return a single package', () async {
      when(baseOperation.getById('1')).thenAnswer((_) async => tPackage.toMap());

      final result = await packageOperation.getPackageById('1');

      expect(result, isA<PackageModel>());
      expect(result?.id, tPackage.id);
      verify(baseOperation.getById('1')).called(1);
    });

    test('insertPackage should insert a new package', () async {
      when(baseOperation.insert(any)).thenAnswer((_) async => 1);

      final id = await packageOperation.insertPackage(tPackage);

      expect(id, 1);
      verify(baseOperation.insert(any)).called(1);
    });

    test('updatePackage should update an existing package', () async {
      when(baseOperation.update(any, any)).thenAnswer((_) async => 1);

      final result = await packageOperation.updatePackage(tPackage.id, tPackage);

      expect(result, 1);
      verify(baseOperation.update(tPackage.id, any)).called(1);
    });

    test('deletePackage should delete a package', () async {
      when(baseOperation.delete(any)).thenAnswer((_) async => 1);

      final result = await packageOperation.deletePackage('1');

      expect(result, 1);
      verify(baseOperation.delete('1')).called(1);
    });
  });
}
