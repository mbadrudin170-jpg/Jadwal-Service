// path: lib/shared/enum/apk_architecture_enum.dart

/// Jenis arsitektur aplikasi yang didukung.
enum ApkArchitectureEnum {
  /// Aplikasi 32-bit.
  bit32,

  /// Aplikasi 64-bit.
  bit64,

  /// Aplikasi universal (mendukung 32-bit dan 64-bit).
  universal,


  /// Aplikasi untuk arsitektur x86_64.
  x86_64, arm64,
}
