# Fungsi Berkas Proyek

Dokumen ini menjelaskan fungsi dari berbagai file penting dalam proyek untuk memudahkan pemahaman dan pemeliharaan.

---

### **Direktori `lib/main`**

**Tujuan:**
Berisi file-file *entry point* (titik masuk) aplikasi. Struktur ini memungkinkan peluncuran aplikasi dengan konfigurasi yang berbeda tergantung pada peran (Admin atau User) dan lingkungan (Development atau Production). Ini adalah praktik kunci dalam manajemen *build flavor*.

**Struktur:**
Direktori ini terbagi menjadi dua sub-direktori utama:
*   `lib/main/main_admin`: Titik masuk untuk aplikasi khusus **Admin**.
*   `lib/main/main_user`: Titik masuk untuk aplikasi yang digunakan oleh **User**.

Setiap sub-direktori memiliki dua file:
*   `_dev.dart`: Untuk lingkungan **pengembangan (development)**. Menggunakan konfigurasi seperti Firebase project versi dev.
*   `_prod.dart`: Untuk lingkungan **produksi (production)**. Menggunakan konfigurasi untuk rilis resmi ke pengguna.

**Alur Kerja Inisialisasi (di dalam fungsi `main`):**
Sebelum aplikasi dijalankan dengan `runApp()`, beberapa layanan penting diinisialisasi terlebih dahulu:

1.  **`WidgetsFlutterBinding.ensureInitialized()`**: Memastikan semua *binding* Flutter siap sebelum menjalankan kode asinkron.
2.  **`FlutterNativeSplash.preserve()`**: Menahan *splash screen* agar tetap tampil selama proses inisialisasi berlangsung.
3.  **`Firebase.initializeApp()`**: Menghubungkan aplikasi ke proyek Firebase. File ini mengimpor opsi Firebase yang berbeda (`firebase_option_...dart`) sesuai dengan *flavor*-nya (misal, `firebase_option_admin_dev.dart` untuk admin dev).
4.  **Inisialisasi Layanan Tambahan**:
    *   **`MobileAds.instance.initialize()`**: Mengaktifkan SDK Google Mobile Ads (ada di semua *flavor*).
    *   **`BackgroundService.init()`**: Mempersiapkan tugas latar belakang (hanya di aplikasi *user*).
    *   **`GmaMediationUnity().set...Consent()`**: Mengatur persetujuan GDPR & CCPA untuk mediasi iklan Unity (hanya di aplikasi *user*).
5.  **`runApp(ProviderScope(child: ...))`**: Menjalankan UI aplikasi utama (`AppAdmin` atau `AppUser`) dan membungkusnya dengan `ProviderScope` agar *state management* menggunakan Riverpod tersedia di seluruh aplikasi.

**Keuntungan Utama:**
*   **Pemisahan Konfigurasi:** Memisahkan kunci API, endpoint, dan konfigurasi lain antara lingkungan dev dan prod, sehingga lebih aman dan terorganisir.
*   **Build yang Fleksibel:** Memudahkan proses *build* untuk target yang berbeda tanpa harus mengubah kode secara manual.

---

### **Direktori `lib/shared/export`**

**Tujuan:**
Menyederhanakan impor modul dengan menggunakan teknik "barrel file". Setiap file di dalam direktori ini (misalnya `model.dart`, `enum.dart`, `service.dart`) bertugas meng-`export` semua file dari sub-direktori terkait. Dengan cara ini, file lain di dalam aplikasi hanya perlu melakukan satu kali impor dari *barrel file* ini untuk mengakses semua model, enum, atau layanan, tanpa perlu mengimpor setiap file satu per satu.

**Contoh Penggunaan:**
*   **File `lib/shared/export/model.dart`** mengekspor semua file model dari `lib/features/.../model/...`.
*   Di file lain, Anda cukup menulis:
    ```dart
    import 'package:wifi/shared/export/model.dart';
    ```
    ...untuk bisa langsung menggunakan `UserModel`, `ProductModel`, dll.

**Keuntungan Utama:**
*   **Impor yang Rapi:** Mengurangi jumlah baris `import` di bagian atas setiap file.
*   **Manajemen Dependensi yang Lebih Mudah:** Jika lokasi file model berubah, Anda hanya perlu memperbarui path `export` di dalam `model.dart`, tanpa perlu mengubah setiap file yang mengimpornya.
*   **Struktur Proyek yang Bersih:** Membuat kode lebih terorganisir dan mudah dinavigasi.

---

### **`lib/shared/theme/app_sizes.dart`**

**Tujuan:**
Menyediakan konstanta untuk ukuran (padding, margin) dan spasi (`SizedBox`) yang akan digunakan secara seragam di seluruh aplikasi. Ini memastikan konsistensi desain dan mempermudah pembaruan.

**Struktur & Penggunaan:**

*   **Kelas `TSizes`:** Berisi nilai `double` untuk ukuran.
    *   **Contoh:** `TSizes.p16` menghasilkan nilai `16.0`.
    *   **Penggunaan:** `Padding(padding: EdgeInsets.all(TSizes.p16))`

*   **Variabel `gapH*` & `gapW*`:** Menyediakan widget `SizedBox` siap pakai.
    *   `gapH16` untuk spasi **vertikal** (`height: 16.0`).
    *   `gapW16` untuk spasi **horizontal** (`width: 16.0`).
    *   **Penggunaan:** `Column(children: [widget1, gapH16, widget2])`

**Keuntungan Utama:**
*   **Konsistensi UI:** Menjaga agar semua jarak dan ukuran seragam.
*   **Perawatan Mudah:** Cukup ubah di satu file untuk mengubah ukuran di seluruh aplikasi.
*   **Kode Lebih Jelas:** Menghindari penggunaan angka acak (magic numbers) di dalam kode UI.

---

### **`lib/shared/theme/app_colors.dart`**

**Tujuan:**
Menjadi pusat definisi palet warna aplikasi. Semua warna yang digunakan dalam tema (terang maupun gelap) dan komponen spesifik didefinisikan di sini.

**Struktur & Penggunaan:**

*   **Kelas `TColors`:** Berisi properti `static const` untuk setiap warna.
*   **Contoh:** `TColors.primaryColor`, `TColors.lightBackground`, `TColors.pointColor`.
*   **Penggunaan:** `container.color = TColors.primaryColor`.

**Keuntungan Utama:**
*   **Branding Konsisten:** Memastikan warna sesuai dengan identitas merek di seluruh aplikasi.
*   **Manajemen Tema:** Memudahkan penyesuaian warna untuk tema terang dan gelap.
*   **Satu Sumber Kebenaran:** Semua nilai warna terpusat di satu tempat.

---

### **`lib/shared/theme/app_icons.dart`**

**Tujuan:**
Mengelola semua ikon yang digunakan di aplikasi secara terpusat untuk memastikan konsistensi visual dan kemudahan penggantian.

**Struktur & Penggunaan:**

*   **Kelas `TIcons`:** Berisi properti `static const IconData` untuk setiap ikon.
*   **Contoh:** `TIcons.add`, `TIcons.customers`, `TIcons.points`.
*   **Penggunaan:** `Icon(TIcons.save)`.

**Keuntungan Utama:**
*   **Ikon Seragam:** Menghindari penggunaan ikon yang berbeda untuk fungsi yang sama.
*   **Penggantian Mudah:** Mengganti satu ikon di `TIcons` akan memperbaruinya di seluruh aplikasi.
*   **Kode Lebih Deskriptif:** `Icon(TIcons.delete)` lebih jelas daripada `Icon(Icons.delete)` karena menegaskan bahwa itu adalah ikon standar aplikasi.

---

### **`lib/shared/theme/app_theme.dart`**

**Tujuan:**
Mendefinisikan seluruh properti visual (tema) untuk mode terang (`lightTheme`) dan mode gelap (`darkTheme`), menggabungkan warna, tipografi, dan gaya komponen.

**Struktur & Penggunaan:**

*   **Kelas `AppTheme`:** Berisi dua properti utama: `static final ThemeData lightTheme` dan `static final ThemeData darkTheme`.
*   Menggunakan `TColors` untuk warna dan mendefinisikan `TextTheme` untuk tipografi.
*   Menyesuaikan tema untuk komponen spesifik seperti `AppBar`, `ElevatedButton`, dan `ListTile`.
*   **Penggunaan:** Diterapkan di level tertinggi aplikasi (misal: di `MaterialApp.theme` dan `MaterialApp.darkTheme`).

**Keuntungan Utama:**
*   **Pemisahan Logika:** Memisahkan definisi tema dari logika UI lainnya.
*   **Tampilan Terpadu:** Memastikan semua komponen di seluruh aplikasi memiliki tampilan dan nuansa yang konsisten sesuai dengan mode tema yang aktif.

---

### **`lib/shared/theme/theme_provider.dart`**

**Tujuan:**
Mengelola **state** atau kondisi tema aplikasi saat ini. Ini memungkinkan pengguna untuk mengubah tema (terang, gelap, atau sistem) dan menyimpan preferensi tersebut secara lokal.

**Struktur & Penggunaan:**

*   **Kelas `ThemeProviderImpl`:** Mengimplementasikan `ChangeNotifier` untuk memberi tahu aplikasi saat tema berubah.
*   Menggunakan `LocalStorageService` untuk menyimpan dan memuat preferensi tema pengguna, sehingga pilihan tema tetap ada bahkan setelah aplikasi ditutup.
*   Menyediakan metode seperti `setTheme(ThemeMode)` untuk mengubah tema.
*   **Penggunaan:** Disediakan melalui `ChangeNotifierProvider` di widget root (`AppUser` atau `AppAdmin`) sehingga bisa diakses dari mana saja di dalam aplikasi.

**Keuntungan Utama:**
*   **Interaktivitas Pengguna:** Memberikan kontrol kepada pengguna untuk memilih tema favorit mereka.
*   **Persistensi:** Mengingat pilihan pengguna, memberikan pengalaman yang lebih personal.
*   **Manajemen State Terpusat:** Mengelola state tema di satu lokasi yang logis.

---

### **Direktori `lib/shared/enum`**

**Tujuan:**
Direktori ini berisi kumpulan file `enum` (enumerasi) yang mendefinisikan sekumpulan nilai konstan untuk berbagai tipe data dalam aplikasi. Penggunaan `enum` sangat penting untuk mencegah kesalahan pengetikan (typo), menghindari penggunaan string mentah (*magic strings*), dan membuat kode lebih aman, terbaca, dan mudah dikelola.

#### **`apk_architecture_enum.dart`**
*   **Enum:** `ApkArchitectureEnum`
*   **Fungsi:** Mendefinisikan jenis arsitektur CPU (`bit32`, `bit64`, `universal`, `x86_64`) untuk file APK.

#### **`category_type_enum.dart`**
*   **Enum:** `CategoryType`
*   **Fungsi:** Membedakan jenis kategori transaksi, yaitu `income` (pemasukan), `expense` (pengeluaran), dan `transfer`.
*   **Fitur Tambahan:** Dilengkapi `extension` `displayName` untuk mendapatkan representasi teks dalam Bahasa Indonesia (misal: 'Pemasukan').

#### **`duration_type_enum.dart`**
*   **Enum:** `DurationType`
*   **Fungsi:** Menentukan satuan durasi untuk sebuah paket atau layanan, seperti `minutes`, `hours`, `days`, dan `months`.
*   **Fitur Tambahan:** Memiliki `getter` `displayName` untuk menampilkan nama satuan dalam Bahasa Indonesia (misal: 'Hari').

#### **`payment_status_enum.dart`**
*   **Enum:** `PaymentStatus`
*   **Fungsi:** Merepresentasikan status pembayaran sebuah tagihan atau transaksi, yaitu `paid` (lunas) dan `unpaid` (belum lunas).
*   **Fitur Tambahan:** Dilengkapi `getter` `displayName` untuk konversi ke teks 'Lunas' atau 'Belum Lunas'.

#### **`table_name_enum.dart`**
*   **Enum:** `TableName`
*   **Fungsi:** Berisi daftar semua nama tabel yang ada di dalam database lokal (SQLite). Sangat krusial untuk operasi sinkronisasi dan akses database agar terhindar dari kesalahan nama tabel.

#### **`transaction_type_enum.dart`**
*   **Enum:** `TransactionType`
*   **Fungsi:** Mendefinisikan jenis-jenis transaksi dasar: `income`, `expense`, dan `transfer`.
*   **Fitur Tambahan:** Memiliki `getter` `displayName` untuk mengubah nilai enum menjadi teks yang mudah dibaca ('Pemasukan', 'Pengeluaran', 'Transfer').

#### **`user_role_enum.dart`**
*   **Enum:** `UserRole`
*   **Fungsi:** Membedakan peran pengguna dalam sistem, yaitu `admin` (hak akses penuh) dan `user` (hak akses terbatas).
