# Dokumentasi: `lib/shared/theme/app_colors.dart`

`AppColors` adalah kelas utilitas statis yang berfungsi sebagai palet warna terpusat untuk aplikasi. Tujuannya adalah untuk mendefinisikan semua warna yang digunakan di seluruh UI dalam satu lokasi yang konsisten dan mudah dikelola, mirip dengan bagaimana `AppIcons` mengelola ikon.

---

## Arsitektur dan Desain

1.  **Pola Kelas Utilitas Statis**: Sama seperti `AppIcons`, `AppColors` menggunakan properti `static const` untuk mendefinisikan warna. Ini memungkinkan pengembang untuk mengakses warna langsung melalui nama kelas (misalnya, `AppColors.primaryColor`) tanpa perlu membuat instance dari kelas tersebut. Ini efisien dan membuat kode sangat mudah dibaca.

2.  **Single Source of Truth (Satu Sumber Kebenaran) untuk Warna**: Dengan mendeklarasikan semua warna inti di sini, `AppColors` menjadi satu-satunya sumber kebenaran untuk palet warna aplikasi. Jika ada kebutuhan untuk rebranding atau mengubah skema warna (misalnya, mengubah `primaryColor` dari `Colors.deepPurple` menjadi `Colors.blue`), perubahan hanya perlu dilakukan di satu tempat. Ini secara otomatis akan memperbarui seluruh aplikasi, memastikan konsistensi dan menghemat waktu pengembangan yang signifikan.

3.  **Kategorisasi Semantik**: Warna-warna tidak hanya didefinisikan sebagai nilai hex acak; mereka diberi nama semantik yang menjelaskan peran mereka dalam UI (`primaryColor`, `lightBackground`, `errorColor`). Hal ini sangat penting karena memisahkan *peran* warna dari *nilai* spesifiknya. Seorang pengembang tidak perlu mengingat bahwa warna error adalah `#F44336`; mereka hanya perlu meminta `AppColors.errorColor`. Ini membuat kode lebih mudah dibaca dan dipelihara.

4.  **Dukungan Tema Terang & Gelap**: Kelas ini secara eksplisit mendefinisikan warna untuk tema terang (`lightBackground`, `textOnLight`) dan tema gelap (`darkBackground`, `darkSurface`, `textOnDark`). Ini memfasilitasi pembuatan `ThemeData` yang terpisah untuk setiap mode, memungkinkan aplikasi untuk beralih tema dengan mulus.

5.  **Grup Warna Khusus Fitur**: Penambahan grup warna `Tambahan Warna Poin` (`pointColor`, `pointBackground`) adalah contoh yang bagus untuk memperluas palet. Saat fitur baru (seperti sistem poin) ditambahkan, warna-warna spesifiknya dapat didefinisikan di sini. Ini menjaga palet tetap terorganisir dan memudahkan untuk melihat warna apa yang terkait dengan fitur mana.

6.  **Fungsi Utilitas Logging**: Kehadiran fungsi `logColorInitialization` menunjukkan kesadaran akan perlunya proses debug. Meskipun sederhana, ini bisa menjadi alat yang berguna untuk memastikan bahwa konfigurasi tema dimuat seperti yang diharapkan selama startup aplikasi.

---

## Penggunaan

`AppColors` terutama digunakan saat mendefinisikan `ThemeData` aplikasi, tetapi juga dapat digunakan langsung di dalam widget untuk pewarnaan kustom.

**Penggunaan Utama (dalam `app_theme.dart`):**

```dart
// Di dalam file definisi tema (misalnya, app_theme.dart)

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.lightBackground,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    error: AppColors.errorColor,
  ),
  // ... properti tema lainnya
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryColor,
  scaffoldBackgroundColor: AppColors.darkBackground,
  // ... properti tema lainnya
);
```

**Penggunaan Sekunder (langsung di widget):**

```dart
// Di dalam widget untuk memberikan warna kustom

Container(
  padding: const EdgeInsets.all(8.0),
  decoration: BoxDecoration(
    color: AppColors.pointBackground, // Menggunakan warna latar belakang poin
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Poin Spesial!',
    style: TextStyle(color: AppColors.pointColor), // Menggunakan warna utama poin
  ),
);
```

---

## Kesimpulan

`AppColors` adalah komponen fundamental dari arsitektur tema yang baik. Dengan memusatkan definisi warna dan memberinya nama semantik, ia menciptakan sistem yang kuat, dapat dipelihara, dan mudah digunakan. Ini tidak hanya memastikan konsistensi visual di seluruh aplikasi tetapi juga secara dramatis menyederhanakan proses pembaruan skema warna, menjadikannya praktik terbaik yang sangat direkomendasikan untuk proyek Flutter dalam berbagai skala.
