
// path: test/admin/halaman/lainnya/manage_announcement_page_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wifi/admin/halaman/lainnya/manage_announcement_page.dart';
import 'package:wifi/fitur/notifikasi/notifikasi_service_provider.dart';
import 'package:wifi/shared/enum/tipe_notifikasi_enum.dart';
import 'package:wifi/shared/model/notifikasi_model.dart';
import 'package:wifi/shared/operasi/firebase_operasi/notifikasi_op_firebase.dart';
import 'package:wifi/shared/providers/shared_providers.dart';

// Mocks
class MockNotifikasiOpFirebase extends Mock implements NotifikasiOpFirebase {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNotifikasiOpFirebase mockNotifikasiOp;
  late MockNavigatorObserver mockNavigatorObserver;
  late ProviderContainer container;
  final testDate = DateTime(2023, 10, 26);

  final tPengumuman = NotifikasiModel(
    id: '1',
    title: 'Judul Lama',
    description: 'Deskripsi Lama',
    type: TipeNotifikasi.pengumuman.name,
    createdAt: testDate,
    updatedAt: testDate,
  );

  setUp(() {
    mockNotifikasiOp = MockNotifikasiOpFirebase();
    mockNavigatorObserver = MockNavigatorObserver();

    container = ProviderContainer(
      overrides: [
        notifikasiOpFirebaseProvider.overrideWithValue(mockNotifikasiOp),
      ],
    );

    when(() => mockNotifikasiOp.add(any())).thenAnswer((_) async => 'new_id');
    when(() => mockNotifikasiOp.update(any())).thenAnswer((_) async {});

    registerFallbackValue(tPengumuman);
  });

  Widget createWidgetUnderTest({NotifikasiModel? announcement}) {
    return ProviderScope(
      parent: container,
      child: MaterialApp(
        home: ManageAnnouncementPage(announcement: announcement),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('ManageAnnouncementPage', () {
    testWidgets('01. harus menampilkan form tambah dengan benar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Buat Pengumuman'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('02. harus menampilkan form edit dengan data yang terisi',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(announcement: tPengumuman));
      expect(find.text('Edit Pengumuman'), findsOneWidget);
      expect(find.text('Judul Lama'), findsOneWidget);
      expect(find.text('Deskripsi Lama'), findsOneWidget);
    });

    testWidgets('03. harus menampilkan error jika field kosong saat disimpan',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Kirim Notifikasi'));
      await tester.pump();

      expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('04. harus memanggil add saat mode tambah', (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(const Key('judul')), 'Judul Baru');
      await tester.enterText(
          find.byKey(const Key('deskripsi')), 'Deskripsi Baru');

      await tester.tap(find.text('Kirim Notifikasi'));
      await tester.pumpAndSettle();

      verify(() => mockNotifikasiOp.add(any(that: isA<NotifikasiModel>())))      .called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('05. harus memanggil update saat mode edit', (tester) async {
      when(() => mockNavigatorObserver.didPop(any(), any())).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(announcement: tPengumuman));

      await tester.enterText(find.byKey(const Key('judul')), 'Judul Update');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      verify(() => mockNotifikasiOp.update(any(
              that: isA<NotifikasiModel>()
                ..having((n) => n.title, 'title', 'Judul Update'))))
          .called(1);
      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('06. harus menampilkan snackbar error jika terjadi kegagalan',
        (tester) async {
      when(() => mockNotifikasiOp.add(any())).thenThrow(Exception('Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byKey(const Key('judul')), 'Judul Baru');
      await tester.enterText(
          find.byKey(const Key('deskripsi')), 'Deskripsi Baru');

      await tester.tap(find.text('Kirim Notifikasi'));
      await tester.pumpAndSettle();

      expect(find.text('Gagal mengirim notifikasi'), findsOneWidget);
      verifyNever(() => mockNavigatorObserver.didPop(any(), any()));
    });
  });
}
