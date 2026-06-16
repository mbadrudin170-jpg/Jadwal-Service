
// path: test/admin/app_admin_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/admin/app_admin.dart';
import 'package:wifi/admin/halaman_utama.dart';

void main() {
  group('AppAdmin', () {
    testWidgets('01. harus menampilkan HalamanUtama', (WidgetTester tester) async {
      await tester.pumpWidget(const AppAdmin());

      expect(find.byType(HalamanUtama), findsOneWidget);
    });
  });
}
