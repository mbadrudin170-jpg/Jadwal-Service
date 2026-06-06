// path: test/shared/operasi/firebase_operasi/notifikasi_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/enum/tipe_notifikasi_enum.dart';
import 'package:wifi/shared/model/notifikasi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';

import 'notifikasi_op_firebase_test.mocks.dart';

@GenerateMocks([BaseOpFirebase])
void main() {
  group('Uji Coba NotifikasiOpFirebase', () {
    late FakeFirebaseFirestore firestore;
    late MockBaseOpFirebase mockBaseOp;
    late NotifikasiOpFirebase notifikasiOp;
    final collection = TableNameValue.get(TableName.notifikasi);
    final now = DateTime.now();

    // 1. Inisialisasi sebelum setiap tes
    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockBaseOp = MockBaseOpFirebase();
      notifikasiOp = NotifikasiOpFirebase(
        firestore: firestore,
        baseOp: mockBaseOp,
      );
    });

    // 2. Data notifikasi untuk pengujian
    final notifikasi1 = NotifikasiModel(
      id: 'notif1',
      title: 'Judul 1',
      description: 'Isi 1',
      type: TipeNotifikasiEnum.transaksi,
      idTujuan: 'user1',
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      tanggalTampil: now,
      updatedAt: now,
    );

    final notifikasi2 = NotifikasiModel(
      id: 'notif2',
      title: 'Judul 2',
      description: 'Isi 2',
      type: TipeNotifikasiEnum.events,
      idTujuan: 'user2',
      startDate: now,
      endDate: now.add(const Duration(days: 2)),
      tanggalTampil: now,
      updatedAt: now,
    );

    final notifikasiKedaluwarsa = NotifikasiModel(
      id: 'notif3',
      title: 'Judul 3',
      description: 'Isi 3',
      type: TipeNotifikasiEnum.order,
      idTujuan: 'user3',
      startDate: now.subtract(const Duration(days: 2)),
      endDate: now.subtract(const Duration(days: 1)),
      tanggalTampil: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
    );

    final notifikasiTerbaca = NotifikasiModel(
      id: 'notif4',
      title: 'Judul 4',
      description: 'Isi 4',
      type: TipeNotifikasiEnum.transaksi,
      idTujuan: 'user4',
      isRead: true,
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      tanggalTampil: now,
      updatedAt: now,
    );

    final notifikasiDihapus = NotifikasiModel(
      id: 'notif5',
      title: 'Judul 5',
      description: 'Isi 5',
      type: TipeNotifikasiEnum.transaksi,
      idTujuan: 'user5',
      isDeleted: true,
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      tanggalTampil: now,
      updatedAt: now,
    );

    test(
        'Test 1: getActiveNotifications harus mengembalikan notifikasi yang aktif, belum dibaca, dan belum dihapus',
        () async {
      // Menambahkan data uji ke firestore palsu
      await firestore
          .collection(collection)
          .doc(notifikasi1.id)
          .set(notifikasi1.toFirebase());
      await firestore
          .collection(collection)
          .doc(notifikasi2.id)
          .set(notifikasi2.toFirebase());
      await firestore
          .collection(collection)
          .doc(notifikasiKedaluwarsa.id)
          .set(notifikasiKedaluwarsa.toFirebase());
      await firestore
          .collection(collection)
          .doc(notifikasiTerbaca.id)
          .set(notifikasiTerbaca.toFirebase());
      await firestore
          .collection(collection)
          .doc(notifikasiDihapus.id)
          .set(notifikasiDihapus.toFirebase());

      // Mendengarkan stream
      final stream = notifikasiOp.getActiveNotifications();

      // Memeriksa hasil stream
      expect(
        stream,
        emits((List<NotifikasiModel> list) {
          // Hanya notifikasi1 dan notifikasi2 yang harus muncul
          final ids = list.map((e) => e.id).toList();
          return list.length == 2 &&
              ids.contains(notifikasi1.id) &&
              ids.contains(notifikasi2.id);
        }),
      );
    });

    test('Test 2: add harus memanggil baseOp.insert dengan data yang benar',
        () async {
      // Mengatur mock untuk mengembalikan Future kosong
      when(mockBaseOp.insert(any, any, any)).thenAnswer((_) async {});

      // Memanggil metode add
      await notifikasiOp.add(notifikasi1);

      // Memverifikasi bahwa baseOp.insert dipanggil dengan argumen yang benar
      verify(mockBaseOp.insert(
        collection,
        notifikasi1.id,
        notifikasi1.toFirebase(),
      )).called(1);
    });

    test('Test 3: delete harus memanggil baseOp.delete dengan ID yang benar',
        () async {
      const idToDelete = 'notif1';
      // Mengatur mock untuk mengembalikan Future kosong
      when(mockBaseOp.delete(any, any)).thenAnswer((_) async {});

      // Memanggil metode delete
      await notifikasiOp.delete(idToDelete);

      // Memverifikasi bahwa baseOp.delete dipanggil dengan argumen yang benar
      verify(mockBaseOp.delete(collection, idToDelete)).called(1);
    });

    test(
        'Test 4: tandaiSudahDibaca harus memanggil baseOp.update dengan data yang benar',
        () async {
      const idToUpdate = 'notif1';
      // Mengatur mock untuk mengembalikan Future kosong
      when(mockBaseOp.update(any, any, any)).thenAnswer((_) async {});

      // Memanggil metode tandaiSudahDibaca
      await notifikasiOp.tandaiSudahDibaca(idToUpdate);

      // Memverifikasi bahwa baseOp.update dipanggil dengan argumen yang benar
      verify(mockBaseOp.update(collection, idToUpdate, {
        ColumnNames.isRead: true,
      })).called(1);
    });
  });
}
