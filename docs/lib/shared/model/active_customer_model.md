
# Dokumentasi: ActiveCustomerModel

## Lokasi File
`lib/shared/model/active_customer_model.dart`

## Ringkasan
`ActiveCustomerModel` adalah model data yang merepresentasikan status langganan aktif dari seorang pelanggan. Model ini menyimpan informasi krusial seperti ID pelanggan, ID paket yang dibeli, durasi aktif paket, dan status pembayaran. Data ini digunakan di seluruh aplikasi untuk memverifikasi akses pelanggan terhadap layanan dan untuk menampilkan informasi langganan yang relevan.

Model ini dirancang untuk dapat di-serialisasi dan di-deserialisasi dari/ke format **SQLite** (untuk penyimpanan lokal) dan **Firebase** (untuk sinkronisasi cloud), memastikan konsistensi data di kedua platform.

## Penggunaan
Model ini digunakan secara ekstensif oleh:
-   `ActiveCustomerOperation`: Untuk operasi CRUD (Create, Read, Update, Delete) terkait data pelanggan aktif di database lokal.
-   Berbagai file UI di aplikasi Admin dan User untuk menampilkan detail langganan, seperti sisa masa aktif, status, dan riwayat.
-   `ActiveCustomerForm`: Untuk membuat atau mengedit data langganan aktif dari panel admin.

## Detail Kolom
| Nama Kolom | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | ID unik untuk setiap entitas pelanggan aktif. | Dihasilkan otomatis menggunakan `Uuid().v4()` jika tidak disediakan. |
| `customerId` | `String` | ID pelanggan yang memiliki langganan ini. Merujuk ke `CustomerModel`. | Wajib diisi. |
| `packageId` | `String` | ID paket yang dibeli. Merujuk ke `PackageModel`. | Wajib diisi. |
| `transactionId` | `String?` | ID transaksi yang terkait dengan pembelian paket ini. | Opsional. |
| `startDate` | `DateTime` | Tanggal mulai aktifnya paket langganan. | Wajib diisi. |
| `endDate` | `DateTime` | Tanggal berakhirnya paket langganan. | Wajib diisi. |
| `status` | `PaymentStatus` | Status pembayaran paket. | Menggunakan enum `PaymentStatus` (contoh: `paid`, `unpaid`). |
| `updatedAt` | `DateTime?` | Waktu terakhir data ini diperbarui. | Dicatat untuk keperluan sinkronisasi dan audit. |
| `isDeleted` | `bool` | Status hapus sementara (soft delete). | `true` jika dianggap terhapus. Defaultnya `false`. |
| `archivedAt` | `DateTime?` | Waktu data ini diarsipkan. | Digunakan untuk memindahkan data lama dari query utama. |

## Metode Utama

### `ActiveCustomerModel.fromSqlite(Map<String, dynamic> map)`
Factory constructor untuk membuat instance `ActiveCustomerModel` dari data `Map` yang berasal dari database SQLite. Metode ini melakukan parsing tipe data yang spesifik untuk SQLite, seperti mengubah `millisecondsSinceEpoch` (integer) menjadi `DateTime`.

### `Map<String, dynamic> toSqlite()`
Mengonversi instance `ActiveCustomerModel` menjadi `Map` yang siap untuk disimpan ke dalam database SQLite. `DateTime` diubah menjadi `millisecondsSinceEpoch` (integer) dan `bool` menjadi `1` atau `0`.

### `ActiveCustomerModel.fromFirebase(String id, Map<String, dynamic> data)`
Factory constructor untuk membuat instance `ActiveCustomerModel` dari data `Map` yang berasal dari Firestore. Metode ini menangani parsing `Timestamp` Firebase menjadi `DateTime`.

### `Map<String, dynamic> toFirebase()`
Mengonversi instance `ActiveCustomerModel` menjadi `Map` yang siap untuk disimpan atau diperbarui di Firestore. `DateTime` diubah menjadi objek `Timestamp` Firebase.

### `copyWith({...})`
Membuat salinan (kopi) dari objek `ActiveCustomerModel` yang ada, dengan kemungkinan untuk menimpa beberapa field dengan nilai yang baru. Ini sangat berguna untuk memastikan imutabilitas objek.

## Contoh Penggunaan
```dart
// Membuat instance baru saat pelanggan membeli paket
final newSubscription = ActiveCustomerModel(
  customerId: 'cust-001',
  packageId: 'pkg-internet-bulanan',
  transactionId: 'trans-12345',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(const Duration(days: 30)),
  status: PaymentStatus.paid,
);

// Menyimpan ke SQLite
final sqliteMap = newSubscription.toSqlite();
// await database.insert('active_customers', sqliteMap);

// Menyimpan ke Firebase
final firebaseMap = newSubscription.toFirebase();
// await firestore.collection('active_customers').doc(newSubscription.id).set(firebaseMap);
```

Dengan adanya dokumentasi ini, pengembangan dan pemeliharaan fitur yang bergantung pada data langganan aktif menjadi lebih mudah dipahami dan dikelola.
