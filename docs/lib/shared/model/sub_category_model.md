
# Dokumentasi: SubCategoryModel

## Lokasi File
`lib/shared/model/sub_category_model.dart`

## Ringkasan
`SubCategoryModel` adalah model data yang merepresentasikan sub-kategori dari sebuah `CategoryModel`. Tujuannya adalah untuk memberikan tingkat perincian yang lebih dalam saat mengklasifikasikan transaksi. Sebagai contoh, jika `CategoryModel` adalah "Transportasi", maka `SubCategoryModel` bisa berupa "Bensin", "Parkir", atau "Transportasi Umum".

Struktur `SubCategoryModel` relatif sederhana karena ia bertindak sebagai entitas anak. Ia selalu terikat pada sebuah kategori induk melalui `categoryId`. Dalam implementasi database, sub-kategori tidak disimpan dalam tabel terpisah, melainkan diserialisasi dan disimpan **di dalam** dokumen atau baris dari `CategoryModel` induknya.

## Penggunaan
-   Model ini tidak memiliki `Operation` atau `FirebaseOp` sendiri karena siklus hidupnya dikelola sepenuhnya oleh `CategoryModel` induk.
-   `CategoryModel`: Mengandung sebuah `List<SubCategoryModel>`.
-   `CategoryForm`: Form di aplikasi admin memungkinkan penambahan, pengeditan, atau penghapusan sub-kategori secara dinamis saat mengelola sebuah kategori.
-   `TransactionForm`: Setelah pengguna memilih kategori, dropdown kedua mungkin muncul untuk memilih sub-kategori jika tersedia.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap sub-kategori. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `name` | `String` | Nama dari sub-kategori (contoh: "Restoran"). | Wajib diisi. |
| `categoryId` | `String` | ID dari `CategoryModel` induk tempat sub-kategori ini berada. | Relasi penting untuk mengikat sub-kategori ke induknya. |
| `updatedAt` | `DateTime?` | Waktu terakhir data ini diperbarui. | |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | Default `false`. |
| `archivedAt` | `DateTime?` | Waktu data ini diarsipkan. | |

## Metode Utama
Karena `SubCategoryModel` disimpan sebagai bagian dari `CategoryModel`, metode serialisasinya sangat penting.

### `SubCategoryModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance `SubCategoryModel` dari `Map`. Ini digunakan oleh `CategoryModel.fromSqlite` saat melakukan parsing data JSON dari kolom `subCategoryId`.

### `Map<String, dynamic> toSqlite()`
Mengonversi `SubCategoryModel` menjadi `Map`. Hasil dari metode ini akan menjadi bagian dari daftar yang kemudian di-encode menjadi JSON oleh `CategoryModel.toSqlite()`.

### `SubCategoryModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membuat instance dari `Map` yang merupakan bagian dari list `subCategories` di dalam dokumen `CategoryModel` di Firestore.

### `Map<String, dynamic> toFirebase()`
Mengonversi `SubCategoryModel` menjadi `Map`. `CategoryModel.toFirebase()` akan memanggil metode ini pada setiap item dalam `List<SubCategoryModel>` untuk membuat `List<Map>` yang akan disimpan di Firestore.

### `copyWith({...})`
Membuat salinan dari objek `SubCategoryModel` dengan beberapa field yang diperbarui.

## Contoh Penggunaan
Penggunaan `SubCategoryModel` hampir selalu terjadi dalam konteks `CategoryModel`.

```dart
// Membuat kategori dengan beberapa sub-kategori
final utilityCategory = CategoryModel(
  name: 'Tagihan & Utilitas',
  type: CategoryType.expense,
  subCategories: [
    // Ini adalah instance dari SubCategoryModel
    SubCategoryModel(name: 'Listrik', categoryId: 'some-category-id'), // ID kategori akan diisi oleh logika bisnis
    SubCategoryModel(name: 'Air', categoryId: 'some-category-id'),
    SubCategoryModel(name: 'Internet', categoryId: 'some-category-id'),
  ],
);

// Saat menyimpan, `utilityCategory.toFirebase()` akan secara otomatis memanggil `toFirebase()`
// pada setiap SubCategoryModel di dalamnya.
final firebaseMap = utilityCategory.toFirebase();

/*
firebaseMap akan terlihat seperti ini:
{
  'name': 'Tagihan & Utilitas',
  'type': 'expense',
  'subCategoryId': [
    { 'id': '...', 'name': 'Listrik', 'categoryId': '...' },
    { 'id': '...', 'name': 'Air', 'categoryId': '...' },
    { 'id': '...', 'name': 'Internet', 'categoryId': '...' },
  ],
  // ... field lainnya
}
*/
```

Dokumentasi ini menjelaskan peran `SubCategoryModel` sebagai komponen detail dari `CategoryModel` dan bagaimana ia dikelola sebagai bagian dari entitas induknya.
