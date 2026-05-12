# Cetak Biru Proyek

Dokumen ini merinci arsitektur, fitur, dan keputusan teknis yang dibuat selama pengembangan aplikasi.

## Gambaran Umum

Aplikasi ini terdiri dari dua bagian: aplikasi untuk **pengguna** dan aplikasi untuk **admin**. Keduanya berbagi basis kode yang sama tetapi memiliki titik masuk (`main.dart`) dan fungsionalitas yang berbeda.

## Fitur yang Diterapkan

### 1. Struktur Aplikasi Ganda (Admin & Pengguna)
- **Titik Masuk Berbeda**: Aplikasi menggunakan `main_admin.dart` untuk admin dan `main_user.dart` untuk pengguna.
- **Berbagi Kode**: Sebagian besar layanan, model, dan utilitas ditempatkan di direktori `lib/shared` untuk digunakan kembali oleh kedua aplikasi.

### 2. Alur Inisialisasi & Splash Screen

- **Implementasi Terpisah**: Masing-masing aplikasi (Admin dan Pengguna) memiliki file *splash screen* sendiri untuk menjaga pemisahan logika dan tampilan awal.
  - **Admin**: Menggunakan `lib/admin/splash_screen_admin.dart` yang menampilkan pesan status dinamis selama proses inisialisasi yang panjang di `lib/admin/app_admin.dart`.
  - **Pengguna**: Menggunakan `lib/user/page/splash_screen_user.dart` yang menangani logika navigasi otomatis (mengarahkan ke halaman login atau beranda berdasarkan status sesi).

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

### 5. Rencana Perubahan Saat Ini (Selesai)

- **Tujuan**: Membuat aplikasi admin dapat dijalankan dengan alur inisialisasi yang benar dan mengatasi semua eror kompilasi dan runtime.
- **Langkah-langkah yang Telah Dilakukan**:
  1.  **Mengidentifikasi & Memperbaiki Android Crash**: Menambahkan `com.google.android.gms.ads.APPLICATION_ID` ke `AndroidManifest.xml`.
  2.  **Mengidentifikasi & Memperbaiki Eror Kompilasi**: Menemukan metode `requestPermissions` yang hilang di `NotifikasiServis` dan pemanggilan `SplashScreen` yang tidak valid di `app.dart`.
  3.  **Memperbaiki Layanan Notifikasi**: Menambahkan metode `requestPermissions` dan memperbarui semua panggilan ke `flutter_local_notifications` untuk menggunakan argumen bernama.
  4.  **Memperbaiki Alur Inisialisasi Admin**: Memastikan `lib/admin/app_admin.dart` menggunakan `SplashScreen` yang benar dari `lib/admin/splash_screen_admin.dart`.

## Temuan & Status Kode

- **Analisis Statis**: Seluruh *error* analisis statis (`flutter analyze`) telah berhasil diperbaiki. *Codebase* saat ini dalam kondisi bersih dari *linting issues*.
- **Rekomendasi Perbaikan Path Aset**: Ditemukan bahwa path gambar logo pada `lib/user/page/splash_screen_user.dart` saat ini mengarah ke `'assets/logo/ikon/ikon_apk.png'`, namun path aset yang valid di dalam proyek adalah `'assets/image/ikon_apk.png'`. Direkomendasikan untuk memperbaiki path ini agar logo dapat ditampilkan dengan benar di *splash screen* aplikasi pengguna.
