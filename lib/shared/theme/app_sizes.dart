// path: lib/shared/theme/app_sizes.dart

import 'package:flutter/widgets.dart';

/// Berisi konstanta untuk ukuran yang seragam di seluruh aplikasi,
/// seperti padding, margin, dan celah antar-widget.
///
/// Penggunaan:
/// - `Sizes.p8` untuk nilai `double` 8.0.
/// - `gapH8` untuk `SizedBox` dengan tinggi 8.0.
/// - `gapW8` untuk `SizedBox` dengan lebar 8.0.

class TSizes {
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p28 = 28.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;
  static const double p64 = 64.0;
  static const double p80 = 80.0;
}

/// Celah vertikal (Vertical gaps)
const gapH4 = SizedBox(height: TSizes.p4);
const gapH8 = SizedBox(height: TSizes.p8);
const gapH12 = SizedBox(height: TSizes.p12);
const gapH16 = SizedBox(height: TSizes.p16);
const gapH20 = SizedBox(height: TSizes.p20);
const gapH24 = SizedBox(height: TSizes.p24);
const gapH28 = SizedBox(height: TSizes.p28);
const gapH32 = SizedBox(height: TSizes.p32);
const gapH40 = SizedBox(height: TSizes.p40);
const gapH48 = SizedBox(height: TSizes.p48);
const gapH64 = SizedBox(height: TSizes.p64);

/// Celah horizontal (Horizontal gaps)
const gapW4 = SizedBox(width: TSizes.p4);
const gapW8 = SizedBox(width: TSizes.p8);
const gapW12 = SizedBox(width: TSizes.p12);
const gapW16 = SizedBox(width: TSizes.p16);
const gapW20 = SizedBox(width: TSizes.p20);
const gapW24 = SizedBox(width: TSizes.p24);
const gapW28 = SizedBox(width: TSizes.p28);
const gapW32 = SizedBox(width: TSizes.p32);
const gapW40 = SizedBox(width: TSizes.p40);
const gapW48 = SizedBox(width: TSizes.p48);
const gapW64 = SizedBox(width: TSizes.p64);
