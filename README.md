# Cetak Biru Proyek

Dokumen ini merinci arsitektur, fitur, dan keputusan teknis yang dibuat selama pengembangan aplikasi.

## Gambaran Umum

Aplikasi ini terdiri dari dua bagian: aplikasi untuk **pengguna** dan aplikasi untuk **admin**. Keduanya berbagi basis kode yang sama tetapi memiliki titik masuk (`main.dart`) dan fungsionalitas yang berbeda.

## Fitur yang Diterapkan

### 1. Struktur Aplikasi Ganda (Admin & Pengguna)
- **Titik Masuk Berbeda**: Aplikasi menggunakan `main_admin.dart` untuk admin dan `main_user.dart` untuk pengguna.
- **Berbagi Kode**: Sebagian besar layanan, model, dan utilitas ditempatkan di direktori `lib/shared` untuk digunakan kembali oleh kedua aplikasi.

### 2. Alur Inisialisasi Aplikasi (Admin)
- **Inisialisasi Terpusat**: Aplikasi admin sekarang memiliki alur inisialisasi yang terstruktur di `lib/admin/app.dart`.
- **Proses Inisialisasi**: Alur ini menangani langkah-langkah penting secara berurutan:
  1.  Inisialisasi Firebase.
  2.  Konfigurasi zona waktu dan lokalisasi.
  3.  Inisialisasi layanan notifikasi (termasuk meminta izin).
  4.  Persiapan database SQLite lokal.
  5.  Pengunduhan data awal dan pembersihan data lama.
  6.  Pengecekan koneksi internet.
- **UI Splash Screen Dinamis**: Selama proses inisialisasi, `SplashScreen` yang sama dari aplikasi pengguna ditampilkan dengan pesan status yang diperbarui secara dinamis (misalnya, "Menginisialisasi layanan Google...", "Mempersiapkan database lokal...").

### 3. Layanan Notifikasi Lokal
- **Implementasi**: Menggunakan paket `flutter_local_notifications`.
- **Fitur**:
  - Menampilkan notifikasi langsung.
  - Menjadwalkan notifikasi untuk waktu tertentu.
  - Membatalkan notifikasi.
  - Meminta izin dari pengguna (di Android dan iOS).
- **Perbaikan**: Kode layanan telah diperbarui untuk menggunakan *named arguments* sesuai dengan versi terbaru dari paket, mengatasi potensi *breaking changes*.

### 4. Konfigurasi Android
- **ID Aplikasi AdMob**: `AndroidManifest.xml` telah diperbarui dengan ID aplikasi AdMob sampel. Ini adalah perbaikan penting untuk mencegah aplikasi crash saat startup karena adanya dependensi `google_mobile_ads`, bahkan jika iklan tidak secara aktif ditampilkan di aplikasi admin.

### 5. Komponen UI yang Fleksibel
- **`SplashScreen`**: Widget `SplashScreen` di `lib/user/page/splash_screen.dart` telah dimodifikasi menjadi lebih fleksibel.
  - Jika dipanggil dengan parameter `loadingMessage`, ia hanya akan menampilkan pesan tersebut (digunakan oleh aplikasi admin).
  - Jika dipanggil tanpa parameter, ia akan menjalankan logika navigasi otomatisnya untuk aplikasi pengguna (memeriksa sesi login dan mengarahkan ke halaman yang sesuai).

## Rencana Perubahan Saat Ini (Selesai)

- **Tujuan**: Membuat aplikasi admin dapat dijalankan dengan alur inisialisasi yang benar dan mengatasi semua eror kompilasi dan runtime.
- **Langkah-langkah yang Telah Dilakukan**:
  1.  **Mengidentifikasi & Memperbaiki Android Crash**: Menambahkan `com.google.android.gms.ads.APPLICATION_ID` ke `AndroidManifest.xml`.
  2.  **Mengidentifikasi & Memperbaiki Eror Kompilasi**: Menemukan metode `requestPermissions` yang hilang di `NotifikasiServis` dan pemanggilan `SplashScreen` yang tidak valid di `app.dart`.
  3.  **Memperbaiki Layanan Notifikasi**: Menambahkan metode `requestPermissions` dan memperbarui semua panggilan ke `flutter_local_notifications` untuk menggunakan argumen bernama.
  4.  **Membuat `SplashScreen` Fleksibel**: Memodifikasi `SplashScreen` untuk menerima `loadingMessage` opsional agar bisa digunakan oleh kedua aplikasi.
  5.  **Finalisasi `app.dart`**: Memperbarui `lib/admin/app.dart` untuk memanggil `SplashScreen` yang baru dengan benar, sehingga menyelesaikan semua eror.
