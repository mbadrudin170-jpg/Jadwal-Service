// path: lib/fitur/dompet/model/dompet_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/constant/nama_kolom.dart';
import 'package:wifi/shared/debug/log.dart';
import 'package:wifi/shared/model/has_id.dart';
import 'package:wifi/shared/utils/parser_util.dart';

part 'dompet_model.freezed.dart';

@freezed
abstract class DompetModel with _$DompetModel implements HasId {
  const DompetModel._();

  const factory DompetModel({
    @Default('') String id,
    required String nama,
    @Default(0.0) double saldo,
    DateTime? diperbaruiPada,
    @Default(false) bool diHapus,
    DateTime? diarsipkanPada,
  }) = _DompetModel;

  // Factory method untuk membuat instance dengan UUID otomatis (opsional)
  factory DompetModel.createNew({
    required String nama,
    double saldo = 0.0,
    DateTime? diperbaruiPada,
    bool diHapus = false,
    DateTime? diarsipkanPada,
  }) {
    final id = const Uuid().v4();
    Log.info('WalletModel created: $id, name: $nama');
    return DompetModel(
      id: id,
      nama: nama,
      saldo: saldo,
      diperbaruiPada: diperbaruiPada,
      diHapus: diHapus,
      diarsipkanPada: diarsipkanPada,
    );
  }

  // Method dari SQLite
  factory DompetModel.fromSqlite(final Map<String, dynamic> map) {
    final id = map[NamaKolom.id] as String?;
    return DompetModel(
      id: id ?? const Uuid().v4(), // generate UUID jika null
      nama: (map[NamaKolom.nama] as String?) ?? '',
      saldo: (map[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0,
      diperbaruiPada: ParserUtil.parseDateTime(map[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(map[NamaKolom.diHapus]),
      diarsipkanPada: ParserUtil.parseDateTime(map[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.saldo: saldo,
      NamaKolom.diperbaruiPada:
          (diperbaruiPada ?? DateTime.now()).millisecondsSinceEpoch,
      NamaKolom.diHapus: diHapus ? 1 : 0,
      NamaKolom.diarsipkanPada: diarsipkanPada?.millisecondsSinceEpoch,
    };
  }

  // Method dari Firebase
  factory DompetModel.fromFirebase(
      final String id, final Map<String, dynamic> data) {
    return DompetModel(
      id: id,
      nama: (data[NamaKolom.nama] as String?) ?? '',
      saldo: (data[NamaKolom.saldo] as num?)?.toDouble() ?? 0.0,
      diperbaruiPada: ParserUtil.parseDateTime(data[NamaKolom.diperbaruiPada]),
      diHapus: ParserUtil.parseBool(data[NamaKolom.diHapus]),
      diarsipkanPada: ParserUtil.parseDateTime(data[NamaKolom.diarsipkanPada]),
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      NamaKolom.id: id,
      NamaKolom.nama: nama,
      NamaKolom.saldo: saldo,
      NamaKolom.diHapus: diHapus,
      NamaKolom.diperbaruiPada:
          Timestamp.fromDate((diperbaruiPada ?? DateTime.now()).toUtc()),
      NamaKolom.diarsipkanPada: diarsipkanPada != null
          ? Timestamp.fromDate(diarsipkanPada!.toUtc())
          : null,
    };
  }
}
