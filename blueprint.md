# Aturan Kerja

- **Sebelum memulai tugas baru, wajib membaca file `blueprint.md` dan file README yang relevan (`docs/user/README.md`, `docs/shared/README.md`, `docs/admin/README.md`)** untuk memahami konteks, status, dan alur kerja proyek.

# Blueprint Aplikasi WiFi Management

Dokumen ini berfungsi sebagai cetak biru untuk pengembangan aplikasi manajemen hotspot WiFi, merinci arsitektur, fitur, dan rencana implementasi.

## 1. Gambaran Umum

Aplikasi ini bertujuan untuk menyediakan platform yang mudah digunakan bagi admin untuk mengelola layanan hotspot WiFi dan bagi pengguna untuk melihat status langganan, riwayat transaksi, dan berinteraksi dengan layanan.

Aplikasi ini dibagi menjadi dua bagian utama:
- **Aplikasi Admin:** Untuk mengelola pelanggan, paket, transaksi, dan pengaturan jaringan.
- **Aplikasi Pengguna:** Untuk pelanggan melihat informasi akun, masa aktif paket, dan memberikan masukan.

## 2. Struktur Proyek
*(Akan ditambahkan pada pembaruan berikutnya)*

## 3. Fitur & Fungsi

Berikut adalah rincian fungsionalitas dari setiap file yang telah dibuat atau dimodifikasi:

### Folder: `lib/shared/`
- **`lib/shared/utils/perhitungan_util.dart`**
  - **Tujuan:** Menyediakan fungsi-fungsi utilitas untuk kalkulasi terkait status aplikasi.
  - **Fungsi Utama:**
    - `getTeksSisaMasaAktif()`: Menghitung dan mengembalikan representasi teks dari sisa masa aktif paket (misal: "Sisa 5 hari").
    - `getWarnaSisaMasaAktif()`: Menentukan warna (hijau, oranye, merah) berdasarkan sisa masa aktif untuk memberikan isyarat visual di UI.
- **`lib/shared/model/kritik_saran_model.dart`**
  - **Tujuan:** Mendefinisikan struktur data untuk kritik dan saran yang dikirim oleh pengguna.
  - **Fungsi Utama:**
    - Berisi properti seperti `id`, `userId`, `isi`, `tanggal`, dan `diperbarui`.
    - Menyediakan konstruktor `fromFirebase` untuk mengubah data dari Firestore menjadi objek `KritikSaranModel`.
 - **`lib/shared/model/pengaturan_model.dart`**
   - **Tujuan:** Mendefinisikan struktur data untuk konfigurasi global aplikasi yang diambil dari Firestore.
   - **Fitur:**
     - Properti `modePemeliharaan` (boolean) untuk mengontrol status pemeliharaan aplikasi.
     - Properti `infoPemeliharaan` (string) untuk menyimpan pesan yang akan ditampilkan kepada pengguna saat mode pemeliharaan aktif.
     - Konstruktor `fromFirebase` untuk mem-parsing data dari snapshot Firestore menjadi objek `PengaturanModel`.

### Folder: `lib/user/`
- **`lib/user/app_user.dart`**
  - **Tujuan:** Bertindak sebagai titik masuk utama (entry point) untuk aplikasi pengguna, yang bertanggung jawab untuk memeriksa status global sebelum aplikasi berjalan sepenuhnya.
  - **Fitur:**
    - **Pemeriksaan Koneksi & Mode Pemeliharaan:** Sebelum me-render UI utama, aplikasi akan memeriksa koneksi internet. Jika online, ia akan mengambil data pengaturan dari Firestore untuk memeriksa apakah `modePemeliharaan` aktif.
    - **Penanganan Status:**
      - Jika pemeliharaan aktif, aplikasi akan menampilkan `MaintenancePage`.
      - Jika pemeliharaan nonaktif atau perangkat offline, aplikasi akan melanjutkan ke alur normal (menampilkan `SplashScreenUser`).
- **`lib/user/page/home_page.dart`**
  - **Tujuan:** Bertindak sebagai halaman beranda bagi pengguna setelah login.
  - **Fitur:**
    - Menampilkan daftar riwayat transaksi atau langganan pengguna.
    - Menggunakan `StreamBuilder` untuk mendapatkan data pelanggan secara *real-time*.
    - Menggunakan `FutureBuilder` untuk memuat riwayat langganan lengkap.
    - Menampilkan status masa aktif setiap item riwayat menggunakan utilitas dari `perhitungan_util.dart`.
    - Memiliki `BannerAdWidget` untuk menampilkan iklan.
- **`lib/user/page/profil_page.dart`**
  - **Tujuan:** Menampilkan detail informasi profil pengguna.
  - **Fitur:**
    - Menampilkan informasi pribadi seperti nama, nomor HP, dan password (dengan opsi tampil/sembunyi).
    - Menampilkan informasi paket yang sedang aktif, termasuk nama paket, tanggal berakhir, dan sisa masa aktif.
    - Opsi untuk menyalin nomor HP ke clipboard.
    - Tombol untuk menavigasi ke halaman edit profil dan pengaturan.
    - Menggunakan `RefreshIndicator` untuk memuat ulang data profil.
- **`lib/user/page/kritik_dan_saran.dart`**
  - **Tujuan:** Halaman bagi pengguna untuk melihat riwayat masukan (kritik dan saran) yang telah mereka kirimkan.
  - **Fitur:**
    - Menampilkan daftar masukan dalam bentuk `Card`.
    - Pengguna dapat mengetuk item untuk **mengedit** atau **menghapus** masukan tersebut.
    - Dialog konfirmasi ditampilkan sebelum proses penghapusan.
    - Menggunakan `StreamBuilder` untuk menampilkan data dari Firestore secara *real-time*.
- **`lib/user/page/form_kritik_dan_saran.dart`**
  - **Tujuan:** Menyediakan formulir bagi pengguna untuk mengirim atau mengedit kritik dan saran.
  - **Fitur:**
    - Berisi `TextFormField` untuk input teks.
    - Logika untuk menyimpan masukan baru atau memperbarui masukan yang sudah ada di Firestore.
    - Menampilkan `SnackBar` sebagai notifikasi setelah operasi berhasil atau gagal.

### File Konfigurasi Firebase:
- **`firestore.rules`**
  - **Tujuan:** Mengamankan data di Cloud Firestore.
  - **Aturan Utama:**
    - **`allow read: if true;`** pada `/pengaturan/konfigurasi_global`: Mengizinkan semua klien (termasuk yang belum login) untuk membaca status pemeliharaan. Ini penting agar aplikasi bisa menampilkan halaman pemeliharaan bahkan sebelum pengguna masuk.
    - **`allow write: if request.auth.token.admin == true;`**: Membatasi hak tulis (membuat, mengubah, menghapus) hanya kepada pengguna yang terautentikasi dan memiliki *custom claim* `admin` di token mereka. Ini mencegah pengguna biasa mengubah status pemeliharaan aplikasi secara tidak sah.

---
## 4. Catatan Pengembangan & Log Perubahan

### # Versi: v1.0.1
Sumber: `pubspec.yaml` (version: 1.0.0+1)
Tanggal: 25 Juli 2024

#### Tujuan:
- Mengimplementasikan fitur **Mode Pemeliharaan** yang dapat dikontrol dari jauh melalui Firestore.
- Mengamankan data pengaturan aplikasi menggunakan Firestore Security Rules.

#### Perubahan:
- **`lib/shared/model/pengaturan_model.dart` (Baru):**
  - **ditambah:** Membuat model untuk data pengaturan global, termasuk status pemeliharaan.
- **`lib/user/app_user.dart` (Refactor):**
  - **ditambah:** Menambahkan logika di `initState` untuk memeriksa koneksi internet dan mengambil data pengaturan dari Firestore.
  - **ditambah:** Menggunakan `FutureBuilder` untuk secara dinamis menampilkan `MaintenancePage` atau aplikasi utama berdasarkan status pemeliharaan dari server.
- **`lib/user/page/splash_screen_user.dart` (Refactor):**
  - **dihapus:** Menghilangkan logika pemeriksaan status pemeliharaan yang redundan, karena sekarang ditangani sepenuhnya oleh `app_user.dart`.
  - **diubah:** Fokus file ini sekarang murni hanya untuk memeriksa sesi login pengguna.
- **`firestore.rules` (Baru):**
  - **ditambah:** Membuat file aturan keamanan untuk Firestore.
  - **ditambah:** Menambahkan aturan yang mengizinkan `read` publik untuk status pemeliharaan, tetapi membatasi `write` hanya untuk admin.
- **`firebase.json` (Diperbarui):**
  - **diubah:** Diperbarui secara otomatis setelah `firebase init firestore` untuk menautkan file `firestore.rules` ke konfigurasi deploy.

#### Bug yang Diatasi:
- **Kerentanan Keamanan:** Data di Firestore dapat diubah oleh siapa saja. Dengan `firestore.rules`, masalah ini teratasi.
- **Logika Redundan:** Pemeriksaan status aplikasi yang sebelumnya mungkin tersebar, kini terpusat di `app_user.dart`.

#### Solusi & Analisa:
- Dengan memisahkan logika pemeriksaan status pemeliharaan ke `app_user.dart`, alur startup aplikasi menjadi lebih jelas dan terpusat. `SplashScreenUser` kini memiliki tanggung jawab tunggal. Implementasi `firestore.rules` adalah langkah krusial untuk mengamankan aplikasi dan mencegah akses yang tidak sah ke data konfigurasi penting. Fitur ini sekarang siap produksi dari segi fungsionalitas dan keamanan dasar.

### # Versi: v1.0.0
Sumber: pubspec.yaml (version: 1.0.0+1)
Tanggal: 24 Juli 2024

#### Tujuan:
- Memperbaiki serangkaian *error* analisis statis yang menyebabkan build gagal dan perilaku tidak terduga.

#### Perubahan:
- **`lib/user/page/home_page.dart`**:
  - **diubah:** Mengganti pemanggilan fungsi `hitungStatusMasaAktif` yang sudah tidak ada dengan metode baru dari kelas utilitas `PerhitunganUtil.getTeksSisaMasaAktif` dan `PerhitunganUtil.getWarnaSisaMasaAktif`.
  - **dihapus:** Impor untuk `hitung_masa_aktif.dart` yang sudah tidak relevan.
- **`lib/user/page/profil_page.dart`**:
  - **diubah:** Mengadaptasi kode untuk menggunakan metode baru dari `PerhitunganUtil` untuk menampilkan sisa masa aktif dan warnanya.
  - **dihapus:** Impor yang tidak terpakai.

#### Bug:
- `uri_does_not_exist`: Path impor salah.
- `undefined_method`: Memanggil fungsi `hitungStatusMasaAktif` yang sudah dihapus/diganti.
- `undefined_operator`: Mencoba mengakses properti dari hasil fungsi yang tidak mengembalikannya.
- `unused_import`: Beberapa file memiliki impor yang tidak digunakan.

#### Solusi:
- Memperbaiki path impor yang salah.
- Melakukan refaktorisasi dengan mengganti pemanggilan fungsi lama ke metode baru dari kelas `PerhitunganUtil`.
- Menghapus semua impor yang tidak terpakai untuk membersihkan kode.

#### Analisa:
- Perbaikan ini berhasil menstabilkan basis kode dan menghilangkan semua *error* analisis statis. Ini adalah langkah penting sebelum menambahkan fitur baru untuk memastikan fondasi proyek yang solid.

### # Versi: v1.0.0
Sumber: pubspec.yaml (version: 1.0.0+1)
Tanggal: 24 Juli 2024

#### Tujuan:
- Memperbaiki *error* analisis terkait fungsi *logging* yang tidak terdefinisi di seluruh aplikasi.

#### Perubahan:
- **`lib/user/page/profil_page.dart`**:
  - **ditambah:** Menambahkan impor `package:wifi/shared/debug/log.dart`.
  - **diubah:** Mengganti semua pemanggilan `log(...)` bawaan dari `dart:developer` menjadi pemanggilan metode dari kelas `Log` kustom (`Log.info()`, `Log.warning()`, `Log.error()`).

#### Bug:
- `undefined_method`: Peringatan `The method 'log' isn't defined for the type '_ProfilPageState'` muncul di banyak tempat karena impor `dart:developer` belum ada atau karena standar logging baru belum diterapkan.

#### Solusi:
- Mengimplementasikan kelas logging kustom (`Log`) di seluruh file `profil_page.dart` untuk standardisasi. Ini memastikan bahwa semua output log mengikuti format yang sama dan mudah untuk dikelola.

#### Analisa:
- Dengan refaktorisasi ini, sistem logging menjadi lebih terstruktur dan informatif. Ini akan mempermudah proses *debugging* di masa depan karena log sekarang memiliki level (info, warning, error) dan format yang konsisten.
---

## 5. Rencana & Langkah Saat Ini
Proyek sekarang dalam keadaan stabil. Langkah selanjutnya adalah memperbaiki 6 isu analisis statis yang tersisa.
