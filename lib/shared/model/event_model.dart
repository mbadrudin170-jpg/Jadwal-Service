// path: lib/shared/model/event_model.dart

import 'package:wifi/shared/constant/column_names.dart';
import 'package:wifi/shared/model/has_id.dart';

/// Model data untuk Pengumuman (Event).
class EventModel implements HasId {
  /// Konstruktor untuk EventModel.
  EventModel({
    required this.id,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  final String id;

  /// URL gambar pengumuman.
  final String imageUrl;

  /// Status apakah pengumuman sedang aktif.
  final bool isActive;

  /// Tanggal dibuat.
  final DateTime createdAt;

  /// Tanggal diperbarui (opsional).
  final DateTime? updatedAt;

  /// Membuat instance [EventModel] dari Map (JSON).
  factory EventModel.fromMap(final Map<String, dynamic> map) {
    return EventModel(
      id: map[ColumnNames.id] as String? ?? '',
      imageUrl: map[ColumnNames.imageUrl] as String? ?? '',
      isActive: map[ColumnNames.isActive] as bool? ?? false,
      createdAt: map[ColumnNames.createdAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[ColumnNames.createdAt] as int)
          : DateTime.now(),
      updatedAt: map[ColumnNames.updatedAt] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[ColumnNames.updatedAt] as int)
          : null,
    );
  }

  /// Mengonversi instance [EventModel] ke Map (JSON).
  Map<String, dynamic> toMap() {
    return {
      ColumnNames.id: id,
      ColumnNames.imageUrl: imageUrl,
      ColumnNames.isActive: isActive,
      ColumnNames.createdAt: createdAt.millisecondsSinceEpoch,
      ColumnNames.updatedAt: updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Membuat salinan [EventModel] dengan beberapa properti yang diubah.
  EventModel copyWith({
    final String? id,
    final String? imageUrl,
    final bool? isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
