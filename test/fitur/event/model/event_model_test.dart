// path: test/fitur/event/model/event_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/event/model/event_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';

void main() {
  group('EventModel', () {
    final tDateTime = DateTime(2023, 1, 1, 10);

    final tEventModel = EventModel(
      id: 'evt-123',
      linkGambar: 'https://example.com/image.png',
      statusAktif: true,
      tanggalDibuat: tDateTime,
      tanggalMulai: tDateTime,
      tanggalBerakhir: tDateTime,
      diperbaruiPada: tDateTime,
    );

    test('01. Inisialisasi: harus menyimpan nilai properti dengan benar', () {
      expect(tEventModel.id, 'evt-123');
      expect(tEventModel.linkGambar, 'https://example.com/image.png');
      expect(tEventModel.statusAktif, true);
      expect(tEventModel.tanggalDibuat, tDateTime);
    });

    group('fromSupabase', () {
      test(
        '02. harus mengembalikan objek EventModel yang valid dari data Supabase',
        () {
          final Map<String, dynamic> supabaseData = {
            NamaKolom.linkGambar: 'https://example.com/image.png',
            NamaKolom.statusAktif: true,
            NamaKolom.tanggalDibuat: tDateTime.toIso8601String(),
            NamaKolom.tanggalMulai: tDateTime.toIso8601String(),
            NamaKolom.tangglBerakhir: tDateTime.toIso8601String(),
            NamaKolom.diperbaruiPada: tDateTime.toIso8601String(),
          };

          final result = EventModel.fromSupabase('evt-123', supabaseData);

          expect(result, tEventModel);
        },
      );
    });

    group('toSupabase', () {
      test('03. harus menghasilkan Map yang benar untuk Supabase', () {
        final result = tEventModel.toSupabase();
        final expectedMap = {
          NamaKolom.id: 'evt-123',
          NamaKolom.linkGambar: 'https://example.com/image.png',
          NamaKolom.statusAktif: true,
          NamaKolom.tanggalMulai: tDateTime.toIso8601String(),
          NamaKolom.tangglBerakhir: tDateTime.toIso8601String(),
          NamaKolom.tanggalDibuat: tDateTime.toIso8601String(),
          NamaKolom.diperbaruiPada: tDateTime.toIso8601String(),
        };
        expect(result, expectedMap);
      });
    });

    group('fromSqlite', () {
      test(
        '04. harus mengembalikan objek EventModel yang valid dari Map SQLite',
        () {
          final sqliteMap = {
            NamaKolom.id: 'evt-123',
            NamaKolom.linkGambar: 'https://example.com/image.png',
            NamaKolom.statusAktif: 1,
            NamaKolom.tanggalDibuat: tDateTime.millisecondsSinceEpoch,
            NamaKolom.tanggalMulai: tDateTime.millisecondsSinceEpoch,
            NamaKolom.tangglBerakhir: tDateTime.millisecondsSinceEpoch,
            NamaKolom.diperbaruiPada: tDateTime.millisecondsSinceEpoch,
          };

          final result = EventModel.fromSqlite(sqliteMap);
          expect(result, tEventModel);
        },
      );
    });

    group('toSqlite', () {
      test(
        '05. harus menghasilkan Map yang benar untuk penyimpanan SQLite',
        () {
          final result = tEventModel.toSqlite();
          final expectedMap = {
            NamaKolom.id: 'evt-123',
            NamaKolom.linkGambar: 'https://example.com/image.png',
            NamaKolom.statusAktif: 1,
            NamaKolom.tanggalDibuat: tDateTime.millisecondsSinceEpoch,
            NamaKolom.tanggalMulai: tDateTime.millisecondsSinceEpoch,
            NamaKolom.tangglBerakhir: tDateTime.millisecondsSinceEpoch,
            NamaKolom.diperbaruiPada: tDateTime.millisecondsSinceEpoch,
          };
          expect(result, expectedMap);
        },
      );
    });
  });
}
