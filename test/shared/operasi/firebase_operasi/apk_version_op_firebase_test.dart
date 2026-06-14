// path: test/shared/operasi/firebase_operasi/apk_version_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/nama_tabel.dart';
import 'package:wifi/shared/enum/arsitektur_apk.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/fitur/versi_apk/model/versi_apk_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/apk_version_op_firebase.dart';

void main() {
  late ApkVersionOpFirebase apkVersionOp;
  late FakeFirebaseFirestore fakeFirestore;
  late CollectionReference collectionRef;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    apkVersionOp = ApkVersionOpFirebase(firestore: fakeFirestore);
    collectionRef =
        fakeFirestore.collection(NamaTabel.get(TableName.userApkVersion));
  });

  final apkVersion = VersiApkModel(
    id: '1',
    versiTerkahir: '1.0.0',
    nomorBuildTerakhir: {ArsitekturApk.bit64: 1, ArsitekturApk.x86_64: 1},
    linkDownload: {
      ArsitekturApk.bit64: 'http://example.com/bit64.apk',
      ArsitekturApk.x86_64: 'http://example.com/x86_64.apk'
    },
    catatanRilis: 'Initial release',
    diperbaruiPada: DateTime(2023),
  );

  test(
      '1. Uji coba getLatestApkVersion harus mengembalikan versi APK terbaru yang aktif',
      () async {
    // Arrange
    await collectionRef.doc(apkVersion.id).set(apkVersion.toFirebase());

    // Act
    final result = await apkVersionOp.ambilVersiTerbaru();

    // Assert
    expect(result, isA<VersiApkModel>());
    expect(result?.versiTerkahir, '1.0.0');
    expect(result?.nomorBuildTerakhir[ArsitekturApk.bit64], 1);
  });
}
