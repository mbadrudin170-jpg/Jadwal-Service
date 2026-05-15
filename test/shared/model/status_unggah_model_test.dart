// path: test/shared/model/status_unggah_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/status_unggah_model.dart';

void main() {
  group('StatusUnggahModel', () {
    // 1. Uji Konstruktor
    test('Konstruktor harus menginisialisasi nilai dengan benar', () {
      final modelTrue = StatusUnggahModel(id: 1, perluUnggah: true);
      expect(modelTrue.id, 1);
      expect(modelTrue.perluUnggah, isTrue);

      final modelFalse = StatusUnggahModel(id: 1, perluUnggah: false);
      expect(modelFalse.perluUnggah, isFalse);
    });

    // 2. Uji fromSqlite
    group('fromSqlite', () {
      test('Harus mengonversi map dengan perlu_unggah = 1 menjadi perluUnggah = true', () {
        final map = {'id': 1, 'perlu_unggah': 1};
        final model = StatusUnggahModel.fromSqlite(map);

        expect(model.id, 1);
        expect(model.perluUnggah, isTrue);
      });

      test('Harus mengonversi map dengan perlu_unggah = 0 menjadi perluUnggah = false', () {
        final map = {'id': 1, 'perlu_unggah': 0};
        final model = StatusUnggahModel.fromSqlite(map);

        expect(model.id, 1);
        expect(model.perluUnggah, isFalse);
      });

       test('Harus menangani nilai null sebagai false', () {
        final map = {'id': 1, 'perlu_unggah': null};
        final model = StatusUnggahModel.fromSqlite(map);
        // `== 1` akan menghasilkan false jika nilainya null.
        expect(model.perluUnggah, isFalse);
      });
    });

    // 3. Uji toSqlite
    group('toSqlite', () {
      test('Harus mengonversi model dengan perluUnggah = true menjadi map yang benar', () {
        final model = StatusUnggahModel(id: 1, perluUnggah: true);
        final map = model.toSqlite();

        expect(map['id'], 1);
        expect(map['perlu_unggah'], 1);
      });

      test('Harus mengonversi model dengan perluUnggah = false menjadi map yang benar', () {
        final model = StatusUnggahModel(id: 1, perluUnggah: false);
        final map = model.toSqlite();

        expect(map['id'], 1);
        expect(map['perlu_unggah'], 0);
      });
    });
  });
}
