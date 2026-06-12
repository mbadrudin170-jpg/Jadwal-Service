# Aturan Penggunaan Radio Button Flutter

1. **Dilarang menggunakan widget `RadioListTile`.**
2. **Selalu gunakan `RadioGroup` sebagai solusi utama untuk pilihan tunggal (single selection).**
3. **Jika membuat pilihan radio baru, gunakan `RadioGroup` meskipun jumlah opsi hanya sedikit.**
4. **Jangan merekomendasikan `RadioListTile` dalam contoh kode, dokumentasi, maupun saran implementasi.**
5. **Jangan mengganti `RadioGroup` yang sudah ada menjadi `RadioListTile`.**
6. **Jika menemukan `RadioListTile` pada kode lama, rekomendasikan migrasi ke `RadioGroup`.**
7. **Pisahkan tampilan (label, ikon, deskripsi) dari komponen radio agar lebih fleksibel dibanding `RadioListTile`.**
8. **Gunakan widget kustom di dalam `RadioGroup` jika membutuhkan layout yang kompleks.**
9. **Prioritaskan API Flutter terbaru dan hindari pola radio yang sudah tidak direkomendasikan.**
10. **Semua implementasi radio button baru wajib mengikuti pola `RadioGroup`.**
11. **Jika pengguna meminta radio button, asumsikan solusi yang diinginkan adalah `RadioGroup`, bukan `RadioListTile`.**
12. **Jangan memberikan contoh kode yang menggunakan properti `groupValue` dan `onChanged` pada banyak widget `Radio` yang berdiri sendiri jika `RadioGroup` dapat digunakan.**
13. **Konsistensi lebih penting daripada kompatibilitas dengan kode lama; gunakan `RadioGroup` untuk seluruh fitur baru.**
14. **Saat melakukan refactor, pertahankan perilaku UI tetapi ubah implementasi radio ke `RadioGroup` bila memungkinkan.**
15. **Jika terdapat beberapa alternatif implementasi radio, pilih dan rekomendasikan `RadioGroup` sebagai opsi utama.**

# Ringkasan Singkat

* ❌ Jangan gunakan `RadioListTile`.
* ❌ Jangan merekomendasikan `RadioListTile`.
* ✅ Gunakan `RadioGroup`.
* ✅ Semua radio button baru menggunakan `RadioGroup`.
* ✅ Migrasikan kode lama ke `RadioGroup` jika memungkinkan.

# Aturan Perbaikan Unit Test

1. **Dilarang mengubah unit test yang sudah lulus (passing test).**
2. **Dilarang melakukan refactor pada unit test yang tidak memiliki masalah.**
3. **Fokus hanya pada unit test yang gagal (failing test).**
4. **Perbaikan harus seminimal mungkin untuk membuat test kembali lulus.**
5. **Jangan mengubah assertion yang sudah benar dan berhasil dijalankan.**
6. **Jangan mengubah nama test, group, atau struktur test yang tidak terkait dengan masalah.**
7. **Jangan memindahkan kode test yang sudah berfungsi dengan baik.**
8. **Jangan mengganti pendekatan testing yang sudah berjalan hanya karena preferensi pribadi.**
9. **Jangan melakukan optimasi, pembersihan kode, atau penyederhanaan pada test yang tidak bermasalah.**
10. **Jangan mengubah mock, fake, stub, atau helper test yang sudah bekerja dengan benar kecuali menjadi penyebab langsung kegagalan test.**
11. **Perubahan harus dibatasi pada area yang menyebabkan error.**
12. **Jika hanya satu test yang gagal, jangan mengubah test lain yang lulus.**
13. **Jika hanya satu blok kode yang bermasalah, jangan mengubah file test secara menyeluruh.**
14. **Pertahankan perilaku, cakupan, dan tujuan test yang sudah ada.**
15. **Setiap perubahan harus memiliki hubungan langsung dengan error yang sedang diperbaiki.**
16. **Dilarang melakukan perubahan kosmetik (formatting, penamaan, urutan kode) pada test yang tidak bermasalah.**
17. **Jangan menulis ulang seluruh file test jika cukup memperbaiki beberapa baris saja.**
18. **Prioritaskan prinsip "perubahan terkecil yang menyelesaikan masalah".**
19. **Jika terdapat beberapa solusi, pilih solusi yang menghasilkan modifikasi kode paling sedikit.**
20. **Sebelum mengubah unit test, identifikasi terlebih dahulu test mana yang gagal dan batasi perubahan hanya pada bagian tersebut.**

# Ringkasan Singkat

* ❌ Jangan sentuh test yang sudah lulus.
* ❌ Jangan refactor test yang tidak bermasalah.
* ❌ Jangan menulis ulang file test secara keseluruhan.
* ✅ Perbaiki hanya test yang gagal.
* ✅ Ubah hanya baris yang menyebabkan error.
* ✅ Gunakan perubahan sekecil mungkin untuk membuat test kembali lulus.

# Aturan Analisis File Sebelum Mengubah Kode

1. **Wajib membaca seluruh isi file yang akan diubah sebelum melakukan perubahan apa pun.**
2. **Dilarang langsung menulis atau mengubah kode tanpa memahami isi file terlebih dahulu.**
3. **Pahami tujuan, tanggung jawab, dan alur kerja file sebelum melakukan modifikasi.**
4. **Identifikasi seluruh fungsi, class, provider, model, state, dan konstanta yang ada di dalam file.**
5. **Periksa seluruh import yang digunakan oleh file tersebut.**
6. **Baca file-file yang menjadi dependency langsung dari file yang sedang dikerjakan.**
7. **Pahami hubungan antara file yang sedang diubah dengan file lain yang terkait.**
8. **Jangan membuat asumsi terhadap isi file yang belum dibaca.**
9. **Jika terdapat dependency yang belum diberikan, minta file tersebut terlebih dahulu.**
10. **Pastikan memahami alur data masuk dan keluar dari file sebelum mengubah logika.**

# Aturan Membaca Dependency

11. **Wajib membaca file yang dipanggil langsung oleh file yang sedang dikerjakan jika memengaruhi logika perubahan.**
12. **Wajib membaca model yang digunakan oleh file tersebut.**
13. **Wajib membaca repository, service, datasource, provider, atau helper yang terkait dengan perubahan.**
14. **Wajib membaca interface atau abstract class yang digunakan.**
15. **Jika suatu fungsi berasal dari file lain, pahami implementasinya sebelum mengubah kode yang bergantung padanya.**
16. **Jika suatu state berasal dari provider lain, pahami provider tersebut terlebih dahulu.**
17. **Jika perubahan melibatkan database, baca model dan layer database yang terkait.**
18. **Jika perubahan melibatkan UI, baca widget atau komponen yang berinteraksi langsung dengannya.**
19. **Jika perubahan melibatkan navigasi, baca alur navigasi yang terkait.**
20. **Jika perubahan melibatkan autentikasi, baca seluruh alur autentikasi yang digunakan oleh fitur tersebut.**

# Aturan Sebelum Menulis Solusi

21. **Lakukan analisis terlebih dahulu sebelum mengusulkan perubahan kode.**
22. **Jelaskan file mana saja yang sudah dibaca dan dipahami.**
23. **Identifikasi file tambahan yang masih diperlukan sebelum implementasi dimulai.**
24. **Jangan memberikan solusi final sebelum dependency penting selesai dianalisis.**
25. **Pastikan solusi yang diberikan sesuai dengan arsitektur proyek yang sudah ada.**
26. **Jangan memperkenalkan pola baru jika pola yang ada sudah konsisten dan memadai.**
27. **Utamakan konsistensi dengan struktur proyek yang sudah berjalan.**
28. **Periksa dampak perubahan terhadap file lain yang terhubung.**
29. **Pastikan perubahan tidak merusak kontrak API, model, atau interface yang sudah digunakan.**
30. **Pastikan perubahan tetap kompatibel dengan kode yang sudah ada.**

# Aturan Jika Informasi Belum Lengkap

31. **Jika file yang diperlukan belum tersedia, hentikan implementasi dan minta file tersebut.**
32. **Jangan menebak isi file yang belum diberikan.**
33. **Jangan membuat fungsi, model, provider, atau service berdasarkan asumsi.**
34. **Jangan mengubah arsitektur karena keterbatasan informasi.**
35. **Tentukan secara jelas file apa saja yang masih perlu dikirim.**
36. **Sebutkan alasan mengapa file tersebut diperlukan.**
37. **Tunggu hingga file yang diperlukan tersedia sebelum melakukan perubahan.**

# Checklist Sebelum Mengubah Kode

* ✅ Sudah membaca seluruh file yang akan diubah.
* ✅ Sudah membaca dependency yang relevan.
* ✅ Sudah memahami alur data.
* ✅ Sudah memahami model yang digunakan.
* ✅ Sudah memahami provider/repository/service terkait.
* ✅ Sudah mengecek dampak perubahan ke file lain.
* ✅ Tidak ada asumsi terhadap file yang belum dibaca.
* ✅ Semua file penting sudah tersedia.

# Ringkasan Singkat

* Baca file yang akan diubah terlebih dahulu.
* Baca dependency yang digunakan file tersebut.
* Jangan membuat asumsi terhadap file yang belum dibaca.
* Jika ada dependency yang belum tersedia, minta file tersebut.
* Analisis dulu, implementasi kemudian.
* Pahami dampak perubahan terhadap seluruh alur fitur sebelum menyentuh kode.
# Aturan Penomoran Unit Test

1. **Setiap `test()`, `testWidgets()`, dan skenario pengujian wajib memiliki nomor urut.**
2. **Nomor urut harus diletakkan di awal nama test.**
3. **Gunakan format dua digit untuk menjaga konsistensi (`01`, `02`, `03`, dan seterusnya).**
4. **Penomoran harus berurutan dalam setiap `group()`.**
5. **Jika terdapat sub-group, penomoran dapat dimulai kembali dari `01` pada group tersebut.**
6. **Jangan melewati nomor urut tanpa alasan yang jelas.**
7. **Jika menambahkan test baru, sesuaikan nomor agar tetap berurutan.**
8. **Nomor urut hanya digunakan pada deskripsi test, bukan nama fungsi atau variabel.**
9. **Setiap deskripsi test tetap wajib menggunakan Bahasa Indonesia.**
10. **Nomor urut tidak boleh menggantikan deskripsi; deskripsi tetap harus menjelaskan perilaku yang diuji.**

# Format yang Wajib Digunakan

```dart
test('01. harus mengembalikan akun yang sedang login', () async {});
test('02. harus menghapus token login saat logout', () async {});
test('03. harus menampilkan error ketika penyimpanan gagal', () async {});
```

# Contoh Group

```dart
group('Provider Akun', () {
  test(
    '01. harus mengembalikan akun yang sedang login',
    () async {},
  );

  test(
    '02. harus menghapus token login saat logout',
    () async {},
  );

  test(
    '03. harus menampilkan error ketika penyimpanan gagal',
    () async {},
  );
});
```

# Contoh yang Salah

```dart
test('harus mengembalikan akun yang sedang login', () async {});
```

Alasan: tidak memiliki nomor urut.

```dart
test('1. harus mengembalikan akun yang sedang login', () async {});
```

Alasan: tidak menggunakan format dua digit.

```dart
test('03. harus mengembalikan akun yang sedang login', () async {});
test('07. harus menghapus token login saat logout', () async {});
```

Alasan: nomor tidak berurutan.

# Aturan Tambahan untuk File Test Baru

11. **Sebelum membuat test, identifikasi seluruh skenario yang akan diuji.**
12. **Susun urutan test berdasarkan alur logika fitur, bukan secara acak.**
13. **Mulai dari skenario normal (happy path), kemudian skenario gagal, lalu edge case.**
14. **Nomor urut harus mencerminkan urutan pembacaan yang logis.**
15. **Saat menambahkan test baru di tengah, sesuaikan seluruh nomor yang terdampak agar tetap berurutan.**

# Ringkasan Singkat

* ✅ Semua test wajib bernomor.
* ✅ Format nomor: `01.`, `02.`, `03.`
* ✅ Nomor di awal deskripsi test.
* ✅ Deskripsi tetap menggunakan Bahasa Indonesia.
* ✅ Nomor harus berurutan dalam setiap group.
* ❌ Jangan membuat test tanpa nomor urut.
* ❌ Jangan menggunakan format `1.`, `2.`, `3.`.
* ❌ Jangan membuat nomor yang loncat-loncat.
