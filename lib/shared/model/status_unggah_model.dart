import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';

part 'status_unggah_model.freezed.dart';

const String namaTabel = 'upload_status';
const String idNeedUpload = 'need_upload';

@freezed
abstract class StatusUnggahModel with _$StatusUnggahModel {
  const StatusUnggahModel._();

  factory StatusUnggahModel({
    @Default(idNeedUpload) String id, // HAPUS 'required'
    required bool butuhUnggah, // TETAP required (tanpa default)
    DateTime? diperbaruiPada,
  }) = _StatusUnggahModel;

  factory StatusUnggahModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[NamaKolom.diperbaruiPada] as int?;

    final model = StatusUnggahModel(
      id: map[NamaKolom.id] as String,
      butuhUnggah: map[NamaKolom.value] == '1',
      diperbaruiPada: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.butuhUnggah}');
    return model;
  }

  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      NamaKolom.id: id,
      NamaKolom.value: butuhUnggah ? '1' : '0',
      NamaKolom.diperbaruiPada: diperbaruiPada?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  @override
  String toString() {
    return 'UploadStatusModel(id: $id, needUpload: $butuhUnggah, diperbaruiPada: $diperbaruiPada)';
  }
}
