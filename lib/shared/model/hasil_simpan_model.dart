// path: lib/model/hasil_simpan_model.dart

class HasilSimpanModel<T> {
  final bool sukses;
  final String pesan;
  final T? data;

  HasilSimpanModel({required this.sukses, required this.pesan, this.data});
}
