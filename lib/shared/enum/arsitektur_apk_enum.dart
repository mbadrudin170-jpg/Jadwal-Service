// path: lib/shared/enum/arsitektur_apk_enum.dart

/// Jenis arsitektur aplikasi yang didukung.
enum ArsitekturApkEnum {
  /// Aplikasi 32-bit.
  bit_32,

  /// Aplikasi 64-bit.
  bit_64,

  /// Aplikasi universal (mendukung 32-bit dan 64-bit).
  universal,

  /// Aplikasi untuk arsitektur ARM64.
  arm64,

  /// Aplikasi untuk arsitektur x86_64.
  x86_64,
}
