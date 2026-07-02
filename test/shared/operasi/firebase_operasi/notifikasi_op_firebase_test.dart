// path: test/shared/operasi/firebase_operasi/notifikasi_op_firebase_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/notifikasi/model/notifikasi_model.dart';
import 'package:wifi/fitur/notifikasi/operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/operasi/firebase_operasi/base_op_firebase.dart';

import 'notifikasi_op_firebase_test.mocks.dart';

@GenerateMocks([BaseOpFirebase])
void main() {
  late FakeFirebaseFirestore firestore;
  late MockBaseOpFirebase mockBaseOp;
  late NotifikasiOpFirebase notifikasiOp;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    mockBaseOp = MockBaseOpFirebase();
    notifikasiOp = NotifikasiOpFirebase(
      firestore: firestore,
      baseOp: mockBaseOp,
    );
  });

  final now = DateTime.now();
  final notif1 = NotifikasiModel(
      id: '1',
      tipe: TipeNotifikasiEnum.info,
      judul: 'Judul 1',
      deskripsi: 'Pesan 1',
      tanggalMulai: now,
      tanggalBerakhir: now.add(const Duration(days: 1)),
      tanggalTampil: now.subtract(const Duration(hours: 1)),
      diperbaruiPada: now,
      idTujuan: 'tujuan1',
      userId: 'user1',
      targetRole: AppRole.user);

  final notif2 = NotifikasiModel(
      id: '2',
      userId: 'user123',
      tipe: TipeNotifikasiEnum.order,
      judul: 'Judul 2',
      deskripsi: 'Pesan 2',
      tanggalMulai: now,
      tanggalBerakhir: now.add(const Duration(days: 1)),
      tanggalTampil: now.subtract(const Duration(hours: 1)),
      diperbaruiPada: now,
      idTujuan: 'tujuan2',
      targetRole: AppRole.user);

  final notifDihapus = notif1.copyWith(id: '3', dihapus: true);
  final notifDibaca = notif1.copyWith(id: '4', setatusDibaca: true);
  final notifMasaDepan = notif1.copyWith(
    id: '5',
    tanggalTampil: now.add(const Duration(days: 1)),
  );

  group('getNotifAktif', () {
    test(
      '01. harus mengembalikan stream berisi notifikasi yang aktif (belum dihapus, belum dibaca, dan tanggal tampil sudah lewat)',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif1.id)
            .set(notif1.toFirebase());
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif2.id)
            .set(notif2.toFirebase());

        final stream = notifikasiOp.getNotifAktif();

        expect(
          stream,
          emits(
            isA<List<NotifikasiModel>>()
                .having((list) => list.length, 'panjang list', 2)
                .having(
                  (list) => list.map((e) => e.id),
                  'id notifikasi',
                  containsAll([notif1.id, notif2.id]),
                ),
          ),
        );
      },
    );

    test(
      '02. harus mengembalikan stream kosong jika tidak ada notifikasi aktif',
      () async {
        final stream = notifikasiOp.getNotifAktif();
        expect(stream, emits(isEmpty));
      },
    );

    test('03. harus memfilter notifikasi yang sudah dihapus', () async {
      await firestore
          .collection(NamaTabel.notifikasi)
          .doc(notif1.id)
          .set(notif1.toFirebase());
      await firestore
          .collection(NamaTabel.notifikasi)
          .doc(notifDihapus.id)
          .set(notifDihapus.toFirebase());

      final stream = notifikasiOp.getNotifAktif();

      expect(
        stream,
        emits(
          isA<List<NotifikasiModel>>()
              .having((list) => list.length, 'panjang list', 1)
              .having((list) => list.first.id, 'id notifikasi', notif1.id),
        ),
      );
    });

    test('04. harus memfilter notifikasi yang sudah dibaca', () async {
      await firestore
          .collection(NamaTabel.notifikasi)
          .doc(notif1.id)
          .set(notif1.toFirebase());
      await firestore
          .collection(NamaTabel.notifikasi)
          .doc(notifDibaca.id)
          .set(notifDibaca.toFirebase());

      final stream = notifikasiOp.getNotifAktif();

      expect(
        stream,
        emits(
          isA<List<NotifikasiModel>>()
              .having((list) => list.length, 'panjang list', 1)
              .having((list) => list.first.id, 'id notifikasi', notif1.id),
        ),
      );
    });

    test(
      '05. harus memfilter notifikasi yang tanggal tampilnya di masa depan',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif1.id)
            .set(notif1.toFirebase());
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifMasaDepan.id)
            .set(notifMasaDepan.toFirebase());

        final stream = notifikasiOp.getNotifAktif();

        expect(
          stream,
          emits(
            isA<List<NotifikasiModel>>()
                .having((list) => list.length, 'panjang list', 1)
                .having((list) => list.first.id, 'id notifikasi', notif1.id),
          ),
        );
      },
    );
  });

  group('getByUserId', () {
    test(
      '07. harus mengembalikan notifikasi yang sesuai dengan userId (belum dihapus dan belum dibaca)',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif1.id)
            .set(notif1.toFirebase());
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif2.id)
            .set(notif2.toFirebase());

        final stream = notifikasiOp.getByUserId('user123');

        expect(
          stream,
          emits(
            isA<List<NotifikasiModel>>()
                .having((list) => list.length, 'panjang list', 1)
                .having((list) => list.first.id, 'id notifikasi', notif2.id),
          ),
        );
      },
    );

    test(
      '08. harus mengembalikan stream kosong jika tidak ada notifikasi untuk userId tersebut',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif1.id)
            .set(notif1.toFirebase());

        final stream = notifikasiOp.getByUserId('user-lain');

        expect(stream, emits(isEmpty));
      },
    );
  });

  group('getById', () {
    test(
      '10. harus mengembalikan stream berisi satu notifikasi jika ID ditemukan dan valid',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif1.id)
            .set(notif1.toFirebase());

        final stream = notifikasiOp.getById(notif1.id);

        expect(
          stream,
          emits(
            isA<List<NotifikasiModel>>()
                .having((list) => list.length, 'panjang list', 1)
                .having((list) => list.first.id, 'id notifikasi', notif1.id),
          ),
        );
      },
    );

    test(
      '11. harus mengembalikan stream kosong jika dokumen tidak ada',
      () async {
        final stream = notifikasiOp.getById('id-tidak-ada');
        expect(stream, emits(isEmpty));
      },
    );

    test(
      '12. harus mengembalikan stream kosong jika notifikasi sudah dihapus',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifDihapus.id)
            .set(notifDihapus.toFirebase());
        final stream = notifikasiOp.getById(notifDihapus.id);
        expect(stream, emits(isEmpty));
      },
    );

    test(
      '13. harus mengembalikan stream kosong jika notifikasi sudah dibaca',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifDibaca.id)
            .set(notifDibaca.toFirebase());
        final stream = notifikasiOp.getById(notifDibaca.id);
        expect(stream, emits(isEmpty));
      },
    );
  });

  group('ambilKhususAdmin', () {
    final notifOrder = notif2.copyWith(
      id: 'order1',
      tipe: TipeNotifikasiEnum.order,
      targetRole: AppRole.admin,
    );
    final notifTransaksi = notif1.copyWith(
      id: 'transaksi1',
      tipe: TipeNotifikasiEnum.transaksi,
      targetRole: AppRole.admin,
    );
    final notifInfo = notif1.copyWith(
      id: 'info1',
      tipe: TipeNotifikasiEnum.info,
    );

    test(
      '15. harus mengembalikan notifikasi khusus admin (tipe order atau transaksi) yang aktif',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifOrder.id)
            .set(notifOrder.toFirebase());
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifTransaksi.id)
            .set(notifTransaksi.toFirebase());
        final stream = notifikasiOp.ambilKhususAdmin();
        expect(
          stream,
          emits(
            isA<List<NotifikasiModel>>()
                .having((list) => list.length, 'panjang list', 1)
                .having(
                  (list) => list.map((e) => e.id),
                  'id notifikasi',
                  containsAll([notifOrder.id]),
                ),
          ),
        );
      },
    );

    test(
      '16. harus memfilter notifikasi yang bukan tipe order atau transaksi',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifOrder.id)
            .set(notifOrder.toFirebase());
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifInfo.id)
            .set(notifInfo.toFirebase());

        final stream = notifikasiOp.ambilKhususAdmin();

        expect(
          stream,
          emits(
            isA<List<NotifikasiModel>>()
                .having((list) => list.length, 'panjang list', 1)
                .having(
                  (list) => list.first.id,
                  'id notifikasi',
                  notifOrder.id,
                ),
          ),
        );
      },
    );

    test(
      '17. harus mengembalikan stream kosong jika tidak ada notifikasi khusus admin',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifInfo.id)
            .set(notifInfo.toFirebase());

        final stream = notifikasiOp.ambilKhususAdmin();

        expect(stream, emits(isEmpty));
      },
    );
  });

  group('addNotifikasi', () {
    test(
      '19. harus memanggil _baseOp.sisipkan dengan parameter yang benar',
      () async {
        when(
          mockBaseOp.sisipkan(
            NamaTabel.notifikasi,
            notif1.id,
            notif1.toFirebase(),
          ),
        ).thenAnswer((_) async {});

        await notifikasiOp.addNotifikasi(notif1);

        verify(
          mockBaseOp.sisipkan(
            NamaTabel.notifikasi,
            notif1.id,
            notif1.toFirebase(),
          ),
        ).called(1);
      },
    );

    test(
      '20. harus melempar kembali (rethrow) exception jika _baseOp.sisipkan gagal',
      () async {
        final exception = Exception('Gagal simpan');
        when(
          mockBaseOp.sisipkan(
            NamaTabel.notifikasi,
            notif1.id,
            notif1.toFirebase(),
          ),
        ).thenThrow(exception);

        expect(() => notifikasiOp.addNotifikasi(notif1), throwsA(exception));
      },
    );
  });

  group('updateNotif', () {
    test(
      '21. harus memanggil _baseOp.update dengan parameter yang benar',
      () async {
        when(
          mockBaseOp.update(
            NamaTabel.notifikasi,
            notif1.id,
            notif1.toFirebase(),
          ),
        ).thenAnswer((_) async {});

        await notifikasiOp.updateNotif(notif1);

        verify(
          mockBaseOp.update(
            NamaTabel.notifikasi,
            notif1.id,
            notif1.toFirebase(),
          ),
        ).called(1);
      },
    );

    test(
      '22. harus melempar kembali (rethrow) exception jika _baseOp.update gagal',
      () async {
        final exception = Exception('Gagal update');
        when(
          mockBaseOp.update(
            NamaTabel.notifikasi,
            notif1.id,
            notif1.toFirebase(),
          ),
        ).thenThrow(exception);

        expect(() => notifikasiOp.updateNotif(notif1), throwsA(exception));
      },
    );
  });

  group('softDeleteNotifikasi', () {
    test(
      '23. harus memanggil _baseOp.softDelete dengan parameter yang benar',
      () async {
        when(
          mockBaseOp.softDelete(NamaTabel.notifikasi, 'notif-id'),
        ).thenAnswer((_) async {});

        await notifikasiOp.softDeleteNotifikasi('notif-id');

        verify(
          mockBaseOp.softDelete(NamaTabel.notifikasi, 'notif-id'),
        ).called(1);
      },
    );

    test(
      '24. harus melempar kembali (rethrow) exception jika _baseOp.softDelete gagal',
      () async {
        final exception = Exception('Gagal hapus');
        when(
          mockBaseOp.softDelete(NamaTabel.notifikasi, 'notif-id'),
        ).thenThrow(exception);

        expect(() => notifikasiOp.softDeleteNotifikasi('notif-id'),
            throwsA(exception));
      },
    );
  });

  group('hapusBerdasarkanIdTransaksi', () {
    test(
      '25. harus menghapus notifikasi yang cocok dengan transactionId',
      () async {
        final notifWithTujuan = notif1.copyWith(idTujuan: 'trx123');
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notifWithTujuan.id)
            .set(notifWithTujuan.toFirebase());
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif2.id)
            .set(notif2.toFirebase());

        await notifikasiOp.hapusBerdasarkanIdTransaksi('trx123');

        final snapshot = await firestore.collection(NamaTabel.notifikasi).get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.id, notif2.id);
      },
    );

    test(
      '26. tidak boleh gagal jika tidak ada notifikasi yang cocok',
      () async {
        await firestore
            .collection(NamaTabel.notifikasi)
            .doc(notif1.id)
            .set(notif1.toFirebase());

        await notifikasiOp.hapusBerdasarkanIdTransaksi('trx-tidak-ada');

        final snapshot = await firestore.collection(NamaTabel.notifikasi).get();
        expect(snapshot.docs.length, 1);
      },
    );
  });

  group('tandaiSudahDibaca', () {
    test(
      '28. harus memanggil _baseOp.update untuk menandai notifikasi sebagai sudah dibaca',
      () async {
        when(
          mockBaseOp.update(NamaTabel.notifikasi, 'notif-id', {
            NamaKolom.setatusDibaca: true,
          }),
        ).thenAnswer((_) async {});

        await notifikasiOp.tandaiSudahDibaca('notif-id');

        verify(
          mockBaseOp.update(NamaTabel.notifikasi, 'notif-id', {
            NamaKolom.setatusDibaca: true,
          }),
        ).called(1);
      },
    );

    test(
      '29. harus melempar kembali (rethrow) exception jika _baseOp.update gagal',
      () async {
        final exception = Exception('Gagal tandai dibaca');
        when(
          mockBaseOp.update(NamaTabel.notifikasi, 'notif-id', {
            NamaKolom.setatusDibaca: true,
          }),
        ).thenThrow(exception);

        expect(
          () => notifikasiOp.tandaiSudahDibaca('notif-id'),
          throwsA(exception),
        );
      },
    );
  });
}
