// path: lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:wifi/shared/theme/app_colors.dart';
import 'package:wifi/shared/theme/app_sizes.dart';

// Gaya teks sekarang didefinisikan langsung di sini untuk isolasi tema.
// Ini mencegah "kebocoran" gaya antara mode terang dan gelap.

// 1. Definisikan TextTheme dasar tanpa warna.
const TextTheme _baseTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: 'Inter',
    fontSize: 57,
    fontWeight: FontWeight.bold,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: 45,
    fontWeight: FontWeight.bold,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: 36,
    fontWeight: FontWeight.bold,
  ),
  headlineLarge: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p32,
    fontWeight: FontWeight.bold,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p24,
    fontWeight: FontWeight.w500,
  ),
  titleLarge: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p20,
    fontWeight: FontWeight.w500,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ),
  bodyLarge: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  ),
  labelLarge: TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Inter',
    fontSize: TSizes.p8, // Anda sudah mengubah ini dari 10, saya pertahankan.
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  ),
);

// 2. Buat TextTheme spesifik untuk mode terang dengan menerapkan warna hitam.
final TextTheme _teksModeTerang = _baseTextTheme.apply(
  bodyColor: Colors.black87,
  displayColor: Colors.black87,
);

// 3. Buat TextTheme spesifik untuk mode gelap dengan menerapkan warna putih.
final TextTheme _teksModeGelap = _baseTextTheme.apply(
  bodyColor: Colors.white,
  displayColor: Colors.white,
);

/// Kelas ini mendefinisikan tema terang dan gelap untuk aplikasi,
/// termasuk skema warna, tipografi, dan gaya komponen.
class AppTheme {
  /// Definisi tema terang (light theme).
  static final ThemeData modeTerang = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: TColors.primaryColor,
    scaffoldBackgroundColor: TColors.lightBackground,
    colorScheme: ColorScheme.fromSeed(seedColor: TColors.primaryColor),
    textTheme:
        _teksModeTerang, // Menggunakan TextTheme terang yang sudah diisolasi
    appBarTheme: AppBarTheme(
      backgroundColor: TColors.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: _teksModeTerang.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: _teksModeTerang.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: TColors.primaryColor,
        textStyle: _teksModeTerang.labelLarge, // Ditambahkan
      ),
    ),
  );

  static final ThemeData modeGelap = ThemeData(
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
        _teksModeGelap, // Menggunakan TextTheme gelap yang sudah diisolasi
    appBarTheme: AppBarTheme(
      backgroundColor: TColors.darkSurface,
      foregroundColor: Colors.white,
      titleTextStyle: _teksModeGelap.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardThemeData(color: TColors.darkSurface),
    listTileTheme: ListTileThemeData(
      subtitleTextStyle: _teksModeGelap.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: TColors.lightBackground,
        backgroundColor: TColors.darkBackground,
        textStyle: _teksModeGelap.labelLarge, // Ditambahkan
      ),
    ),
  );
}

/// Extension untuk memudahkan akses [TextTheme] dan [ColorScheme] melalui context.
extension ThemeContext on BuildContext {
  /// Memudahkan akses ke textTheme: context.textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Memudahkan akses ke colorScheme: context.colorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
