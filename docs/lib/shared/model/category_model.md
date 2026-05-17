
# Dokumentasi: CategoryModel

## Lokasi File
`lib/shared/model/category_model.dart`

## Ringkasan
`CategoryModel` adalah model data yang merepresentasikan sebuah kategori transaksi. Kategori ini digunakan untuk mengelompokkan transaksi keuangan, seperti "makanan", "transportasi", atau "gaji". Setiap kategori memiliki tipe (`CategoryType`), yaitu `expense` (pengeluaran) atau `income` (pemasukan), dan dapat memiliki daftar sub-kategori (`SubCategoryModel`) untuk pengelompokan yang lebih detail.

Model ini mendukung serialisasi untuk **SQLite** dan **Firebase**, memungkinkan data kategori dapat disimpan secara lokal dan disinkronkan dengan cloud.

## Penggunaan
-   `CategoryOperation`: Mengelola operasi CRUD untuk data kategori di database lokal.
-   `TransactionForm`: Digunakan dalam form transaksi untuk memilih kategori saat mencatat pengeluaran atau pemasukan baru.
-   `CategoryForm`: Form di aplikasi admin untuk membuat atau mengedit kategori.
-   Halaman laporan dan analisis: Data kategori digunakan untuk menghasilkan laporan keuangan berdasarkan pengelompokan.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap kategori. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `name` | `String` | Nama dari kategori (contoh: "Belanja Bulanan"). | Wajib diisi. |
| `type` | `CategoryType` | Tipe kategori, yaitu `expense` atau `income`. | Menggunakan enum `CategoryType`. |
| `subCategories` | `List<SubCategoryModel>` | Daftar sub-kategori yang berada di bawah kategori ini. | Disimpan sebagai JSON string di SQLite dan List of Maps di Firebase. |
| `updatedAt` | `DateTime?` | Waktu terakhir data ini diperbarui. | |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | Default `false`. |
| `archivedAt` | `DateTime?` | Waktu data ini diarsipkan. | |

## Metode Utama

### `CategoryModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance `CategoryModel` dari `Map` SQLite. Metode ini menangani deserialisasi `subCategories` dari format JSON string menjadi `List<SubCategoryModel>`.

### `Map<String, dynamic> toSqlite()`
Mengonversi `CategoryModel` menjadi `Map` untuk penyimpanan SQLite. Daftar `subCategories` di-encode menjadi JSON string sebelum disimpan.

### `CategoryModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membuat instance dari data `Map` Firebase. Metode ini secara rekursif membuat `List<SubCategoryModel>` dari daftar `Map` yang ada di data Firebase.

### `Map<String, dynamic> toFirebase()`
Mengonversi `CategoryModel` menjadi `Map` untuk disimpan di Firebase. Daftar `subCategories` diubah menjadi `List` dari `Map`.

### `copyWith({...})`
Membuat salinan dari objek `CategoryModel` dengan beberapa field yang diperbarui. Berguna untuk menjaga imutabilitas state.

## Contoh Penggunaan
```dart
// Membuat kategori baru dengan sub-kategori
final foodCategory = CategoryModel(
  name: 'Makanan & Minuman',
  type: CategoryType.expense,
  subCategories: [
    SubCategoryModel(name: 'Restoran'),
    SubCategoryModel(name: 'Pasar'),
  ],
);

// Menyimpan ke SQLite
final sqliteMap = foodCategory.toSqlite();
// await database.insert('categories', sqliteMap);

// Membaca dari Firebase
// final doc = await firestore.collection('categories').doc('some-id').get();
// final categoryFromFirebase = CategoryModel.fromFirebase(doc.id, doc.data()!);
// print(categoryFromFirebase.subCategories.first.name); // Output: Restoran
```

Dokumentasi ini memberikan panduan tentang struktur data kategori dan cara kerjanya dengan penyimpanan lokal dan cloud, yang sangat penting untuk fitur-fitur manajemen keuangan di aplikasi.
