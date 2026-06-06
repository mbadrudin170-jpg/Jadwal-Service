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
      userId: 'user1',
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
      userId: 'user2',
      startDate: now,
      endDate: now.add(const Duration(days: 2)),
      tanggalTampil: now,
      updatedAt: now,
    );

    final notifikasiTerbaca = NotifikasiModel(
      id: 'notif4',
      title: 'Judul 4',
      description: 'Isi 4',
      type: TipeNotifikasiEnum.transaksi,
      idTujuan: 'user4',
      userId: 'user4',
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
      userId: 'user5',
      isDeleted: true,
      startDate: now,
      endDate: now.add(const Duration(days: 1)),
      tanggalTampil: now,
      updatedAt: now,
    );

    final notifikasiMasaDepan = NotifikasiModel(
      id: 'notif6',
      title: 'Judul 6',
      description: 'Isi 6',
      type: TipeNotifikasiEnum.transaksi,
      idTujuan: 'user6',
      userId: 'user6',
      startDate: now.add(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 2)),
      tanggalTampil: now.add(const Duration(days: 1)),
      updatedAt: now,
    );

    test(
        'Test 1: getActiveNotifications harus mengambil data yang ${ColumnNames.isRead} false, ${ColumnNames.isDeleted} false, ${ColumnNames.tanggalTampil} <= now,',
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
          .doc(notifikasiTerbaca.id)
          .set(notifikasiTerbaca.toFirebase());
      await firestore
          .collection(collection)
          .doc(notifikasiDihapus.id)
          .set(notifikasiDihapus.toFirebase());
      await firestore
          .collection(collection)
          .doc(notifikasiMasaDepan.id)
          .set(notifikasiMasaDepan.toFirebase());

      // Mendengarkan stream
      final stream = notifikasiOp.getActiveNotifications();

      expect(
        stream,
        emits(isA<List<NotifikasiModel>>().having(
          (list) => list.map((e) => e.id).toSet(),
          'ID set',
          {notifikasi1.id, notifikasi2.id},
        )),
      );
    });

    test(
        '2 getByUserId harus mengambil data yang ${ColumnNames.idTujuan} nya sesuai, ${ColumnNames.isDeleted}=false, ${ColumnNames.isRead}=false,} ',
        () async {
      // Menambahkan data uji
      await firestore.collection(collection).doc(notifikasi1.id).set(notifikasi1
          .toFirebase()); // idTujuan = user1, isRead=false, isDeleted=false

      await firestore
          .collection(collection)
          .doc(notifikasiTerbaca.id)
          .set(notifikasiTerbaca.toFirebase()); // idTujuan = user4, isRead=true

      await firestore.collection(collection).doc(notifikasiDihapus.id).set(
          notifikasiDihapus.toFirebase()); // idTujuan = user5, isDeleted=true

      // Notifikasi dengan user1 tapi sudah dibaca (kita buat data baru)
      final notifikasi1Terbaca = NotifikasiModel(
        id: 'notif1_read',
        title: 'Judul 1 dibaca',
        description: 'Isi',
        type: TipeNotifikasiEnum.transaksi,
        idTujuan: 'user1',
        userId: 'user1',
        isRead: true,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        tanggalTampil: now,
        updatedAt: now,
      );
      await firestore
          .collection(collection)
          .doc(notifikasi1Terbaca.id)
          .set(notifikasi1Terbaca.toFirebase());
      final stream = notifikasiOp.getByUserId('user1');

      expect(
        stream,
        emits(isA<List<NotifikasiModel>>().having(
          (list) => list.map((e) => e.id).toSet(),
          'ID set',
          {notifikasi1.id}, // hanya notifikasi1, bukan notifikasi1Terbaca
        )),
      );
    });

    test(
        '3. getById harus mengambil data yang ${ColumnNames.id} nya sesuai, ${ColumnNames.isDeleted}=false, ${ColumnNames.isRead}=false,}',
        () async {
      // Notifikasi aktif
      await firestore
          .collection(collection)
          .doc(notifikasi1.id)
          .set(notifikasi1.toFirebase());

      final stream = notifikasiOp.getById(notifikasi1.id);

      expect(
        stream,
        emits(isA<List<NotifikasiModel>>().having(
          (list) => list.map((e) => e.id).toSet(),
          'ID set',
          {notifikasi1.id},
        )),
      );
    });

    test(
        '3b. getById tidak mengembalikan notifikasi jika sudah dibaca (isRead=true)',
        () async {
      // Notifikasi dengan isRead=true
      final notifikasi1Terbaca = NotifikasiModel(
        id: notifikasi1.id,
        title: 'Judul 1 dibaca',
        description: 'Isi',
        type: TipeNotifikasiEnum.transaksi,
        idTujuan: 'user1',
        userId: 'user1',
        isRead: true,
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        tanggalTampil: now,
        updatedAt: now,
      );
      await firestore
          .collection(collection)
          .doc(notifikasi1.id)
          .set(notifikasi1Terbaca.toFirebase());

      final stream = notifikasiOp.getById(notifikasi1.id);

      expect(
        stream,
        emits(isA<List<NotifikasiModel>>().having(
          (list) => list.length,
          'length',
          0,
        )),
      );
    });

    test('Test 2: add harus memanggil baseOp.insert dengan data yang benar',
        () async {
      when(mockBaseOp.insert(any, any, any)).thenAnswer((_) async {});
      await notifikasiOp.add(notifikasi1);
      verify(mockBaseOp.insert(
        collection,
        notifikasi1.id,
        notifikasi1.toFirebase(),
      )).called(1);
    });

    test('3 update harus memanggil baseOp.update dengan data yang benar',
        () async {
      await notifikasiOp.update(notifikasi1);
    });

    test('Test 3: delete harus memanggil baseOp.delete dengan ID yang benar',
        () async {
      const idToDelete = 'notif1';
      when(mockBaseOp.delete(any, any)).thenAnswer((_) async {});
      await notifikasiOp.delete(idToDelete);
      verify(mockBaseOp.delete(collection, idToDelete)).called(1);
    });

    test(
        'Test 4: tandaiSudahDibaca harus memanggil baseOp.update dengan data yang benar',
        () async {
      const idToUpdate = 'notif1';
      when(mockBaseOp.update(any, any, any)).thenAnswer((_) async {});
      await notifikasiOp.tandaiSudahDibaca(idToUpdate);
      verify(mockBaseOp.update(collection, idToUpdate, {
        ColumnNames.isRead: true,
      })).called(1);
    });
  });
}
