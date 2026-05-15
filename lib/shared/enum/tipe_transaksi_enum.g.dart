// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipe_transaksi_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipeTransaksiEnumAdapter extends TypeAdapter<TipeTransaksiEnum> {
  @override
  final int typeId = 1;

  @override
  TipeTransaksiEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipeTransaksiEnum.pemasukan;
      case 1:
        return TipeTransaksiEnum.pengeluaran;
      case 2:
        return TipeTransaksiEnum.transfer;
      default:
        return TipeTransaksiEnum.pemasukan;
    }
  }

  @override
  void write(BinaryWriter writer, TipeTransaksiEnum obj) {
    switch (obj) {
      case TipeTransaksiEnum.pemasukan:
        writer.writeByte(0);
        break;
      case TipeTransaksiEnum.pengeluaran:
        writer.writeByte(1);
        break;
      case TipeTransaksiEnum.transfer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipeTransaksiEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
