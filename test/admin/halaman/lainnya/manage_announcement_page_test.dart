
// path: test/admin/halaman/lainnya/manage_announcement_page_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/shared/model/notifikasi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/firebase_operation_provider/firebase_operation_provider.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';

// Mocks
class MockNotifikasiOpFirebase extends Mock implements NotifikasiOpFirebase {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNotifikasiOpFirebase mockNotifikasiOp;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;

  final tPengumuman1 = NotifikasiModel(
    id: '1',
    judul: 'Pengumuman 1',
    isi: 'Isi Pengumuman 1',
    tanggalTampil: DateTime(2023, 1, 1),
  );

  final tPengumuman2 = NotifikasiModel(
    id: '2',
    judul: 'Pengumuman 2',
    isi: 'Isi Pengumuman 2',
    tanggalTampil: DateTime(2023, 1, 2),
  );

  setUp(() {
    mockNotifikasiOp = MockNotifikasiOpFirebase();
    mockNavigatorObserver = MockNavigatorObserver();
    container = ProviderContainer(
      overrides: [
        notifikasiOpFirebaseProvider.overrideWithValue(mockNotifikasiOp),
      ],
    );

    when(() => mockNotifikasiOp.getKhususAdmin())
        .thenAnswer((_) => Stream.value([tPengumuman1, tPengumuman2]));
    when(() => mockNotifikasiOp.addNotifikasi(any())).thenAnswer((_) async {});
    when(() => mockNotifikasiOp.deleteNotif(any())).thenAnswer((_) async {});

    registerFallbackValue(tPengumuman1);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: const ManageAnnouncementPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('ManageAnnouncementPage', () {
    testWidgets('01. harus menampilkan CircularProgressIndicator saat loading',
        (tester) async {
      final completer = StreamController<List<NotifikasiModel>>();
      when(() => mockNotifikasiOp.getKhususAdmin())
          .thenAnswer((_) => completer.stream);

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.add([]); // Complete the stream
      await tester.pumpAndSettle();
    });

    testWidgets('02. harus menampilkan data saat berhasil dimuat', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Pengumuman 1'), findsOneWidget);
      expect(find.text('Pengumuman 2'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan pesan error jika terjadi kegagalan',
        (tester) async {
      when(() => mockNotifikasiOp.getKhususAdmin())
          .thenAnswer((_) => Stream.error('Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('04. harus menampilkan "Tidak ada pengumuman." jika data kosong',
        (tester) async {
      when(() => mockNotifikasiOp.getKhususAdmin())
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada pengumuman.'), findsOneWidget);
    });

    testWidgets('05. harus bisa menambahkan pengumuman baru', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('judul')), 'Judul Baru');
      await tester.enterText(find.byKey(const Key('isi')), 'Isi Baru');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      verify(() => mockNotifikasiOp.addNotifikasi(any(
          that: isA<NotifikasiModel>()
            ..having((a) => a.judul, 'judul', 'Judul Baru')))).called(1);
    });

    testWidgets('06. harus bisa menghapus pengumuman', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Pengumuman 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus').last);
      await tester.pumpAndSettle();

      verify(() => mockNotifikasiOp.deleteNotif('1')).called(1);
    });
  });
}
