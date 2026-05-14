# PERINGATAN : Penting diingat AI dilarang keras untuk merubah isi file GEMINI.md yang berhak merubah file ini adalah user sendiri
- AI di wajibkan mengikuti semua aturan dalam file ini


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
  errorBuilder: (context, error, st) {
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

```

* **Pencatatan Terstruktur**: Untuk log yang lebih detail, fungsi `log` menerima beberapa parameter opsional:

  * `name`: Sebuah `String` untuk mengkategorikan pesan log (misalnya, 'my_app.network').
  * `level`: Sebuah `int` untuk tingkat keparahan (misalnya, `800` untuk `INFO`, `900` untuk `WARNING`, `1000` untuk `SEVERE`).
  * `e`: Sebuah `Object` untuk mencatat pengecualian.
  * `st`: Sebuah objek `st`.


  *Contoh:*

```
import 'dart:developer' as developer;

try {
  throw 'Something went wrong!';
} catch (e, s) {
  Log.error(
    'An error occurred',
    name: 'sync data',
    e: e,
    st: s,
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
<!-- 
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
} -->



-------------------

# Cara Menggunakan WidgetsBinding di Proyek Flutter

Baik, saya akan menjelaskan cara menggunakan `WidgetsBinding` dan `WidgetsFlutterBinding` di proyek Flutter Anda dengan bahasa yang sederhana dan praktis.

---

## 1. Inisialisasi Binding (WAJIB di main.dart)

Sebelum menjalankan aplikasi, Anda harus memastikan binding sudah siap. Ini **WAJIB** dilakukan jika Anda menggunakan plugin atau menjalankan kode asynchronous sebelum `runApp()`.

**Lokasi**: `lib/main.dart`

```dart
// path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:wifi/app.dart';

void main() {
  // ditambah: Memastikan semua binding Flutter sudah diinisialisasi
  // sebelum menjalankan aplikasi. Ini diperlukan agar plugin seperti
  // SharedPreferences, Firebase, dan Google Mobile Ads bisa bekerja.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setelah binding siap, baru jalankan aplikasi
  runApp(const WifiApp());
}
```

**Kapan `ensureInitialized()` diperlukan?**
- Saat menggunakan `SharedPreferences` sebelum `runApp()`
- Saat menginisialisasi Firebase
- Saat menginisialisasi Google Mobile Ads
- Saat menjalankan kode asynchronous di `main()` sebelum `runApp()`

---

## 2. Menggunakan WidgetsBindingObserver (Mendeteksi Lifecycle Aplikasi)

`WidgetsBindingObserver` berguna untuk mengetahui saat aplikasi masuk ke background, kembali ke foreground, atau saat layar berubah.

### Contoh Penerapan di Service/Widget:

```dart
// path: lib/user/services/storage/local_storage_service.dart
// diubah: Menambahkan WidgetsBindingObserver untuk menangani lifecycle aplikasi
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';

class LocalStorageService extends WidgetsBindingObserver {
  final SharedPreferences prefs;

  LocalStorageService({required this.prefs}) {
    // ditambah: Mendaftarkan diri sebagai observer lifecycle
    WidgetsBinding.instance.addObserver(this);
    Log.info('[Inisialisasi Service] LocalStorageService dibuat dan terdaftar sebagai observer.');
  }

  // ... kode lainnya ...

  // ditambah: Method ini dipanggil saat state aplikasi berubah
  // (misal: resumed, paused, inactive, detached)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Aplikasi kembali ke foreground (aktif)
        Log.info('[Lifecycle] Aplikasi resumed - kembali aktif.');
        break;
      case AppLifecycleState.paused:
        // Aplikasi masuk ke background (tidak terlihat)
        Log.info('[Lifecycle] Aplikasi paused - masuk background.');
        break;
      case AppLifecycleState.inactive:
        // Aplikasi dalam transisi (misal: ada panggilan telepon masuk)
        Log.info('[Lifecycle] Aplikasi inactive - transisi.');
        break;
      case AppLifecycleState.detached:
        // Aplikasi akan di-terminate
        Log.info('[Lifecycle] Aplikasi detached - akan ditutup.');
        break;
    }
  }

  // ditambah: Method untuk membersihkan observer saat service tidak digunakan
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Log.info('[Dispose] LocalStorageService dihapus dari observer.');
  }
}
```

---

## 3. Menggunakan didChangeMetrics (Mendeteksi Perubahan Ukuran Layar)

Berguna saat pengguna memutar layar (rotasi) atau mengubah ukuran jendela.

```dart
// path: lib/widget/contoh_widget.dart
class ContohWidget extends StatefulWidget {
  const ContohWidget({super.key});

  @override
  State<ContohWidget> createState() => _ContohWidgetState();
}

class _ContohWidgetState extends State<ContohWidget> with WidgetsBindingObserver {
  late Size ukuranLayar;

  @override
  void initState() {
    super.initState();
    // ditambah: Mendaftarkan observer
    WidgetsBinding.instance.addObserver(this);
    // Ambil ukuran layar saat ini
    ukuranLayar = View.of(context).physicalSize;
  }

  // ditambah: Dipanggil saat ukuran layar berubah (rotasi)
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    setState(() {
      ukuranLayar = View.of(context).physicalSize;
    });
    Log.info('[Metrics] Ukuran layar berubah: $ukuranLayar');
  }

  @override
  void dispose() {
    // ditambah: Hapus observer untuk mencegah memory leak
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Ukuran layar: $ukuranLayar');
  }
}
```

---

## 4. Menggunakan addPostFrameCallback (Menjalankan Kode Setelah Frame Selesai)

Berguna untuk menjalankan kode setelah widget selesai dibangun.

```dart
// path: lib/widget/halaman_utama.dart
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  @override
  void initState() {
    super.initState();
    
    // ditambah: Menjalankan kode setelah frame pertama selesai dibangun
    // Ini berguna untuk menampilkan dialog, snackbar, atau navigasi
    // yang memerlukan context yang sudah siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Contoh: Menampilkan dialog selamat datang
      _tampilkanDialogSelamatDatang();
    });
  }

  // Fungsi untuk menampilkan dialog selamat datang
  void _tampilkanDialogSelamatDatang() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selamat Datang'),
        content: const Text('Aplikasi WiFi siap digunakan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman Utama')),
    );
  }
}
```

---

## 5. Menggunakan firstFrameRasterized / waitUntilFirstFrameRasterized

Berguna untuk menunggu frame pertama selesai dirender (biasanya untuk splash screen).

```dart
// path: lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menampilkan splash screen
  runApp(const SplashScreen());
  
  // ditambah: Menunggu frame pertama selesai dirender
  // Ini memastikan splash screen terlihat sebelum kita melakukan
  // inisialisasi berat seperti loading data dari Firebase
  await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
  
  // Setelah splash screen terlihat, lakukan inisialisasi
  await inisialisasiAplikasi();
  
  // Ganti ke aplikasi utama
  runApp(const WifiApp());
}

Future<void> inisialisasiAplikasi() async {
  Log.info('[Main] Memulai inisialisasi aplikasi.');
  // Load data dari SharedPreferences, Firebase, dll.
  await Future.delayed(const Duration(seconds: 2));
  Log.info('[Main] Inisialisasi selesai.');
}
```

---

## 6. Menggunakan handlePopRoute (Menangani Tombol Back)

Biasanya ditangani otomatis oleh `Navigator`, tapi bisa di-override.

```dart
// path: lib/app.dart
class WifiApp extends StatelessWidget {
  const WifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi App',
      home: const HalamanUtama(),
      // ditambah: Menangani tombol back secara manual
      // Ini berguna jika Anda ingin konfirmasi sebelum keluar aplikasi
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            // Konfirmasi sebelum keluar
            final keluar = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Tidak'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            );
            if (keluar == true && context.mounted) {
              SystemNavigator.pop();
            }
          },
          child: child!,
        );
      },
    );
  }
}
```

---

## Ringkasan
# Cara Menggunakan WidgetsBinding di Proyek Flutter

Baik, saya akan menjelaskan cara menggunakan `WidgetsBinding` dan `WidgetsFlutterBinding` di proyek Flutter Anda dengan bahasa yang sederhana dan praktis.

---

## 1. Inisialisasi Binding (WAJIB di main.dart)

Sebelum menjalankan aplikasi, Anda harus memastikan binding sudah siap. Ini **WAJIB** dilakukan jika Anda menggunakan plugin atau menjalankan kode asynchronous sebelum `runApp()`.

**Lokasi**: `lib/main.dart`

```dart
// path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:wifi/app.dart';

void main() {
  // ditambah: Memastikan semua binding Flutter sudah diinisialisasi
  // sebelum menjalankan aplikasi. Ini diperlukan agar plugin seperti
  // SharedPreferences, Firebase, dan Google Mobile Ads bisa bekerja.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setelah binding siap, baru jalankan aplikasi
  runApp(const WifiApp());
}
```

**Kapan `ensureInitialized()` diperlukan?**
- Saat menggunakan `SharedPreferences` sebelum `runApp()`
- Saat menginisialisasi Firebase
- Saat menginisialisasi Google Mobile Ads
- Saat menjalankan kode asynchronous di `main()` sebelum `runApp()`

---

## 2. Menggunakan WidgetsBindingObserver (Mendeteksi Lifecycle Aplikasi)

`WidgetsBindingObserver` berguna untuk mengetahui saat aplikasi masuk ke background, kembali ke foreground, atau saat layar berubah.

### Contoh Penerapan di Service/Widget:

```dart
// path: lib/user/services/storage/local_storage_service.dart
// diubah: Menambahkan WidgetsBindingObserver untuk menangani lifecycle aplikasi
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/shared/model/pelanggan_model.dart';
import 'package:wifi/shared/debug/log.dart';

class LocalStorageService extends WidgetsBindingObserver {
  final SharedPreferences prefs;

  LocalStorageService({required this.prefs}) {
    // ditambah: Mendaftarkan diri sebagai observer lifecycle
    WidgetsBinding.instance.addObserver(this);
    Log.info('[Inisialisasi Service] LocalStorageService dibuat dan terdaftar sebagai observer.');
  }

  // ... kode lainnya ...

  // ditambah: Method ini dipanggil saat state aplikasi berubah
  // (misal: resumed, paused, inactive, detached)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Aplikasi kembali ke foreground (aktif)
        Log.info('[Lifecycle] Aplikasi resumed - kembali aktif.');
        break;
      case AppLifecycleState.paused:
        // Aplikasi masuk ke background (tidak terlihat)
        Log.info('[Lifecycle] Aplikasi paused - masuk background.');
        break;
      case AppLifecycleState.inactive:
        // Aplikasi dalam transisi (misal: ada panggilan telepon masuk)
        Log.info('[Lifecycle] Aplikasi inactive - transisi.');
        break;
      case AppLifecycleState.detached:
        // Aplikasi akan di-terminate
        Log.info('[Lifecycle] Aplikasi detached - akan ditutup.');
        break;
    }
  }

  // ditambah: Method untuk membersihkan observer saat service tidak digunakan
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Log.info('[Dispose] LocalStorageService dihapus dari observer.');
  }
}
```

---

## 3. Menggunakan didChangeMetrics (Mendeteksi Perubahan Ukuran Layar)

Berguna saat pengguna memutar layar (rotasi) atau mengubah ukuran jendela.

```dart
// path: lib/widget/contoh_widget.dart
class ContohWidget extends StatefulWidget {
  const ContohWidget({super.key});

  @override
  State<ContohWidget> createState() => _ContohWidgetState();
}

class _ContohWidgetState extends State<ContohWidget> with WidgetsBindingObserver {
  late Size ukuranLayar;

  @override
  void initState() {
    super.initState();
    // ditambah: Mendaftarkan observer
    WidgetsBinding.instance.addObserver(this);
    // Ambil ukuran layar saat ini
    ukuranLayar = View.of(context).physicalSize;
  }

  // ditambah: Dipanggil saat ukuran layar berubah (rotasi)
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    setState(() {
      ukuranLayar = View.of(context).physicalSize;
    });
    Log.info('[Metrics] Ukuran layar berubah: $ukuranLayar');
  }

  @override
  void dispose() {
    // ditambah: Hapus observer untuk mencegah memory leak
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Ukuran layar: $ukuranLayar');
  }
}
```

---

## 4. Menggunakan addPostFrameCallback (Menjalankan Kode Setelah Frame Selesai)

Berguna untuk menjalankan kode setelah widget selesai dibangun.

```dart
// path: lib/widget/halaman_utama.dart
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  @override
  void initState() {
    super.initState();
    
    // ditambah: Menjalankan kode setelah frame pertama selesai dibangun
    // Ini berguna untuk menampilkan dialog, snackbar, atau navigasi
    // yang memerlukan context yang sudah siap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Contoh: Menampilkan dialog selamat datang
      _tampilkanDialogSelamatDatang();
    });
  }

  // Fungsi untuk menampilkan dialog selamat datang
  void _tampilkanDialogSelamatDatang() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selamat Datang'),
        content: const Text('Aplikasi WiFi siap digunakan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman Utama')),
    );
  }
}
```

---

## 5. Menggunakan firstFrameRasterized / waitUntilFirstFrameRasterized

Berguna untuk menunggu frame pertama selesai dirender (biasanya untuk splash screen).

```dart
// path: lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menampilkan splash screen
  runApp(const SplashScreen());
  
  // ditambah: Menunggu frame pertama selesai dirender
  // Ini memastikan splash screen terlihat sebelum kita melakukan
  // inisialisasi berat seperti loading data dari Firebase
  await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
  
  // Setelah splash screen terlihat, lakukan inisialisasi
  await inisialisasiAplikasi();
  
  // Ganti ke aplikasi utama
  runApp(const WifiApp());
}

Future<void> inisialisasiAplikasi() async {
  Log.info('[Main] Memulai inisialisasi aplikasi.');
  // Load data dari SharedPreferences, Firebase, dll.
  await Future.delayed(const Duration(seconds: 2));
  Log.info('[Main] Inisialisasi selesai.');
}
```

---

## 6. Menggunakan handlePopRoute (Menangani Tombol Back)

Biasanya ditangani otomatis oleh `Navigator`, tapi bisa di-override.

```dart
// path: lib/app.dart
class WifiApp extends StatelessWidget {
  const WifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi App',
      home: const HalamanUtama(),
      // ditambah: Menangani tombol back secara manual
      // Ini berguna jika Anda ingin konfirmasi sebelum keluar aplikasi
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            // Konfirmasi sebelum keluar
            final keluar = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Tidak'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            );
            if (keluar == true && context.mounted) {
              SystemNavigator.pop();
            }
          },
          child: child!,
        );
      },
    );
  }
}
```

---

## Ringkasan


# **DOKUMEN ATURAN PENGEMBANGAN APLIKASI FLUTTER - WIFI PROJECT**

Dokumen ini berisi aturan komprehensif yang harus dipatuhi oleh AI dalam membantu pengembangan aplikasi Flutter WiFi Project. Semua aturan telah dikonsolidasikan, dibersihkan dari konflik, dan disusun secara profesional berdasarkan prioritas dan relevansi.

---

## **BAGIAN 1: PRINSIP DASAR INTERAKSI**

### 1.1 Bahasa Komunikasi
- **WAJIB** menggunakan Bahasa Indonesia dalam semua komunikasi, penamaan fungsi, variabel, parameter, nama file, dan dokumentasi.
- Dilarang menggunakan bahasa selain Bahasa Indonesia dalam konteks yang disebutkan di atas.

### 1.2 Kepatuhan terhadap Perintah
- AI **WAJIB** mengikuti semua perintah pengguna tanpa penyimpangan.
- AI **TIDAK BOLEH** melawan atau mengabaikan perintah pengguna.
- AI **DILARANG** berasumsi liar. Jika menemui data yang ambigu atau tidak jelas, AI **WAJIB** bertanya kepada pengguna untuk klarifikasi.
- AI harus memastikan semua file dalam proyek saling sinkron.

### 1.3 Alur Konfirmasi Pekerjaan
Sebelum memulai pekerjaan, AI **WAJIB**:
1. Menjelaskan secara rinci apa yang akan dikerjakan
2. Menjelaskan alasan mengapa pekerjaan tersebut perlu dilakukan
3. Menunggu konfirmasi eksplisit dari pengguna

**Kata kunci persetujuan**: setuju, oke, ok, ya, yes → AI boleh mengerjakan.
**Kata kunci penolakan**: jangan, tidak, nggak, nggak → AI tidak boleh mengerjakan.

---

## **BAGIAN 2: STRUKTUR DAN ORGANISASI KODE**

### 2.1 Path File (WAJIB)
Setiap file **HARUS** memiliki komentar path di bagian paling atas file:

```dart
// path: lib/nama_folder/nama_file.dart
```

### 2.2 Dokumentasi File (WAJIB)
Setiap file **HARUS** memiliki dokumentasi lengkap di bagian atas setelah path:

```dart
// path: lib/path/nama_file.dart
// Fitur: [Nama Fitur Utama]
// Tujuan: [Tujuan file ini dibuat]
// 
// Daftar Fungsi:
// - fungsiA(): [Penjelasan singkat]
// - fungsiB(): [Penjelasan singkat]
```

### 2.3 Komentar pada Kode (WAJIB)
Setiap perubahan kode **HARUS** diberi komentar dengan format:

```dart
// dihapus: [alasan penghapusan]
// diubah: [alasan perubahan]  
// ditambah: [alasan penambahan]
```

Setiap fungsi **HARUS** memiliki komentar di atasnya:

```dart
// Fungsi untuk menavigasi ke halaman detail pelanggan
void navigasiKeHalamanDetail() {
  // kode di sini
}
```

### 2.4 Pengelompokan Fungsi dalam File
Fungsi-fungsi dalam file **HARUS** dikelompokkan berdasarkan kategori operasi:
- **CREATE** (Pembuatan data)
- **READ** (Pembacaan data)
- **UPDATE** (Pembaruan data)
- **DELETE** (Penghapusan data)
- **DIARSIPKAN** (Pengarsipan data)
- **SISIPKAN DATA** (Penyisipan data)

### 2.5 Import
- **WAJIB** menggunakan format: `import 'package:wifi/nama_file.dart';`
- **DILARANG** menggunakan relative path untuk import.

---

## **BAGIAN 3: PERFORMANCE DAN OPTIMASI**

### 3.1 Penggunaan const
- **WAJIB** menggunakan `const` sebanyak mungkin untuk widget statis demi performa UI.
- Setiap widget yang tidak berubah **HARUS** dideklarasikan sebagai `const`.

### 3.2 Manajemen Memori
- **WAJIB** menggunakan `if (!mounted) return;` sebelum melakukan `setState()` atau operasi UI setelah operasi asynchronous.
- **WAJIB** mengimplementasikan `dispose()` untuk membersihkan resource.
- AI harus berusaha agar aplikasi hemat penggunaan RAM perangkat pengguna.

### 3.3 Pola Asynchronous
**WAJIB** menggunakan pola `async/await` untuk semua operasi:
- I/O (Input/Output)
- Network requests
- Database operations

**DILARANG** menggunakan `.then()` berantai.

### 3.4 Penggunaan late
- **HINDARI** penggunaan `late` yang tidak perlu.
- Gunakan inisialisasi langsung atau nullable dengan penanganan yang tepat.

### 3.5 Penanganan Null
- **USAHAKAN** data memiliki nilai default, jangan selalu nullable.
- **WAJIB** mengidentifikasi data dengan jelas, hindari null yang tidak perlu.
- Pada file model, **SEBISA MUNGKIN** berikan data default, jangan nullable.

---

## **BAGIAN 4: SISTEM LOGGING (WAJIB)**

### 4.1 Library Logging
- **WAJIB** menggunakan file log di: `// path: lib/shared/debug/log.dart`
- **DILARANG** menggunakan `developer.log` langsung, harus melalui kelas `Log`.

### 4.2 Jenis Log
Gunakan jenis log yang sesuai:

| Jenis Log | Penggunaan | Contoh |
|-----------|------------|--------|
| `Log.info()` | Informasi operasi normal | `Log.info('Data berhasil disimpan.');` |
| `Log.warning()` | Peringatan, data tidak ditemukan | `Log.warning('Data pengguna tidak ditemukan.');` |
| `Log.error()` | Error dengan exception dan stack trace | `Log.error('Gagal menyimpan', e: error, st: stackTrace);` |
| `Log.api()` | Operasi API/Firebase/AdMob | `Log.api('/users', data, method: 'POST');` |

### 4.3 Cakupan Logging
- **WAJIB** menyisipkan log di **SEMUA** titik kode: logika maupun UI.
- **TIDAK BOLEH** ada kode yang terlewat tanpa log.
- Log **HARUS** sangat rinci, perbanyak pesan dengan informasi variabel menggunakan `$variabel`.

### 4.4 Format Log Versi
Setiap perubahan **WAJIB** memiliki log dengan format:

```
# Versi: v<versi_dari_pubspec>
Sumber: pubspec.yaml (version: <full_version>)
Tanggal: <tanggal>

## Tujuan:
## Perubahan:
## Bug:
## Solusi:
## Dampak:
## Catatan:
## Analisa:
```

**ATURAN VERSI:**
- AI **WAJIB** mengambil versi dari `pubspec.yaml` field `version`.
- Format: `1.0.3+4` → log menggunakan `v1.0.3`.
- **DILARANG** membuat versi sendiri atau menebak versi.
- Jika versi belum berubah: tetap gunakan versi yang sama (boleh lebih dari 1 log dalam 1 versi).
- Jika versi berubah: anggap sebagai fase baru dengan analisa lebih detail.

---

## **BAGIAN 5: DATABASE DAN PENYIMPANAN DATA**

### 5.1 Firebase Firestore
- Gunakan `get()` untuk data statis.
- Gunakan `snapshots()` **HANYA** jika benar-benar membutuhkan realtime update.
- **AKTIFKAN** persistence: `persistenceEnabled: true`.

### 5.2 Struktur Data (WAJIB)
Semua data yang disimpan ke Firebase **HARUS** memiliki field:

| Field | Tipe Data | Keterangan |
|-------|-----------|------------|
| `id` | `String` | **WAJIB**, menggunakan UUID |
| `isDeleted` | `boolean` | Status penghapusan |
| `diarsipkan` | `Timestamp` | Waktu pengarsipan |
| `diPerbarui` | `Timestamp` | Waktu pembaruan |
| `saldo` | `int` | Jumlah saldo |
| `tipe` | `String` | Tipe data |
| `poinYangDihasilkan` | `int` | Poin yang dihasilkan |
| `poinYangDigunakan` | `int` | Poin yang digunakan |
| `statusPembayaran` | `String` | Status pembayaran |
| `tanggal` | `Timestamp` | Tanggal transaksi |
| `jumlah` | `int` | Jumlah |
| `keterangan` | `String` | Keterangan |
| `isPublic` | `boolean` | Status publik |
| `poinHadiah` | `int` | Poin hadiah |
| `poinPenukaran` | `int` | Poin penukaran |
| `wajibUpdate` | `boolean` | Status wajib update |
| `tautanUnduhan` | `map` | Tautan unduhan |
| `nomorBuildTerbaru` | `map` | Nomor build terbaru |
| `youtubeTutorial` | `String` | URL tutorial YouTube |

### 5.3 ID Generation
- **WAJIB** menggunakan UUID untuk pembuatan ID.
- ID **TIDAK BOLEH** null.

---

## **BAGIAN 6: PENGUJIAN (TESTING)**

### 6.1 Kewajiban Testing
- AI **WAJIB** memberitahukan pengguna jika ada kode yang masih bisa di-test.
- AI **WAJIB** membuat file test untuk setiap kode logika yang dibuat.

### 6.2 Aturan File Test
- **DILARANG** mengubah nama atau deskripsi test yang sudah ada (hanya user yang boleh).
- **DILARANG** menghapus test yang sudah ada.
- Test **HARUS** dikelompokkan berdasarkan group dalam file yang sama.
- Hasil test **HARUS** sangat sesuai dengan deskripsi atau nama testnya.

### 6.3 Mocking
- Untuk test yang bergantung ke SQLite, gunakan kelas palsu (mock) untuk `DatabaseHelper` yang menggunakan database di memori.

### 6.4 Identifikasi File yang Belum Di-test
Gunakan perintah: `ls -R test/ lib/` untuk mengetahui file mana yang belum dibuatkan file testnya.

---

## **BAGIAN 7: PROSES BUILD DAN ANALISIS**

### 7.1 Analisis Kode
Setelah menyelesaikan pekerjaan, AI **WAJIB** menjalankan:
```bash
flutter analyze
```
atau menggunakan MCP tools: `analyze_files`

**Pastikan tidak ada error atau warning yang tersisa.**

### 7.2 Clean Build
Jika diperintahkan "clean", AI **WAJIB** menjalankan:
```bash
flutter clean && flutter pub get
```

### 7.3 Protokol Perubahan Kode
Saat melakukan perubahan pada file, AI harus:
1. Menulis **SELURUH** isi file (jangan sepotong-sepotong).
2. Membuat file salinan terlebih dahulu untuk mencoba fitur baru.
3. Setelah dipastikan tidak ada bug, pindahkan ke file aslinya.

### 7.4 MCP Tools yang Tersedia
AI dapat menggunakan MCP tools berikut untuk mempermudah pekerjaan:

**Dart Tools:**
- `analyze_files` - Analisis file
- `run_tests` - Menjalankan test
- `dart_fix` - Perbaikan otomatis
- `dart_format` - Format kode
- `pub` - Package management
- `hot_reload` / `hot_restart` - Reload aplikasi
- `get_app_logs` - Melihat log aplikasi
- `get_runtime_errors` - Melihat error runtime
- `flutter_driver` - Integration testing

**Firebase Tools:** (tersedia sesuai konfigurasi)

---

## **BAGIAN 8: DOKUMENTASI**

### 8.1 Sebelum Memulai Tugas
AI **WAJIB** membaca file dokumentasi yang relevan:
- `docs/user/README.md`
- `docs/shared/README.md`
- `docs/admin/README.md`

### 8.2 Setelah Menyelesaikan Tugas
AI **WAJIB** membuat/memperbarui dokumentasi di:
- `docs/user/README.md`
- `docs/shared/README.md`
- `docs/admin/README.md`

**Catatan**: Gabungkan dengan dokumen yang sudah ada, **JANGAN HAPUS** dokumen yang sudah ada.

### 8.3 Dokumentasi Per File
Setiap file **HARUS** didokumentasikan dengan sangat detail:
- Semua kode harus diterangkan
- Tidak boleh ada yang terlewat
- Format sesuai Bagian 2.2

---

## **BAGIAN 9: ATURAN KHUSUS WIDGET DAN UI**

### 9.1 DropdownButtonFormField
- **JANGAN** menggunakan properti `value`.
- Gunakan `initialValue` sebagai gantinya.

### 9.2 RadioGroup
- **USAHAKAN** menggunakan widget `RadioGroup` untuk pilihan.

### 9.3 Lifecycle Widget
- **WAJIB** implementasi `dispose()` untuk membersihkan resource.
- **WAJIB** menggunakan `if (!mounted) return;` sebelum operasi UI.

---

## **BAGIAN 10: ATURAN FILE GEMINI.md**

- **DILARANG KERAS** mengubah file `GEMINI.md` tanpa perintah langsung dari pengguna.
- File ini hanya boleh diubah jika pengguna secara eksplisit memerintahkan.

---

## **BAGIAN 11: DIAGRAM ALUR KERJA AI**

```
┌─────────────────────────────────────────────────────────────┐
│                    ALUR KERJA PENGEMBANGAN                   │
└─────────────────────────────────────────────────────────────┘

1. BACA DOKUMEN PROYEK
   ├── docs/user/README.md
   ├── docs/shared/README.md
   └── docs/admin/README.md

2. BACA pubspec.yaml UNTUK VERSI
   └── Catat versi untuk log

3. ANALISIS PERMINTAAN USER
   ├── Jika ambigu → TANYA USER
   └── Jika jelas → LANJUT

4. JELASKAN RENCANA PEKERJAAN KE USER
   └── TUNGGU KONFIRMASI

5. JIKA DISETUJUI:
   ├── Buat file salinan untuk uji coba
   ├── Kerjakan perubahan pada salinan
   ├── Validasi dengan analyze_files
   └── Pindahkan ke file asli

6. SETELAH SELESAI:
   ├── Tambahkan path file
   ├── Tambahkan komentar perubahan
   ├── Tambahkan log (Log.info/warning/error)
   ├── Jalankan flutter analyze
   ├── Buat/update dokumentasi
   ├── Buat file test jika diperlukan
   └── Buat log versi

7. LAPORKAN KE USER
```

---

## **BAGIAN 12: RINGKASAN PRIORITAS ATURAN**

**Jika terjadi bentrok antar aturan, gunakan prioritas berikut:**

1. Keamanan dan stabilitas aplikasi
2. Perintah eksplisit dari pengguna
3. Standar logging dan dokumentasi
4. Performa dan optimasi
5. Konsistensi kode
6. Testing

---

**Dokumen ini adalah acuan tunggal yang harus dipatuhi. Semua aturan sebelumnya yang bertentangan dengan dokumen ini dinyatakan tidak berlaku. AI wajib menyimpan dokumen ini ke dalam memori untuk referensi selama sesi pengembangan.**