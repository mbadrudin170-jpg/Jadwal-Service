// path: test/admin/halaman/widget/box_info_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/halaman/widget/box_info.dart';

void main() {
  testWidgets('BoxInfo widget renders correctly and has correct styles', (final WidgetTester tester) async {
    // Data dummy untuk pengujian
    const String title = 'Total Pelanggan';
    const String value = '123';
    const IconData icon = Icons.people;
    const Color color = Colors.blue;

    // Build widget BoxInfo
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BoxInfo(
            title: title,
            value: value,
            icon: icon,
            color: color,
          ),
        ),
      ),
    );

    // Verifikasi bahwa widget dasar ditampilkan
    expect(find.text(title), findsOneWidget);
    expect(find.text(value), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);

    // Verifikasi gaya untuk widget Text title
    final Text titleText = tester.widget(find.text(title));
    expect(titleText.style?.fontSize, 16);
    expect(titleText.style?.fontWeight, FontWeight.bold);

    // Verifikasi gaya untuk widget Text value
    final Text valueText = tester.widget(find.text(value));
    expect(valueText.style?.fontSize, 20);
    expect(valueText.style?.fontWeight, FontWeight.bold);
  });
}
