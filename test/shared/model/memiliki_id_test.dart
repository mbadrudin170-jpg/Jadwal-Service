// path: test/shared/model/memiliki_id_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

// Kelas tiruan (mock) yang mengimplementasikan MemilikiId untuk pengujian.
class ModelContoh implements MemilikiId {
  @override
  final String id;

  ModelContoh(this.id);
}

// Kelas lain untuk memastikan interface bisa digunakan oleh banyak kelas.
class ItemContoh implements MemilikiId {
  @override
  String get id => _id;
  final String _id;

  ItemContoh(this._id);
}

void main() {
  group('Interface MemilikiId', () {
    test('Kelas yang mengimplementasikan MemilikiId harus memiliki properti id', () {
      // Membuat instance dari kelas tiruan
      const idUnik = '12345-abcde';
      final model = ModelContoh(idUnik);

      // Memverifikasi bahwa properti `id` ada dan dapat diakses
      expect(model.id, isNotNull);
      expect(model.id, isA<String>());
      expect(model.id, equals(idUnik));
    });

    test('Properti id harus dapat diakses melalui referensi MemilikiId', () {
      const idUnik = 'item-001';
      // Membuat instance dari kelas lain
      final item = ItemContoh(idUnik);

      // Menunjuk ke instance menggunakan tipe interface
      final MemilikiId objekDenganId = item;

      // Memverifikasi bahwa `id` dapat diakses melalui interface
      expect(objekDenganId.id, equals(idUnik));
    });

    test('Dua implementasi berbeda harus memiliki id mereka sendiri', () {
      final model = ModelContoh('model-id');
      final item = ItemContoh('item-id');

      expect(model.id, 'model-id');
      expect(item.id, 'item-id');
      expect(model.id, isNot(equals(item.id)));
    });

    test('List dengan tipe MemilikiId dapat menampung implementasi yang berbeda', () {
        final model = ModelContoh('id-1');
        final item = ItemContoh('id-2');

        // List ini dapat menampung objek apa pun yang mengimplementasikan MemilikiId
        final List<MemilikiId> daftarObjek = [model, item];

        expect(daftarObjek.length, 2);
        expect(daftarObjek[0].id, 'id-1');
        expect(daftarObjek[1].id, 'id-2');
    });
  });
}
