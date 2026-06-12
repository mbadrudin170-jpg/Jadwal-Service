// path: lib/shared/model/upload_status_model.dart

import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';

class UploadStatusModel {
  static const String tableName = 'upload_status';

  static const String idNeedUpload = 'need_upload';

  final String id;
  final bool needUpload;
  final DateTime? updatedAt;

  const UploadStatusModel({
    required this.id,
    required this.needUpload,
    this.updatedAt,
  });
  factory UploadStatusModel.create({
    required final String id,
    required final bool needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel dibuat: id=$id, needUpload=$needUpload');
    return UploadStatusModel(
      id: id,
      needUpload: needUpload,
      updatedAt: updatedAt,
    );
  }

  factory UploadStatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[NamaKolom.updatedAt] as int?;

    final model = UploadStatusModel(
      id: map[NamaKolom.id] as String,
      needUpload: map[NamaKolom.value] == '1',
      updatedAt: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.needUpload}');
    return model;
  }

  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      NamaKolom.id: id,
      NamaKolom.value: needUpload ? '1' : '0',
      NamaKolom.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  UploadStatusModel copyWith({
    final String? id,
    final bool? needUpload,
    final DateTime? updatedAt,
  }) {
    Log.info('UploadStatusModel.copyWith: id=$id, needUpload=$needUpload');

    return UploadStatusModel(
      id: id ?? this.id,
      needUpload: needUpload ?? this.needUpload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UploadStatusModel(id: $id, needUpload: $needUpload, updatedAt: $updatedAt)';
  }
}
