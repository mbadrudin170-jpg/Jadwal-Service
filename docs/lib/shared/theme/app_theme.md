# Dokumentasi: `lib/shared/theme/app_theme.dart`

`AppTheme` adalah kelas utilitas statis yang merupakan puncak dari arsitektur tema aplikasi. File ini berfungsi sebagai "maestro" yang mengorkestrasi `AppColors` dan gaya tipografi (`TextTheme`) untuk menghasilkan objek `ThemeData` yang lengkap dan dapat digunakan untuk tema terang (light) dan gelap (dark).

---

## Arsitektur dan Desain

1.  **Pola Kelas Utilitas Statis**: `AppTheme` berisi properti `static final` untuk `lightTheme` dan `darkTheme`. Ini berarti kedua objek `ThemeData` ini dibuat sekali dan dapat diakses dari mana saja di aplikasi tanpa perlu membuat instance dari `AppTheme`, memastikan konsistensi dan efisiensi.

2.  **Penggabungan Sistem Desain**: Di sinilah keajaiban terjadi. `AppTheme` mengambil palet warna yang telah didefinisikan secara abstrak di `AppColors` dan skala tipografi dari `TextTheme` (yang didefinisikan secara lokal di file ini) dan menggabungkannya. Ini adalah implementasi dari prinsip pemisahan tanggung jawab (Separation of Concerns): `AppColors` tahu *tentang warna*, `TextTheme` tahu *tentang teks*, dan `AppTheme` tahu *cara menggabungkannya*.

3.  **Kustomisasi Tema per Komponen**: Di luar warna dan teks dasar, `AppTheme` melangkah lebih jauh dengan menyediakan gaya khusus untuk komponen widget individual melalui properti `appBarTheme`, `elevatedButtonTheme`, dan `cardTheme`. Ini adalah praktik yang sangat baik karena memastikan bahwa semua `AppBar`, `ElevatedButton`, dan `Card` di seluruh aplikasi akan memiliki tampilan dan nuansa yang seragam secara default, mengurangi kebutuhan untuk menata gaya setiap widget secara manual.

4.  **Dukungan Material 3**: Pengaturan `useMaterial3: true` menandakan bahwa aplikasi ini mengadopsi versi terbaru dari sistem desain Google, Material You. Ini memengaruhi tampilan dan nuansa default dari banyak komponen, memberikan aplikasi estetika yang modern.

5.  **Pemanfaatan `ColorScheme.fromSeed`**: Daripada mendefinisikan setiap warna dalam `ColorScheme` secara manual, tema ini menggunakan konstruktor `ColorScheme.fromSeed`. Ini adalah fitur kuat dari Material 3 di mana Flutter dapat secara algoritmis menghasilkan seluruh palet warna yang harmonis dari satu `seedColor` (dalam hal ini, `AppColors.primaryColor`). Ini menyederhanakan pembuatan tema dan memastikan bahwa warna-warna tersebut secara inheren cocok satu sama lain.

6.  **Tipografi Lokal**: Perlu dicatat bahwa file ini mendefinisikan `_appTextTheme` sendiri, yang mungkin sedikit berbeda dari `appTextTheme` global di `app_text_style.dart`. Dalam konteks file ini, `_appTextTheme` lokal inilah yang digunakan, menunjukkan bahwa setiap file tema dapat memiliki penyesuaian tipografinya sendiri jika diperlukan.

---

## Penggunaan

Kelas `AppTheme` digunakan di level tertinggi aplikasi, biasanya di dalam widget `MaterialApp`, untuk menyediakan tema ke seluruh pohon widget.

```dart
// Di file main.dart atau app.dart

import 'package:provider/provider.dart';
import 'package:wifi/shared/theme/app_theme.dart';
import 'package:wifi/shared/theme/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan ThemeProvider untuk memungkinkan pergantian tema
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Aplikasi WiFi',
            // Menggunakan properti dari AppTheme berdasarkan mode saat ini
            theme: AppTheme.lightTheme, 
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, // mis. ThemeMode.light, ThemeMode.dark, atau ThemeMode.system
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
```

Dengan pengaturan ini, seluruh aplikasi kini memiliki akses ke tema yang konsisten. Setiap widget dapat mengambil informasi tema saat ini menggunakan `Theme.of(context)`.

---

## Kesimpulan

`app_theme.dart` adalah inti dari sistem tema visual aplikasi. Ia secara efektif menggabungkan warna, teks, dan gaya komponen menjadi dua paket `ThemeData` yang kohesif dan dapat digunakan kembali. Dengan memusatkan logika tema di sini, pengembang memastikan bahwa aplikasi memiliki tampilan yang konsisten dan profesional, sambil juga membuatnya sangat mudah untuk mengubah seluruh tampilan aplikasi hanya dengan menyesuaikan beberapa baris di file-file tema bersama ini.
