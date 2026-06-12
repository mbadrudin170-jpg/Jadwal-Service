// path: prompt/aturan_test.md

### Aturan Test

1. nama test harus menggunakan bahasa indonesia dan kasih nomor urut nya di masing masing test.
2. .
3. nama test dan penempatan path nya harus sesuai dengan file aslinya jika file aslinya lib/shared/operasi/firebase_operasi/settings_op_firebase.dart maka file test nya juga harus test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart.
4. setelah memperbarui file test nya jalankan flutter analzye agar tidak ada error lalu jalankan flutter test untuk file tersebut contoh `flutter test test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart`.
5. jangan pernah merubah test yang tidak error dan test yang sukses cukup rubah saja unit test nya bermasalah.
6. sebelum membuatkan unit test nya tolong baca dan pahami kode sumber nya.
7. Tolong pahami dan selalu ingat aturan ini:
    1. jika kode yang sedang dikerjakan ternyata diimport dari file lain AI wajib melihat file file yang diimport itu,jika file yang di import juga menggunakan kode yang dimpoert dari file lain maka AI wajib membaca nya juga. agar tidak salah file AI harus menajalankan ls -R lib atau ls -R test jika itu file test.
    2. penulisan kode, AI wajib menuliskan kode yang sesuai dengan versi paket saya di pubspec.yaml, kalau bisa lihat dokumentasinya dengan menjalankan read_package_uris dan pub_dev_search,
    3. kode di setiap file harus konsisten.
8. semua file harus dibuatkan file test nya jangan ada yang tidak dibuatkan .
9. setiap file test harus menggunakan mocktail jangan gunakan mockito, lalu cek versi yang terpasang di pubspec.yaml agar penulisan kode nua sesuai dengan versi yang terpasang.


Buatkan unit test lengkap untuk file berikut.

Aturan:
1. Test harus mencakup seluruh kode dari awal hingga akhir file.
2. Setiap public method wajib memiliki test.
3. Setiap private method yang dapat diuji melalui public API wajib tercakup.
4. Semua percabangan if, else if, else, switch, try, catch, dan return harus memiliki test.
5. Semua kondisi sukses, gagal, null, kosong, dan edge case harus diuji.
6. Semua state perubahan wajib diverifikasi.
7. Semua dependency eksternal harus dimock menggunakan Mocktail.
8. Jangan melewati kode apa pun tanpa analisis.
9. Sebelum membuat test, buat daftar seluruh fungsi, kondisi, dan skenario yang ditemukan.
10. Setelah test selesai, buat tabel yang menunjukkan bagian mana yang sudah dan belum tercakup.
11. Target coverage minimal 100% line coverage dan branch coverage.
12. Jika ada bagian yang tidak dapat diuji, jelaskan alasannya secara rinci.
13. Tulis file test lengkap, bukan potongan kode.
14. Gunakan Flutter Test dan Mocktail.
15. Pastikan seluruh assertion relevan dan tidak ada test duplikat.

Langkah kerja:
1. Analisis file.
2. Daftarkan seluruh skenario test.
3. Tampilkan checklist coverage.
4. Tulis file test lengkap.
5. Jelaskan bagian yang masih belum bisa tercakup jika ada.

Berikut file yang akan diuji: