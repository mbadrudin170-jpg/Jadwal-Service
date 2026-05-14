// path: lib/shared/model/status_unggah_model.dart


/// Model ini merepresentasikan satu baris tunggal dalam tabel `status_unggah`.
/// Tujuannya adalah untuk bertindak sebagai "bendera" global yang menandakan
/// apakah ada perubahan lokal yang perlu diunggah ke server.
class StatusUnggahModel {
  /// ID unik untuk baris ini, biasanya akan selalu 1.
  final int id;

  /// Bendera yang menandakan status. `true` jika ada data untuk diunggah,
  /// `false` jika tidak.
  final bool perluUnggah;

  /// Konstruktor untuk `StatusUnggahModel`.
  StatusUnggahModel({required this.id, required this.perluUnggah});

  // diubah: Nama metode diubah dari fromMap menjadi fromSqlite agar lebih jelas tujuannya
  /// Konversi dari Map (yang didapat dari database SQLite) ke model.
  factory StatusUnggahModel.fromSqlite(Map<String, dynamic> map) {
    return StatusUnggahModel(
      id: map['id'] as int,
      // Database SQLite tidak punya tipe boolean, jadi kita simpan sebagai integer (0 atau 1).
      // Konversi 1 menjadi true, dan lainnya menjadi false.
      perluUnggah: map['perlu_unggah'] == 1,
    );
  }

  // diubah: Nama metode diubah dari toMap menjadi toSqlite agar lebih jelas tujuannya
  /// Konversi dari model ke Map untuk disimpan ke database SQLite.
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'perlu_unggah': perluUnggah ? 1 : 0, // Simpan sebagai integer
    };
  }
}
