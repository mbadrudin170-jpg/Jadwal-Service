// path: lib/shared/model/status_unggah_model.dart

/// Model ini merepresentasikan satu baris tunggal dalam tabel `status_aplikasi`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diungga ke server.
class StatusUnggahModel {
  /// Nama tabel di database SQLite.
  static const String tableName = 'status_aplikasi';

  /// Kunci unik untuk baris status `perlu_unggah`.
  static const String idPerluUnggah = 'perlu_unggah';

  /// ID unik untuk baris ini, yang juga merupakan kuncinya (misalnya, 'perlu_unggah').
  final String id;

  /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
  /// `false` jika tidak.
  final bool perluUnggah;

  /// Waktu terakhir kali status `perluUnggah` diubah, disimpan sebagai milidetik sejak epoch.
  final DateTime? diperbarui;

  /// Konstruktor untuk `StatusUnggahModel`.
  StatusUnggahModel({
    required this.id,
    required this.perluUnggah,
    this.diperbarui,
  });

  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory StatusUnggahModel.fromSqlite(final Map<String, dynamic> map) {
    final diperbaruiEpoch = map['diperbarui'] as int?;
    return StatusUnggahModel(
      // Kunci 'id' di database kita adalah string
      id: map['id'] as String,
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai string ('0' atau '1') di kolom 'value'.
      perluUnggah: map['value'] == '1',
      // Konversi dari milidetik epoch kembali ke DateTime.
      diperbarui: diperbaruiEpoch != null
          ? DateTime.fromMillisecondsSinceEpoch(diperbaruiEpoch)
          : null,
    );
  }

  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      // Simpan sebagai string '0' atau '1' di kolom 'value'
      'value': perluUnggah ? '1' : '0',
      // Konversi DateTime ke milidetik sejak epoch agar bisa disimpan di SQLite sebagai INTEGER.
      'diperbarui': diperbarui?.millisecondsSinceEpoch,
    };
  }
}
