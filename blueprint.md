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

### 6. Perbaikan Form Transaksi (Mode Edit)
- **Lokasi**: `lib/admin/halaman/form/form_transaksi.dart`.
- **Masalah**: Dalam mode edit, `DropdownButtonFormField` tidak secara otomatis menampilkan nilai yang sudah ada saat data dimuat secara asinkron.
- **Solusi**: Dengan memberikan `key` unik pada setiap `DropdownButtonFormField` menggunakan `ValueKey` (misalnya, `ValueKey<DompetModel?>(_selectedDompet)`), kita memaksa Flutter untuk membuat ulang state dari `FormField` tersebut setiap kali nilainya berubah. Ini memastikan bahwa `initialValue` dievaluasi kembali dengan benar.

### 7. Refaktorisasi Logika Pengurutan
- **Tujuan**: Mengurangi duplikasi kode dan meningkatkan pemeliharaan.
- **Masalah**: Logika untuk mengurutkan daftar pelanggan aktif di `lib/admin/halaman/tab/pelanggan_aktif.dart` sangat kompleks dan terikat langsung pada UI, membuatnya sulit untuk digunakan kembali atau diubah.
- **Solusi**: Logika pengurutan diekstraksi ke dalam kelas utilitas baru yang dapat digunakan kembali, yaitu `lib/shared/utils/pelanggan_aktif_sorter.dart`. Kelas ini sekarang berisi semua logika perbandingan (`comparator`) dan enum `OpsiUrutkan`.
- **Hasil**: Halaman `PelangganAktifPage` diperbarui untuk menggunakan `PelangganAktifSorter`, yang secara signifikan menyederhanakan metode `_applyFilterAndSort` dan memisahkan logika bisnis dari lapisan presentasi.

## Rencana Perubahan Saat Ini

- **Tujuan**: Merefaktorisasi logika pengurutan di `pelanggan_aktif.dart` untuk meningkatkan kualitas kode dan kemudahan pemeliharaan.
- **Langkah-langkah**:
  1.  **Membuat Sorter**: Membuat kelas utilitas `PelangganAktifSorter` di `lib/shared/utils/pelanggan_aktif_sorter.dart`.
  2.  **Memindahkan Logika**: Memindahkan enum `OpsiUrutkan` dan semua logika perbandingan ke dalam kelas sorter baru.
  3.  **Refaktor**: Memperbarui `lib/admin/halaman/tab/pelanggan_aktif.dart` untuk mendelegasikan tugas pengurutan ke `PelangganAktifSorter`.
  4.  **Dokumentasi**: Memperbarui `blueprint.md` untuk mencerminkan perubahan arsitektur ini.
