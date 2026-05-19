# // path: prompt/aturan_analisis_error.md


---

### Aturan Analisis Error dan Masalah (AI)

**Tujuan:** Memastikan setiap kali terjadi error atau masalah pada suatu file, AI melakukan pemeriksaan menyeluruh terhadap file tersebut beserta semua dependensi impornya berdasarkan struktur proyek nyata, tanpa spekulasi, dan memeriksa dampak ke file lain.

---

**1. Identifikasi File Bermasalah dan Pemetaan Proyek**
- Tentukan file yang sedang mengalami error atau yang akan diubah/diperbaiki.
- Catat pesan error, stack trace, atau deskripsi masalah yang muncul.
- **Wajib menjalankan `ls -R lib/`** (atau perintah setara) untuk mendapatkan daftar lengkap file dan struktur direktori di dalam folder `lib/`.
- Dari hasil `ls -R lib/`, kenali semua file yang mungkin terkait, termasuk:
  - File yang diimpor langsung oleh file bermasalah.
  - File lain yang berpotensi menjadi sumber masalah berdasarkan nama, lokasi, atau pola.
- Gunakan peta struktur ini sebagai dasar untuk semua langkah penelusuran selanjutnya.

**2. Telusuri dan Baca Seluruh File yang Diimpor (Larangan Spekulasi)**
- Baca daftar impor di bagian atas file yang sedang dikerjakan.
- Untuk setiap impor yang **berasal dari dalam proyek** (bukan package eksternal), **wajib membuka dan membaca isi file tersebut**.
- Fokus pada definisi yang benar-benar digunakan: kelas, fungsi, variabel, enum, ekstensi, dll.
- **Dilarang berspekulasi** atau mengasumsikan isi file impor tanpa membacanya. Setiap referensi ke file impor harus didasarkan pada kode nyata yang sudah dibaca.
- Pastikan tanda tangan (signature), tipe data, parameter, dan struktur yang digunakan di file asli cocok dengan definisi di file impor.
- Jika file impor juga memiliki impor lokal lain yang relevan dengan masalah, AI **harus menelusuri lebih dalam** (dependensi tingkat kedua).

   **Cara Menemukan File dari Path Impor:**
   - **Untuk impor `package:`**: buang bagian `package:nama_app/`, lalu cocokkan dengan struktur di hasil `ls -R lib/`.
   - **Untuk impor relatif**: mulai dari direktori file yang sedang dikerjakan, telusuri path `../` berdasarkan hasil `ls -R lib/`.
   - **Jika file tidak ditemukan**, **wajib jalankan `ls -R lib/`** (atau `find lib/ -type f -name "*.dart"`) untuk mendapatkan struktur terbaru dan cari ulang. Jangan pernah berspekulasi lokasi file.

**3. Analisis Sumber Error Secara Runtut**
Setelah menelusuri file impor, lakukan langkah berikut untuk menentukan sumber error:

- **a. Periksa kesesuaian panggilan:**  
  Bandingkan cara pemanggilan fungsi/metode/widget di file utama dengan definisi aslinya di file impor. Cek: nama, parameter, tipe data, named/positional, required/optional, dan return type.

- **b. Periksa asumsi yang meleset:**  
  Jika di file utama ada asumsi tertentu (misal: suatu fungsi dianggap synchronous padahal async, atau dianggap melempar exception tertentu), cocokkan dengan fakta di file impor.

- **c. Periksa apakah ada perubahan di file impor:**  
  Lihat isi file impor, apakah ada perubahan yang baru saja terjadi? (misal: method dihapus, diganti nama, ditambah parameter, atau dijadikan private).

- **d. Cek apakah error menjalar dari file lain:**  
  Jika file impor yang dicek ternyata juga mengimpor file lokal lain, dan masalah belum ditemukan, **telusuri lebih dalam** ke file tersebut (ulangi poin 2).

- **e. Tentukan lokasi perbaikan:**  
  Setelah semua penelusuran, simpulkan di mana perbaikan harus dilakukan:
  - Di file utama (karena pemanggilan salah).
  - Di file impor (karena definisi yang kurang atau salah).
  - Di kedua file (jika ada ketidakcocokan desain).

- **f. Jangan berspekulasi:**  
  Jika ada bagian yang belum jelas atau file tidak bisa dibaca, **akui dan tanyakan ke pengguna**, jangan menebak.

**4. Periksa Dampak ke File Lain yang Menggunakan Class Ini (Reverse Dependency)**
- Setelah file selesai dianalisis atau akan diperbaiki, **wajib mencari file lain yang menggunakan class dari file tersebut**.
- Gunakan perintah:  
  `grep -r "NamaClass" lib/ --include="*.dart"`  
  di mana `NamaClass` adalah nama class utama (atau class yang diubah) dalam file yang sedang dikerjakan.
- Buka file-file yang ditemukan dan periksa apakah perubahan yang akan dilakukan (misal: mengubah signature method, menghapus method, mengganti tipe properti) akan merusak kompatibilitas di file-file tersebut.
- Jika ya, sertakan penyesuaian yang diperlukan di file-file itu, atau beri tahu pengguna tentang dampaknya.
- Jangan hanya fokus pada perbaikan di file yang dikerjakan, pastikan tidak merusak file lain yang menggunakan class tersebut.

---