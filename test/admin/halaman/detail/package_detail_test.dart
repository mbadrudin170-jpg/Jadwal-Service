// path: test/admin/halaman/detail/package_detail_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/admin/halaman/detail/package_detail.dart';
import 'package:wifi/admin/halaman/form/package_form.dart';
import 'package:wifi/shared/model/package_model.dart';
import 'package:wifi/shared/export/enum.dart';

import 'package:wifi/shared/theme/app_icons.dart';
import 'package:wifi/shared/theme/app_sizes.dart';

@GenerateMocks([])
void main() {
  late PackageModel paketUji;

  setUp(() {
    paketUji = PackageModel(
      id: 'paket-1',
      name: 'Paket Super Cepat',
      price: 100000,
      duration: 30,
      durationType: DurationType.days,
      rewardPoints: 50,
      isActive: true,
      description: 'Deskripsi paket internet super cepat',
    );
  });

  /// 1. Memastikan halaman detail paket menampilkan informasi yang benar
  testWidgets('1. Menampilkan informasi detail paket dengan benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PackageDetailPage(package: paketUji),
        ),
      ),
    );

    // Verifikasi Judul AppBar
    expect(find.text('Detail Paket'), findsOneWidget);

    // Verifikasi Nama Paket
    expect(find.text('Paket Super Cepat'), findsOneWidget);

    // Verifikasi Harga (Format Rupiah biasanya ditangani widget internal, kita cek teks mentah atau label)
    expect(find.text('Harga'), findsOneWidget);

    // Verifikasi Durasi
    expect(find.text('Durasi'), findsOneWidget);
    expect(find.text('30 Hari'), findsOneWidget);

    // Verifikasi Poin
    expect(find.text('Poin Hadiah'), findsOneWidget);
    expect(find.text('50 Poin'), findsOneWidget);

    // Verifikasi Deskripsi
    expect(find.text('Deskripsi paket internet super cepat'), findsOneWidget);
  });

  /// 2. Memastikan tombol edit menavigasi ke halaman form paket
  testWidgets('2. Menavigasi ke PackageForm saat tombol edit ditekan',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PackageDetailPage(package: paketUji),
        ),
      ),
    );

    // Temukan tombol edit berdasarkan icon TIcons.edit
    final tombolEdit = find.byIcon(TIcons.edit);
    expect(tombolEdit, findsOneWidget);

    // Tekan tombol edit
    await tester.tap(tombolEdit);
    await tester.pumpAndSettle();

    // Verifikasi apakah sekarang berada di halaman PackageForm
    expect(find.byType(PackageForm), findsOneWidget);
  });
}