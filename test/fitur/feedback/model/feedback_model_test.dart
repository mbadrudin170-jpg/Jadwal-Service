// path: test/fitur/feedback/model/feedback_model_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/feedback/model/feedback_model.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';

void main() {
  group('FeedbackModel Tests', () {
    final now = DateTime.now();
    // Menggunakan DateTime dengan presisi detik untuk menghindari ketidakcocokan milidetik pada beberapa platform
    final testDate = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    final feedback = FeedbackModel(
      id: 'fb-123',
      pesan: 'Pesan pengujian unit',
      tanggal: testDate,
      userId: 'user-456',
      diperbaruiPada: testDate,
    );

    test('01. harus membuat instance FeedbackModel yang valid', () {
      expect(feedback.id, 'fb-123');
      expect(feedback.pesan, 'Pesan pengujian unit');
      expect(feedback.userId, 'user-456');
      expect(feedback.dihapus, false);
      expect(feedback.tanggal, testDate);
    });

    test(
      '02. fromSqlite harus mengembalikan model yang valid dari Map SQLite',
      () {
        final map = {
          NamaKolom.id: 'fb-123',
          NamaKolom.pesan: 'Pesan pengujian unit',
          NamaKolom.userId: 'user-456',
          NamaKolom.tanggal: testDate.millisecondsSinceEpoch,
          NamaKolom.diperbaruiPada: testDate.millisecondsSinceEpoch,
          NamaKolom.dihapus: 0,
        };

        final result = FeedbackModel.fromSqlite(map);

        expect(result.id, feedback.id);
        expect(result.pesan, feedback.pesan);
        expect(result.userId, feedback.userId);
        expect(
          result.tanggal?.millisecondsSinceEpoch,
          testDate.millisecondsSinceEpoch,
        );
        expect(result.dihapus, false);
      },
    );

    test(
      '03. toSqlite harus mengembalikan map yang valid untuk penyimpanan SQLite',
      () {
        final result = feedback.toSqlite();

        expect(result[NamaKolom.id], feedback.id);
        expect(result[NamaKolom.pesan], feedback.pesan);
        expect(result[NamaKolom.userId], feedback.userId);
        expect(result[NamaKolom.dihapus], 0);
        expect(result[NamaKolom.tanggal], testDate.millisecondsSinceEpoch);
      },
    );

    test(
      '04. fromFirebase harus mengembalikan model yang valid dari data Firestore',
      () {
        final data = {
          NamaKolom.pesan: 'Pesan pengujian unit',
          NamaKolom.userId: 'user-456',
          NamaKolom.tanggal: Timestamp.fromDate(testDate.toUtc()),
          NamaKolom.diperbaruiPada: Timestamp.fromDate(testDate.toUtc()),
          NamaKolom.dihapus: false,
        };

        final result = FeedbackModel.fromFirebase('fb-123', data);

        expect(result.id, 'fb-123');
        expect(result.pesan, feedback.pesan);
        expect(result.userId, feedback.userId);
        expect(result.dihapus, false);
      },
    );

    test(
      '05. toFirebase harus mengembalikan map yang valid untuk Firestore',
      () {
        final result = feedback.toFirebase();

        expect(result[NamaKolom.id], feedback.id);
        expect(result[NamaKolom.pesan], feedback.pesan);
        expect(result[NamaKolom.userId], feedback.userId);
        expect(result[NamaKolom.dihapus], false);
        expect(result[NamaKolom.tanggal], isA<Timestamp>());
      },
    );
  });
}
