// path: test/shared/model/status_model_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/model/status_model.dart';

void main() {
  group('StatusModel', () {
    final now = DateTime.now();
    final nowUtc = now.toUtc();
    final timestamp = Timestamp.fromDate(nowUtc);

    test('01. factory constructor should have default id', () {
      final model = StatusModel(updatedAt: now);
      expect(model.id, globalStatusId);
    });

    group('fromFirebase', () {
      test('02. should create StatusModel from a valid Firebase map', () {
        final data = {
          NamaKolom.id: 'test_id',
          NamaKolom.diperbaruiPada: timestamp,
        };

        final model = StatusModel.fromFirebase(data);

        expect(model.id, 'test_id');
        // Firestore Timestamps can have microsecond precision differences.
        // Compare milliseconds since epoch for reliable testing.
        expect(
          model.updatedAt!.millisecondsSinceEpoch,
          timestamp.toDate().millisecondsSinceEpoch,
        );
      });

      test('03. should use globalStatusId if id is null in Firebase map', () {
        final data = {
          NamaKolom.diperbaruiPada: timestamp,
        };

        final model = StatusModel.fromFirebase(data);

        expect(model.id, globalStatusId);
      });

      test('04. should handle null updatedAt from Firebase', () {
        final data = {
          NamaKolom.id: 'test_id',
          NamaKolom.diperbaruiPada: null,
        };

        final model = StatusModel.fromFirebase(data);

        expect(model.id, 'test_id');
        expect(model.updatedAt, isNull);
      });
    });

    group('toFirebase', () {
      test('05. should convert StatusModel to a valid Firebase map', () {
        final model = StatusModel(id: 'test_id', updatedAt: now);
        final firebaseMap = model.toFirebase();

        expect(firebaseMap[NamaKolom.id], 'test_id');
        expect(firebaseMap[NamaKolom.diperbaruiPada], isA<Timestamp>());
        expect(
          (firebaseMap[NamaKolom.diperbaruiPada] as Timestamp).toDate(),
          nowUtc,
        );
      });
    });

    group('fromSqlite', () {
      test('06. should create StatusModel from a valid SQLite map', () {
        final sqliteMap = {
          NamaKolom.id: 'sqlite_id',
          NamaKolom.diperbaruiPada: now.millisecondsSinceEpoch,
        };

        final model = StatusModel.fromSqlite(sqliteMap);

        expect(model.id, 'sqlite_id');
        expect(model.updatedAt!.millisecondsSinceEpoch,
            now.millisecondsSinceEpoch);
      });

      test(
          '07. should use DateTime.now() if updatedAt is missing in SQLite map',
          () {
        final sqliteMap = {
          NamaKolom.id: 'sqlite_id_no_date',
        };

        final before = DateTime.now().millisecondsSinceEpoch;
        final model = StatusModel.fromSqlite(sqliteMap);
        final after = DateTime.now().millisecondsSinceEpoch;

        expect(model.id, 'sqlite_id_no_date');
        expect(model.updatedAt, isNotNull);
        expect(
            model.updatedAt!.millisecondsSinceEpoch, greaterThanOrEqualTo(before));
        expect(
            model.updatedAt!.millisecondsSinceEpoch, lessThanOrEqualTo(after));
      });

      test('08. should use globalStatusId if id is missing in SQLite map', () {
        final sqliteMap = {
          NamaKolom.diperbaruiPada: now.millisecondsSinceEpoch,
        };

        final model = StatusModel.fromSqlite(sqliteMap);

        expect(model.id, globalStatusId);
      });
    });

    group('toSqlite', () {
      test('09. should convert StatusModel to a valid SQLite map', () {
        final model = StatusModel(id: 'sqlite_id', updatedAt: now);
        final sqliteMap = model.toSqlite();

        expect(sqliteMap[NamaKolom.id], 'sqlite_id');
        expect(
            sqliteMap[NamaKolom.diperbaruiPada], now.millisecondsSinceEpoch);
      });
    });
  });
}
