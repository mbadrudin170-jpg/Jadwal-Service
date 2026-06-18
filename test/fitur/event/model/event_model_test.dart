// path: test/fitur/event/model/event_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/event/model/event_model.dart';

void main() {
  group('EventModel Unit Tests', () {
    final tDateTime = DateTime(2023, 1, 1, 10, 0, 0);

    final tEventModel = EventModel(
      id: 'evt-123',
      linkGambar: 'https://example.com/image.png',
      statusAktif: true,
      tanggalDibuat: tDateTime,
      tanggalMulai: tDateTime,
      tanggalBerakhir: tDateTime,
    );

    test('Inisialisasi: harus menyimpan nilai properti dengan benar', () {
      expect(tEventModel.id, 'evt-123');
      expect(tEventModel.linkGambar, 'https://example.com/image.png');
      expect(tEventModel.statusAktif, true);
      expect(tEventModel.tanggalDibuat, tDateTime);
    });

    test(
      'fromJson: harus mengembalikan objek EventModel yang valid dari Map',
      () {
        final Map<String, dynamic> jsonMap = {
          'id': 'evt-123',
          'link_gambar': 'https://example.com/image.png',
          'status_aktif': true,
          'tanggal_dibuat': tDateTime.toIso8601String(),
          'tanggal_mulai': tDateTime.toIso8601String(),
          'tanggal_berakhir': tDateTime.toIso8601String(),
        };

        final result = EventModel.fromJson(jsonMap);

        expect(result.id, tEventModel.id);
        expect(result.linkGambar, tEventModel.linkGambar);
        expect(result.statusAktif, tEventModel.statusAktif);
        expect(result.tanggalDibuat, tEventModel.tanggalDibuat);
      },
    );

    test('toJson: harus menghasilkan Map yang benar dari objek EventModel', () {
      final result = tEventModel.toJson();

      expect(result['id'], tEventModel.id);
      expect(result['link_gambar'], tEventModel.linkGambar);
      expect(result['status_aktif'], tEventModel.statusAktif);
      expect(
        result['tanggal_dibuat'],
        tEventModel.tanggalDibuat.toIso8601String(),
      );
    });
  });
}
