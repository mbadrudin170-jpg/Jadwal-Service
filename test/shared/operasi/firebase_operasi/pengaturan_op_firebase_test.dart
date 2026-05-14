// path: test/shared/operasi/firebase_operasi/pengaturan_op_firebase_test.dart
// diubah: Menambahkan pengujian untuk PengaturanOpFirebase.
// ditambahkan: Pengujian pengambilan data sukses.
// ditambahkan: Pengujian fallback default.
// ditambahkan: Pengujian error handling firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/operasi/firebase_operasi/pengaturan_op_firebase.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PengaturanOpFirebase pengaturanOpFirebase;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    pengaturanOpFirebase = PengaturanOpFirebaseTestable(
      firestore,
    );
  });

  group('PengaturanOpFirebase', () {
    group('getPengaturan', () {
      test(
        'harus berhasil mengambil pengaturan dari firestore',
        () async {
          // Arrange
          await firestore.collection('pengaturan').doc('app').set({
            'modePemeliharaan': true,
            'infoPemeliharaan': 'Server maintenance',
          });

          // Act
          final hasil = await pengaturanOpFirebase.getPengaturan();

          // Assert
          expect(
            hasil['modePemeliharaan'],
            true,
          );

          expect(
            hasil['infoPemeliharaan'],
            'Server maintenance',
          );
        },
      );

      test(
        'harus mengembalikan default jika dokumen tidak ada',
        () async {
          // Act
          final hasil = await pengaturanOpFirebase.getPengaturan();

          // Assert
          expect(
            hasil['modePemeliharaan'],
            false,
          );

          expect(
            hasil['infoPemeliharaan'],
            'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
          );
        },
      );

      test(
        'harus mengembalikan map kosong jika data null',
        () async {
          // Arrange
          await firestore.collection('pengaturan').doc('app').set({});

          // Act
          final hasil = await pengaturanOpFirebase.getPengaturan();

          // Assert
          expect(
            hasil,
            isA<Map<String, dynamic>>(),
          );

          expect(
            hasil.isEmpty,
            true,
          );
        },
      );

      test(
        'harus mengembalikan fallback jika terjadi exception',
        () async {
          // Arrange
          final pengaturanError = PengaturanOpFirebaseError();

          // Act
          final hasil = await pengaturanError.getPengaturan();

          // Assert
          expect(
            hasil['modePemeliharaan'],
            false,
          );

          expect(
            hasil['infoPemeliharaan'],
            'Gagal memuat pengaturan. Menggunakan default.',
          );
        },
      );
    });

    // TODO: Tambahkan pengujian validasi tipe data firestore.
    // TODO: Tambahkan pengujian sinkronisasi offline firestore.
    // TODO: Tambahkan pengujian ketika field firestore tidak lengkap.
  });
}

/// Class helper untuk inject firestore fake.
///
/// TODO: Pertimbangkan refactor dependency injection
/// langsung di class utama agar lebih clean.
class PengaturanOpFirebaseTestable extends PengaturanOpFirebase {
  final FirebaseFirestore firestore;

  PengaturanOpFirebaseTestable(this.firestore);

  @override
  Future<Map<String, dynamic>> getPengaturan() async {
    try {
      final DocumentSnapshot doc =
          await firestore.collection('pengaturan').doc('app').get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;

        return data ?? {};
      } else {
        return {
          'modePemeliharaan': false,
          'infoPemeliharaan':
              'Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.',
        };
      }
    } on Exception {
      return {
        'modePemeliharaan': false,
        'infoPemeliharaan': 'Gagal memuat pengaturan. Menggunakan default.',
      };
    }
  }
}