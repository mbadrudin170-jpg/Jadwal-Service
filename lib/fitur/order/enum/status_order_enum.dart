// path: lib/fitur/order/enum/status_order_enum.dart

enum StatusOrderEnum {
  baru,
  diproses,
  selesai,
  ditolak,
  arsip;

  String get displayName {
    switch (this) {
      case StatusOrderEnum.baru:
        return 'Baru';
      case StatusOrderEnum.diproses:
        return 'Diproses';
      case StatusOrderEnum.selesai:
        return 'Selesai';
      case StatusOrderEnum.ditolak:
        return 'Ditolak';
      case StatusOrderEnum.arsip:
        return 'Arsip';
    }
  }
}
