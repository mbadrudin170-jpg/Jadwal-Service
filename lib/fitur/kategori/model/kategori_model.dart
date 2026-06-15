// path: lib/fitur/kategori/model/kategori_model.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/export/enum.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/model/sub_category_model.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'kategori_model.freezed.dart';

@freezed
abstract class KategoriModel with _$KategoriModel implements HasId {
  const KategoriModel._(); // Private constructor untuk method custom

  const factory KategoriModel({
    @Default('') String id,
    required String nama,
    required TipeKategori tipe,
    @Default(<SubCategoryModel>[]) List<SubCategoryModel> idSubKategori,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _KategoriModel;

  // Factory method opsional untuk membuat instance dengan UUID otomatis
  factory KategoriModel.createNew({
    required String nama,
    required TipeKategori tipe,
    List<SubCategoryModel> idSubKategori = const [],
    DateTime? diperbaruiPada,
    bool diHapus = false,
    DateTime? diarsipkanPada,
  }) {
    final id = const Uuid().v4();
    Log.info('CategoryModel created: $id, name: $nama');
    return KategoriModel(
      id: id,
      nama: nama,
      tipe: tipe,
      idSubKategori: idSubKategori,
      diperbaruiPada: diperbaruiPada,
      diHapus: diHapus,
      diarsipkanPada: diarsipkanPada,
    );
  }

  // Helper untuk parsing enum dengan aman
  static T? _safeParseEnum<T extends Enum>(
    final List<T> values,
    final dynamic name,
  ) {
    if (name == null || name is! String) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    Log.warning('Failed to parse enum for type $T', name);
    return null;
  }

  // =========================
  // SQLITE
  // =========================

  factory KategoriModel.fromSqlite(final Map<String, dynamic> map) {
    List<SubCategoryModel> parseSubCategories(final dynamic data) {
      if (data == null) return [];
      try {
        if (data is String && data.isNotEmpty) {
          final list = jsonDecode(data) as List<dynamic>;
          return list
              .map((final item) {
                if (item is Map<String, dynamic>) {
                  return SubCategoryModel.fromSqlite(item);
                }
                return null;
              })
              .whereType<SubCategoryModel>()
              .toList();
        }
        return [];
      } on FormatException catch (e, st) {
        Log.error('Failed to parse subcategories from JSON', e: e, s: st);
        return [];
      }
    }

    return KategoriModel(
      id: map[NamaKolom.id] as String? ?? const Uuid().v4(),
      nama: map[NamaKolom.nama] as String? ?? '',
      tipe: _safeParseEnum(TipeKategori.values, map[NamaKolom.tipe]) ??
          TipeKategori.expense,
      idSubKategori: parseSubCategories(map[NamaKolom.idSubKategori]),
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idSubKategori: jsonEncode(
        idSubKategori.map((sub) => sub.toSqlite()).toList(),
      ),
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diHapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // =========================
  // FIREBASE
  // =========================

  factory KategoriModel.fromFirebase(
    final String id,
    final Map<String, dynamic> data,
  ) {
    List<SubCategoryModel> parseSubCategories(final dynamic subCategoryData) {
      if (subCategoryData is List) {
        return subCategoryData
            .map((final item) {
              if (item is Map<String, dynamic>) {
                final String subId =
                    item[NamaKolom.id] as String? ?? const Uuid().v4();
                return SubCategoryModel.fromFirebase(subId, item);
              }
              return null;
            })
            .whereType<SubCategoryModel>()
            .toList();
      }
      return [];
    }

    return KategoriModel(
      id: id,
      nama: data[NamaKolom.nama] as String? ?? '',
      tipe: _safeParseEnum(TipeKategori.values, data[NamaKolom.tipe]) ??
          TipeKategori.expense,
      idSubKategori: parseSubCategories(data[NamaKolom.idSubKategori]),
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.diHapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.tipe: tipe.name,
      NamaKolom.idSubKategori:
          idSubKategori.map((sub) => sub.toFirebase()).toList(),
      NamaKolom.diHapus: diHapus,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((diperbaruiPada ?? DateTime.now()).toUtc()),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
