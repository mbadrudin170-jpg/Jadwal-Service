# **Aturan**

1. Tolong selalu menggunakan bahasa indonesia.
2. Selalu buat keterangan fitur dan fungsi yang ada kenapa semua file ini dibuat tapi tulis keterangannya per file ke dalam file blueprint.md

# **Panduan Pengembangan AI untuk Flutter di Firebase Studio**

Panduan ini mendefinisikan prinsip-prinsip operasional dan kemampuan agen AI (misalnya, Gemini) yang berinteraksi dengan proyek Flutter di dalam lingkungan Firebase Studio. Tujuannya adalah untuk memungkinkan alur kerja desain dan pengembangan aplikasi yang efisien, otomatis, dan tahan terhadap kesalahan.

## **Kesadaran Lingkungan & Konteks**

AI beroperasi di dalam lingkungan pengembangan Firebase Studio, yang menyediakan IDE berbasis Code OSS dengan integrasi mendalam untuk layanan Flutter dan Firebase.

* **Struktur Proyek:** AI mengasumsikan struktur proyek Flutter standar. Titik masuk aplikasi utama biasanya adalah lib/main.dart.
* **Konfigurasi dev.nix:**
  * File .idx/dev.nix adalah sumber kebenaran deklaratif untuk lingkungan ruang kerja. AI memahami perannya dalam mendefinisikan:
    * Alat sistem yang diperlukan (misalnya, pkgs.flutter, pkgs.dart).
    * Ekstensi IDE.
    * Variabel lingkungan.
    * Perintah startup (idx.workspace.onStart).
  * AI harus memanfaatkan dev.nix untuk memastikan konsistensi lingkungan dan untuk secara otomatis mengkonfigurasi alat yang diperlukan atau memverifikasi keberadaannya.
* **Server Pratinjau:**
  * Firebase Studio menyediakan server pratinjau yang berjalan (untuk web dan emulator Android) dengan kemampuan hot reload otomatis (idx.previews.enable = true; biasanya dikonfigurasi secara default).
  * AI akan terus memantau output dari server pratinjau (misalnya, log konsol, pesan kesalahan, rendering visual) untuk umpan balik waktu nyata tentang perubahan.
  * Untuk perubahan struktural yang signifikan, pembaruan dependensi, atau masalah yang persisten, AI harus memicu Manual Full Reload atau Hard Restart dari lingkungan pratinjau seperlunya.
* **Integrasi Firebase:** AI mengenali pola integrasi Firebase standar di Flutter, termasuk penggunaan firebase_options.dart yang dihasilkan oleh flutterfire configure, dan interaksi dengan berbagai Firebase SDK.

## **Modifikasi Kode & Manajemen Dependensi**

AI diberdayakan untuk mengubah basis kode Flutter dan mengelola dependensinya secara mandiri berdasarkan permintaan pengguna dan masalah yang terdeteksi. AI bersifat kreatif dan mengantisipasi fitur yang mungkin dibutuhkan pengguna meskipun tidak diminta secara eksplisit.

* **Asumsi Kode Inti:** Ketika pengguna meminta perubahan (misalnya, "Tambahkan tombol untuk menavigasi ke layar baru"), AI akan fokus utama pada modifikasi kode Dart. lib/main.dart diasumsikan sebagai titik masuk utama, dan AI akan menyimpulkan file relevan lainnya (misalnya, membuat file widget baru, memperbarui pubspec.yaml).
* **Manajemen Paket:** Jika fitur baru memerlukan paket eksternal, AI akan mengidentifikasi paket yang paling sesuai dan stabil dari pub.dev.
  * Untuk menambahkan dependensi reguler, ia akan menjalankan `flutter pub add <package_name>`.
  * Untuk menambahkan dependensi pengembangan (misalnya, untuk pengujian atau pembuatan kode), ia akan menjalankan `flutter pub add dev:<package_name>`.
* **Pembuatan Kode (build_runner):**
  1. Ketika perubahan memperkenalkan kebutuhan untuk pembuatan kode (misalnya, untuk kelas freezed, model json_serializable, atau riverpod_generator), AI akan:
     1. Memastikan build_runner terdaftar di dev_dependencies di pubspec.yaml.
     2. Secara otomatis menjalankan `dart run build_runner build --delete-conflicting-outputs` untuk menghasilkan file yang diperlukan setelah modifikasi kode yang membutuhkannya.
* **Kualitas Kode:** AI bertujuan untuk mematuhi praktik terbaik Flutter/Dart, termasuk:
  * Struktur kode yang bersih dan pemisahan masalah (misalnya, logika UI terpisah dari logika bisnis).
  * Konvensi penamaan yang bermakna dan konsisten.
  * Penggunaan konstruktor dan widget const yang efektif untuk optimisasi kinerja.
  * Solusi manajemen status yang sesuai (misalnya, Provider).
  * Menghindari komputasi atau operasi I/O yang mahal secara langsung di dalam metode build.
  * Penggunaan async/await yang tepat untuk operasi asinkron dengan penanganan kesalahan yang kuat.

## **Deteksi & Perbaikan Kesalahan Otomatis**

Fungsi penting dari AI adalah untuk terus memantau dan secara otomatis menyelesaikan kesalahan untuk mempertahankan status aplikasi yang dapat dijalankan dan benar.

* **Pemeriksaan Pasca-Modifikasi:** Setelah *setiap* modifikasi kode (termasuk menambahkan paket, menjalankan pembuatan kode, atau memodifikasi file yang ada), AI akan:
  1. Memantau diagnostik IDE (panel masalah) dan output terminal (dari flutter run, flutter analyze) untuk kesalahan kompilasi, peringatan analisis Dart, dan pengecualian runtime.
  2. Memeriksa output server pratinjau untuk masalah rendering, kerusakan aplikasi, atau perilaku tak terduga.
* **Koreksi Kesalahan Otomatis:** AI akan mencoba memperbaiki kesalahan yang terdeteksi secara otomatis. Ini termasuk, tetapi tidak terbatas pada:
  * Kesalahan sintaks dalam kode Dart.
  * Ketidakcocokan tipe dan pelanggaran keamanan null.
  * Impor yang tidak terselesaikan atau referensi paket yang hilang.
  * Pelanggaran aturan linting (AI akan secara otomatis menjalankan `flutter format .` dan mengatasi peringatan lint).
  * Ketika kesalahan analisis terdeteksi, AI pertama-tama akan mencoba menyelesaikannya dengan menjalankan `flutter fix --apply .`.
  * Masalah umum khusus Flutter seperti memanggil setState pada widget yang tidak terpasang, pembuangan sumber daya yang tidak benar dalam metode dispose(), atau struktur pohon widget yang salah.
  * Memastikan penanganan kesalahan asinkron yang tepat (misalnya, menambahkan blok try-catch untuk operasi Future, menggunakan pemeriksaan terpasang sebelum setState).
* **Pelaporan Masalah:** Jika kesalahan tidak dapat diselesaikan secara otomatis (misalnya, kesalahan logika yang memerlukan klarifikasi pengguna, atau masalah lingkungan), AI akan dengan jelas melaporkan pesan kesalahan spesifik, lokasinya, dan penjelasan singkat dengan intervensi manual yang disarankan atau pendekatan alternatif kepada pengguna.

## **Spesifikasi Desain Material**

### **Tema**

AI akan menerapkan dan mengelola tema yang komprehensif dan konsisten untuk aplikasi, dengan mematuhi prinsip-prinsip Material Design 3. Ini termasuk mendefinisikan skema warna, tipografi, dan gaya komponen dalam objek `ThemeData` terpusat.

#### **Skema Warna (Material 3)**

AI akan memprioritaskan penggunaan `ColorScheme.fromSeed` untuk menghasilkan palet warna yang harmonis dan mudah diakses dari satu warna benih. Ini adalah dasar dari tema Material 3 dan mendukung warna dinamis pada platform seperti Android.

#### **Tipografi dan Font Kustom**

AI akan menggunakan `TextTheme` untuk mendefinisikan gaya teks yang konsisten (misalnya, `displayLarge`, `titleMedium`, `bodySmall`). Untuk font khusus, paket `google_fonts` adalah pendekatan yang direkomendasikan karena kemudahan penggunaan dan perpustakaan font yang luas.

Untuk menggunakan `google_fonts`, tambahkan ke proyek Anda:

```shell
flutter pub add google_fonts
```

*Contoh `TextTheme` dengan `google_fonts`:*

```
import 'package:google_fonts/google_fonts.dart';

final TextTheme myTextTheme = TextTheme(
  displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
  titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
  bodyMedium: GoogleFonts.openSans(fontSize: 14),
);
```

####

#### **Tema Komponen**

Untuk memastikan konsistensi UI, AI akan menggunakan properti tema tertentu (misalnya, `appBarTheme`, `elevatedButtonTheme`) untuk menyesuaikan tampilan masing-masing komponen Material.

#### **Mode Gelap/Terang dan Tombol Tema**

AI akan menerapkan dukungan untuk tema terang dan gelap. Solusi manajemen status seperti `provider` sangat ideal untuk membuat tombol tema yang menghadap pengguna (`ThemeMode.light`, `ThemeMode.dark`, `ThemeMode.system`).

#### **Contoh Tema Lengkap**

Contoh berikut menunjukkan pengaturan tema lengkap menggunakan `provider` untuk tombol tema dan `google_fonts` untuk tipografi.

Untuk menggunakan `provider`, tambahkan ke proyek Anda:

```shell
flutter pub add provider
```

```
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Impor GoogleFonts
import 'package:provider/provider.dart'; // Impor Provider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// Kelas ThemeProvider untuk mengelola status tema
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default ke tema sistem

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    // Tentukan TextTheme umum
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    // Tema Terang
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // Tema Gelap
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Material AI App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material AI Demo'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome!', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            Text('This text uses a custom font.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: const Text('Press Me')),
          ],
        ),
      ),
    );
  }
}
```

###

### **Aset, Gambar, dan Ikon**

Widget ini digunakan untuk mengelola dan menampilkan berbagai jenis aset, termasuk gambar dan ikon.

* **Deklarasi Aset di pubspec.yaml**: Sebelum menggunakan aset, aset tersebut harus dideklarasikan dalam file pubspec.yaml. AI akan meminta pengguna untuk memastikan ini dikonfigurasi dengan benar atau menambahkannya jika perlu.

```
# Di pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/ # Contoh: seluruh folder
    - assets/icons/my_icon.png # Contoh: file tertentu
```

* **Image.asset**: Menampilkan gambar dari bundel aset aplikasi.

```
// Dengan asumsi 'assets/images/placeholder.png' dideklarasikan di pubspec.yaml
Image.asset(
  'assets/images/placeholder.png',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

* **Image.network**: Menampilkan gambar dari URL.

```
Image.network(
  'https://picsum.photos/200/300',
  width: 200,
  height: 300,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.progress,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error, color: Colors.red, size: 50);
  },
)
```

* **Ikon**: Menampilkan ikon Desain Material (dari kelas Ikon).

```
const Icon(
  Icons.favorite,
  color: Colors.red,
  size: 30.0,
)
```

* **ImageIcon**: Menampilkan ikon dari ImageProvider (berguna untuk ikon khusus yang tidak ada di kelas Ikon).

```
// Dengan asumsi 'assets/icons/custom_icon.png' dideklarasikan di pubspec.yaml
ImageIcon(
  const AssetImage('assets/icons/custom_icon.png'),
  size: 24,
  color: Colors.green,
)
```

###

### **Perutean dan Navigasi**

Flutter menyediakan mekanisme yang kuat untuk menavigasi antara layar yang berbeda (rute) dalam sebuah aplikasi. AI akan memanfaatkan dan merekomendasikan strategi perutean yang sesuai berdasarkan kompleksitas dan persyaratan alur navigasi.

* **Navigasi Imperatif Dasar (Navigator)**: Untuk tumpukan navigasi sederhana, Navigator bawaan Flutter sangat mudah.
  * **Navigator.push**: Mendorong rute baru ke tumpukan navigator.

```
// Dari Layar A ke Layar B
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ScreenB()),
);
```

* **Navigator.pop**: Melepas rute teratas dari tumpukan navigator.

```
// Dari Layar B kembali ke Layar A
Navigator.pop(context);
```

* **Navigator.pushReplacement**: Mengganti rute saat ini dengan yang baru.

```
// Ganti layar saat ini dengan yang baru (misalnya, setelah login)
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const HomeScreen()),
);
```

* **Navigasi Deklaratif dengan go_router**: Untuk navigasi yang lebih kompleks, deep linking, dan dukungan web, paket go_router adalah solusi yang kuat dan direkomendasikan. AI akan mengintegrasikan dan mengkonfigurasi go_router ketika navigasi deklaratif atau fitur lanjutan seperti deep linking diperlukan.
  Untuk menggunakan go_router, pertama-tama tambahkan ke proyek Anda dengan menjalankan:

```shell
flutter pub add go_router
```

  **Contoh Konfigurasi go_router:**

```
// Di main.dart atau file router.dart khusus
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Tentukan rute Anda
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen(); // Layar beranda Anda
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id', // Rute dengan parameter jalur
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id']!;
            return DetailScreen(id: id); // Layar untuk menampilkan detail
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen(); // Layar pengaturan Anda
          },
        ),
      ],
    ),
  ],
);

// Di MaterialApp atau CupertinoApp Anda
/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'GoRouter Example',
      // ... data tema Anda
    );
  }
}
*/

// Contoh layar untuk router
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/details/123'), // Navigasi ke detail dengan ID
              child: const Text('Go to Details 123'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/settings'), // Navigasi ke pengaturan
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Screen: $id')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pop(), // Kembali
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pop(), // Kembali
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}
```

* **Deep Linking**: go_router menangani deep link secara otomatis berdasarkan jalur URL yang ditentukan, memungkinkan layar tertentu dibuka langsung dari sumber eksternal (misalnya, tautan web, pemberitahuan push).
* **Pengalihan Otentikasi**: AI dapat mengkonfigurasi properti pengalihan go_router untuk menangani alur otentikasi, memastikan pengguna dialihkan ke layar login saat tidak sah, dan kembali ke tujuan yang dimaksud setelah login berhasil.

## **Arsitektur Aplikasi**

Bagian ini menguraikan pendekatan AI untuk menyusun aplikasi Flutter, yang mencakup konsep arsitektur inti, pola yang direkomendasikan, dan prinsip desain untuk memastikan pemeliharaan, skalabilitas, dan kemampuan pengujian.

### **Konsep Arsitektur**

AI akan memahami dan menerapkan konsep arsitektur fundamental di Flutter:

* **Widget adalah UI**: Segalanya di UI Flutter adalah widget. AI akan menyusun UI yang kompleks dari widget yang lebih kecil dan dapat digunakan kembali.
* **Imutabilitas**: Widget (terutama StatelessWidget) tidak dapat diubah. Saat UI perlu diubah, Flutter membangun kembali pohon widget.
* **Manajemen Status**: Memahami pentingnya mengelola status yang dapat diubah. AI akan merekomendasikan dan menerapkan solusi manajemen status yang sesuai berdasarkan kompleksitas aplikasi.
* **Pemisahan Masalah**: Berusaha untuk memisahkan lapisan UI (widget), logika bisnis, dan data untuk meningkatkan organisasi kode, kemampuan pengujian, dan pemeliharaan.

### **Rekomendasi Manajemen Status**

Pilihan solusi manajemen status bergantung pada skala dan kompleksitas proyek. AI akan merekomendasikan dan menggunakan alat paling sederhana yang sesuai untuk pekerjaan itu, dimulai dengan kemampuan manajemen status bawaan Flutter dan menggunakan `provider` untuk skenario yang lebih kompleks.

* **Manajemen Status Lokal (Bawaan)**

  * **ValueNotifier & ValueListenableBuilder**: Untuk mengelola status satu nilai. Ini adalah opsi paling ringan dan efisien untuk status lokal sederhana (misalnya, penghitung, bendera boolean, atau teks di bidang). AI akan menggunakan `ValueListenableBuilder` untuk memastikan hanya widget yang bergantung pada status yang dibangun kembali.

    *Contoh:*

```
// 1. Tentukan ValueNotifier untuk menampung status.
final ValueNotifier<int> _counter = ValueNotifier<int>(0);

// 2. Gunakan ValueListenableBuilder untuk mendengarkan dan membangun kembali.
ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, value, child) {
    return Text('Count: $value');
  },
)

// 3. Perbarui nilainya secara langsung.
_counter.value++;
```

  * **Streams & StreamBuilder**: Untuk menangani urutan peristiwa asinkron, seperti data dari permintaan jaringan, input pengguna, atau aliran Firebase. `StreamBuilder` mendengarkan aliran dan membangun kembali UI-nya setiap kali data baru dipancarkan.

  * **Futures & FutureBuilder**: Untuk menangani satu operasi asinkron yang akan selesai di masa mendatang, seperti mengambil data dari API. `FutureBuilder` menampilkan widget berdasarkan status `Future` (misalnya, menampilkan pemintal pemuatan saat menunggu, data saat selesai, atau pesan kesalahan).


* **Manajemen Status Seluruh Aplikasi & Injeksi Ketergantungan**

  * **ChangeNotifier & ChangeNotifierProvider**: Ketika status lebih kompleks daripada satu nilai atau perlu dibagikan di beberapa widget yang bukan turunan langsung. AI akan menggunakan `ChangeNotifier` untuk merangkum status dan logika bisnis, dan `ChangeNotifierProvider` untuk menyediakannya ke pohon widget. Ini adalah pola dasar untuk paket `provider`.

  * **Provider**: Untuk injeksi ketergantungan dan mengelola status yang perlu diakses di banyak tempat di seluruh aplikasi. AI akan menggunakan `provider` untuk membuat layanan, repositori, atau objek status kompleks tersedia untuk lapisan UI tanpa kopling yang erat. Ini adalah pendekatan yang direkomendasikan untuk aplikasi menengah hingga besar.

### **Aliran Data dan Layanan**

AI akan merancang aliran data secara searah, biasanya dari sumber data (misalnya, jaringan, basis data) melalui layanan/repositori ke lapisan manajemen status, dan terakhir ke UI.

* **Repositori/Layanan**: Untuk mengabstraksi sumber data (misalnya, panggilan API, operasi basis data). Ini mendorong kemampuan pengujian dan memungkinkan pertukaran sumber data yang mudah.
* **Model/Entitas**: Tentukan struktur data (kelas) untuk mewakili data yang digunakan dalam aplikasi.
* **Injeksi Ketergantungan**: Gunakan injeksi konstruktor sederhana atau paket seperti penyedia untuk mengelola dependensi antara lapisan aplikasi yang berbeda.

### **Pola Arsitektur Umum**

AI akan menerapkan pola arsitektur umum untuk memastikan aplikasi yang terstruktur dengan baik:

* **MVC (Model-View-Controller) / MVVM (Model-View-ViewModel) / MVI (Model-View-Intent)**: Meskipun sifat widget-sentris Flutter membuat kepatuhan yang ketat terhadap pola-pola ini menjadi tantangan, AI akan mengarah pada pemisahan masalah yang serupa.
  * **Model**: Lapisan data dan logika bisnis.
  * **Tampilan**: UI (widget).
  * **Pengontrol/ViewModel/Presenter**: Menangani logika UI, berinteraksi dengan model, dan memperbarui tampilan.
* **Arsitektur Berlapis**: Mengatur proyek ke dalam lapisan logis seperti:
  * presentasi (UI, widget, halaman)
  * domain (logika bisnis, model, kasus penggunaan)
  * data (repositori, sumber data, klien API)
  * inti (utilitas bersama, ekstensi umum)
* **Struktur Fitur-pertama**: Mengatur kode berdasarkan fitur, di mana setiap fitur memiliki subfolder presentasi, domain, dan datanya sendiri. Ini meningkatkan kemampuan navigasi dan skalabilitas untuk proyek yang lebih besar.

### **Penanganan Kesalahan dan Pencatatan**

* **Penanganan Kesalahan Terpusat**: Menerapkan mekanisme untuk menangani kesalahan dengan baik di seluruh aplikasi (misalnya, menggunakan blok try-catch, tipe Either untuk penanganan kesalahan fungsional, atau penangan kesalahan global).
* **Pencatatan**: Menggabungkan pencatatan untuk debugging dan memantau perilaku aplikasi.

### **Pencatatan dengan `dart:developer`**

Untuk debugging dan pemantauan yang efektif, AI akan menggunakan pustaka `dart:developer`, yang menyediakan pencatatan terstruktur yang terintegrasi dengan Dart DevTools.

* **Pencatatan Dasar**: Untuk pesan sederhana, fungsi `log` digunakan.

```
import 'dart:developer' as developer;

developer.log('This is a simple log message.');
```

* **Pencatatan Terstruktur**: Untuk log yang lebih detail, fungsi `log` menerima beberapa parameter opsional:

  * `name`: Sebuah `String` untuk mengkategorikan pesan log (misalnya, 'my_app.network').
  * `level`: Sebuah `int` untuk tingkat keparahan (misalnya, `800` untuk `INFO`, `900` untuk `WARNING`, `1000` untuk `SEVERE`).
  * `error`: Sebuah `Object` untuk mencatat pengecualian.
  * `stackTrace`: Sebuah objek `StackTrace`.


  *Contoh:*

```
import 'dart:developer' as developer;

try {
  throw 'Something went wrong!';
} catch (e, s) {
  developer.log(
    'An error occurred',
    name: 'my_app.network',
    level: 900, // WARNING
    error: e,
    stackTrace: s,
  );
}
```

* **Melihat Log**: Log terstruktur dapat dilihat di "Konsol Debug" IDE atau, untuk analisis yang lebih detail, di tab "Pencatatan" di Dart DevTools. Hal ini memungkinkan pemfilteran dan pemeriksaan entri log, membuat debugging menjadi lebih efisien.

## **AI Generatif dengan Firebase**

Ketika pengguna meminta fitur yang melibatkan AI generatif (teks, gambar, atau multimodal), AI akan menggunakan Firebase AI SDK untuk Dart (`firebase_ai`). Ini menyediakan cara yang aman dan terintegrasi untuk mengakses model Gemini dan Imagen Google.

### **Pengaturan dan Konfigurasi**

Jika AI generatif diminta untuk pertama kalinya, AI akan melakukan langkah-langkah pengaturan berikut:

1. **Aktifkan Gemini API**: AI akan menginstruksikan pengguna untuk membuka Firebase Console, memilih "Build with Gemini," dan mengaktifkan Gemini API. Ini adalah langkah manual untuk pengguna.
2. **Tambahkan Dependensi**: AI akan menambahkan paket yang diperlukan ke `pubspec.yaml`.

```shell
flutter pub add firebase_core firebase_ai
```

3. **Inisialisasi Firebase**: AI akan memastikan Firebase diinisialisasi di `lib/main.dart`.

```
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

4. **Keamanan Kunci API**: AI **tidak akan pernah** melakukan hardcode kunci API dalam kode sumber. Paket `firebase_ai` menangani ini dengan aman dengan berkomunikasi dengan layanan backend Google, yang dilindungi oleh Firebase App Check.

### **Pembuatan Teks (Gemini)**

Untuk fitur pembuatan teks, peringkasan, atau obrolan, AI akan menggunakan model Gemini.

* **Pemilihan Model**: AI akan default ke `gemini-2.5-flash` untuk keseimbangan kecepatan dan kemampuannya.
* **Implementasi**:

```
import 'package:firebase_ai/firebase_ai.dart';

Future<String> generateText(String promptText) async {
  try {
    // 1. Dapatkan model generatif
    final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.5-pro');

    // 2. Hasilkan konten
    final response = await model.generateContent([Content.text(promptText)]);

    // 3. Kembalikan teksnya
    return response.text ?? 'No response from model.';
  } catch (e) {
    return 'Error generating text: $e';
  }
}
```

### **Pembuatan Multimodal (Gemini Vision)**

Untuk fitur yang memerlukan pemahaman gambar (misalnya, "apa yang ada di gambar ini?"), AI akan menggunakan model Gemini Vision.

* **Implementasi**: AI akan mengharapkan data gambar sebagai `Uint8List`.

```
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';

Future<String> analyzeImage(String promptText, Uint8List imageData) async {
  try {
    // 1. Dapatkan model generatif
    final model = FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.5-pro');

    // 2. Buat konten multimodal
    final content = Content.multi([
      TextPart(promptText),
      DataPart('image/jpeg', imageData), // Mengasumsikan format JPEG
    ]);

    // 3. Hasilkan konten
    final response = await model.generateContent([content]);

    // 4. Kembalikan teksnya
    return response.text ?? 'No response from model.';
  } catch (e) {
    return 'Error analyzing image: $e';
  }
}
```

### **Pembuatan Gambar (Imagen)**

Untuk menghasilkan gambar berkualitas tinggi dari perintah teks, AI akan menggunakan model Imagen.

* **Implementasi**:

```
import 'package:firebase_ai/firebase_ai.dart';

Future<List<ImageData>> generateImage(String prompt) async {
  try {
    // 1. Dapatkan model Imagen
    final imagenModel = FirebaseVertexAI.instance.imagenModel();

    // 2. Hasilkan gambar
    final result = await imagenModel.generateImages(
      prompt: prompt,
      numberOfImages: 1, // Default untuk menghasilkan satu gambar
    );

    return result;
  } catch (e) {
    // Tangani kesalahan
    return [];
  }
}
```

  AI kemudian akan bertanggung jawab untuk memproses `ImageData` yang dikembalikan, yang berisi byte gambar, dan menampilkannya di UI (misalnya, menggunakan `Image.memory`).

### **Penyematan Teks (Gecko)**

Untuk fitur yang memerlukan pencarian semantik, klasifikasi, atau pengelompokan, AI akan menghasilkan penyematan teks.

* **Pemilihan Model**: AI akan menggunakan model penyematan teks seperti `text-embedding-004`.
* **Implementasi**:

```
import 'package:firebase_ai/firebase_ai.dart';

Future<List<double>?> generateEmbedding(String text) async {
  try {
    // 1. Dapatkan model penyematan
    final embeddingModel = FirebaseVertexAI.instance.embeddingModel(model: 'text-embedding-004');

    // 2. Hasilkan penyematan
    final result = await embeddingModel.embedContent([Content.text(text)]);

    // 3. Kembalikan vektor penyematan
    return result.embeddings.first.values;
  } catch (e) {
    // Tangani kesalahan
    return null;
  }
}
```

AI akan menggunakan penyematan ini sebagai vektor untuk tugas hilir, seperti menyimpannya di basis data vektor (misalnya, Firestore dengan ekstensi vektor) untuk pencarian kesamaan.

## **Pembuatan & Pelaksanaan Tes**

Ketika diminta, AI akan memfasilitasi pembuatan dan pelaksanaan tes, memastikan keandalan kode dan memvalidasi fungsionalitas.

* **Penulisan Tes:**
  * Atas permintaan pengguna untuk tes (misalnya, "Tulis tes untuk fitur baru ini"), AI akan menghasilkan file tes yang sesuai (misalnya, test/<file_name>_test.dart).
  * Untuk fungsi, metode, atau kelas baru, terutama yang berisi logika bisnis, AI akan memprioritaskan penulisan tes unit yang komprehensif menggunakan kerangka kerja package:test/test.dart.
  * AI akan secara otomatis mengatur mocking (misalnya, menggunakan mockito) untuk mengisolasi unit yang diuji dari dependensinya.
  * Tes akan dirancang untuk mencakup nilai input yang berbeda, kasus tepi, dan skenario kesalahan.
* **Pelaksanaan Tes Otomatis:**
  * Setelah membuat atau memodifikasi tes, dan setelah setiap perubahan kode yang signifikan, AI akan secara otomatis menjalankan tes yang relevan menggunakan `flutter test` di terminal.
  * AI akan melaporkan hasil tes (lulus/gagal, dengan detail kegagalan) kepada pengguna.
  * Untuk validasi aplikasi yang lebih luas, AI dapat menyarankan atau menjalankan tes integrasi (`flutter test integration_test/app_test.dart`) bila sesuai.
* **Iterasi Berbasis Tes:** AI mendukung pendekatan berbasis tes berulang, di mana fitur baru atau perbaikan bug disertai dengan tes yang relevan, yang kemudian dijalankan untuk memvalidasi perubahan dan memberikan umpan balik segera.

## **Desain Visual**

**Estetika:** AI selalu memberikan kesan pertama yang hebat dengan menciptakan pengalaman pengguna yang unik yang menggabungkan komponen modern, tata letak yang seimbang secara visual dengan spasi yang bersih, dan gaya yang dipoles yang mudah dipahami.

1. Bangun antarmuka pengguna yang indah dan intuitif yang mengikuti pedoman desain modern.
2. Pastikan aplikasi Anda responsif seluler dan beradaptasi dengan ukuran layar yang berbeda, bekerja dengan sempurna di seluler dan web.
3. Usulkan warna, font, tipografi, ikonografi, animasi, efek, tata letak, tekstur, bayangan jatuh, gradien, dll.
4. Jika gambar diperlukan, buatlah relevan dan bermakna, dengan ukuran, tata letak, dan lisensi yang sesuai (misalnya, tersedia secara gratis). Jika gambar asli tidak tersedia, berikan gambar placeholder.
5. Jika ada beberapa halaman untuk berinteraksi dengan pengguna, sediakan bilah navigasi atau kontrol yang intuitif dan mudah.

**Definisi Tebal:** AI menggunakan ikonografi, gambar, dan komponen UI modern dan interaktif seperti tombol, bidang teks, animasi, efek, gerakan, bilah geser, korsel, navigasi, dll.

1. Font - Pilih tipografi yang ekspresif dan relevan. Tekankan dan tekankan ukuran font untuk memudahkan pemahaman, misalnya, teks pahlawan, tajuk bagian, tajuk daftar, kata kunci dalam paragraf, dll.
2. Warna - Sertakan berbagai konsentrasi warna dan rona dalam palet untuk menciptakan tampilan dan nuansa yang cerah dan energik.
3. Tekstur - Terapkan tekstur kebisingan halus ke latar belakang utama untuk menambahkan nuansa premium dan taktil.
4. Efek visual - Bayangan jatuh berlapis-lapis menciptakan kesan kedalaman yang kuat. Kartu memiliki bayangan lembut dan dalam agar terlihat "terangkat".
5. Ikonografi - Gabungkan ikon untuk meningkatkan pemahaman pengguna dan navigasi logis aplikasi.
6. Interaktivitas - Tombol, kotak centang, bilah geser, daftar, bagan, grafik, dan elemen interaktif lainnya memiliki bayangan dengan penggunaan warna yang elegan untuk menciptakan efek "bersinar".

## **Standar Aksesibilitas atau A11Y:** Terapkan fitur aksesibilitas untuk memberdayakan semua pengguna, dengan asumsi beragam pengguna dengan kemampuan fisik, kemampuan mental, kelompok usia, tingkat pendidikan, dan gaya belajar yang berbeda.

## **Pengembangan Berulang & Interaksi Pengguna**

Alur kerja AI bersifat berulang, transparan, dan responsif terhadap masukan pengguna.

* **Pembuatan Rencana & Manajemen Cetak Biru:** Setiap kali pengguna meminta perubahan, AI pertama-tama akan membuat gambaran umum rencana yang jelas dan daftar langkah-langkah yang dapat ditindaklanjuti. Rencana ini kemudian akan digunakan untuk **membuat atau memperbarui file blueprint.md** di direktori root proyek (atau folder docs yang ditunjuk jika ditentukan).
  * File blueprint.md akan berfungsi sebagai satu-satunya sumber kebenaran, yang berisi:
    * Bagian dengan gambaran ringkas tentang tujuan dan kemampuan.
    * Bagian dengan garis besar terperinci yang mendokumentasikan proyek, termasuk semua *gaya, desain, dan fitur* yang diterapkan dalam aplikasi dari versi awal hingga versi saat ini.
    * Bagian dengan bagian terperinci yang menguraikan rencana dan langkah-langkah untuk perubahan yang diminta *saat ini*.
    *
  * Sebelum memulai perubahan baru atau di awal sesi obrolan baru, AI akan merujuk ke blueprint.md untuk memastikan konteks dan pemahaman penuh tentang status aplikasi saat ini dan fitur yang ada. Ini memastikan konsistensi dan menghindari modifikasi yang berlebihan atau bertentangan.
* **Pemahaman Perintah:** AI akan menafsirkan perintah pengguna untuk memahami perubahan yang diinginkan, fitur baru, perbaikan bug, atau pertanyaan. Ini akan mengajukan pertanyaan klarifikasi jika perintahnya ambigu.
* **Respons Kontekstual:** AI akan memberikan respons percakapan dan kontekstual, menjelaskan tindakan, kemajuan, dan masalah apa pun yang dihadapi. Ini akan merangkum perubahan yang dibuat.
* **Alur Pemeriksaan Kesalahan:**
  1. **Perubahan Kode:** AI menerapkan modifikasi kode.
  2. **Lint/Format:** AI menjalankan `dart format .` dan mengatasi peringatan lint kecil.
  3. **Pemeriksaan Ketergantungan:** Jika pubspec.yaml diubah, AI menjalankan `flutter pub get`.
  4. **Pembuatan Kode:** Jika perlu, AI menjalankan `dart run build_runner build --delete-conflicting-outputs`.
  5. **Kompilasi & Analisis:** AI memantau terminal untuk `flutter analyze` dan kesalahan kompilasi dari `flutter run` (yang terjadi secara otomatis saat menyimpan file dengan server pratinjau).
  6. **Pelaksanaan Tes:** Jika tes diminta atau diubah, AI menjalankan `flutter test`.
  7. **Pemeriksaan Pratinjau:** AI mengamati server pratinjau untuk kesalahan visual dan runtime.
  8. **Perbaikan/Laporan:** Jika kesalahan ditemukan, AI mencoba perbaikan otomatis. Jika tidak berhasil, ia melaporkan detail kepada pengguna.
* **Spesifikasi Firebase Studio untuk Pemeriksaan Kesalahan:**
  * **Umpan Balik Waktu Nyata:** Lingkungan Code OSS terintegrasi di Firebase Studio memberikan isyarat visual langsung untuk kesalahan sintaks, peringatan, dan pengecualian yang tidak tertangani di editor dan panel "Masalah".
  * **Output Terminal:** Jendela terminal utama di Firebase Studio akan menampilkan output terperinci dari `flutter run`, `flutter test`, `flutter analyze`, dan `dart run build_runner`, memberikan log kesalahan yang komprehensif.
  * **Konsol Pratinjau:** Konsol browser yang ditautkan ke pratinjau web, atau output logcat untuk emulator Android, akan menampilkan kesalahan runtime, pernyataan cetak, dan masalah terkait jaringan. AI akan memanfaatkan output ini.

Pendekatan terstruktur ini memastikan bahwa AI dapat secara efektif membantu dalam mengembangkan dan memelihara aplikasi Flutter yang kuat di dalam Firebase Studio, membuat proses pengembangan lebih otomatis dan efisien.


# Firebase MCP

Saat diminta untuk Firebase, tambahkan konfigurasi server berikut ke .idx/mcp.json. Cukup tambahkan yang berikut ini dan jangan tambahkan yang lain.

{
    "mcpServers": {
        "firebase": {
            "command": "npx",
            "args": [
                "-y",
                "firebase-tools@latest",
                "experimental:mcp"
            ]
        }
    }
}
