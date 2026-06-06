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
      idTujuan: 'trx1', // ID Transaksi
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
      idTujuan: 'trx1', // ID Transaksi yang sama
      userId: 'user1',
      startDate: now,
      endDate: now.add(const Duration(days: 2)),
      tanggalTampil: now,
      updatedAt: now,
    );
    
    final notifikasi3 = NotifikasiModel(
      id: 'notif3',
      title: 'Judul 3',
      description: 'Isi 3',
      type: TipeNotifikasiEnum.events,
      idTujuan: 'trx2', // ID Transaksi berbeda
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
        'Test 1: getActiveNotifications harus mengembalikan notifikasi yang aktif',
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
        'Test 2: getByUserId harus mengembalikan notifikasi yang sesuai untuk userId tertentu',
        () async {
      // Menambahkan data uji
      await firestore.collection(collection).doc(notifikasi1.id).set(notifikasi1
          .toFirebase()); // userId = user1, isRead=false, isDeleted=false
      await firestore.collection(collection).doc(notifikasi3.id).set(notifikasi3
          .toFirebase()); // userId = user2

      // Notifikasi dengan userId = user1 tapi sudah dibaca
      final notifikasiUser1Terbaca = notifikasi1.copyWith(id: 'notif_user1_read', isRead: true);
      await firestore
          .collection(collection)
          .doc(notifikasiUser1Terbaca.id)
          .set(notifikasiUser1Terbaca.toFirebase());

      final stream = notifikasiOp.getByUserId('user1');

      expect(
        stream,
        emits(isA<List<NotifikasiModel>>().having(
          (list) => list.map((e) => e.id).toSet(),
          'ID set',
          {notifikasi1.id}, // Harusnya hanya notifikasi1
        )),
      );
    });

    test(
        'Test 3: getById harus mengembalikan notifikasi yang aktif dengan ID yang cocok',
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
        'Test 4: getById tidak boleh mengembalikan notifikasi jika sudah dibaca',
        () async {
      // Notifikasi dengan isRead=true
      final notifikasi1Terbaca = notifikasi1.copyWith(isRead: true);
      await firestore
          .collection(collection)
          .doc(notifikasi1.id)
          .set(notifikasi1Terbaca.toFirebase());

      final stream = notifikasiOp.getById(notifikasi1.id);

      // Harusnya mengembalikan list kosong
      expect(
        stream,
        emits(isA<List<NotifikasiModel>>().having((l) => l.isEmpty, 'is empty', true)),
      );
    });

    test('Test 5: add harus memanggil baseOp.insert dengan data yang benar',
        () async {
      when(mockBaseOp.insert(any, any, any)).thenAnswer((_) async {});
      await notifikasiOp.add(notifikasi1);
      verify(mockBaseOp.insert(
        collection,
        notifikasi1.id,
        notifikasi1.toFirebase(),
      )).called(1);
    });

    test('Test 6: update harus memanggil baseOp.update dengan data yang benar',
        () async {
      when(mockBaseOp.update(any, any, any)).thenAnswer((_) async {});
      await notifikasiOp.update(notifikasi1);
      verify(mockBaseOp.update(
        collection,
        notifikasi1.id,
        notifikasi1.toFirebase(),
      )).called(1);
    });

    test('Test 7: delete harus memanggil baseOp.delete dengan ID yang benar',
        () async {
      const idToDelete = 'notif1';
      when(mockBaseOp.delete(any, any)).thenAnswer((_) async {});
      await notifikasiOp.delete(idToDelete);
      verify(mockBaseOp.delete(collection, idToDelete)).called(1);
    });

    test(
        'Test 8: tandaiSudahDibaca harus memanggil baseOp.update dengan data yang benar',
        () async {
      const idToUpdate = 'notif1';
      when(mockBaseOp.update(any, any, any)).thenAnswer((_) async {});
      await notifikasiOp.tandaiSudahDibaca(idToUpdate);
      verify(mockBaseOp.update(collection, idToUpdate, {
        ColumnNames.isRead: true,
      })).called(1);
    });
    
    test(
        'Test 9: deleteByTransactionId harus menghapus semua notifikasi dengan idTujuan yang cocok',
        () async {
      // Setup: Tambahkan beberapa notifikasi ke firestore palsu
      await firestore
          .collection(collection)
          .doc(notifikasi1.id)
          .set(notifikasi1.toFirebase()); // idTujuan: trx1
      await firestore
          .collection(collection)
          .doc(notifikasi2.id)
          .set(notifikasi2.toFirebase()); // idTujuan: trx1
      await firestore
          .collection(collection)
          .doc(notifikasi3.id)
          .set(notifikasi3.toFirebase()); // idTujuan: trx2

      // Eksekusi: Hapus notifikasi yang berhubungan dengan 'trx1'
      await notifikasiOp.deleteByTransactionId('trx1');

      // Verifikasi: Periksa isi firestore setelah penghapusan
      final snapshot = await firestore.collection(collection).get();
      
      // Harusnya hanya notifikasi3 (dengan idTujuan 'trx2') yang tersisa
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.id, notifikasi3.id);
    });

  });
}
