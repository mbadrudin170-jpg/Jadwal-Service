// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransaksiModelAdapter extends TypeAdapter<TransaksiModel> {
  @override
  final int typeId = 0;

  @override
  TransaksiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransaksiModel(
      id: fields[0] as String,
      tanggal: fields[1] as DateTime,
      keterangan: fields[2] as String,
      jumlah: fields[3] as double,
      tipe: fields[4] as TipeTransaksiEnum,
      idDompet: fields[5] as String,
      idKategori: fields[6] as String,
      idDompetTujuan: fields[7] as String?,
      idPelanggan: fields[8] as String?,
      idPaket: fields[9] as String?,
      idSubKategori: fields[10] as String?,
      statusPembayaran: fields[11] as StatusPembayaranEnum,
      poinYangDihasilkan: fields[12] as int,
      poinYangDigunakan: fields[13] as int,
      diperbarui: fields[14] as DateTime?,
      diarsipkan: fields[15] as DateTime?,
      isDeleted: fields[16] as bool,
      durasiPaket: fields[17] as int?,
      tipeDurasiPaket: fields[18] as TipeDurasi?,
      tanggalMulai: fields[19] as DateTime?,
      tanggalBerakhir: fields[20] as DateTime?,
      aktivasiPaket: fields[21] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TransaksiModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tanggal)
      ..writeByte(2)
      ..write(obj.keterangan)
      ..writeByte(3)
      ..write(obj.jumlah)
      ..writeByte(4)
      ..write(obj.tipe)
      ..writeByte(5)
      ..write(obj.idDompet)
      ..writeByte(6)
      ..write(obj.idKategori)
      ..writeByte(7)
      ..write(obj.idDompetTujuan)
      ..writeByte(8)
      ..write(obj.idPelanggan)
      ..writeByte(9)
      ..write(obj.idPaket)
      ..writeByte(10)
      ..write(obj.idSubKategori)
      ..writeByte(11)
      ..write(obj.statusPembayaran)
      ..writeByte(12)
      ..write(obj.poinYangDihasilkan)
      ..writeByte(13)
      ..write(obj.poinYangDigunakan)
      ..writeByte(14)
      ..write(obj.diperbarui)
      ..writeByte(15)
      ..write(obj.diarsipkan)
      ..writeByte(16)
      ..write(obj.isDeleted)
      ..writeByte(17)
      ..write(obj.durasiPaket)
      ..writeByte(18)
      ..write(obj.tipeDurasiPaket)
      ..writeByte(19)
      ..write(obj.tanggalMulai)
      ..writeByte(20)
      ..write(obj.tanggalBerakhir)
      ..writeByte(21)
      ..write(obj.aktivasiPaket);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransaksiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
