// path: lib/shared/theme/app_theme.dart
// diubah: Memperbaiki kesalahan referensi warna dan properti shade.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wifi/shared/theme/app_colors.dart';

/// Kelas ini mendefinisikan tema terang dan gelap untuk aplikasi,
/// termasuk skema warna, tipografi, dan gaya komponen.
class AppTheme {
  // Tema umum untuk teks, menggunakan Google Fonts
  static final TextTheme _appTextTheme = TextTheme(
    displayLarge:
        GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium:
        GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.w500),
    displaySmall:
        GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w500),
    headlineLarge:
        GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium:
        GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall:
        GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500),
    titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge:
        GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium:
        GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall:
        GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.normal),
    labelSmall: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.normal),
  );

  /// Definisi tema terang (light theme).
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.lightBackground,
      error: AppColors.errorColor,
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle:
          _appTextTheme.headlineSmall?.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: _appTextTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Definisi tema gelap (dark theme).
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
      primary: AppColors.primaryColor,
      secondary: Colors.grey.shade300, // diubah: Menggunakan warna yang valid
      surface: AppColors.darkBackground,
      error:
          AppColors.errorColor.shade300, // diubah: Menggunakan shade yang valid
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      titleTextStyle:
          _appTextTheme.headlineSmall?.copyWith(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: _appTextTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
