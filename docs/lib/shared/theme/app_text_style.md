# Dokumentasi: `lib/shared/theme/app_text_style.dart`

File ini mendefinisikan objek `TextTheme` global bernama `appTextTheme`. Tujuannya adalah untuk menyediakan satu sumber kebenaran (single source of truth) untuk semua gaya teks yang digunakan di seluruh aplikasi, memastikan konsistensi tipografi dan mempermudah pemeliharaan.

---

## Arsitektur dan Desain

1.  **Konfigurasi Terpusat**: Daripada mendefinisikan `TextStyle` secara manual di setiap widget, aplikasi ini mengadopsi praktik terbaik dengan membuat satu objek `TextTheme` yang komprehensif. Objek ini kemudian diintegrasikan ke dalam `ThemeData` aplikasi, membuatnya tersedia secara otomatis untuk semua widget di bawah pohon `MaterialApp`.

2.  **Pemanfaatan `google_fonts`**: Proyek ini menggunakan pustaka `google_fonts`, yang merupakan cara paling efisien dan direkomendasikan untuk menggunakan font dari Google Fonts di Flutter. Pustaka ini menangani pengunduhan font secara otomatis saat runtime (jika belum di-cache) dan memungkinkan pengembang untuk mereferensikan font hanya dengan namanya, tanpa perlu mengunduh file font secara manual dan mendaftarkannya di `pubspec.yaml`.

3.  **Pemilihan Font yang Disengaja**: Ada pilihan desain yang jelas dalam pemilihan font:
    -   **Poppins** untuk judul (`display*`, `headline*`, `titleLarge`): Ini memberikan tampilan yang modern, bersih, dan sedikit tegas, cocok untuk teks yang lebih besar dan menarik perhatian.
    -   **Open Sans** untuk teks isi dan label (`titleMedium`, `titleSmall`, `body*`, `label*`): Font ini dikenal dengan keterbacaannya yang sangat baik dalam ukuran kecil dan untuk blok teks yang panjang, menjadikannya pilihan yang solid untuk konten utama aplikasi.
    
    Kombinasi dua font ini (sebuah *font pairing*) adalah teknik desain umum untuk menciptakan hierarki visual dan minat estetika.

4.  **Kepatuhan pada Skala Tipe Material Design**: Nama-nama gaya (`displayLarge`, `headlineMedium`, `bodySmall`, dll.) sesuai dengan skala tipe yang didefinisikan dalam pedoman Material Design. Mengikuti konvensi ini memudahkan pengembang untuk menerapkan gaya yang benar sesuai dengan peran semantiknya. Misalnya, judul halaman utama kemungkinan akan menggunakan `headlineMedium`, sementara teks paragraf biasa akan menggunakan `bodyMedium`.

5.  **Logging untuk Debugging**: Seperti file tema lainnya, file ini menyertakan fungsi `logTextThemeCreation`. Ini adalah sentuhan yang bagus untuk pengembangan, memungkinkan konfirmasi di log bahwa tema teks kustom memang sedang dibuat dan diterapkan saat aplikasi dimulai.

---

## Penggunaan

Objek `appTextTheme` tidak dimaksudkan untuk digunakan secara langsung di dalam widget. Sebaliknya, ia disuntikkan ke dalam `ThemeData` aplikasi.

**Integrasi Tema (di `app_theme.dart`):**

```dart
// Di dalam file definisi tema (misalnya, app_theme.dart)
import 'package:wifi/shared/theme/app_text_style.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  // ... properti lain
  textTheme: appTextTheme, // Di sini appTextTheme diterapkan
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  // ... properti lain
  textTheme: appTextTheme, // Diterapkan juga untuk tema gelap
);
```

**Penggunaan di Widget (Secara Implisit):**

Setelah tema diterapkan, widget secara otomatis akan menggunakan gaya yang benar melalui `Theme.of(context).textTheme`.

```dart
// Di dalam metode build sebuah widget

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Flutter secara otomatis akan menerapkan gaya headlineSmall dari tema
    Text("Selamat Datang", style: Theme.of(context).textTheme.headlineSmall),
    
    // Dan di sini akan diterapkan gaya bodyMedium
    Text("Ini adalah deskripsi dari aplikasi luar biasa kami. Silakan jelajahi fitur-fiturnya."),

    // Anda juga dapat mengambilnya secara eksplisit seperti ini
    DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyLarge!,
      child: Text("Teks dengan gaya bodyLarge"),
    ),
  ],
);
```

---

## Kesimpulan

`app_text_style.dart` adalah pilar utama dari sistem desain aplikasi. Dengan mendefinisikan skala tipografi yang konsisten dan dapat diakses secara global, ia memberdayakan pengembang untuk membangun UI yang tidak hanya terlihat profesional dan kohesif tetapi juga mudah untuk dikelola dan diperbarui. Ini adalah implementasi textbook dari sistem tema teks di Flutter.
