// path: lib/shared/enum/tipe_notifikasi_enum.dart

enum TipeNotifikasiEnum {
  transaksi,
  events,
  order,
  info
}

extension TipeNotifikasiExtension on TipeNotifikasiEnum {
  String get displayName {
    switch (this) {
      case TipeNotifikasiEnum.transaksi:
        return 'Transaksi';
      case TipeNotifikasiEnum.events:
        return 'Event';
      case TipeNotifikasiEnum.order:
        return 'Pesanan';
        case TipeNotifikasiEnum.info:
        return 'Info';
      }
  }
}
