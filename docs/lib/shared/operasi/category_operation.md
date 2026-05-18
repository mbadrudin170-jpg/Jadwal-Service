# Dokumentasi: `lib/shared/operasi/category_operation.dart`

`CategoryOperation` adalah kelas yang bertanggung jawab untuk mengelola semua operasi terkait `CategoryModel` di database lokal SQLite. Kategori digunakan untuk mengelompokkan entitas lain, seperti paket internet (`PackageModel`) atau item pengeluaran (`ExpenseModel`), sehingga lebih mudah diatur dan disaring.

---

## Peran dan Konsep

-   **Pengelompokan**: Fungsi utama dari kategori adalah untuk memberikan label yang dapat digunakan untuk mengelompokkan item. Misalnya, admin bisa membuat kategori "Paket Rumahan" dan "Paket Bisnis" untuk paket internet, atau "Operasional" dan "Pemasaran" untuk pengeluaran.
-   **Tipe Kategori (`CategoryType`)**: Setiap kategori memiliki tipe yang ditentukan oleh enum `CategoryType`. Ini memungkinkan sistem untuk membedakan antara kategori yang digunakan untuk tujuan berbeda (misalnya, `CategoryType.paket` untuk paket internet dan `CategoryType.pengeluaran` untuk pengeluaran). Ini sangat penting agar saat pengguna memilih kategori, mereka hanya melihat opsi yang relevan.

---

## Metode Utama

### Operasi Tulis (Write)

-   `createCategory(category, {fromServer})`: Menambahkan kategori baru ke database.
-   `updateCategory(category, {fromServer})`: Memperbarui data kategori yang sudah ada.
-   `archiveOneCategory(id, {fromServer})`: Melakukan *soft delete* pada sebuah kategori. Kategori yang diarsipkan tidak akan muncul lagi di pilihan, tetapi datanya masih ada di database.
-   `deleteCategory(id, {fromServer})`: Melakukan **hard delete**, yaitu menghapus data kategori secara permanen dari database.
-   `insertOrUpdateBatch(items, {fromServer})`: Metode efisien untuk menyisipkan atau memperbarui banyak kategori sekaligus, biasanya digunakan saat sinkronisasi data dari server.
-   `clearAndInsertAll(items, {fromServer})`: Operasi drastis yang **menghapus semua kategori** yang ada di database lokal dan menggantinya dengan daftar `items` yang baru. Ini sangat berguna untuk memastikan data lokal sama persis dengan data di server setelah sinkronisasi penuh.

### Operasi Baca (Read)

-   `getCategories()`: Mengambil semua kategori yang aktif (tidak diarsipkan).
-   `getCategoriesByType(type)`: **Metode query yang paling umum digunakan**. Mengambil semua kategori aktif yang cocok dengan `CategoryType` tertentu. Misalnya, saat mengisi dropdown untuk pemilihan kategori paket, aplikasi akan memanggil `getCategoriesByType(CategoryType.paket)`.
-   `getCategoryById(id)`: Mengambil satu kategori berdasarkan ID uniknya.
-   `getChangesSince(since)`: Digunakan dalam proses sinkronisasi untuk hanya mengambil kategori yang telah berubah (dibuat atau diperbarui) sejak waktu `since`.

---

## Interaksi dengan `BaseOperation`

Seperti kelas operasi lainnya, `CategoryOperation` mendelegasikan semua operasi tulisnya ke `BaseOperation`. Ini memastikan bahwa setiap kali admin membuat, mengubah, atau menghapus kategori, perubahan tersebut akan ditandai untuk diunggah ke Firestore. Hal ini menjaga konsistensi data kategori di semua perangkat yang terhubung ke sistem.
