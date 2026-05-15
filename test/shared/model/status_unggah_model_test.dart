// path: test/shared/model/status_unggah_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/status_unggah_model.dart';

void main() {
  group('StatusUnggahModel', () {
    const id = StatusUnggahModel.idPerluUnggah;
    final now = DateTime.now();
    final nowEpoch = now.millisecondsSinceEpoch;

    // 1. Uji Konstruktor
    test('1. Konstruktor harus menginisialisasi semua nilai dengan benar', () {
      // Kasus 1: Dengan tanggal diperbarui
      final model1 = StatusUnggahModel(
        id: id,
        perluUnggah: true,
        diperbarui: now,
      );
      expect(model1.id, id);
      expect(model1.perluUnggah, isTrue);
      expect(model1.diperbarui, now);

      // Kasus 2: Tanpa tanggal diperbarui (opsional)
      final model2 = StatusUnggahModel(id: id, perluUnggah: false);
      expect(model2.id, id);
      expect(model2.perluUnggah, isFalse);
      expect(model2.diperbarui, isNull);
    });

    // 2. Uji fromSqlite
    group('2. fromSqlite', () {
      test('Harus mengonversi map dari SQLite menjadi model yang lengkap', () {
        final map = {
          'id': id,
          'value': '1', // true
          'diperbarui': nowEpoch,
        };
        final model = StatusUnggahModel.fromSqlite(map);

        expect(model.id, id);
        expect(model.perluUnggah, isTrue);
        // Membandingkan epoch untuk presisi
        expect(model.diperbarui?.millisecondsSinceEpoch, nowEpoch);
      });

      test('Harus menangani nilai `diperbarui` yang null dari SQLite', () {
        final map = {
          'id': id,
          'value': '0', // false
          'diperbarui': null, // Kolom bisa jadi null
        };
        final model = StatusUnggahModel.fromSqlite(map);

        expect(model.id, id);
        expect(model.perluUnggah, isFalse);
        expect(model.diperbarui, isNull);
      });

      test('Harus mengonversi value selain \'1\' menjadi perluUnggah = false', () {
        final map = {'id': id, 'value': 'abc', 'diperbarui': null};
        final model = StatusUnggahModel.fromSqlite(map);

        expect(model.perluUnggah, isFalse);
      });
    });

    // 3. Uji toSqlite
    group('3. toSqlite', () {
      test('Harus mengonversi model yang lengkap ke map untuk SQLite', () {
        final model = StatusUnggahModel(
          id: id,
          perluUnggah: true,
          diperbarui: now,
        );
        final map = model.toSqlite();

        expect(map['id'], id);
        expect(map['value'], '1');
        expect(map['diperbarui'], nowEpoch);
      });

      test('Harus menangani nilai `diperbarui` yang null saat konversi ke map', () {
        final model = StatusUnggahModel(id: id, perluUnggah: false);
        final map = model.toSqlite();

        expect(map['id'], id);
        expect(map['value'], '0');
        expect(map['diperbarui'], isNull);
      });
    });
  });
}
