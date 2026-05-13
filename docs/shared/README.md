# README Shared

Direktori `shared` berisi kode yang digunakan bersama oleh aplikasi admin dan aplikasi pengguna untuk memastikan konsistensi dan mengurangi duplikasi kode.

## **Peningkatan Kualitas Kode & Logging (27 Juli 2024)**

Fokus pada peningkatan keandalan dan visibilitas kode yang dibagikan.

### `services/cek_koneksi_internet.dart`

- **Peningkatan Logging**: Log yang sangat rinci ditambahkan untuk melacak setiap langkah dalam proses pemeriksaan koneksi internet. Ini mencakup log sebelum memanggil plugin `connectivity_plus`, hasil mentah yang diterima, dan logika percabangan untuk menentukan status online/offline. Tujuannya adalah untuk memudahkan diagnosis masalah konektivitas.
- **Perbaikan Stabilitas**: Memperbaiki serangkaian error sintaks pada pemanggilan `Log.error`. Kesalahan ini menyebabkan aplikasi gagal kompilasi dan menyoroti kesalahpahaman tentang cara kerja fungsi log. Perbaikan ini memastikan bahwa error dan stack trace ditangani dengan benar, sesuai dengan definisi fungsi.

### `debug/log.dart`

- **Klarifikasi Penggunaan**: Proses perbaikan error di atas memberikan pemahaman yang lebih jelas tentang penggunaan `Log.warning` vs. `Log.error`:
    - `Log.error`: Digunakan secara khusus untuk `try-catch` dan **memiliki** parameter bernama `e:` dan `st:` untuk menangani objek exception dan stack trace.
    - `Log.warning`: Digunakan untuk kondisi tak terduga yang bukan merupakan exception (misalnya, data tidak ditemukan, status tidak valid). Fungsi ini **tidak** memiliki parameter `e:` atau `st:`; informasi tambahan harus dimasukkan ke dalam pesan string utama.

---

## Standarisasi Waktu (UTC) & Integritas Data

Ini adalah salah satu pembaruan arsitektur paling penting untuk memastikan keandalan sinkronisasi dan logika berbasis waktu di seluruh aplikasi.

### Masalah: Ambiguitas Zona Waktu

Sebelumnya, banyak bagian dari kode menggunakan `DateTime.now()` untuk menghasilkan timestamp. Fungsi ini menghasilkan waktu **lokal** perangkat, yang menyebabkan masalah serius:

1.  **Sinkronisasi Tidak Andal**: Jika admin di Jakarta (WIB/UTC+7) membuat data pada pukul 10:00, waktu yang tersimpan adalah `10:00+0700`. Jika pengguna di Bali (WITA/UTC+8) menerima data ini, perbandingan waktu bisa menjadi salah. Perubahan yang seharusnya baru mungkin terlihat lama, dan sebaliknya.
2.  **Logika Kadaluarsa yang Salah**: Fitur seperti "hapus data setelah 30 hari" menjadi tidak dapat diprediksi. Data yang disimpan oleh pengguna di zona waktu yang lebih "cepat" (misalnya UTC+12) bisa dihapus lebih awal dari yang seharusnya saat diperiksa oleh sistem yang berjalan di UTC.

### Solusi: UTC sebagai Satu-Satunya Sumber Kebenaran

Untuk mengatasi ini, standar baru telah diterapkan di **semua file operasi data** (`lib/shared/operasi/`):

1.  **Penyimpanan Wajib dalam UTC**: Setiap kali sebuah timestamp dibuat atau diperbarui (misalnya di kolom `diperbarui`, `diarsipkan`, `tanggal`, dll.), kode **WAJIB** menggunakan `DateTime.now().toUtc()`.
2.  **Perbandingan Wajib dalam UTC**: Setiap perbandingan antara timestamp dari database dan waktu saat ini juga **WAJIB** menggunakan `DateTime.now().toUtc()`. Ini memastikan perbandingan yang akurat ("apel dengan apel").

### Contoh Kritis: `pembersihan_data_operasi.dart`

Bug paling berbahaya ditemukan dan diperbaiki di file ini.
- **Sebelumnya**: Menggunakan fungsi `datetime('now', ...)` dari SQLite. Fungsi ini menggunakan waktu **lokal** sistem, menciptakan perbandingan antara data UTC (dari aplikasi) dan waktu lokal (dari database), yang sangat rawan kesalahan.
- **Sekarang**: Logika dipindahkan sepenuhnya ke Dart. Aplikasi menghitung `batasWaktu` menggunakan `DateTime.now().toUtc()`, lalu meneruskannya sebagai parameter ke query SQL. Ini menjamin perbandingan selalu UTC vs UTC.

### Manfaat

- **Integritas Data**: Semua data waktu sekarang konsisten di seluruh database lokal dan server.
- **Sinkronisasi yang Andal**: Sistem dapat dengan andal mendeteksi perubahan terbaru untuk diunggah atau diunduh.
- **Pencegahan Bug**: Menghilangkan seluruh kelas bug zona waktu yang sulit dilacak.

---

## `operasi/` (Lapisan Operasi Data)

Direktori ini adalah jantung dari manajemen data lokal aplikasi. Ini berisi kelas-kelas "operasi" yang bertanggung jawab untuk semua interaksi CRUD (Create, Read, Update, Delete) dengan database SQLite lokal. Setiap kelas operasi dikhususkan untuk satu model data (misalnya, `dompet_operasi.dart` untuk `DompetModel`).

### Arsitektur Sinkronisasi & Peran `operasi_dasar.dart`

- **Pusat Logika**: `lib/shared/operasi/operasi_dasar.dart` adalah kelas dasar abstrak yang menjadi fondasi bagi semua kelas operasi lainnya. Tujuannya adalah untuk memusatkan logika umum, terutama yang berkaitan dengan sinkronisasi data.

- **Pembedaan Operasi (Lokal vs. Server)**: Perubahan paling signifikan dalam arsitektur ini adalah penambahan parameter opsional `dariServer` pada semua metode yang melakukan operasi tulis (seperti `sisipkan`, `perbarui`, `hapus`, dll.).
    - **`dariServer: false` (default)**: Menandakan bahwa operasi diinisiasi oleh tindakan pengguna lokal (misalnya, pengguna menekan tombol "Simpan"). Ketika ini terjadi, `operasi_dasar.dart` akan secara otomatis memanggil `setWaktuUpdateTerbaru()` setelah operasi berhasil. Ini mencatat waktu perubahan, yang kemudian digunakan oleh layanan sinkronisasi untuk mengetahui bahwa ada data baru yang perlu diunggah ke server.
    - **`dariServer: true`**: Menandakan bahwa operasi berasal dari proses sinkronisasi data dari server (misalnya, saat mengunduh pembaruan dari Firestore). Dengan menyetel flag ini ke `true`, `operasi_dasar.dart` akan **melewatkan** pemanggilan `setWaktuUpdateTerbaru()`. Ini adalah mekanisme krusial untuk **mencegah loop sinkronisasi** (di mana data yang baru diunduh akan segera ditandai untuk diunggah kembali).

- **Manfaat**: Arsitektur ini menciptakan alur data yang jelas dan terkontrol, memisahkan logika bisnis dari pemicu sinkronisasi, dan membuat sistem lebih efisien dan dapat diandalkan.

## `export/`

Direktori ini berisi file "barrel" yang mengekspor beberapa file lain dari satu lokasi. Ini menyederhanakan pernyataan impor di seluruh aplikasi.

### `operasi.dart`

File ini berfungsi sebagai titik ekspor tunggal untuk semua kelas "operasi" yang berada di `lib/shared/operasi/`. Kelas-kelas ini kemungkinan menangani logika bisnis atau operasi data untuk berbagai model dalam aplikasi (misalnya, `Dompet`, `Pelanggan`, `Transaksi`).

**Perbaikan (Struktur Impor):**

- **Masalah**: Sebelumnya, file ini menggunakan ekspor relatif (misalnya, `export 'dompet_operasi.dart';`). Pendekatan ini rapuh dan menyebabkan kesalahan analisis `uri_does_not_exist` karena resolver URI tidak dapat secara konsisten menemukan file yang benar dari konteks yang berbeda.
- **Solusi**: Semua pernyataan ekspor telah diperbarui untuk menggunakan sintaks `package:` absolut (misalnya, `export 'package:wifi/shared/operasi/dompet_operasi.dart';`).
- **Manfaat**: Penggunaan path `package:` memastikan bahwa file selalu dapat ditemukan secara andal oleh alat analisis dan build Dart, terlepas dari di mana file `operasi.dart` diimpor. Ini membuat basis kode lebih kuat dan mudah dipelihara.

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

## `widget/`

Direktori ini berisi widget-widget umum yang dapat digunakan kembali di berbagai bagian aplikasi, baik di sisi admin maupun pengguna.

### `card/point_card.dart`

- **Tujuan**: Menyediakan widget kartu (card) yang dirancang untuk menampilkan total poin pengguna secara visual dan menarik.
- **Fitur**:
    - **Kustomisasi**: Memungkinkan penyesuaian ikon (`icon`), warna tema (`themeColor`), dan tentu saja jumlah poin (`points`) yang ditampilkan.
    - **Desain Modern**: Menggunakan `BoxDecoration` dengan `borderRadius` dan `boxShadow` untuk memberikan efek kartu yang "terangkat" (elevated).
    - **Praktik Terbaik**: Kode telah diperbarui untuk menggunakan `withAlpha()` daripada `withOpacity()` yang sudah usang, memastikan kualitas kode dan performa rendering yang lebih baik.
    - **Struktur Jelas**: Tata letak diatur dengan `Row` dan `Column` untuk menyajikan ikon dan teks poin secara berdampingan dengan rapi.

### `nama_paket.dart` (Refactored)

- **Tujuan**: Sebagai komponen UI yang bertanggung jawab untuk menampilkan nama sebuah paket langganan. Widget ini telah di-refactor secara signifikan untuk menjadi **data-source agnostic**, artinya ia tidak lagi peduli dari mana data paket berasal (apakah dari database SQLite lokal atau dari Firestore).

- **Arsitektur Lama vs. Baru**:
    - **Lama**: Widget ini menerima `idPaket` dan secara internal memanggil `PaketOperasi().getPaketById()` untuk mengambil data dari SQLite. Ini menciptakan keterikatan yang erat antara UI dan lapisan data lokal (admin).
    - **Baru**: Widget ini sekarang menerima satu parameter `Future<PaketModel?> paketFuture`. Tanggung jawab untuk menyediakan `Future` ini (yaitu, melakukan query ke database) telah dipindahkan ke pemanggil widget.

- **Fitur & Manfaat**:
    - **Decoupling (Pemisahan Tanggung Jawab)**: UI (`NamaPaketWidget`) sekarang sepenuhnya terpisah dari logika pengambilan data. Ini adalah praktik arsitektur perangkat lunak yang baik, membuat kode lebih bersih, modular, dan mudah diuji.
    - **Fleksibilitas**: Karena hanya mengharapkan `Future`, widget ini dapat digunakan di mana saja. Di aplikasi admin, kita bisa memberinya `Future` dari `PaketOperasi` (SQLite). Di aplikasi pengguna, kita bisa memberinya `Future` dari `FirestoreService` (Firestore). Ini menyelesaikan bug inti di mana widget mencoba mencari ID Firestore di database SQLite.
    - **UI Asinkron yang Baik**: Menggunakan `FutureBuilder` secara internal untuk menangani siklus hidup `Future`: ia akan menampilkan `CircularProgressIndicator` saat data sedang dimuat, pesan error jika terjadi kegagalan, dan nama paket (`paket.nama`) jika berhasil.
