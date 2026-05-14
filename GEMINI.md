# Aturan dan Pedoman untuk mengerjakan proyek disini

# Aturan Wajib
1. Bahasa : disaat ingin berbincang dengan saya Ai wajib menggunakan bahasa Indonesia, baik itu untuk penamaan class, fungsi, variabel, parameter, kalau AI menemukan ada yang tidak konsisten mengenai bahasa ini disarankan untuk membuat komentar TODO misalnya `//TODO: penamaan class atau fungsi tidak menggunakan bahasa indoensia`.
2. 

# Aturan Utama
1. Jangan pernah merubah isi file ini.
2. selalu ikuti semua aturan dan pedoman yang ada di file ini.
3. simpan semua aturan dan pedoman nya ke memori AI.
4. karena disini ada tahap-tahap selama mengerjakan proyek ini.
5. Disini Ai bertugas sebagai pekerja user yang paham banget mengenai firebase, flutter, dart, dan IDX studio.
6. Selalu jaga konsistensi sebuah kode.
7. Setiap kode harus disisipkan Log contoh Log.info, Log.warning dan Log error yang dipanggil dari file custome khusus log bernama debug.log.dart jadi jangan gunakan developer.log lagi.
8. Untuk meenampilkan snackbar AI harus memanggil dari file custom khusus snackbar di file snackbar_utils.dart.

### **Konsep Arsitektur**

AI akan memahami dan menerapkan konsep arsitektur fundamental di Flutter:

* **Widget adalah UI**: Segalanya di UI Flutter adalah widget. AI akan menyusun UI yang kompleks dari widget yang lebih kecil dan dapat digunakan kembali.
* **Imutabilitas**: Widget (terutama StatelessWidget) tidak dapat diubah. Saat UI perlu diubah, Flutter membangun kembali pohon widget.
* **Manajemen Status**: Memahami pentingnya mengelola status yang dapat diubah. AI akan merekomendasikan dan menerapkan solusi manajemen status yang sesuai berdasarkan kompleksitas aplikasi.
* **Pemisahan Masalah**: Berusaha untuk memisahkan lapisan UI (widget), logika bisnis, dan data untuk meningkatkan organisasi kode, kemampuan pengujian, dan pemeliharaan.

## Performa Kode
1. Disetiap file AI harus menggunakan Future & wait, perbanyak const, dan dispose.
2. jangan sampai membuat memori leak, boros RAM, dan ngeblank,

# Sebelum Bekerja
1. Selalu tanyakan ke user apakah ada pekerjaan untuk AI.
2. Baca Struktur di folder root lib/ untuk mengetahui proyek saya ada file apa saja.
3. Dilarang nerasumsi liar kalau tidak yakin atau ragu tolong tanyakan ke user.
4. Selalu ikuti semua perintah user, kalau ada perintah user yang akan membuat kode menjadi error atau tidak konsisten tanyakan lagi keuser apakah user yakin dengan semua perintah itu, lalu kasih saran yang sesuai.
5. jangan berasumsi liar AI harus kerjakan apa yang spesifik dengan perintah user saja jikalau ada pembaruan kode yang melenceng dari perintah user maka AI wajib meminta persetujuan user apalagi kalau sampai refaktor besar-besaran.
6. 

# Database Firebase & Sqlite
1. Setiap data yang akan disimpan ke sqlite atau pun firebase tipe nya wajib sama dengan yang ada di modelnya.
2. 

# Memulai Pekerjaan
1. Setelah mendapatkan tugas dari user AI diharuskan baca dahulu file analysis_options.yaml, docs/admin/README.md, docs/shared/README.md, dan docs/user/README.md agar AI tahu alur kerja sebuah projek user.
2. Setelah selesai melakukan pekerjaan AI diharapkan selalu melakukan flutter analyze atau analyze project agar tidak error atau warning yang tertinggal.
3. 

## Konsiten & kebersihan kode
1. AI harus merujuk ke file analysis_options.yaml agar semua kode sesuai dengan rules yang ada di file analysis_options ini.
3. Kalau ditengah pekerjaan AI ada mengalamai error dan warning AI harus merujuk ke file analysis_options dan terminal soalnya takut ada kdoe yang di larang oleh rules itu.
4. saat menghadapi error/warning AI harus dengan teliti membaca terminal kenapa kode tersebut bisa error.
5. untuk menjaga struktur yang profesional 
agar sebuah file atau kode ditempatkan di file atau folder tertentu.
6. AI harus memisahkan sebuah logika, UI(widget), dan Data, kalau semisalnya AI menemukan koda yeng disarankan di pisah AI harus menulis komentar `TODO`.

## Format Utils
1. untuk format mata uang, angka, jam dan tanggal user dan AI akan memanggil fungsi dari file lain dilarang menulis format didalam file itu sendiri karena proyek ini sudah mempunya file khusus format itu, sebagai satu-satunya file untuk memformat sebuah mata uang, tanggal, waktu dan angka.

## Warna, Teks, Tipograpy
1. untuk konsistensi AI dan user akan menggunakan file yang sudah ada dan dikhususkan untuk warna, teks, Tipography. untuk menjaga konsistensi proyek agar nantinya user dan AI bisa perbarui hanya disatu tempat.
2. silahkan berikan saran jika ada yang lebih bagus dan di rekomendasikan oleh flutter & dart, lalu tuliskan semua saran itu ke file README.md.


## Auran Lainnya selama pengerjaan berlangsung

# Selesai Pekerjaan
1. AI diharapkan menulis komentar `// TODO:...` jika ada fungsi atau kdiimplemenetasikan, kode yang belum sepenuhnya fix selesai, menemukan kode yang tidak konsisten, dan sebagainya.
2. AI Harus menuliskan rangkuman difolder README.md yang ada diroot proyek, apa saja yang membuat error dan solusinya apa saja yang telah AI lakukan sehingga kode itu tidak error/warning lagi.
3. setelah melakukan pekerjaan dan menulis rangkuman di follder README.md sekarang AI harus melakukan dokumentasi sebuah projek yang telah AI lakukan kenapa kerjakan kedalam file docs/admin/README.md, docs/shared/README.md, dan docs/user/README.md tapi jangan hapus dokumen yang sudah ada.
4. setelah melakukan pekerjaan wajib menjalankan flutter analyze/analyze project agar tidak ada error dan warning tersembunyi.
5. 