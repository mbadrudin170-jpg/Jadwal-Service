# README Shared

Direktori `shared` berisi kode yang digunakan bersama oleh aplikasi admin dan aplikasi pengguna untuk memastikan konsistensi dan mengurangi duplikasi kode.

## `theme/`

Direktori ini berisi semua yang terkait dengan tema dan gaya visual aplikasi.

### `app_text_style.dart`

File ini mendefinisikan `TextTheme` terpusat untuk keseluruhan aplikasi. Tujuannya adalah untuk memastikan konsistensi gaya tipografi di semua bagian UI.

**Fitur Utama:**

- **Konsistensi**: Menyediakan satu sumber kebenaran untuk semua gaya teks.
- **Keterbacaan**: Menggunakan font `GoogleFonts.poppins` untuk judul (tampilan modern) dan `GoogleFonts.openSans` untuk isi teks (keterbacaan maksimal).
- **Kemudahan Pengelolaan**: Perubahan pada tipografi hanya perlu dilakukan di satu tempat.

### `app_colors.dart`

File ini mendefinisikan palet warna yang konsisten untuk seluruh aplikasi.

**Fitur Utama:**

- **Konsistensi Warna**: Menyediakan satu sumber kebenaran untuk semua warna yang digunakan dalam aplikasi.
- **Akses Mudah**: Warna didefinisikan sebagai `static const` di dalam kelas `AppColors`, memungkinkan akses langsung tanpa perlu membuat instance kelas (misalnya, `AppColors.primaryColor`).
- **Perawatan Mudah**: Mengubah warna di satu file ini akan secara otomatis memperbaruinya di seluruh aplikasi.

### `theme_provider.dart`

File ini berisi `ThemeProvider`, sebuah kelas yang mengelola status tema aplikasi (terang, gelap, atau sistem) menggunakan `ChangeNotifier` dari paket `provider`.

**Fitur Utama:**

- **Manajemen Status Tema**: Menyimpan `ThemeMode` saat ini.
- **Pemberitahuan Perubahan**: Menggunakan `notifyListeners()` untuk memberitahu seluruh aplikasi ketika tema diubah.
- **Kontrol Tema**: Menyediakan metode seperti `toggleTheme()` untuk beralih antara tema terang/gelap dan `setSystemTheme()` untuk sinkronisasi dengan pengaturan OS.

**Cara Menggunakan:**

1.  **Bungkus Aplikasi Anda**: Bungkus widget root aplikasi Anda dengan `ChangeNotifierProvider`.

    ```dart
    import 'package:provider/provider.dart';
    import 'package:wifi/shared/theme/theme_provider.dart';

    void main() {
      runApp(
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: const MyApp(),
        ),
      );
    }
    ```

2.  **Dengarkan Perubahan**: Gunakan `Consumer<ThemeProvider>` atau `Provider.of<ThemeProvider>(context)` untuk mengakses status tema dan membangun UI yang sesuai.

    ```dart
    Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          // ...
        );
      },
    )
    ```

3.  **Ubah Tema**: Panggil metode pada `ThemeProvider` untuk mengubah tema dari mana saja di aplikasi.

    ```dart
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    ```
