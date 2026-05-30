// path: lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_colors.dart';

// Gaya teks sekarang didefinisikan langsung di sini untuk isolasi tema.
// Ini mencegah "kebocoran" gaya antara mode terang dan gelap.

// 1. Definisikan TextTheme dasar tanpa warna.
const TextTheme _baseTextTheme = TextTheme(
  displayLarge: TextStyle(
      fontFamily: 'Poppins', fontSize: 57, fontWeight: FontWeight.bold),
  displayMedium: TextStyle(
      fontFamily: 'Poppins', fontSize: 45, fontWeight: FontWeight.bold),
  displaySmall: TextStyle(
      fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.bold),
  headlineLarge: TextStyle(
      fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(
      fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold),
  headlineSmall: TextStyle(
      fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w500),
  titleLarge: TextStyle(
      fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w500),
  titleMedium: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15),
  titleSmall: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1),
  bodyLarge: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5),
  bodyMedium: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25),
  bodySmall: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4),
  labelLarge: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25),
  labelMedium: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5),
  labelSmall: TextStyle(
      fontFamily: 'Open Sans',
      fontSize: 10,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.5),
);

// 2. Buat TextTheme spesifik untuk mode terang dengan menerapkan warna hitam.
final TextTheme _lightTextTheme = _baseTextTheme.apply(
  bodyColor: Colors.black87,
  displayColor: Colors.black87,
);

// 3. Buat TextTheme spesifik untuk mode gelap dengan menerapkan warna putih.
final TextTheme _darkTextTheme = _baseTextTheme.apply(
  bodyColor: Colors.white,
  displayColor: Colors.white,
);

/// Kelas ini mendefinisikan tema terang dan gelap untuk aplikasi,
/// termasuk skema warna, tipografi, dan gaya komponen.
class AppTheme {
  /// Definisi tema terang (light theme).
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: TColors.primaryColor,
    scaffoldBackgroundColor: TColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TColors.primaryColor,
    ),
    textTheme:
        _lightTextTheme, // Menggunakan TextTheme terang yang sudah diisolasi
    appBarTheme: AppBarTheme(
      backgroundColor: TColors.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle:
          _lightTextTheme.headlineSmall?.copyWith(color: Colors.white),
    ),
    listTileTheme: ListTileThemeData(
      // Tidak perlu override warna di sini lagi, akan diwariskan dari _lightTextTheme
      subtitleTextStyle:
          _lightTextTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: TColors.primaryColor,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: TColors.primaryColor,
    scaffoldBackgroundColor: TColors.darkBackground,
    canvasColor: TColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TColors.primaryColor,
      brightness: Brightness.dark,
      surface: TColors.darkSurface,
    ),
    textTheme:
        _darkTextTheme, // Menggunakan TextTheme gelap yang sudah diisolasi
    appBarTheme: AppBarTheme(
      backgroundColor: TColors.darkSurface,
      foregroundColor: Colors.white,
      titleTextStyle: _darkTextTheme.headlineSmall,
    ),
    cardTheme: const CardThemeData(
      color: TColors.darkSurface,
    ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle:
          _darkTextTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: TColors.lightBackground,
        backgroundColor: TColors.darkBackground,
      ),
    ),
  );
}
