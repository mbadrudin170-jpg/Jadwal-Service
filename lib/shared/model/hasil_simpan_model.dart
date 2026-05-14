// path: lib/model/hasil_simpan_model.dart

/// Model generik untuk merepresentasikan hasil dari operasi penyimpanan (simpan/update).
class HasilSimpanModel<T> {
  /// Menandakan apakah operasi berhasil atau tidak.
  final bool sukses;

  /// Pesan yang memberikan detail lebih lanjut tentang hasil operasi.
  final String pesan;

  /// Data opsional yang mungkin dikembalikan setelah operasi berhasil.
  final T? data;

  /// Konstruktor untuk `HasilSimpanModel`.
  HasilSimpanModel({required this.sukses, required this.pesan, this.data});
}
