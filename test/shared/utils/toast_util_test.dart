'''// path: test/shared/utils/toast_util_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi/shared/utils/toast_util.dart';

// Karena ToastUtil sangat bergantung pada BuildContext dan UI (toastification),
// pengujian ini akan fokus pada memastikan metode dapat dipanggil tanpa error.
// Pengujian UI yang sebenarnya akan lebih cocok di tingkat widget/integration test.

// Mock BuildContext untuk pengujian
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  // Toastification membutuhkan Material ancestor, jadi kita bungkus dengan MaterialApp.
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('ToastUtil', () {
    testWidgets(
        '01. success() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        Builder(
          builder: (BuildContext context) {
            // Panggil method untuk memastikan tidak ada exception
            expect(
                () => ToastUtil.success(context, 'Pesan sukses'), returnsNormally);
            return Container();
          },
        ),
      ));
      // Tunggu frame untuk memproses pemanggilan toast
      await tester.pumpAndSettle();
    });

    testWidgets(
        '02. error() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        Builder(
          builder: (BuildContext context) {
            expect(
                () => ToastUtil.error(context, 'Pesan error'), returnsNormally);
            return Container();
          },
        ),
      ));
      await tester.pumpAndSettle();
    });

    testWidgets(
        '03. warning() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        Builder(
          builder: (BuildContext context) {
            expect(() => ToastUtil.warning(context, 'Pesan peringatan'),
                returnsNormally);
            return Container();
          },
        ),
      ));
      await tester.pumpAndSettle();
    });

    testWidgets(
        '04. info() harus berjalan tanpa error', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        Builder(
          builder: (BuildContext context) {
            expect(
                () => ToastUtil.info(context, 'Pesan info'), returnsNormally);
            return Container();
          },
        ),
      ));
      await tester.pumpAndSettle();
    });

    testWidgets(
        '05. harus menangani context yang tidak mounted dengan baik', (WidgetTester tester) async {
      // Buat BuildContext yang sudah tidak aktif (unmounted)
      BuildContext? unmountedContext;
      
      await tester.pumpWidget(makeTestableWidget(
        Builder(
          builder: (BuildContext context) {
            unmountedContext = context;
            return Container();
          },
        ),
      ));

      // Hapus widget dari tree untuk membuat context-nya unmounted
      await tester.pumpWidget(Container());

      // Panggil ToastUtil dengan context yang sudah tidak mounted
      // Seharusnya tidak ada error yang terjadi
      expect(() => ToastUtil.success(unmountedContext!, 'Pesan'), returnsNormally);
      
      // Pastikan tidak ada toast yang ditampilkan atau error yang muncul
      await tester.pumpAndSettle();
    });
  });
}
''