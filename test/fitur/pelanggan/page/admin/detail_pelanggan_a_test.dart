// path: test/fitur/pelanggan/page/admin/detail_pelanggan_a_test.dart
import 'dart:async'; // Tambahkan baris ini untuk mengatasi error Completer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/page/admin/detail_pelanggan_a.dart';
import 'package:wifi/fitur/pelanggan/page/user/detail_pelanggan_u.dart';
import 'package:wifi/fitur/pelanggan/provider/pelanggan_provider.dart';
import 'package:wifi/fitur/pelanggan/widget/detail_pelanggan_ui.dart';

void main() {
  // Data mock untuk PelangganModel
  final mockPelanggan = PelangganModel(
    id: 'id-123',
    nama: 'John Doe',
    telepon: '081234567890',
    alamat: 'Jl. Contoh No. 1',
    kataSandi: 'password123',
    macAddress: '00:1B:44:11:3A:B7',
  );

  // Wrapper untuk widget test dengan ProviderScope
  Widget createWidgetUnderTest(String idPelanggan, List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: DetailPelanggan(idPelanggan: idPelanggan),
      ),
    );
  }

  group('DetailPelanggan Widget Tests', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetUnderTest('id-123', [
          pelangganDetailProvider('id-123')
              .overrideWith((ref) => Completer<(PelangganModel?, int)>().future),
        ]),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('02. harus menampilkan pesan error saat terjadi kesalahan',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetUnderTest('id-123', [
          pelangganDetailProvider('id-123').overrideWith(
            (ref) => Future<(PelangganModel?, int)>.error('Gagal memuat'),
          ),
        ]),
      );

      // Assert
      expect(find.text('Gagal memuat data: Gagal memuat'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan saat pelanggan tidak ditemukan',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetUnderTest('id-123', [
          pelangganDetailProvider('id-123').overrideWith(
            (ref) => (null, 0),
          ),
        ]),
      );

      // Assert
      expect(find.text('Pelanggan tidak ditemukan'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan DetailPelangganUI dengan data yang benar',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetUnderTest('id-123', [
          pelangganDetailProvider('id-123').overrideWith(
            (ref) => (mockPelanggan, 100),
          ),
        ]),
      );

      // Assert
      expect(find.byType(DetailPelangganUI), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);
      expect(find.text('100'), findsOneWidget); // Poin
    });

    testWidgets('05. harus memiliki tombol edit di AppBar',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createWidgetUnderTest('id-123', [
          pelangganDetailProvider('id-123')
              .overrideWith((ref) => (mockPelanggan, 100)),
        ]),
      );

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
