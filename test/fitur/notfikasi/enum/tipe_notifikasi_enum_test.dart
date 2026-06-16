// path: test/fitur/notfikasi/enum/tipe_notifikasi_enum_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi/fitur/notfikasi/enum/tipe_notifikasi_enum.dart';

void main() {
  group('TipeNotifikasiExtension', () {
    test('01. harus mengembalikan "Transaksi" untuk TipeNotifikasiEnum.transaksi',
        () {
      // Assert
      expect(TipeNotifikasiEnum.transaksi.displayName, 'Transaksi');
    });

    test('02. harus mengembalikan "Event" untuk TipeNotifikasiEnum.events', () {
      // Assert
      expect(TipeNotifikasiEnum.events.displayName, 'Event');
    });

    test('03. harus mengembalikan "Pesanan" untuk TipeNotifikasiEnum.order',
        () {
      // Assert
      expect(TipeNotifikasiEnum.order.displayName, 'Pesanan');
    });

    test('04. harus mengembalikan "Info" untuk TipeNotifikasiEnum.info', () {
      // Assert
      expect(TipeNotifikasiEnum.info.displayName, 'Info');
    });
  });
}
