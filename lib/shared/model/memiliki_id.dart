// path: lib/shared/model/memiliki_id.dart

/// Interface untuk model yang memiliki properti ID.
///
/// Semua model dalam aplikasi yang memerlukan identitas unik
/// harus mengimplementasikan interface ini.
///
/// Contoh:
/// ```dart
/// class UserModel implements MemilikiId {
///   @override
///   final String id;
///
///   UserModel({required this.id});
/// }
/// ```
abstract class MemilikiId {
  /// ID unik untuk setiap model.
  ///
  /// Biasanya menggunakan UUID v4 atau ID dari database.
  String get id;
}
