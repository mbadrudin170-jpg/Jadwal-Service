
# Dokumentasi: HasId

## Lokasi File
`lib/shared/model/has_id.dart`

## Ringkasan
`HasId` adalah sebuah *abstract class* (atau bisa dianggap sebagai *interface*) yang sangat sederhana namun fundamental dalam arsitektur aplikasi. Tujuannya adalah untuk mendefinisikan sebuah kontrak bahwa setiap kelas model yang mengimplementasikannya **wajib** memiliki sebuah properti `id` bertipe `String`.

Dengan menggunakan `HasId`, kita dapat membuat fungsi-fungsi atau kelas-kelas generik yang bisa bekerja dengan model apapun selama model tersebut memiliki ID unik. Ini sangat menyederhanakan kode, mengurangi duplikasi, dan meningkatkan fleksibilitas sistem, terutama pada lapisan operasi data (`BaseOperation`).

## Penggunaan
Kelas ini diimplementasikan oleh hampir semua model data utama di dalam aplikasi yang perlu diidentifikasi secara unik, disimpan di database, dan disinkronkan. Contoh model yang mengimplementasikan `HasId` antara lain:
-   `CustomerModel`
-   `TransactionModel`
-   `PackageModel`
-   `ActiveCustomerModel`
-   `CategoryModel`
-   `FeedbackModel`
-   `ApkVersionModel`
-   dan lain-lain.

## Detail Properti
| Nama Properti | Tipe Data | Deskripsi | Keterangan |
| :--- | :--- | :--- | :--- |
| `id` | `String` | Properti getter abstrak yang wajib di-override. | Berfungsi sebagai pengenal unik untuk setiap instance model. Biasanya berupa UUID v4 atau ID dari database (seperti ID dokumen Firestore). |

## Contoh Penggunaan dalam Kode

### Implementasi pada Model
```dart
// path: lib/shared/model/customer_model.dart

import 'package:wifi/shared/model/has_id.dart';

class CustomerModel implements HasId {
  @override
  final String id;

  final String name;

  // ... properti lainnya

  CustomerModel({String? id, required this.name}) : id = id ?? const Uuid().v4();
}
```

### Penggunaan dalam Fungsi Generik
Kelas `BaseOperation` menggunakan `HasId` sebagai *generic constraint* (`<T extends HasId>`). Ini memungkinkan metode-metode di dalamnya (seperti `insert`, `update`, `delete`) untuk bekerja dengan model apapun asalkan model tersebut memiliki properti `id`.

```dart
// path: lib/shared/operasi/base_operation.dart (Contoh Konseptual)

abstract class BaseOperation<T extends HasId> {
  
  Future<void> insert(T model) async {
    // Karena T adalah HasId, kita bisa dengan aman mengakses model.id
    final map = model.toSqlite(); // Asumsi ada method toSqlite()
    await database.insert('tableName', map, where: 'id = ?', whereArgs: [model.id]);
  }

  Future<T?> findById(String id) async {
    // ... implementasi
  }
  
  Future<void> delete(String id) async {
    // ... implementasi
  }
}
```
Dengan adanya `HasId`, kita tidak perlu membuat `insertCustomer`, `insertTransaction`, `insertPackage`, dst. secara terpisah. Cukup satu metode generik yang bekerja untuk semua model yang kompatibel.

Dokumentasi ini menyoroti bagaimana `HasId` menjadi pilar penting dalam menciptakan arsitektur yang bersih, dapat digunakan kembali, dan mudah diperluas.
