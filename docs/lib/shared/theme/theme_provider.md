# Dokumentasi: `lib/shared/theme/theme_provider.dart`

File ini adalah pusat dari fungsionalitas manajemen tema dinamis aplikasi. `ThemeProvider` bertanggung jawab untuk mengelola, menyimpan, dan memberi tahu aplikasi tentang perubahan mode tema (terang, gelap, atau sistem).

---

## Arsitektur dan Desain

1.  **Pola Abstraksi dan Implementasi**: Desainnya sangat solid dengan memisahkan antarmuka dari implementasi:
    -   `ThemeProvider`: Sebuah kelas `abstract` yang mendefinisikan "kontrak". Ia memberi tahu seluruh aplikasi properti apa (`themeMode`, `isDarkMode`) dan metode apa (`setTheme`, `loadTheme`) yang akan tersedia pada provider tema, tanpa membocorkan detail cara kerjanya.
    -   `ThemeProviderImpl`: Implementasi konkret dari kontrak tersebut. Di sinilah logika sebenarnya berada.
    
    Pola ini sangat kuat karena memungkinkan bagian lain dari aplikasi untuk bergantung pada abstraksi `ThemeProvider`, bukan pada `ThemeProviderImpl`. Ini memudahkan pengujian (misalnya dengan menyediakan *mock implementation*) dan potensi penggantian di masa depan.

2.  **Manajemen State dengan `ChangeNotifier`**: `ThemeProviderImpl` meng-`extends` `ChangeNotifier`, menjadikannya bagian dari sistem manajemen state bawaan Flutter. Ketika mode tema berubah (misalnya, saat `setTheme` dipanggil), `notifyListeners()` dipanggil. Ini memicu semua widget yang "mendengarkan" provider ini (biasanya melalui widget `Consumer` atau `Selector` dari pustaka `provider`) untuk membangun ulang dirinya sendiri dengan tema baru.

3.  **Persistensi State**: Fitur kunci dari provider ini adalah kemampuannya untuk mengingat pilihan tema pengguna. Ini dicapai melalui integrasi dengan `LocalStorageService`:
    -   **Menyimpan**: Setiap kali `setTheme` dipanggil, mode baru tidak hanya diperbarui di memori (`_themeMode = mode`) tetapi juga diteruskan ke `localStorageService.saveThemeMode(mode)` untuk disimpan secara persisten.
    -   **Memuat**: Saat `ThemeProviderImpl` pertama kali dibuat, ia segera memanggil `loadTheme()`, yang membaca preferensi tema yang terakhir disimpan dari `localStorageService.getThemeMode()`.

4.  **Penanganan `ThemeMode.system`**: Logika di dalam getter `isDarkMode` secara cerdas menangani `ThemeMode.system`. Jika modenya adalah sistem, ia akan secara aktif memeriksa pengaturan kecerahan platform saat ini (`WidgetsBinding.instance.platformDispatcher.platformBrightness`) untuk menentukan apakah mode gelap harus digunakan. Ini memastikan aplikasi selalu sinkron dengan pengaturan OS pengguna saat dalam mode sistem.

5.  **Logging Komprehensif**: Kelas ini dipenuhi dengan panggilan `Log` yang informatif. Ini sangat berharga selama pengembangan dan debugging, karena memungkinkan pengembang untuk melacak aliran state tema: kapan tema dimuat, apa yang dimuat dari penyimpanan, kapan tema diubah, dan apakah ada kegagalan dalam proses penyimpanan/pemuatan.

---

## Penggunaan

`ThemeProvider` diinjeksikan di bagian atas pohon widget aplikasi (biasanya di `main.dart` atau `app.dart`) menggunakan widget `ChangeNotifierProvider`.

```dart
// Di file main.dart atau app.dart

void main() {
  // Inisialisasi service locator atau dependencies lain jika perlu
  final localStorageService = LocalStorageService(); 

  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      // Menyediakan implementasi konkret
      create: (_) => ThemeProviderImpl(localStorageService: localStorageService),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk mendengarkan perubahan tema
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Aplikasi WiFi',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode, // State berasal dari provider
          home: SplashScreen(),
        );
      },
    );
  }
}
```

Untuk mengubah tema dari bagian lain aplikasi (misalnya, dari menu pengaturan):

```dart
// Di dalam sebuah widget, seperti ThemeMenuWidget.dart

// Mengambil provider (tanpa mendengarkan perubahan, karena kita hanya ingin memanggil metode)
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// Memanggil metode untuk mengubah tema
themeProvider.setTheme(ThemeMode.dark);
```

---

## Kesimpulan

`ThemeProvider` adalah contoh yang sangat baik dari manajemen state yang bersih, efisien, dan persisten di Flutter. Ia tidak hanya mengelola state UI yang penting (mode tema) tetapi juga melakukannya dengan cara yang terstruktur, dapat diuji, dan dapat dipelihara dengan memisahkan abstraksi, mengintegrasikan persistensi, dan memanfaatkan sistem manajemen state bawaan Flutter. Ini adalah komponen penting yang memberikan pengalaman pengguna yang dipersonalisasi dan konsisten.
