// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_pembayaran_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatusPembayaranEnumAdapter extends TypeAdapter<StatusPembayaranEnum> {
  @override
  final int typeId = 2;

  @override
  StatusPembayaranEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StatusPembayaranEnum.lunas;
      case 1:
        return StatusPembayaranEnum.belumLunas;
      case 2:
        return StatusPembayaranEnum.pending;
      default:
        return StatusPembayaranEnum.lunas;
    }
  }

  @override
  void write(BinaryWriter writer, StatusPembayaranEnum obj) {
    switch (obj) {
      case StatusPembayaranEnum.lunas:
        writer.writeByte(0);
        break;
      case StatusPembayaranEnum.belumLunas:
        writer.writeByte(1);
        break;
      case StatusPembayaranEnum.pending:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusPembayaranEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
