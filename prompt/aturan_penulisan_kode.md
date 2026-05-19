# // path: prompt/aturan_penulisan_kode.md


---

### Aturan Ngoding Flutter (AI)

**1. Bahasa Komentar dan Percakapan**  
Seluruh komentar di dalam kode serta percakapan dengan AI wajib menggunakan **Bahasa Indonesia**.

**2. Penamaan dalam Kode**  
Seluruh nama **fungsi, variabel, props, parameter, file, dan class** wajib ditulis dalam **Bahasa Inggris**.  
Jika belum mengetahui padanan kata yang tepat:
- Tulis perkiraan nama dalam Bahasa Indonesia di komentar.
- Tanyakan langsung ke AI untuk mendapatkan padanan Bahasa Inggris yang lazim di Flutter/Dart.

**3. Pembiasaan Bahasa Inggris Bertahap**  
Penulisan nama tetap dimulai dengan Bahasa Inggris terlebih dahulu. Proses tanya-jawab ini bertujuan mempercepat migrasi ke Bahasa Inggris penuh tanpa menghambat alur ngoding, sambil tetap belajar secara bertahap.

**4. Format dan Kerapihan Kode**  
- Wajib menggunakan *trailing comma* di setiap widget tree agar auto-format rapi (sesuai `dart format`).  
- Gunakan `const` constructor sebanyak mungkin untuk widget stateless.  
- Pisahkan widget besar menjadi widget-widget kecil yang fokus pada satu tanggung jawab.  
- Jika widget tree sudah menjorok terlalu dalam (nested), ekstrak bagian tersebut menjadi widget private di file yang sama.  
- Maksimal satu widget publik per file, kecuali widget private kecil yang hanya digunakan dalam file yang sama.

**5. Penggunaan Ikon Wajib dari `AppIcons`**  
- Semua ikon dalam aplikasi **harus diambil dari class `AppIcons`** (`lib/shared/theme/app_icons.dart`), **tidak boleh** menggunakan `Icons.xxx` secara langsung di widget.  
- Jika ikon yang dibutuhkan **belum tersedia** di `AppIcons`, **wajib menambahkannya terlebih dahulu** sebagai properti `static const` baru dengan nama yang deskriptif dalam Bahasa Inggris, lalu gunakan properti tersebut.  
- Tujuan: menjaga konsistensi ikon di seluruh aplikasi dan memudahkan penggantian ikon secara terpusat.

---