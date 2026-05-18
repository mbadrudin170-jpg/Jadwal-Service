# Dokumentasi: `lib/shared/operasi/sub_category_operation.dart`

`SubCategoryOperation` adalah kelas yang mengelola operasi CRUD untuk `SubCategoryModel`. Dalam struktur data aplikasi, sub-kategori adalah turunan dari sebuah kategori utama. Misalnya, jika ada kategori "Minuman", sub-kategorinya bisa berupa "Kopi", "Teh", atau "Jus".

---

## Peran dan Hubungan

-   **Data Hirarkis**: Kelas ini membantu menciptakan struktur data yang lebih terorganisir. Daripada memiliki daftar pengeluaran yang datar, penggunaan kategori dan sub-kategori memungkinkan pengelompokan yang lebih baik, yang pada akhirnya mempermudah analisis dan pelaporan.

-   **Tergantung pada Kategori**: Setiap `SubCategoryModel` memiliki `id_kategori` yang menghubungkannya langsung ke sebuah `CategoryModel`. Ini adalah hubungan *one-to-many* (satu kategori dapat memiliki banyak sub-kategori).

-   **Manajemen Terperinci**: Admin dapat membuat, mengubah, dan menghapus sub-kategori secara spesifik untuk setiap kategori utama, memberikan fleksibilitas dalam mengklasifikasikan jenis-jenis transaksi atau item.

---

## Metode Utama

### Operasi Tulis (Write)

-   `createSubCategory(subCategory, {fromServer})`: Menambahkan sub-kategori baru ke database.

-   `updateSubCategory(subCategory, {fromServer})`: Memperbarui data sub-kategori yang sudah ada.

-   `deleteSubCategory(id, {softDelete, fromServer})`: Menghapus sub-kategori. Metode ini mendukung dua mode:
    -   `softDelete = true` (default): Melakukan *soft delete* dengan mengatur `isDeleted = true`. Ini adalah cara yang lebih aman karena data tidak hilang dan bisa dipulihkan jika perlu.
    -   `softDelete = false`: Melakukan *hard delete*, menghapus data secara permanen dari database.

-   `insertOrUpdateBatch(items, {fromServer})`: Metode efisien untuk menyisipkan atau memperbarui banyak sub-kategori sekaligus, digunakan dalam proses sinkronisasi.

### Operasi Baca (Read)

-   `getSubCategoryByCategoryId(categoryId)`: **Metode yang paling sering digunakan**. Mengingat sub-kategori selalu terkait dengan kategori, metode ini adalah cara utama untuk mendapatkan daftar sub-kategori yang relevan untuk ditampilkan kepada pengguna. Misalnya, ketika pengguna memilih kategori "Transportasi", UI akan memanggil metode ini untuk menampilkan sub-kategori seperti "Bensin", "Parkir", atau "Tol".

-   `getSubCategoryById(id)`: Mengambil satu data sub-kategori spesifik berdasarkan ID-nya.

-   `getSubCategoryByIds(ids)`: Mengambil beberapa sub-kategori berdasarkan daftar ID.

---

## Interaksi dengan `BaseOperation`

Sama seperti kelas operasi lainnya, `SubCategoryOperation` mengandalkan `BaseOperation` untuk semua operasi tulis. Ketika seorang admin membuat sub-kategori baru "Kopi Dingin" di bawah kategori "Minuman", `createSubCategory` akan memanggil `baseOperation.insert`. `BaseOperation` kemudian memastikan data baru ini disimpan secara lokal dan ditandai untuk diunggah ke Firestore, sehingga data sub-kategori ini akan tersedia secara konsisten di semua perangkat admin lainnya.
