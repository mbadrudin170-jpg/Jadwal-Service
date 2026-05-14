// path: lib/shared/theme/app_text_style.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wifi/shared/debug/log.dart';

/// Mendefinisikan gaya teks yang konsisten untuk seluruh aplikasi.
///
/// TextTheme ini menggunakan 'Poppins' untuk judul, memberikan tampilan modern dan bersih,
/// sementara 'Open Sans' digunakan untuk teks isi, memastikan keterbacaan yang tinggi.
/// Penggunaan tema teks terpusat ini menjamin konsistensi visual
/// di seluruh aplikasi admin dan pengguna.
final TextTheme appTextTheme = TextTheme(
  displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
  displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold),
  displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
  headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium:
      GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
  headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500),
  titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
  titleMedium: GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyLarge: GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  ),
  bodyMedium: GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  ),
  bodySmall: GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  ),
  labelLarge: GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  ),
  labelMedium: GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  labelSmall: GoogleFonts.openSans(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  ),
);

/// Mencatat log saat TextTheme dibuat untuk tujuan debugging.
void logTextThemeCreation() {
  Log.info(
    'TextTheme terpusat dari app_text_style.dart telah berhasil dibuat dan diterapkan.',
  );
}
