# Dokumentasi: `lib/shared/operasi/package_operation.dart`

`PackageOperation` adalah kelas yang mengelola semua operasi CRUD untuk `PackageModel` di database lokal SQLite. `PackageModel` merepresentasikan produk atau layanan utama yang dijual, yaitu paket internet dengan berbagai durasi, kecepatan, dan harga.

---

## Peran dan Konsep

-   **Manajemen Produk**: Kelas ini berfungsi sebagai *product management tool* di tingkat database. Admin dapat membuat, mengubah, mengarsipkan, dan menghapus paket-paket yang ditawarkan kepada pelanggan.

-   **Pengurutan Logis**: Salah satu fitur menarik dari kelas ini adalah cara ia mengambil data paket. Metode seperti `getAllPackages()` dan `getPackages()` tidak hanya mengambil data, tetapi juga mengurutkannya berdasarkan durasi efektif (Jam < Hari < Bulan). Ini dilakukan menggunakan *raw query* SQL dengan `CASE` statement untuk membuat kolom virtual `urutan` dan mengurutkan berdasarkan itu. Hasilnya, paket yang ditampilkan kepada pengguna (baik admin maupun pelanggan) selalu dalam urutan yang logis dan mudah dipahami.

-   **Visibilitas Paket**: Paket memiliki flag `isPublic`. `PackageOperation` menyediakan metode `getPublicPackages()` yang hanya akan mengambil paket-paket yang ditandai sebagai publik dan aktif. Ini memungkinkan admin untuk membuat paket-paket internal (misalnya untuk testing atau keperluan khusus) tanpa menampilkannya kepada semua pelanggan.

---

## Metode Utama

### Operasi Tulis (Write)

-   `createPackage(package, {fromServer})`: Menambahkan paket baru ke database.

-   `updatePackage(package, {fromServer})`: Memperbarui data paket yang sudah ada.

-   `deletePackage(id, {fromServer})`: Melakukan **hard delete** pada paket. Berbeda dengan *soft delete* (arsip), ini menghapus data secara permanen.

-   `deleteAllPackages({fromServer})`: Menghapus **semua** paket dari database. Operasi ini sangat destruktif.

-   `insertOrUpdateBatch(items, {fromServer})`: Metode efisien untuk menyisipkan atau memperbarui banyak paket sekaligus, yang sangat penting untuk proses sinkronisasi dari server.

### Operasi Baca (Read)

-   `getAllPackages()`: Mengambil **semua** paket dari database, termasuk yang diarsipkan (`isDeleted = true`), dan mengurutkannya berdasarkan durasi.

-   `getPackages()`: Mengambil semua paket **aktif** (`isDeleted = false`) dan mengurutkannya berdasarkan durasi. Ini adalah metode yang biasanya digunakan untuk menampilkan daftar paket yang tersedia untuk dibeli atau dikelola.

-   `getPublicPackages()`: Mengambil semua paket **aktif dan publik** (`isDeleted = false` DAN `isPublic = true`), diurutkan berdasarkan durasi. Inilah yang akan dilihat oleh pelanggan di aplikasi mereka.

-   `getPackageById(id)`: Mengambil satu paket spesifik berdasarkan ID-nya.

-   `getPackagesByIds(ids)`: Mengambil beberapa paket berdasarkan daftar ID.

-   `getChangesSince(since)`: Digunakan oleh mekanisme sinkronisasi untuk mendapatkan daftar paket yang telah diubah sejak sinkronisasi terakhir, sehingga hanya data yang relevan yang diunggah ke server.

---

## Interaksi dengan `BaseOperation`

Semua operasi tulis di `PackageOperation` didelegasikan ke `BaseOperation`. Ketika seorang admin membuat paket baru, misalnya, `createPackage` memanggil `_baseOperation.insert`. `BaseOperation` kemudian akan menangani penambahan data ke tabel `paket` dan juga mencatat bahwa ada perubahan yang perlu diungah (`needUpload = true`), memastikan data paket tetap sinkron di seluruh sistem.
