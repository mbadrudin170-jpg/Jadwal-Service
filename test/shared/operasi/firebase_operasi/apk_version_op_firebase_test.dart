
// path: test/shared/operasi/firebase_operasi/apk_version_op_firebase_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/shared/constant/table_name_value.dart';
import 'package:wifi/shared/enum/apk_architecture_enum.dart';
import 'package:wifi/shared/enum/table_name_enum.dart';
import 'package:wifi/shared/model/apk_version_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/apk_version_op_firebase.dart';

void main() {
  late ApkVersionOpFirebase apkVersionOp;
  late FakeFirebaseFirestore fakeFirestore;
  late CollectionReference collectionRef;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    apkVersionOp = ApkVersionOpFirebase(firestore: fakeFirestore);
    collectionRef =
        fakeFirestore.collection(TableNameValue.get(TableName.userApkVersion));
  });

  final apkVersion = ApkVersionModel(
    id: '1',
    latestVersion: '1.0.0',
    latestBuildNumber: {
      ApkArchitectureEnum.bit64: 1,
      ApkArchitectureEnum.x86_64: 1
    },
    downloadLinks: {
      ApkArchitectureEnum.bit64: 'http://example.com/bit64.apk',
      ApkArchitectureEnum.x86_64: 'http://example.com/x86_64.apk'
    },
    releaseNotes: 'Initial release',
    isUpdateRequired: false,
    updatedAt: DateTime(2023, 1, 1),
  );

  test(
      '1. Uji coba getLatestApkVersion harus mengembalikan versi APK terbaru yang aktif',
      () async {
    // Arrange
    await collectionRef.doc(apkVersion.id).set(apkVersion.toFirebase());

    // Act
    final result = await apkVersionOp.getLatestApkVersion();

    // Assert
    expect(result, isA<ApkVersionModel>());
    expect(result?.latestVersion, '1.0.0');
    expect(result?.latestBuildNumber[ApkArchitectureEnum.bit64], 1);
  });
}
