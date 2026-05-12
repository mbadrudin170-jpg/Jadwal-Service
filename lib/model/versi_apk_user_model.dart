
import 'dart:convert';

import 'package:admin_wifi/enum/enum.dart';

class VersiApkUserModel {
  String id;
  String versiTerbaru;
  Map<ArsitekturApkEnum, int> nomorBuildTerbaru;
  Map<ArsitekturApkEnum, String> urlUnduhan;
  DateTime tanggalRilis;
  String catatanRilis;
  bool isDeleted;
  DateTime? diarsipkan;
  DateTime? diperbarui;

  VersiApkUserModel({
    required this.id,
    required this.versiTerbaru,
    required this.nomorBuildTerbaru,
    required this.urlUnduhan,
    required this.tanggalRilis,
    required this.catatanRilis,
    this.isDeleted = false,
    this.diarsipkan,
    this.diperbarui,
  });

  VersiApkUserModel copyWith({
    String? id,
    String? versiTerbaru,
    Map<ArsitekturApkEnum, int>? nomorBuildTerbaru,
    Map<ArsitekturApkEnum, String>? urlUnduhan,
    DateTime? tanggalRilis,
    String? catatanRilis,
    bool? isDeleted,
    DateTime? diarsipkan,
    DateTime? diperbarui,
  }) {
    return VersiApkUserModel(
      id: id ?? this.id,
      versiTerbaru: versiTerbaru ?? this.versiTerbaru,
      nomorBuildTerbaru: nomorBuildTerbaru ?? this.nomorBuildTerbaru,
      urlUnduhan: urlUnduhan ?? this.urlUnduhan,
      tanggalRilis: tanggalRilis ?? this.tanggalRilis,
      catatanRilis: catatanRilis ?? this.catatanRilis,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
      diperbarui: diperbarui ?? this.diperbarui,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'versi_terbaru': versiTerbaru,
      'nomor_build_terbaru_universal': nomorBuildTerbaru[ArsitekturApkEnum.universal],
      'nomor_build_terbaru_arm64': nomorBuildTerbaru[ArsitekturApkEnum.arm64],
      'nomor_build_terbaru_x86_64': nomorBuildTerbaru[ArsitekturApkEnum.x86_64],
      'url_unduhan_universal': urlUnduhan[ArsitekturApkEnum.universal],
      'url_unduhan_arm64': urlUnduhan[ArsitekturApkEnum.arm64],
      'url_unduhan_x86_64': urlUnduhan[ArsitekturApkEnum.x86_64],
      'tanggal_rilis': tanggalRilis.toIso8601String(),
      'catatan_rilis': catatanRilis,
      'isDeleted': isDeleted ? 1 : 0,
      'diarsipkan': diarsipkan?.toIso8601String(),
      'diperbarui': diperbarui?.toIso8601String(),
    };
  }

  factory VersiApkUserModel.fromSqlite(Map<String, dynamic> map) {
    return VersiApkUserModel(
      id: map['id'],
      versiTerbaru: map['versi_terbaru'],
      nomorBuildTerbaru: {
        ArsitekturApkEnum.universal: map['nomor_build_terbaru_universal'],
        ArsitekturApkEnum.arm64: map['nomor_build_terbaru_arm64'],
        ArsitekturApkEnum.x86_64: map['nomor_build_terbaru_x86_64'],
      },
      urlUnduhan: {
        ArsitekturApkEnum.universal: map['url_unduhan_universal'],
        ArsitekturApkEnum.arm64: map['url_unduhan_arm64'],
        ArsitekturApkEnum.x86_64: map['url_unduhan_x86_64'],
      },
      tanggalRilis: DateTime.parse(map['tanggal_rilis']),
      catatanRilis: map['catatan_rilis'],
      isDeleted: map['isDeleted'] == 1,
      diarsipkan: map['diarsipkan'] != null ? DateTime.parse(map['diarsipkan']) : null,
      diperbarui: map['diperbarui'] != null ? DateTime.parse(map['diperbarui']) : null,
    );
  }

  String toJson() => json.encode(toSqlite());

  factory VersiApkUserModel.fromJson(String source) => VersiApkUserModel.fromSqlite(json.decode(source));

  @override
  String toString() {
    return 'VersiApkUserModel(id: $id, versiTerbaru: $versiTerbaru, nomorBuildTerbaru: $nomorBuildTerbaru, urlUnduhan: $urlUnduhan, tanggalRilis: $tanggalRilis, catatanRilis: $catatanRilis, isDeleted: $isDeleted, diarsipkan: $diarsipkan, diperbarui: $diperbarui)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VersiApkUserModel &&
      other.id == id &&
      other.versiTerbaru == versiTerbaru &&
      mapEquals(other.nomorBuildTerbaru, nomorBuildTerbaru) &&
      mapEquals(other.urlUnduhan, urlUnduhan) &&
      other.tanggalRilis == tanggalRilis &&
      other.catatanRilis == catatanRilis &&
      other.isDeleted == isDeleted &&
      other.diarsipkan == diarsipkan &&
      other.diperbarui == diperbarui;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      versiTerbaru.hashCode ^
      nomorBuildTerbaru.hashCode ^
      urlUnduhan.hashCode ^
      tanggalRilis.hashCode ^
      catatanRilis.hashCode ^
      isDeleted.hashCode ^
      diarsipkan.hashCode ^
      diperbarui.hashCode;
  }
}

bool mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  for (final T key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
}
