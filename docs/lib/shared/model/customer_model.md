
# Dokumentasi: CustomerModel

## Lokasi File
`lib/shared/model/customer_model.dart`

## Ringkasan
`CustomerModel` adalah model data fundamental yang merepresentasikan seorang pelanggan dalam sistem. Model ini menyimpan semua informasi pribadi dan kredensial pelanggan, seperti nama, nomor telepon, alamat, kata sandi untuk login, dan alamat MAC perangkat mereka. Ini adalah salah satu model inti yang menjadi dasar bagi banyak fitur lain di dalam aplikasi.

Model ini dapat di-serialisasi ke dan dari format **SQLite** dan **Firebase**, memungkinkan data pelanggan dikelola baik secara lokal di perangkat admin maupun secara terpusat di cloud untuk diakses oleh aplikasi user.

## Penggunaan
-   `CustomerOperation`: Mengelola seluruh operasi CRUD untuk data pelanggan di database lokal.
-   `CustomerForm`: Form di aplikasi admin yang digunakan untuk mendaftarkan pelanggan baru atau mengedit data pelanggan yang sudah ada.
-   `LoginPage` (Aplikasi User): Memvalidasi kredensial login (nomor telepon dan kata sandi) berdasarkan data yang tersimpan.
-   `ProfilePage` (Aplikasi User): Menampilkan informasi detail pelanggan yang sedang login.
-   Hampir semua model lain yang berhubungan dengan pelanggan (seperti `TransactionModel`, `ActiveCustomerModel`) akan merujuk ke `id` dari `CustomerModel` ini.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap pelanggan. | Dihasilkan otomatis menggunakan `Uuid().v4()`. |
| `name` | `String` | Nama lengkap pelanggan. | Wajib diisi. |
| `phone` | `String` | Nomor telepon pelanggan, digunakan juga untuk login. | Wajib diisi. |
| `address` | `String` | Alamat fisik atau domisili pelanggan. | Wajib diisi. |
| `password` | `String` | Kata sandi yang digunakan pelanggan untuk login ke aplikasi user. | Wajib diisi. |
| `macAddress` | `String` | Alamat MAC perangkat pelanggan. | Opsional, bisa digunakan untuk fitur lanjutan. |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | Default `false`. |
| `updatedAt` | `DateTime?` | Waktu terakhir data pelanggan diperbarui. | |
| `archivedAt` | `DateTime?` | Waktu data pelanggan diarsipkan. | |

## Metode Utama

### `CustomerModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance `CustomerModel` dari data `Map` yang berasal dari SQLite. Melakukan konversi tipe data yang sesuai dari format database.

### `Map<String, dynamic> toSqlite()`
Mengonversi instance `CustomerModel` menjadi `Map` yang siap disimpan ke database SQLite. `DateTime` diubah menjadi `millisecondsSinceEpoch` dan `bool` menjadi `1` atau `0`.

### `CustomerModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membuat instance dari data `Map` yang berasal dari Firestore, dengan `id` dokumen sebagai ID model.

### `Map<String, dynamic> toFirebase()`
Mengonversi `CustomerModel` menjadi `Map` untuk disimpan di Firestore. `DateTime` diubah menjadi objek `Timestamp` Firebase.

### `copyWith({...})`
Membuat salinan dari objek `CustomerModel` dengan kemampuan untuk mengganti beberapa nilai field. Ini penting untuk praktik imutabilitas dalam state management.

## Contoh Penggunaan
```dart
// Membuat pelanggan baru melalui form admin
final newCustomer = CustomerModel(
  name: 'Andi Budiman',
  phone: '081234567890',
  address: 'Jl. Merdeka No. 10',
  password: 'password123',
  macAddress: '00:1A:2B:3C:4D:5E',
);

// Menyimpan ke Firebase (akan di-trigger oleh aplikasi admin)
final firebaseMap = newCustomer.toFirebase();
// await firestore.collection('customers').doc(newCustomer.id).set(firebaseMap);

// Membaca dari SQLite (di aplikasi admin)
// final mapFromDb = await database.query('customers', where: 'id = ?', whereArgs: [someId]);
// final customer = CustomerModel.fromSqlite(mapFromDb.first);
// print(customer.name); // Output: Andi Budiman
```

Dokumentasi ini mengklarifikasi peran sentral `CustomerModel` dalam ekosistem aplikasi dan bagaimana data pelanggan dikelola di berbagai lapisan penyimpanan.
