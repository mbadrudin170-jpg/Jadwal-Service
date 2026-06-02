// path: lib/shared/model/upload_status_model.dart

import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/debug/log.dart';

/// Model ini merepresentasikan satu baris tunggal dalam tabel `upload_status`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
class UploadStatusModel {
  /// Nama tabel di database SQLite.
  static const String tableName = 'upload_status';

  /// Kunci unik untuk baris status `need_upload`.
  static const String idNeedUpload = 'need_upload';

  /// ID unik untuk baris ini, yang juga merupakan kuncinya (misalnya, 'need_upload').
  final String id;
  final bool needUpload;

  /// Waktu terakhir kali status `needUpload` diubah, disimpan sebagai milidetik sejak epoch.
  final DateTime? updatedAt;

  /// Konstruktor untuk `UploadStatusModel`.
  const UploadStatusModel({
    required this.id,
    required this.needUpload,
    this.updatedAt,
  });

  /// Membuat instance UploadStatusModel dengan logging.
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

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory UploadStatusModel.fromSqlite(final Map<String, dynamic> map) {
    Log.info('Memulai konversi dari SQLite Map ke UploadStatusModel');

    final updatedAtEpoch = map[ColumnNames.updatedAt] as int?;

    final model = UploadStatusModel(
      id: map[ColumnNames.id] as String,
      needUpload: map[ColumnNames.value] == '1',
      updatedAt: updatedAtEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(updatedAtEpoch)
          : null,
    );

    Log.info(
        'Konversi ke UploadStatusModel berhasil: id=${model.id}, needUpload=${model.needUpload}');
    return model;
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    Log.info('Memulai konversi UploadStatusModel ke SQLite Map: id=$id');

    final map = <String, dynamic>{
      ColumnNames.id: id,
      ColumnNames.value: needUpload ? '1' : '0',
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };

    Log.info('Konversi ke SQLite Map berhasil: $map');
    return map;
  }

  /// Membuat salinan dari model ini dengan nilai yang diperbarui.
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
