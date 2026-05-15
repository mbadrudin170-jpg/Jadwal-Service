// path: lib/shared/model/paket_model.dart
// diubah: Menambahkan anotasi Hive dan file part untuk TipeDurasi.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi/shared/model/memiliki_id.dart';

part 'paket_model.g.dart';

/// Enum untuk tipe durasi paket.
@HiveType(typeId: 4) // typeId unik untuk enum ini
enum TipeDurasi {
  /// Durasi dalam hitungan menit.
  @HiveField(0)
  menit,

  /// Durasi dalam hitungan jam.
  @HiveField(1)
  jam,

  /// Durasi dalam hitungan hari.
  @HiveField(2)
  hari,

  /// Durasi dalam hitungan bulan.
  @HiveField(3)
  bulan;

  /// Mendapatkan nama tampilan untuk setiap tipe durasi.
  String get displayName => switch (this) {
        TipeDurasi.menit => 'Menit',
        TipeDurasi.jam => 'Jam',
        TipeDurasi.hari => 'Hari',
        TipeDurasi.bulan => 'Bulan',
      };
}

/// Model untuk paket yang ditawarkan.
class PaketModel implements MemilikiId {
  /// ID unik untuk setiap paket.
  @override
  final String id;

  /// Nama paket.
  final String nama;

  /// Harga paket.
  final int harga;

  /// Durasi paket.
  final int durasi;

  /// Tipe durasi paket.
  final TipeDurasi tipe;

  /// Jumlah poin yang diberikan sebagai hadiah saat membeli paket ini.
  final int poinHadiah;

  /// Jumlah poin yang dibutuhkan untuk menukarkan paket ini.
  final int poinPenukaran;

  /// Status apakah paket ini bersifat publik atau tidak.
  final bool isPublic;

  /// Waktu terakhir data diperbarui.
  final DateTime? diperbarui;

  /// Status apakah paket ini sudah dihapus (soft delete).
  final bool isDeleted;

  /// Waktu paket ini diarsipkan.
  final DateTime? diarsipkan;

  /// Konstruktor untuk `PaketModel`.
  PaketModel({
    final String? id,
    required this.nama,
    required this.harga,
    required this.durasi,
    required this.tipe,
    this.poinHadiah = 0,
    this.poinPenukaran = 0,
    this.isPublic = true,
    this.diperbarui,
    this.isDeleted = false,
    this.diarsipkan,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dari [PaketModel] dengan beberapa nilai yang diubah.
  ///
  /// Semua parameter bersifat opsional. Jika tidak diisi, nilai dari instance
  /// saat ini akan digunakan.
  ///
  /// Contoh penggunaan:
  /// ```dart
  /// final paketBaru = paket.copyWith(harga: 75000);
  /// ```
  PaketModel copyWith({
    final String? id,
    final String? nama,
    final int? harga,
    final int? durasi,
    final TipeDurasi? tipe,
    final int? poinHadiah,
    final int? poinPenukaran,
    final bool? isPublic,
    final DateTime? diperbarui,
    final bool? isDeleted,
    final DateTime? diarsipkan,
  }) {
    return PaketModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      durasi: durasi ?? this.durasi,
      tipe: tipe ?? this.tipe,
      poinHadiah: poinHadiah ?? this.poinHadiah,
      poinPenukaran: poinPenukaran ?? this.poinPenukaran,
      isPublic: isPublic ?? this.isPublic,
      diperbarui: diperbarui ?? this.diperbarui,
      isDeleted: isDeleted ?? this.isDeleted,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }

  /// Helper untuk mengurai nilai tanggal dari berbagai format.
  static DateTime? parseDateTime(final dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }


  /// Helper untuk mengurai nilai boolean dari berbagai format.
  static bool parseBool(final Object? value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Helper untuk mengurai nilai TipeDurasi dari String.
  static TipeDurasi parseTipe(final dynamic value) {
    return TipeDurasi.values.firstWhere(
      (final e) => e.name == value,
      orElse: () => TipeDurasi.hari,
    );
  }

  /// Membuat instance `PaketModel` dari data Map SQLite.
  factory PaketModel.fromSqlite(final Map<String, dynamic> map) {
    return PaketModel(
      id: map['id'] as String?,
      nama: map['nama'] as String? ?? '',
      harga: map['harga'] as int? ?? 0,
      durasi: map['durasi'] as int? ?? 0,
      tipe: parseTipe(map['tipe']),
      poinHadiah: map['poin_hadiah'] as int? ?? 0,
      poinPenukaran: map['poin_penukaran'] as int? ?? 0,
      isPublic: parseBool(map['isPublic']),
      isDeleted: parseBool(map['isDeleted']),
      diperbarui: parseDateTime(map['diperbarui']),
      diarsipkan: parseDateTime(map['diarsipkan']),
    );
  }

  /// Mengonversi `PaketModel` ke format Map untuk disimpan di SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'poin_hadiah': poinHadiah,
      'poin_penukaran': poinPenukaran,
      'isPublic': isPublic ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
      'diarsipkan': diarsipkan?.millisecondsSinceEpoch,
    };
  }

  /// Membuat instance `PaketModel` dari data Map Firebase.
  factory PaketModel.fromFirebase(final String id, final Map<String, dynamic> data) {
    return PaketModel(
      id: id,
      nama: data['nama'] as String? ?? '',
      harga: data['harga'] as int? ?? 0,
      durasi: data['durasi'] as int? ?? 0,
      tipe: parseTipe(data['tipe']),
      poinHadiah: data['poin_hadiah'] as int? ?? 0,
      poinPenukaran: data['poin_penukaran'] as int? ?? 0,
      isPublic: parseBool(data['isPublic']),
      isDeleted: parseBool(data['isDeleted']),
      diperbarui: parseDateTime(data['diperbarui']),
      diarsipkan: parseDateTime(data['diarsipkan']),
    );
  }

  /// Mengonversi `PaketModel` ke format Map untuk disimpan di Firebase.
  Map<String, dynamic> toFirebase() {
    final Map<String, dynamic> data = {
      'id': id,
      'nama': nama,
      'harga': harga,
      'durasi': durasi,
      'tipe': tipe.name,
      'poin_hadiah': poinHadiah,
      'poin_penukaran': poinPenukaran,
      'isPublic': isPublic,
      'isDeleted': isDeleted,
      'diperbarui': diperbarui != null
          ? Timestamp.fromDate(diperbarui!)
          : FieldValue.serverTimestamp(),
    };
    if (diarsipkan != null) {
      data['diarsipkan'] = Timestamp.fromDate(diarsipkan!);
    }
    return data;
  }
}
