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

```
lib/
├── admin
│   ├── app_admin.dart
│   ├── data
│   │   └── sqlite.dart
│   ├── firebase_option
│   │   └── firebase_option_admin_dev.dart
│   ├── halaman
│   │   ├── dashboard_page.dart
│   │   ├── detail
│   │   ├── form
│   │   ├── lainnya
│   │   ├── pembantu
│   │   ├── tab
│   │   ├── tes
│   │   └── widget
│   ├── halaman_utama.dart
│   └── splash_screen_admin.dart
├── main_admin.dart
├── main_user.dart
├── shared
│   ├── common
│   ├── data
│   ├── debug
│   ├── enum
│   ├── export
│   ├── model
│   ├── operasi
│   ├── services
│   ├── theme
│   ├── utils
│   ├── whatsapp
│   └── widget
└── user
    ├── app_user.dart
    ├── data
    ├── firebase_option
    ├── hooks
    ├── maintenance_page.dart
    ├── page
    ├── provider
    ├── services
    └── widget
```

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
- **`lib/shared/widget/card/point_card.dart`**
    - **Tujuan**: Menampilkan kartu (card) yang berisi informasi total poin pengguna dengan gaya visual yang menarik.
    - **Fitur**:
        - Menampilkan jumlah poin, ikon, dan menggunakan warna tema yang dapat disesuaikan.
        - Memiliki efek `boxShadow` dan latar belakang ikon yang warnanya disesuaikan dengan `themeColor` untuk memberikan tampilan yang premium.

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

### # Versi: v1.0.0
Sumber: pubspec.yaml (version: 1.0.0+1)
Tanggal: 25 Juli 2024

#### Tujuan:
Memperbaiki peringatan `deprecated_member_use` untuk meningkatkan kualitas kode dan menghilangkan masalah dari `flutter analyze`.

#### Perubahan:
- **`lib/shared/widget/card/point_card.dart`**:
  - **diubah:** Mengganti `themeColor.withOpacity(0.1)` menjadi `themeColor.withAlpha(26)` pada dua tempat (untuk `boxShadow` dan `Container` ikon).

#### Bug:
- `deprecated_member_use`: `flutter analyze` melaporkan bahwa `'withOpacity'` sudah usang dan menyarankan penggunaan metode lain untuk menghindari kehilangan presisi warna.

#### Solusi:
- Mengadopsi `.withAlpha()` sebagai pengganti `.withOpacity()`. Nilai `withAlpha(26)` setara dengan `withOpacity(0.1)` (karena 0.1 * 255 ≈ 25.5, dibulatkan menjadi 26), sehingga tampilan visual tetap sama sementara kode diperbarui sesuai praktik terbaik.

#### Dampak:
- Kode menjadi lebih bersih, modern, dan sesuai dengan rekomendasi linter Flutter terbaru.
- Menghilangkan semua *issue* dari `flutter analyze`, menghasilkan basis kode yang "bersih".

#### Analisa:
- Menjaga basis kode bebas dari peringatan linter adalah praktik yang baik. Dengan proaktif memperbaiki anggota yang usang, kita memastikan aplikasi lebih mudah dipelihara, lebih stabil, dan siap untuk pembaruan Flutter di masa mendatang. Perbaikan ini, meskipun kecil, menunjukkan komitmen terhadap kualitas kode.

### # Versi: v1.0.0
Sumber: `pubspec.yaml` (version: 1.0.0+1)
Tanggal: 25 Juli 2024

#### Tujuan:
- Memastikan konsistensi data antara operasi lokal dan server dengan menambahkan parameter `dariServer` pada semua metode tulis di lapisan operasi data (`lib/shared/operasi/`).

#### Perubahan:
- **`lib/shared/operasi/operasi_dasar.dart`**:
  - **diubah:** Menambahkan parameter opsional `{bool dariServer = false}` ke semua metode tulis (`sisipkan`, `perbarui`, `hapus`, `jalankanOperasiKompleks`, `sisipkanAtauPerbaruiBatch`).
  - **diubah:** Logika internal diubah untuk melewati pemicu sinkronisasi (`setWaktuUpdateTerbaru()`) jika `dariServer` bernilai `true`, mencegah loop sinkronisasi.
- **`lib/shared/operasi/dompet_operasi.dart`**:
  - **diubah:** Semua metode tulis (`createDompet`, `updateDompet`, `deleteDompet`, `arsipkanDompet`, `sisipkanAtauPerbaruiBatch`) diperbarui untuk menerima dan meneruskan parameter `dariServer` ke `OperasiDasar`.
- **`lib/shared/operasi/kategori_operasi.dart`**:
  - **diubah:** Semua metode tulis (`createKategori`, `update`, `delete`, `arsipkanSatuKategori`, `bersihkanDanSisipkanSemua`, `sisipkanAtauPerbaruiBatch`) diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/paket_operasi.dart`**:
  - **diubah:** Semua metode tulis (`createPaket`, `updatePaket`, `hapusPaket`, `hapusSemuaPaket`, `sisipkanAtauPerbaruiBatch`) diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/pelanggan_operasi.dart`**:
  - **diubah:** Semua metode tulis (`createPelanggan`, `updatePelanggan`, `deletePelanggan`, `arsipkanPelanggan`, `sisipkanAtauPerbaruiBatch`) diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/pelanggan_aktif_operasi.dart`**:
  - **diubah:** Semua metode tulis (`createPelangganAktif`, `updatePelangganAktif`, `sisipkanAtauPerbaruiBatch`, `arsipkanPelangganAktif`, `hapusPermanenPelangganYangDiArsipkan`, `hapusSemuaPelangganAktif`, `arsipkanPelangganKadaluarsa`, `arsipkanSemuaPelangganAktif`) diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/transaksi_operasi.dart`**:
  - **diubah:** Metode `tambahTransaksi`, `updateTransaksi`, `arsipkanTransaksi`, dan `sisipkanAtauPerbaruiBatch` diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/kritik_saran_operasi.dart`**:
  - **diubah:** Semua metode tulis (`createKritikSaran`, `sisipkanAtauPerbaruiBatch`, `hapusKritikSaran`, `hapusSemuaKritikSaran`, `hapusByUserId`) diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/pengaturan_operasi.dart`**:
  - **diubah:** Metode `simpanAtauPerbaruiPengaturan` dan `simpanAtauPerbaruiPengaturanDenganBatch` diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/pesanan_operasi.dart`**:
  - **diubah:** Metode `simpanPesanan`, `updateStatusPesanan`, `hapusPesanan`, dan `sisipkanAtauPerbaruiBatch` diperbarui untuk menerima dan meneruskan parameter `dariServer`.
- **`lib/shared/operasi/versi_apk_user_operasi.dart`**:
  - **diubah:** Metode `tambahVersiApkUser`, `perbaruiVersiApkUser`, `arsipkanVersiApkUser`, dan `sisipkanAtauPerbaruiBatch` diperbarui untuk menerima dan meneruskan parameter `dariServer`.

#### Bug yang Diatasi:
- **Potensi Loop Sinkronisasi:** Operasi yang berasal dari server (misalnya, saat mengunduh data) dapat memicu sinkronisasi balik (unggahan), menciptakan siklus yang tidak perlu.
- **Inkonsistensi Logika:** Kurangnya pembeda antara operasi yang diinisiasi oleh pengguna lokal dan operasi yang berasal dari sinkronisasi server.

#### Solusi & Analisa:
- Dengan menambahkan flag `dariServer`, kita sekarang dapat secara eksplisit mengontrol perilaku lapisan data. Ketika sebuah operasi ditandai sebagai berasal dari server, lapisan `OperasiDasar` tidak akan memperbarui waktu sinkronisasi terakhir. Ini secara efektif memutus loop unggah-unduh, membuat proses sinkronisasi lebih efisien, dapat diprediksi, dan lebih mudah di-debug. Perubahan ini memperkuat arsitektur sinkronisasi data aplikasi.

### # Versi: v1.0.0
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
Proyek sekarang dalam keadaan stabil dan bersih dari peringatan analisis. Langkah selanjutnya adalah melanjutkan pengembangan fitur-fitur lain yang dibutuhkan.
