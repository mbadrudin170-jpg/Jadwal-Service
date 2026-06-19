// path: test/fitur/notfikasi/penjadwal_notifikasi_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wifi/fitur/notfikasi/layanan_notifikasi.dart';
import 'package:wifi/fitur/notfikasi/penjadwal_notifikasi.dart';
import 'package:wifi/fitur/transaksi/enum/status_pembayaran.dart';
import 'package:wifi/fitur/transaksi/enum/tipe_transaksi.dart';
import 'package:wifi/fitur/transaksi/model/transaksi_model.dart';
import 'package:wifi/fitur/transaksi/operasi/transaksi_op_firebase.dart';

import 'penjadwal_notifikasi_test.mocks.dart';

@GenerateMocks([LayananNotifikasi, TransaksiOpFirebase])
void main() {
  late MockLayananNotifikasi mockNotifikasiServis;
  late MockTransaksiOpFirebase mockTransaksiOp;

  // Mocking untuk AndroidAlarmManager yang menggunakan static method calls
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/android_alarm_manager');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    mockNotifikasiServis = MockLayananNotifikasi();
    mockTransaksiOp = MockTransaksiOpFirebase();

    TestWidgetsFlutterBinding.ensureInitialized();
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'oneShotAt' || methodCall.method == 'cancel') {
        return true;
      }
      return null;
    });
    log.clear();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  const userId = 'user123';
  final endNotificationId = userId.hashCode;
  final midNotificationId = '${userId}_midpoint'.hashCode;
  final alarmId = userId.hashCode;
  final now = DateTime.now();

  group('PenjadwalNotifikasi', () {
    test(
        '01. harus menjadwalkan notifikasi akhir & tengah periode untuk langganan aktif',
        () async {
      // Arrange
      final tanggalMulai = now.subtract(const Duration(days: 5));
      final tanggalBerakhir = now.add(const Duration(days: 25));
      final transaksi = TransaksiModel(
        id: 'trans1',
        tanggal: tanggalMulai,
        deskripsi: 'Langganan 30 hari',
        jumlah: 50000,
        tipe: TipeTransaksi.income,
        idDompet: 'dompet1',
        idKategori: 'kat1',
        idPelanggan: userId,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        statusPembayaran: StatusPembayaran.paid,
      );

      when(mockTransaksiOp.ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId))
          .thenAnswer((_) async => transaksi);
      when(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async {});

      // Act
      await PenjadwalNotifikasi.aturNotifikasiLangganan(
        mockNotifikasiServis,
        userId,
        transaksiOp: mockTransaksiOp,
      );

      // Assert
      // Verifikasi notifikasi akhir periode
      verify(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: endNotificationId,
        title: 'Langganan Telah Berakhir',
        body: anyNamed('body'),
        jadwal: tanggalBerakhir,
        payload: 'subscription_expired',
      )).called(1);

      // Verifikasi notifikasi tengah periode
      final totalDuration = tanggalBerakhir.difference(tanggalMulai);
      final midpointDate =
          tanggalMulai.add(Duration(seconds: totalDuration.inSeconds ~/ 2));
      verify(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: midNotificationId,
        title: 'Status Langganan Anda',
        body: anyNamed('body'),
        jadwal: midpointDate,
        payload: 'subscription_midpoint',
      )).called(1);

      // Verifikasi alarm manager
      expect(log.where((call) => call.method == 'oneShotAt'), isNotEmpty);
      final oneShotCall = log.firstWhere((call) => call.method == 'oneShotAt');
      expect(oneShotCall.arguments['alarmId'], alarmId);
      expect(oneShotCall.arguments['wakeup'], true);
      expect(oneShotCall.arguments['exact'], true);
    });

    test(
        '02. harus membatalkan notif tengah periode jika tanggalnya sudah lewat',
        () async {
      // Arrange
      final tanggalMulai = now.subtract(const Duration(days: 20));
      final tanggalBerakhir = now.add(const Duration(days: 10));
      final transaksi = TransaksiModel(
        id: 'trans1',
        tanggal: tanggalMulai,
        deskripsi: 'Langganan 30 hari',
        jumlah: 50000,
        tipe: TipeTransaksi.income,
        idDompet: 'dompet1',
        idKategori: 'kat1',
        idPelanggan: userId,
        tanggalMulai: tanggalMulai,
        tanggalBerakhir: tanggalBerakhir,
        statusPembayaran: StatusPembayaran.paid,
      );

      when(mockTransaksiOp.ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId))
          .thenAnswer((_) async => transaksi);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});
      when(mockNotifikasiServis.perbaruiJadwalNotifikasi(
              id: anyNamed('id'),
              title: anyNamed('title'),
              body: anyNamed('body'),
              jadwal: anyNamed('jadwal'),
              payload: anyNamed('payload')))
          .thenAnswer((_) async {});

      // Act
      await PenjadwalNotifikasi.aturNotifikasiLangganan(
        mockNotifikasiServis,
        userId,
        transaksiOp: mockTransaksiOp,
      );

      // Assert
      verify(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: endNotificationId,
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: tanggalBerakhir,
        payload: anyNamed('payload'),
      )).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(midNotificationId)).called(1);
      verifyNever(mockNotifikasiServis.perbaruiJadwalNotifikasi(
        id: midNotificationId,
        title: anyNamed('title'),
        body: anyNamed('body'),
        jadwal: anyNamed('jadwal'),
        payload: anyNamed('payload'),
      ));
    });

    test(
        '03. harus membatalkan semua notifikasi dan alarm jika tidak ada langganan',
        () async {
      // Arrange
      when(mockTransaksiOp.ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId))
          .thenAnswer((_) async => null);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});

      // Act
      await PenjadwalNotifikasi.aturNotifikasiLangganan(
        mockNotifikasiServis,
        userId,
        transaksiOp: mockTransaksiOp,
      );

      // Assert
      verify(mockNotifikasiServis.batalNotifikasi(endNotificationId)).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(midNotificationId)).called(1);
      expect(
          log,
          contains(isMethodCall('cancel',
              arguments: <String, dynamic>{'alarmId': alarmId})));
    });

    test(
        '04. harus membatalkan semua notifikasi dan alarm jika langganan sudah kedaluwarsa',
        () async {
      // Arrange
      final tanggalBerakhir = now.subtract(const Duration(minutes: 1));
      final transaksi = TransaksiModel(
        id: 'trans1',
        tanggal: DateTime(2023),
        deskripsi: 'expired',
        jumlah: 1,
        tipe: TipeTransaksi.income,
        idDompet: 'd',
        idKategori: 'k',
        tanggalBerakhir: tanggalBerakhir,
      );
      when(mockTransaksiOp.ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId))
          .thenAnswer((_) async => transaksi);
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});

      // Act
      await PenjadwalNotifikasi.aturNotifikasiLangganan(
        mockNotifikasiServis,
        userId,
        transaksiOp: mockTransaksiOp,
      );

      // Assert
      verify(mockNotifikasiServis.batalNotifikasi(endNotificationId)).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(midNotificationId)).called(1);
      expect(
          log,
          contains(isMethodCall('cancel',
              arguments: <String, dynamic>{'alarmId': alarmId})));
    });

    test('05. harus membatalkan semua notifikasi dan alarm jika terjadi error',
        () async {
      // Arrange
      when(mockTransaksiOp.ambilTransaksiLunasTerbaruBerdasarkanIdPelanggan(userId))
          .thenThrow(Exception('Firebase error'));
      when(mockNotifikasiServis.batalNotifikasi(any)).thenAnswer((_) async {});

      // Act
      await PenjadwalNotifikasi.aturNotifikasiLangganan(
        mockNotifikasiServis,
        userId,
        transaksiOp: mockTransaksiOp,
      );

      // Assert
      verify(mockNotifikasiServis.batalNotifikasi(endNotificationId)).called(1);
      verify(mockNotifikasiServis.batalNotifikasi(midNotificationId)).called(1);
      expect(
          log,
          contains(isMethodCall('cancel',
              arguments: <String, dynamic>{'alarmId': alarmId})));
    });
  });
}
