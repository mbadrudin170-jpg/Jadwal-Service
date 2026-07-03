// path: test/fitur/pelanggan/widget/detail_pelanggan_ui_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/pelanggan/model/pelanggan_model.dart';
import 'package:wifi/fitur/pelanggan/widget/detail_pelanggan_ui.dart';

void main() {
  final pelanggan = PelangganModel(
    id: '1',
    nama: 'Pelanggan Uji',
    telepon: '08123456789',
    alamat: 'Jl. Uji Coba No. 123',
    kataSandi: 'password123',
    macAddress: '00:11:22:33:44:55',
  );

  Widget buildTestableWidget(Widget widget) {
    return MaterialApp(home: widget);
  }

  group('DetailPelangganUI', () {
    testWidgets('01. harus menampilkan semua informasi pelanggan', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          DetailPelangganUI(pelanggan: pelanggan, totalPoin: 100),
        ),
      );

      expect(find.text('Profil Pelanggan'), findsOneWidget);
      expect(find.text('Pelanggan Uji'), findsOneWidget);
      expect(find.text('08123456789'), findsOneWidget);
      expect(find.text('Jl. Uji Coba No. 123'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
      expect(find.text('00:11:22:33:44:55'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets(
      '02. harus menampilkan tombol edit jika navigasiKeEdit diberikan',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            DetailPelangganUI(
              pelanggan: pelanggan,
              totalPoin: 100,
              navigasiKeEdit: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.edit), findsOneWidget);
      },
    );

    testWidgets(
      '03. tidak boleh menampilkan tombol edit jika navigasiKeEdit null',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            DetailPelangganUI(pelanggan: pelanggan, totalPoin: 100),
          ),
        );

        expect(find.byIcon(Icons.edit), findsNothing);
      },
    );

    testWidgets(
      '04. harus menampilkan tombol salin semua jika onCopyAll diberikan',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            DetailPelangganUI(
              pelanggan: pelanggan,
              totalPoin: 100,
              onCopyAll: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.copy_all), findsOneWidget);
      },
    );

    testWidgets(
      '05. tidak boleh menampilkan tombol salin semua jika onCopyAll null',
      (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            DetailPelangganUI(pelanggan: pelanggan, totalPoin: 100),
          ),
        );

        expect(find.byIcon(Icons.copy_all), findsNothing);
      },
    );

    testWidgets('06. harus memanggil callback saat tombol ditekan', (
      tester,
    ) async {
      var editDitekan = false;
      var poinDitekan = false;
      var salinSemuaDitekan = false;

      await tester.pumpWidget(
        buildTestableWidget(
          DetailPelangganUI(
            pelanggan: pelanggan,
            totalPoin: 100,
            navigasiKeEdit: () => editDitekan = true,
            navigasiKePoin: () => poinDitekan = true,
            onCopyAll: () => salinSemuaDitekan = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.tap(find.text('100'));
      await tester.tap(find.byIcon(Icons.copy_all));

      expect(editDitekan, isTrue);
      expect(poinDitekan, isTrue);
      expect(salinSemuaDitekan, isTrue);
    });
  });
}
