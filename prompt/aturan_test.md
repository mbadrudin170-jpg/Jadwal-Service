// path: prompt/aturan_test.md

### Aturan Test

1. nama test harus menggunakan bahasa indonesia dan kasih nomor urut nya di masing masing test.
2. kalau bisa setiap file unit test nya harus lengkap agar tidak semua kode bisa sesuai dengan yang di harapkan.
3. nama test dan penempatan path nya harus sesuai dengan file aslinya jika file aslinya lib/shared/operasi/firebase_operasi/settings_op_firebase.dart maka file test nya juga harus test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart.
4. setelah memperbarui file test nya jalankan flutter analzye agar tidak ada error lalu jalankan flutter test untuk file tersebut contoh `flutter test test/shared/operasi/firebase_operasi/settings_op_firebase_test.dart`.
5. jangan pernah merubah test yang tidak error dan test yang sukses cukup rubah saja unit test nya bermasalah.
6. sebelum membuatkan unit test nya tolong baca dan pahami kode sumber nya.
7. Tolong pahami dan selalu ingat aturan ini:
    1. jika kode yang sedang dikerjakan ternyata diimport dari file lain AI wajib melihat file file yang diimport itu,jika file yang di import juga menggunakan kode yang dimpoert dari file lain maka AI wajib membaca nya juga. agar tidak salah file AI harus menajalankan ls -R lib atau ls -R test jika itu file test.
    2. penulisan kode, AI wajib menuliskan kode yang sesuai dengan versi paket saya di pubspec.yaml, kalau bisa lihat dokumentasinya dengan menjalankan read_package_uris dan pub_dev_search,
    3. kode di setiap file harus konsisten.
