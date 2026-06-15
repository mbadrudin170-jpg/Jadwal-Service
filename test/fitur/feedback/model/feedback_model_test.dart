// path: test/fitur/feedback/model/feedback_model_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';

void main() {
  group('FeedbackModel', () {
    final tanggal = DateTime.now();
    final diperbaruiPada = tanggal.add(const Duration(hours: 1));
    final diarsipkanPada = tanggal.add(const Duration(days: 1));

    final modelLengkap = FeedbackModel(
      id: 'feedback123',
      content: 'Ini adalah feedback.',
      userId: 'user123',
      date: tanggal,
      updatedAt: diperbaruiPada,
      isDeleted: false,
      archivedAt: diarsipkanPada,
    );

    test('01. harus membuat instance dengan benar', () {
      expect(modelLengkap.id, 'feedback123');
      expect(modelLengkap.content, 'Ini adalah feedback.');
      expect(modelLengkap.userId, 'user123');
      expect(modelLengkap.date, tanggal);
      expect(modelLengkap.updatedAt, diperbaruiPada);
      expect(modelLengkap.isDeleted, false);
      expect(modelLengkap.archivedAt, diarsipkanPada);
    });

    test('02. harus menghasilkan id unik jika tidak disediakan', () {
      final modelTanpaId = FeedbackModel(
        content: 'Feedback tanpa ID.',
        userId: 'user456',
      );
      expect(modelTanpaId.id, isNotNull);
      expect(modelTanpaId.id, isNotEmpty);
    });

    group('copyWith', () {
      test('03. harus menyalin instance tanpa perubahan', () {
        final salinan = modelLengkap.copyWith();
        expect(salinan.id, modelLengkap.id);
        expect(salinan.content, modelLengkap.content);
        expect(salinan.userId, modelLengkap.userId);
        expect(salinan.date, modelLengkap.date);
        expect(salinan.updatedAt, modelLengkap.updatedAt);
        expect(salinan.isDeleted, modelLengkap.isDeleted);
        expect(salinan.archivedAt, modelLengkap.archivedAt);
      });

      test('04. harus menyalin instance dengan perubahan beberapa field', () {
        final tanggalBaru = DateTime.now().add(const Duration(days: 5));
        final salinan = modelLengkap.copyWith(
          content: 'Konten baru',
          isDeleted: true,
          date: tanggalBaru,
        );

        expect(salinan.id, modelLengkap.id);
        expect(salinan.content, 'Konten baru');
        expect(salinan.isDeleted, true);
        expect(salinan.date, tanggalBaru);
        expect(salinan.userId, modelLengkap.userId); // field lama
      });
    });

    group('fromSqlite', () {
      final mapSqlite = {
        NamaKolom.id: 'feedback123',
        NamaKolom.isi: 'Ini dari SQLite.',
        NamaKolom.userId: 'user123',
        NamaKolom.tanggal: tanggal.millisecondsSinceEpoch,
        NamaKolom.diperbaruiPada: diperbaruiPada.millisecondsSinceEpoch,
        NamaKolom.diHapus: 1,
        NamaKolom.diarsipkanPada: diarsipkanPada.millisecondsSinceEpoch,
      };

      test('05. harus membuat instance dari map SQLite yang valid', () {
        final model = FeedbackModel.fromSqlite(mapSqlite);

        expect(model.id, 'feedback123');
        expect(model.content, 'Ini dari SQLite.');
        expect(model.userId, 'user123');
        expect(
            model.date?.millisecondsSinceEpoch, tanggal.millisecondsSinceEpoch);
        expect(model.updatedAt?.millisecondsSinceEpoch,
            diperbaruiPada.millisecondsSinceEpoch);
        expect(model.isDeleted, true);
        expect(model.archivedAt?.millisecondsSinceEpoch,
            diarsipkanPada.millisecondsSinceEpoch);
      });

      test('06. harus menangani nilai null dari map SQLite', () {
        final mapKosong = {
          NamaKolom.id: 'feedback456',
          NamaKolom.isi: null,
          NamaKolom.userId: null,
          NamaKolom.tanggal: null,
          NamaKolom.diperbaruiPada: null,
          NamaKolom.diHapus: null,
          NamaKolom.diarsipkanPada: null,
        };

        final model = FeedbackModel.fromSqlite(mapKosong);
        expect(model.id, 'feedback456');
        expect(model.content, '');
        expect(model.userId, '');
        expect(model.date, isNull);
        expect(model.updatedAt, isNull);
        expect(model.isDeleted, false);
        expect(model.archivedAt, isNull);
      });
    });

    group('toSqlite', () {
      test('07. harus mengonversi ke map SQLite dengan benar', () {
        final map = modelLengkap.toSqlite();

        expect(map[NamaKolom.id], 'feedback123');
        expect(map[NamaKolom.isi], 'Ini adalah feedback.');
        expect(map[NamaKolom.userId], 'user123');
        expect(map[NamaKolom.tanggal], tanggal.millisecondsSinceEpoch);
        expect(map[NamaKolom.diperbaruiPada],
            diperbaruiPada.millisecondsSinceEpoch);
        expect(map[NamaKolom.diHapus], 0);
        expect(map[NamaKolom.diarsipkanPada],
            diarsipkanPada.millisecondsSinceEpoch);
      });

      test('08. harus menangani nilai null saat konversi ke map SQLite', () {
        final modelKosong = FeedbackModel(
          id: 'kosong123',
          content: '',
          userId: '',
        );
        final map = modelKosong.toSqlite();

        expect(map[NamaKolom.id], 'kosong123');
        expect(map[NamaKolom.tanggal], isA<int>());
        expect(map[NamaKolom.diperbaruiPada], isA<int>());
        expect(map[NamaKolom.diarsipkanPada], isNull);
        expect(map[NamaKolom.diHapus], 0);
      });
    });

    group('fromFirebase', () {
      final mapFirebase = {
        NamaKolom.isi: 'Ini dari Firebase.',
        NamaKolom.userId: 'user123',
        NamaKolom.tanggal: Timestamp.fromDate(tanggal),
        NamaKolom.diperbaruiPada: Timestamp.fromDate(diperbaruiPada),
        NamaKolom.diHapus: false,
        NamaKolom.diarsipkanPada: Timestamp.fromDate(diarsipkanPada),
      };

      test('09. harus membuat instance dari map Firebase yang valid', () {
        final model = FeedbackModel.fromFirebase('fb123', mapFirebase);

        expect(model.id, 'fb123');
        expect(model.content, 'Ini dari Firebase.');
        expect(model.userId, 'user123');
        expect(model.date, tanggal);
        expect(model.updatedAt, diperbaruiPada);
        expect(model.isDeleted, false);
        expect(model.archivedAt, diarsipkanPada);
      });

      test('10. harus menangani nilai null dari map Firebase', () {
        final mapKosong = {
          NamaKolom.isi: null,
          NamaKolom.userId: null,
          NamaKolom.tanggal: null,
          NamaKolom.diperbaruiPada: null,
          NamaKolom.diHapus: null,
          NamaKolom.diarsipkanPada: null,
        };

        final model = FeedbackModel.fromFirebase('fb456', mapKosong);
        expect(model.id, 'fb456');
        expect(model.content, '');
        expect(model.userId, '');
        expect(model.date, isNull);
        expect(model.updatedAt, isNull);
        expect(model.isDeleted, false);
        expect(model.archivedAt, isNull);
      });
    });

    group('toFirebase', () {
      test('11. harus mengonversi ke map Firebase dengan benar', () {
        final map = modelLengkap.toFirebase();

        expect(map[NamaKolom.id], 'feedback123');
        expect(map[NamaKolom.isi], 'Ini adalah feedback.');
        expect(map[NamaKolom.userId], 'user123');
        expect(map[NamaKolom.tanggal], Timestamp.fromDate(tanggal.toUtc()));
        expect(map[NamaKolom.diperbaruiPada],
            Timestamp.fromDate(diperbaruiPada.toUtc()));
        expect(map[NamaKolom.diHapus], false);
        expect(map[NamaKolom.diarsipkanPada],
            Timestamp.fromDate(diarsipkanPada.toUtc()));
      });

      test('12. harus menangani nilai null saat konversi ke map Firebase',
          () {
        final modelKosong = FeedbackModel(
          id: 'kosong123',
          content: '',
          userId: '',
        );
        final map = modelKosong.toFirebase();

        expect(map[NamaKolom.id], 'kosong123');
        expect(map[NamaKolom.tanggal], isA<Timestamp>());
        expect(map[NamaKolom.diperbaruiPada], isA<Timestamp>());
        expect(map[NamaKolom.diarsipkanPada], isNull);
        expect(map[NamaKolom.diHapus], false);
      });
    });
  });
}
