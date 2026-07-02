
// path: test/data_dummy/halaman_data_dummy_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/data_dummy/halaman_data_dummy.dart';

void main() {
  group('HalamanDataDummy', () {
    testWidgets('01. harus menampilkan judul dan tombol', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HalamanDataDummy()));

      expect(find.text('Halaman Data Dummy'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(4));
    });
  });
}
