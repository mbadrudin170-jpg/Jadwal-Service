// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipeDurasiAdapter extends TypeAdapter<TipeDurasi> {
  @override
  final int typeId = 4;

  @override
  TipeDurasi read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipeDurasi.menit;
      case 1:
        return TipeDurasi.jam;
      case 2:
        return TipeDurasi.hari;
      case 3:
        return TipeDurasi.bulan;
      default:
        return TipeDurasi.menit;
    }
  }

  @override
  void write(BinaryWriter writer, TipeDurasi obj) {
    switch (obj) {
      case TipeDurasi.menit:
        writer.writeByte(0);
        break;
      case TipeDurasi.jam:
        writer.writeByte(1);
        break;
      case TipeDurasi.hari:
        writer.writeByte(2);
        break;
      case TipeDurasi.bulan:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipeDurasiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
